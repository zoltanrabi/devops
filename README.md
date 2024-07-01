# Salesforce DX Project: Next Steps

Our GitHub CI steps:
-Commit changes
-Create PR with the changes
-Validate the changes (only run necessary tests, changed tests)
-Assignee review the PR
-Assignee Approve PR
-Deployment starts to the org



Dev:
Validacio (delta)
Deploy (ha lehet quick deploy - noTestRun)

Ejfelkor full deploy

Test:
PR-ra ugyanugy approve kell
Dev-bol fogadjon csak PR-t ha lehet
Validacio osszes teszt futassal
Utana Approve
Deploy (noTestRunnal)

master:
csak a testbol
teljes validacio
itt is approve
teljes deploy (noTestRun, itt ugyis lefog futni valoszinuleg mert ez a prod)


-if deployment successful -> merge code into git

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

- [Modification for commit v2]
