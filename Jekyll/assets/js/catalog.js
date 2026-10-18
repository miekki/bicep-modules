(() => {
  const root = document.documentElement;
  const themeToggle = document.getElementById("theme-toggle");
  const search = document.getElementById("module-search");
  const results = document.getElementById("module-results");
  const colorScheme = window.matchMedia("(prefers-color-scheme: dark)");

  const isDarkMode = () =>
    (root.dataset.theme || (colorScheme.matches ? "dark" : "light")) === "dark";
  const updateThemeButton = () => {
    if (themeToggle) {
      themeToggle.setAttribute("aria-pressed", String(isDarkMode()));
    }
  };

  if (themeToggle) {
    updateThemeButton();
    themeToggle.addEventListener("click", () => {
      const theme = isDarkMode() ? "light" : "dark";
      root.dataset.theme = theme;
      try {
        localStorage.setItem("catalog-theme", theme);
      } catch {}
      updateThemeButton();
    });

    colorScheme.addEventListener?.("change", () => {
      if (!root.dataset.theme) {
        updateThemeButton();
      }
    });
  }

  if (search && results) {
    const groups = [...document.querySelectorAll(".catalog-table-scroll")];
    const updateResults = () => {
      const query = search.value.trim().toLocaleLowerCase();
      let visibleModules = 0;
      let visibleGroups = 0;

      for (const group of groups) {
        const rows = [...group.querySelectorAll("tbody tr")];
        let groupModules = 0;

        for (const row of rows) {
          const matches = row.textContent.toLocaleLowerCase().includes(query);
          row.hidden = !matches;
          groupModules += Number(matches);
        }

        group.hidden = groupModules === 0;
        const heading = group.previousElementSibling;
        if (heading?.tagName === "H2") {
          heading.hidden = group.hidden;
        }
        visibleModules += groupModules;
        visibleGroups += Number(groupModules > 0);
      }

      results.textContent = `Showing ${visibleModules} ${
        visibleModules === 1 ? "module" : "modules"
      } across ${visibleGroups} ${
        visibleGroups === 1 ? "category" : "categories"
      }.`;
    };

    search.addEventListener("input", updateResults);
  }
})();
