const core = require('@actions/core');
const github = require('@actions/github');

async function run() {
  try {
    const token = core.getInput('github-token');
    const octokit = github.getOctokit(token);
    const context = github.context;

    const pullRequest = context.payload.workflow_run.pull_requests[0];
    const repository = context.repo;

    await octokit.rest.pulls.merge({
      owner: repository.owner,
      repo: repository.repo,
      pull_number: pullRequest.number,
      merge_method: "merge",
    });

  } catch (error) {
    core.setFailed(error.message);
  }
}

run();