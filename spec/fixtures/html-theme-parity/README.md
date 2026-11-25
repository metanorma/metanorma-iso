The presentation XML fixture and Chromium comparison harness reuse the
metanorma-document ISO/IEC body-parity sample. This spec compares default
(non-alt) legacy ISO HTML with this gem's normally registered ISO theme.
It checks the five sampled headings/paragraphs for order, tags, text, inline
emphasis and 12 computed font, colour and spacing properties at 1440×1000.

Install Puppeteer and its Chromium in a session-local directory, then run:

```
HTML_THEME_PARITY=1 bundle exec rspec spec/metanorma/iso/html/renderer_theme_parity_spec.rb
```

Set PUPPETEER_MODULE to the absolute path to Puppeteer's JavaScript module
when it is installed outside the project. PUPPETEER_EXECUTABLE_PATH can select
an existing Chrome executable. HTML_THEME_PARITY_OUTPUT saves both rendered
HTML files and the browser comparison JSON under an iso subdirectory.
Without HTML_THEME_PARITY=1 the three browser examples are pending; the theme
registration check still runs. Changed-content/style and missing-element
controls guard against a vacuous browser comparison.

JavaScript and remote resources are disabled, so this measures declared font
stacks with local font fallbacks. It does not establish cover, responsive,
print, dark-mode or glyph parity, or broader flavor/taste acceptance for
metanorma-document#114.
