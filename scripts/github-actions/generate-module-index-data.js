/**
 * @param {typeof import("fs").promises} fs
 * @param {string} dir
 */

const { ContainerRegistryClient } = require("@azure/container-registry");
const { DefaultAzureCredential } = require("@azure/identity");
require("dotenv").config();

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

  // Get the SHA of the commit
  const mm_result = await github.rest.git.getRef({
    owner: context.repo.owner,
    repo: context.repo.repo,
    ref: gitTagRef,
  });

  const commitSha = mm_result.data.object.sha;
  
  // Get the tree data
  const mm_result2 = await github.rest.git.getTree({
    owner: context.repo.owner,
    repo: context.repo.repo,
    tree_sha: commitSha,
    recursive: true,
  });
  const tree = mm_result2.data.tree;

  // Find the file in the tree
  const file = tree.find((f) => f.path === mainJsonPath);
  if (!file) {
    throw new Error(`File ${mainJsonPath} not found in repository`);
  }

  const mm_result3 = await github.rest.git.getBlob({
    owner: context.repo.owner,
    repo: context.repo.repo,
    file_sha: file.sha,
  });
  
  const content = mm_result3.data.content;

  // content is base64 encoded, so decode it
  const fileContent = Buffer.from(content, "base64").toString("utf8");

  // Parse the main.json file
  if (fileContent !== "") {
    const strToFind = 'metadata description =';
    const position = fileContent.search(strToFind);
    const cutStr = fileContent.substring(position + strToFind.length, 1000);
    const firstquote = cutStr.indexOf("'") + 1;
    const secondquote = cutStr.indexOf("'", firstquote);
    const description = cutStr.substring(firstquote, secondquote);

    return description;
  } else {
    throw new Error(
      "The specified path does not represent a file or it is empty."
    );
  }
}

async function getLatestTag(repositoryName) {
  const endpoint = process.env.CONTAINER_REGISTRY_ENDPOINT || "<endpoint>";
  const client = new ContainerRegistryClient(
    endpoint,
    new DefaultAzureCredential()
  );

  const repository = client.getRepository(repositoryName);
  const manifest = await listManifestProperties(repository);

  if (manifest && manifest.length) {
    const digest = manifest[0].digest;
    if (digest) {
      const artifact = repository.getArtifact(digest);
      const tags = await listTagProperties(artifact);
      return tags;
    }
  }
}

async function listManifestProperties(repository) {
  const artifacts = [];
  const iterator = repository.listManifestProperties();
  for await (const artifact of iterator) {
    artifacts.push(artifact);
  }

  return artifacts;
}

async function listTagProperties(artifact) {
  const tags = [];
  // Obtain the tags ordered from newest to oldest by passing the `orderBy` option
  //"LastUpdatedOnAscending"
  const iterator = artifact.listTagProperties({
    order: "LastUpdatedOnDescending",
  });
  var tmpTagName = "";

  for await (const tag of iterator) {
    if (tmpTagName != tag.repositoryName) {
      tmpTagName = tag.repositoryName;
      tags.push(tag);
      break;
    }
  }
  return tags;
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
      const mainJsonPath = `${modulePath}/main.bicep`;
      // BRM module git tags do not include the modules/ prefix.
      const mcrModulePath = modulePath.slice(8);
      //const tagListUrl = `https://mcr.microsoft.com/v2/bicep/${mcrModulePath}/tags/list`;
      //GET https://mmbicepmoduleregistry.azurecr.io/acr/v1/storage-account/_tags?n=1&orderby=timedesc
      //const tagListUrl = `https://mmbicepmoduleregistry.azurecr.io/acr/v1/${moduleName}/_tags?n=1&orderby=timedesc`
      core.log(`Before getting latest tag`);
      const moduleLatestTag = getLatestTag(moduleName);
      core.log(`Latest tag is ${moduleLatestTag} - for module ${moduleName}`);

      try {
        core.info(`Processing Module "${modulePath}"...`);
        //core.info(`  Getting available tags at "${tagListUrl}"...`);

        // const tagListResponse = await axios.get(tagListUrl, { headers: {"Authorization": `Bearer ${breatoken}`}});
        // const version = tagListResponse.data.tags.sort();
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
  
        properties[tag] = { description, documentationUri };
        //}

        moduleIndexData.push({
          moduleName: mcrModulePath,
          tag,
          properties,
          moduleVersion: moduleLatestTag
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
