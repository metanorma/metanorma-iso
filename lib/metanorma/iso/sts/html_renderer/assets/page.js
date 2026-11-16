/* Page behaviour — vanilla JS, no dependencies.
   - scroll-spy table of contents (IntersectionObserver)
   - mobile TOC drawer with backdrop
   - back-to-top button
   - heading-anchor deep links (copy URL on click)
*/
(function () {
  "use strict";

  var toc = document.getElementById("toc");
  var toggle = document.getElementById("toc-toggle");
  var themeToggle = document.getElementById("theme-toggle");
  var crumbCurrent = document.getElementById("crumb-current");
  var backToTop = document.getElementById("back-to-top");
  var root = document.documentElement;

  /* ---- light/dark theme: stored choice wins, else system ---- */
  var THEME_KEY = "mn-theme";
  function systemTheme() {
    return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark" : "light";
  }
  function applyTheme(theme) {
    root.setAttribute("data-theme", theme);
    if (themeToggle) {
      themeToggle.setAttribute("aria-pressed", String(theme === "dark"));
      themeToggle.title = theme === "dark" ? "Switch to light mode" : "Switch to dark mode";
    }
  }
  var stored = null;
  try { stored = localStorage.getItem(THEME_KEY); } catch (e) { /* private mode */ }
  applyTheme(stored === "dark" || stored === "light" ? stored : systemTheme());
  if (themeToggle) {
    themeToggle.addEventListener("click", function () {
      var next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
      applyTheme(next);
      try { localStorage.setItem(THEME_KEY, next); } catch (e) { /* ignore */ }
    });
  }
  if (window.matchMedia) {
    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", function (event) {
      var saved = null;
      try { saved = localStorage.getItem(THEME_KEY); } catch (e) { /* ignore */ }
      if (!saved) applyTheme(event.matches ? "dark" : "light");
    });
  }

  /* ---- mobile TOC drawer ---- */
  var backdrop = null;
  function setDrawer(open) {
    if (!toc || !toggle) return;
    toc.classList.toggle("open", open);
    toggle.setAttribute("aria-expanded", String(open));
    toggle.textContent = open ? "×" : "☰";
    if (open && !backdrop) {
      backdrop = document.createElement("div");
      backdrop.className = "toc-backdrop";
      backdrop.addEventListener("click", function () { setDrawer(false); });
      document.body.appendChild(backdrop);
    } else if (!open && backdrop) {
      backdrop.remove();
      backdrop = null;
    }
  }
  if (toggle) {
    toggle.addEventListener("click", function () {
      setDrawer(!(toc && toc.classList.contains("open")));
    });
  }
  if (toc) {
    toc.addEventListener("click", function (event) {
      if (event.target.closest("a")) setDrawer(false);
    });
  }

  /* ---- scroll-spy (also drives the breadcrumb) ---- */
  var links = toc ? Array.prototype.slice.call(toc.querySelectorAll("a[href^='#']")) : [];
  if (links.length && "IntersectionObserver" in window) {
    var byId = {};
    links.forEach(function (a) { byId[a.getAttribute("href").slice(1)] = a; });
    var current = null;
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        var link = byId[entry.target.id];
        if (!link || link === current) return;
        if (current) current.classList.remove("active");
        link.classList.add("active");
        current = link;
        if (crumbCurrent) crumbCurrent.textContent = link.textContent;
        scrollTocIntoView(link);
      });
    }, { rootMargin: "-10% 0px -75% 0px", threshold: 0 });
    Object.keys(byId).forEach(function (id) {
      var el = document.getElementById(id);
      if (el) observer.observe(el);
    });
  }

  // Scrolls the TOC panel so the active entry stays visible. Uses
  // nearest() so a nested <a> finds its <li> wrapper, then computes
  // the minimum scroll needed (only moves when the link is outside
  // the visible band — no jumpy centre-on-every-change behaviour).
  function scrollTocIntoView(link) {
    if (!toc) return;
    var item = link.closest("li");
    if (!item) return;
    var top = item.offsetTop;
    var bottom = top + item.offsetHeight;
    var viewTop = toc.scrollTop;
    var viewBottom = viewTop + toc.clientHeight;
    if (top < viewTop) {
      toc.scrollTo({ top: top - 8, behavior: "smooth" });
    } else if (bottom > viewBottom) {
      toc.scrollTo({ top: bottom - toc.clientHeight + 8, behavior: "smooth" });
    }
  }

  /* ---- heading anchor links: click to copy ---- */
  document.addEventListener("click", function (event) {
    var anchor = event.target.closest("a.h-anchor");
    if (!anchor) return;
    event.preventDefault();
    var url = location.href.split("#")[0] + anchor.getAttribute("href");
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url);
      anchor.classList.add("copied");
      setTimeout(function () { anchor.classList.remove("copied"); }, 900);
    }
    history.replaceState(null, "", anchor.getAttribute("href"));
  });

  /* ---- back to top ---- */
  function onScroll() {
    if (!backToTop) return;
    backToTop.classList.toggle("visible", window.scrollY > 600);
  }
  window.addEventListener("scroll", onScroll, { passive: true });
  if (backToTop) {
    backToTop.addEventListener("click", function () {
      window.scrollTo({ top: 0, behavior: "smooth" });
    });
    onScroll();
  }
})();
