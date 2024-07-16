const core = require('@actions/core');
const github = require('@actions/github');

async function run() {
  try {
    const token = core.getInput('github-token');
    const octokit = github.getOctokit(token);
    const context = github.context;
    const pr = context.payload.pull_request;

    // Check Approvals
    const reviewsResponse = await octokit.rest.pulls.listReviews({
      owner: pr.base.user.login,
      repo: pr.base.repo.name,
      pull_number: pr.number
    });

    const requiredApprovers = reviewsResponse.data.map(reviewer => reviewer.user.login);
    const approvedReviewers = reviewsResponse.data.filter(review => review.state === 'APPROVED').map(review => review.user.login);

    const allApproved = requiredApprovers.every(reviewer => approvedReviewers.includes(reviewer));

    console.log(`Required Approvers: ${requiredApprovers}`);
    console.log(`Approved Reviewers: ${approvedReviewers}`);
    console.log(`All required approvers approved: ${allApproved}`);

    if (!allApproved) {
      core.setFailed('Not all required approvers have approved the pull request.');
      return;
    }

    // Get the workflow run with job names containing 'validate'
    const validateWorkflow = runs.workflow_runs.find(async (run) => {
      const { data: jobs } = await octokit.rest.actions.listJobsForWorkflowRun({
        owner: pr.base.user.login,
        repo: pr.base.repo.name,
        run_id: run.id
      });

      return jobs.jobs.some(job => job.name.toLowerCase().includes('validate')) && run.head_sha === pr.head.sha;
    });

    if (!validateWorkflow || validateWorkflow.conclusion !== 'success') {
      core.setFailed('The required validation workflow has not passed.');
      return;
    }

    if (!validateWorkflow || validateWorkflow.conclusion !== 'success') {
      core.setFailed('The required validation workflow has not passed.');
      return;
    }

    core.setOutput('check_approvals_status', 'success');
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();