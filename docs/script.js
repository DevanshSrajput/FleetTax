const body = document.body;
const themeToggle = document.querySelector("#themeToggle");
const menuToggle = document.querySelector(".menu-toggle");
const siteNav = document.querySelector(".site-nav");
const tickerTrack = document.querySelector(".ticker-track");

const savedTheme = localStorage.getItem("fleettax-theme");
if (savedTheme === "dark") {
  body.classList.add("dark-theme");
}

themeToggle?.addEventListener("click", () => {
  const isDark = body.classList.toggle("dark-theme");
  localStorage.setItem("fleettax-theme", isDark ? "dark" : "light");
});

menuToggle?.addEventListener("click", () => {
  const isOpen = siteNav.classList.toggle("open");
  menuToggle.setAttribute("aria-label", isOpen ? "Close navigation" : "Open navigation");
});

document.querySelectorAll(".site-nav a").forEach((link) => {
  link.addEventListener("click", () => {
    siteNav.classList.remove("open");
    menuToggle?.setAttribute("aria-label", "Open navigation");
  });
});

if (tickerTrack) {
  tickerTrack.innerHTML += tickerTrack.innerHTML;
}

const revealTargets = document.querySelectorAll(
  ".feature-tile, .workflow-grid article, .tech-grid article, .download-card, .doc-panel, .resource-card"
);

const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        revealObserver.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.18 }
);

revealTargets.forEach((target) => {
  target.classList.add("reveal");
  revealObserver.observe(target);
});

const sectionLinks = [...document.querySelectorAll(".site-nav a[href^='#']")];
const docLinks = [...document.querySelectorAll(".docs-toc a[href^='#']")];
const sections = sectionLinks
  .concat(docLinks)
  .map((link) => document.querySelector(link.getAttribute("href")))
  .filter((section, index, list) => section && list.indexOf(section) === index);

const navObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      [...sectionLinks, ...docLinks].forEach((link) => {
        link.classList.toggle("active", link.getAttribute("href") === `#${entry.target.id}`);
      });
    });
  },
  { rootMargin: "-35% 0px -55% 0px", threshold: 0 }
);

sections.forEach((section) => navObserver.observe(section));

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    siteNav?.classList.remove("open");
    menuToggle?.setAttribute("aria-label", "Open navigation");
  }
});

console.info("FleetTax landing page ready.");
