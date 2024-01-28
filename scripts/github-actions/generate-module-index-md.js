/**
 * @param {object[]} items
 * @param {(item: any) => string} keyGetter
 * @returns
 */
function groupBy(items, keyGetter) {
  const map = new Map();

  for (const item of items) {
    const key = keyGetter(item);
    const collection = map.get(key);
    if (!collection) {
      map.set(key, [item]);
    } else {
      collection.push(item);
    }
  }

  return map;
}

/**
 * @param {ReturnType<typeof import("@actions/github").getOctokit>} github
 * @param {typeof import("@actions/github").context} context
 * @param {Array<{ moduleName: string, tags: string[] }>} modules
 * @param {typeof import("prettier")} prettier
 * @returns
 */
async function generateModuleGroupTable(
  github,
  context,
  modules,
  prettier,
  core
) {
  const moduleGroupTableData = [
    [
      "Module",
      "Latest version",
      "Published on",
      "Source code",
      "Readme",
      "Description",
    ],
  ];

  for (const module of modules) {
    const modulePath = `\`${module.moduleName}\``;
    const latestVersion = `\`${module.moduleVersion.name}\``;
    const tag = "main";
    const publishDate = `\`${
      module.moduleVersion.lastUpdatedOn.split("T")[0]
    }\``;
    core.info(
      `publish date is ${publishDate} for module ${module} with version=${latestVersion}`
    );

    const description =
      module.properties &&
      module.properties[tag]?.description?.replace(/\n|\r/g, " ");

    const moduleRootUrl = `https://github.com/miekki/bicep-modules/tree/main/modules/${module.moduleName}`;
    const sourceCodeButton = `[Source code](${moduleRootUrl}/main.bicep)`;
    const readmeButton = `[Readme](${moduleRootUrl}/README.md)`;

    moduleGroupTableData.push([
      modulePath,
      latestVersion,
      publishDate,
      sourceCodeButton,
      readmeButton,
      description,
    ]);
  }

  const { markdownTable } = await import("markdown-table");
  const table = markdownTable(moduleGroupTableData, {
    align: ["l", "r", "r", "r", "r", "l"],
  });

  return prettier.format(table, { parser: "markdown" });
}

/**
 * @typedef Params
 * @property {typeof require} require
 * @property {ReturnType<typeof import("@actions/github").getOctokit>} github
 * @property {typeof import("@actions/github").context} context
 * @property {typeof import("@actions/core")} core
 *
 * @param {Params} params
 */
async function generateModuleIndexMarkdown({ require, github, context, core }) {
  const fs = require("fs").promises;
  const prettier = require("prettier");

  var moduleIndexMarkdown = `---
layout: default
title: Module Index
nav_order: 1
permalink: /
---

# Module Index
`;

  const moduleIndexDataContent = await fs.readFile("moduleIndex.json", {
    encoding: "utf-8",
  });
  if (!moduleIndexDataContent) {
    throw "Could not read moduleIndex.json";
  }

  const moduleIndexData = JSON.parse(moduleIndexDataContent);
  const moduleGroups = groupBy(
    moduleIndexData,
    (x) => x.moduleName.split("/")[0]
  );

  for (const [moduleGroup, modules] of moduleGroups) {
    if (moduleGroup.includes("modules")) {
      continue;
    }
    core.info(`Generating ${moduleGroup}...`);

    const moduleGroupTable = await generateModuleGroupTable(
      github,
      context,
      modules,
      prettier,
      core
    );

    moduleIndexMarkdown += `## ${moduleGroup}\n\n`;
    moduleIndexMarkdown += moduleGroupTable;
    moduleIndexMarkdown += "\n\n";
  }

  await fs.writeFile("index.md", moduleIndexMarkdown);
}

module.exports = generateModuleIndexMarkdown;
