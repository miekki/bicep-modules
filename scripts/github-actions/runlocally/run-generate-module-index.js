// This runs locally the scripts that power the "Publish Module Index" action on github
// (see bicep-modules/.github/workflows/publish-docs.yml)
// to make it easier to debug locally.
//
// Run via run-generate-module-index.js from the root of the repo
// after having set up these environment variables:
//
//   GITHUB_PAT: your github PAT
//   GITHUB_OWNER:
//     "Azure" for Azure/bicep-modules
//       sor your github username for a fork of bicep-modules

const path = require("path");
const core = require("@actions/core");
require("dotenv").config();

const process = require("process");
if (!process.env.GITHUB_PAT) {
  console.error("Need to set GITHUB_PAT");
  return;
}
if (!process.env.GITHUB_OWNER) {
  console.error(
    'Need to set GITHUB_OWNER (e.g. "Azure" for "Azure/bicep-modules"'
  );
  return;
}

const github = require("@actions/github").getOctokit(process.env.GITHUB_PAT);

const context = {
  repo: { owner: process.env.GITHUB_OWNER, repo: "bicep-modules" },
};

const scriptGenerateModuleIndexData = require(path.join(
  process.cwd(),
  "scripts/github-actions/generate-module-index-data.js"
));

scriptGenerateModuleIndexData({ require, github, context, core }).then(() => {
  const scriptGenerateModuleIndexMarkdown = require(path.join(
    process.cwd(),
    "scripts/github-actions/generate-module-index-md.js"
  ));

  scriptGenerateModuleIndexMarkdown({ require, github, context, core }).then(
    () => {
      console.info("Done.");
    }
  );
});
