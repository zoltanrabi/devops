## Solutions with GitHub Actions

### Setting Up the Environment

#### Salesforce Setup

1. **Install Salesforce CLI:** [Download Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
2. **Salesforce Extension Pack:** Install Salesforce Extension Pack for VS Code
3. **Create a SF DEV org:** [Sign Up](https://developer.salesforce.com/signup)
4. **Connect VS Code to the DEV org**

#### GitHub Setup

1. **Register on GitHub:** [Sign Up](https://github.com/join)
2. **Create a repository:** [New Repository](https://github.com/new)
3. **Download GitHub Desktop and connect your repository:** [Download Github Desktop](https://github.com/apps/desktop)
4. **Generate sfdxAuthUrl:**
   - Login to your orgs from VS code
   - Generate and save your sfdxAuthUrl:
   ```sf org display --verbose --json -o your-org-name ```
   - Save the contect of the marked line (string after "force://PlatformCLI::)
![GitHub Branch Rules](.github/images/sfdxAuthUrl.jpg)
---

## GitHub Configuration

### Repository Secrets and Permissions

1. **Create repository secrets:**
   - Go to repository Settings > Secrets and Variables > Actions > New Repository Secret
   - Create the secrets with the following names and set the values to the previously generated sfdxAuthUrls:
    - SFDX_AUTH_URL_DEV
    - SFDX_AUTH_URL_TEST
    - SFDX_AUTH_URL

2. **Add repository variables:**
   - Change to variables tab and add New repository variables:
    - DEV_BRANCH = dev
    - TEST_BRANCH = test
    - PROD_BRANCH = prod
    - INT_ORG = INT

3. **Set workflow permissions:**
   - Go to Settings > Actions > General.
   - Set Read and Write permissions.

### GitHub Branch Rules

1. **Add Rules to branches:**
   - Repeat the steps bellow for each of your branches
   - Go to repository Settings > Rules > Rulesets.
   - Add new Ruleset with configurations:
     - Target: Your branch name (dev, test, prod)
     - Restrict deletions
     - Require pull request before merging
     - Required Approvals (1)
     - Dismiss stale pull request approvals when new commits are pushed
     - Require approval of the most recent reviewable push
     - Require status checks to pass (e.g., validate)
     - Block force pushes

![GitHub Branch Rules](.github/images/githubRuleset.png)
2. **It is possible to restrict who can push to branches. To set it up follow the documentation:**
     - [Protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)

---

## Workflows, Actions, and Scripts

### Pull Request flow automation

#### Pull Request process
1. **PR Creation**
   - Branch rules require an approval and the Validation workflow to run. Validation workflow start automatically after the PR is created.
2. **Validation**
   - Validate the changes against target org. Types:
        Delta: TEST_LEVEL is: RunSpecifiedTests. DELTA validation means that test only those will run which are connected to the changes in the PR:
        - Test classes: changed test classes
        - Normal classes/triggerclasses: Test classes which are related to a changed class (for example: if AccountTrigger.cls is changed the code will try to find test classes which has Test at the end of the class name and Account anywhere in the class name)
        - Validation rule: Object related test classes related to a changed validation rule (for example: if you change Validation rule related to the Account Object the code will gather the test classes which has Test at the end of the class name and Account anywhere in the class name)
        - Record-Triggered flows: Test classes realted to Record-Triggered flows
        - Fields: The test classes related to the Object for which field is changed
        Full: TEST_LEVEL is: RunLocalTests. Runs all test
3. **PR Approval**
   - PR needs to be approved at least by one approver after the Validation executes successfully. It triggers the automatic Deployment. 
4. **Deployment**
   - Deploy the changes to the target org. Types:
        Full: deploy the branch to the org
        Delta: deploy only the changes files to the org
        Quick: deploy the last validated deployment to the org
5. **Merge**
   - Code is merged to the target branch after successful deployment
#### Key componenet of the validation workflow
1. **Validation.yml workflow**
   - It contains the configuration for the validation:
     - branches: the used branch names are listed (dev, test, prod)
     - run-name: it will generate the name for the workflow which is visible in the Action tab in the GitHub repository. It check against which branch we are doing the validation. It generates the corresponding Action name with the org names
     - Under jobs: -> validate: -> name: Set SFDX Auth URL and Test Level we define the sfdxAuthUrl based on the target org and the test level for the validation. DEPLOY_TYPE variable controls if the validation is DELTA validation or FULL validation. Two combination is possible:
      - DEPLOY_TYPE = DELTA and TEST_LEVEL = RunSpecifiedTests
      - DEPLOY_TYPE = FULL and TEST_LEVEL = RunLocalTests
![GitHub Branch Rules](.github/images/validation1.png)
![GitHub Branch Rules](.github/images/validation2.png)