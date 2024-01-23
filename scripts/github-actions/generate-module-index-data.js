/**
 * @param {typeof import("fs").promises} fs
 * @param {string} dir
 */
async function getSubdirNames(fs, dir) {
  var files = await fs.readdir(dir, { withFileTypes: true });
  return files.filter((x) => x.isDirectory()).map((x) => x.name);
}

async function getModuleDescription(
  github,
  core,
  mainJsonPath,
  gitTag,
  context
) {
  const gitTagRef = `heads/${gitTag}`;

  core.info(`MainJsonPath= ${mainJsonPath}`);
  core.info(`  Retrieving main.bicep at Git tag ref ${gitTagRef}`);
  core.info(` getModuleDescription - owner = ${context.repo.owner}`);
  core.info(` getModuleDescription - repo = ${context.repo.repo}`);
  core.info(` getModuleDescription - ref = ${gitTagRef}`);
  
  
  const mm_result = await github.rest.git.getRef({
    owner: context.repo.owner,
    repo: context.repo.repo,
    ref: gitTagRef,
  });

  const commitSha = mm_result.data.object.sha;
  
  // Get the SHA of the commit
  // const {
  //   data: {
  //     object: { sha: commitSha },
  //   },
  // } = await github.rest.git.getRef({
  //   owner: context.repo.owner,
  //   repo: context.repo.repo,
  //   ref: gitTagRef,
  // });

  core.info(` getModuleDescription - commitSha = ${commitSha}`)

  const mm_result2 = await github.rest.git.getTree({
    owner: context.repo.owner,
    repo: context.repo.repo,
    tree_sha: commitSha,
    recursive: true,
  });
  const tree = mm_result2.data.tree;

  core.info(` Tree data = ${JSON.stringify(tree)}`);
  // Get the tree data
  // const {
  //   data: { tree },
  // } = await github.rest.git.getTree({
  //   owner: context.repo.owner,
  //   repo: context.repo.repo,
  //   tree_sha: commitSha,
  //   recursive: true,
  // });

  // Find the file in the tree
  const file = tree.find((f) => f.path === mainJsonPath);
  core.info(`after file search`)
  if (!file) {
    throw new Error(`File ${mainJsonPath} not found in repository`);
  }
  core.info(`file sha is ${file.sha}`);

  const mm_result3 = await github.rest.git.getBlob({
    owner: context.repo.owner,
    repo: context.repo.repo,
    file_sha: file.sha,
  });
  
  const content = mm_result3.data.content;
  // Get the blob data
  // const {
  //   data: { content },
  // } = await github.rest.git.getBlob({
  //   owner: context.repo.owner,
  //   repo: context.repo.repo,
  //   file_sha: file.sha,
  // });

  // content is base64 encoded, so decode it
  const fileContent = Buffer.from(content, "base64").toString("utf8");
  core.info(`file content = ${fileContent}`);

  // Parse the main.json file
  if (fileContent !== "") {
    const strToFind = 'metadata description =';
    const position = fileContent.search(strToFind);
    fileContent = fileContent.substring(position + strToFind.length, 1000);
    const firstquote = fileContent.indexOf("'") + 1;
    const secondquote = fileContent.indexOf("'", firstquote);
    const description = fileContent.substring(firstquote, secondquote);

    core.info(`File description is  = ${description}`);

    return "description"
    // const json = JSON.parse(fileContent);
    // return json.metadata.description;
  } else {
    throw new Error(
      "The specified path does not represent a file or it is empty."
    );
  }
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
async function generateModuleIndexData({ require, github, context, core }) {
  const fs = require("fs").promises;
  const axios = require("axios").default;
  const moduleIndexData = [];

  let numberOfModuleGroupsProcessed = 0;

  // BRM Modules
  for (const moduleGroup of await getSubdirNames(fs, "modules")) {
    const moduleGroupPath = `modules/${moduleGroup}`;
    const moduleNames = await getSubdirNames(fs, moduleGroupPath);

    for (const moduleName of moduleNames) {
      const modulePath = `${moduleGroupPath}/${moduleName}`;
        //const mainJsonPath = `${modulePath}/main.json`;
      const mainJsonPath = `${modulePath}/main.bicep`;
      // BRM module git tags do not include the modules/ prefix.
      const mcrModulePath = modulePath.slice(8);
      //const tagListUrl = `https://mcr.microsoft.com/v2/bicep/${mcrModulePath}/tags/list`;

      try {
        core.info(`Processing Module "${modulePath}"...`);
        //core.info(`  Getting available tags at "${tagListUrl}"...`);

        //const tagListResponse = await axios.get(tagListUrl);
        //const tags = tagListResponse.data.tags.sort();
        const tag = 'main'
        const properties = {};
        //for (const tag of tags) {
          // Using mcrModulePath because BRM module git tags do not include the modules/ prefix
            //const gitTag = `${mcrModulePath}/${tag}`;
            
        const documentationUri = `https://github.com/miekki/bicep-modules/tree/${tag}/${modulePath}/README.md`;
        const description = await getModuleDescription(
          github,
          core,
          mainJsonPath,
          tag,
          context
        );
        //const description = 'Module description'
        properties[tag] = { description, documentationUri };
        //}

        moduleIndexData.push({
          moduleName: mcrModulePath,
          tags,
          properties,
        });
      } catch (error) {
        core.setFailed(error);
      }
    }

    numberOfModuleGroupsProcessed++;
  }


  core.info(`Writing moduleIndex.json`);
  await fs.writeFile(
    "moduleIndex.json",
    JSON.stringify(moduleIndexData, null, 2)
  );

  core.info(`Processed ${numberOfModuleGroupsProcessed} modules groups.`);
  core.info(`Processed ${moduleIndexData.length} total modules.`);
  core.info(
    `${
      moduleIndexData.filter((m) =>
        Object.keys(m.properties).some(
          (key) => "description" in m.properties[key]
        )
      ).length
    } modules have a description`
  );
}

module.exports = generateModuleIndexData;
