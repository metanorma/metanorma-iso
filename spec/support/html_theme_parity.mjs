// Run with node html_theme_parity.mjs INPUT.json. Stdout contains JSON only.
// PUPPETEER_MODULE may point at a session-local installation.
import {readFile} from 'node:fs/promises';
import {pathToFileURL} from 'node:url';
import {createRequire} from 'node:module';
const frontendRequire = createRequire(new URL('../../frontend/package.json', import.meta.url));
const {default: puppeteer} = await import(process.env.PUPPETEER_MODULE || pathToFileURL(frontendRequire.resolve('puppeteer')).href);
const input = JSON.parse(await readFile(process.argv[2], 'utf8'));
const browser = await puppeteer.launch({headless: true, args: ['--no-sandbox']});
try {
  const snapshots = {};
  for (const [side, file] of Object.entries(input.pages)) {
    const page = await browser.newPage();
    await page.setViewport({width: 1440, height: 1000, deviceScaleFactor: 1});
    await page.setJavaScriptEnabled(false);
    await page.setRequestInterception(true);
    page.on('request', request => /^https?:/.test(request.url()) ? request.abort() : request.continue());
    await page.goto(pathToFileURL(file).href, {waitUntil: 'load'});
    snapshots[side] = await page.evaluate(({probes, properties, side}) => {
      const text = element => element.textContent.replace(/\s+/g, ' ').trim();
      const result = Object.fromEntries(probes.map(probe => {
        const matches = [...document.querySelectorAll(probe[side])];
        return [probe.name, matches.map(element => ({
          tag: element.tagName.toLowerCase(),
          text: text(element),
          inline: [...element.querySelectorAll('strong, b, em, i, code')].map(child => ({tag: ({b: 'strong', i: 'em'})[child.tagName.toLowerCase()] || child.tagName.toLowerCase(), text: text(child)})),
          styles: Object.fromEntries(properties.map(property => [property, getComputedStyle(element).getPropertyValue(property)])),
        }))];
      }));
      result.order = probes.filter(probe => document.querySelector(probe[side]))
        .sort((a, b) => document.querySelector(a[side]).compareDocumentPosition(document.querySelector(b[side])) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1)
        .map(probe => probe.name);
      return result;
    }, {...input, side});
    await page.close();
  }
  const mismatches = [];
  if (JSON.stringify(snapshots.legacy.order) !== JSON.stringify(snapshots.theme.order)) {
    mismatches.push(`structure.order: legacy=${JSON.stringify(snapshots.legacy.order)}, theme=${JSON.stringify(snapshots.theme.order)}`);
  }
  for (const probe of input.probes) {
    const legacy = snapshots.legacy[probe.name];
    const theme = snapshots.theme[probe.name];
    if (legacy.length !== 1 || theme.length !== 1) {
      mismatches.push(`${probe.name}: expected one element per renderer, legacy=${legacy.length}, theme=${theme.length}`);
      continue;
    }
    for (const field of ['tag', 'text', 'inline']) {
      if (JSON.stringify(legacy[0][field]) !== JSON.stringify(theme[0][field])) {
        mismatches.push(`${probe.name}.${field}: legacy=${JSON.stringify(legacy[0][field])}, theme=${JSON.stringify(theme[0][field])}`);
      }
    }
    for (const property of input.properties) {
      const expected = legacy[0].styles[property], actual = theme[0].styles[property];
      if (expected !== actual) mismatches.push(`${probe.name}.${property}: legacy=${expected}, theme=${actual}`);
    }
  }
  console.log(JSON.stringify({browser: await browser.version(), snapshots, mismatches}));
} finally {
  await browser.close();
}
