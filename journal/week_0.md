# Terraform Beginner Bootcamp 2023 - Week 0 

## Install the Terraform CLI

The instructions to install Terraform CLI can be found here:
[Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

We'll follow them to build a bash script that does the installation and call that script from `.gitpod.yml`

### Create the Bash script for the Terraform CLI installation

- We'll place the bash script in `./bin/install_terraform_cli`

```bash
#!/usr/bin/env bash

cd /workspace

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform -y

cd $PROJECT_ROOT
```
- We then need to make the script executable to be able to call it directly from the command line:
```bash
chmod u+x ./bin/install_terraform_cli
```

### Create the Bash script for the AWS CLI installation

- We'll place the bash script in `./bin/install_aws_cli`

```bash
#!/usr/bin/env bash

cd /workspace

rm -f '/workspace/awscliv2.zip'
rm -rf '/workspace/aws'

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws sts get-caller-identity

cd $PROJECT_ROOT
```
```

- We also need to make the script executable to be able to call it directly from the command line:

```bash
chmod u+x ./bin/install_aws_cli
```
## Gitpod Lifecycle

With Gitpod, you have the following three types of tasks:
..* **before**: Use this for tasks that need to run before init and before command. For example, customize the terminal or install global project dependencies.
..* **init**: Use this for heavy-lifting tasks such as downloading dependencies or compiling source code.
..* **command**: Use this to start your database or development server.

https://www.gitpod.io/docs/configure/workspaces/task

In our case, we'll need to update the `.gitpod.yml` file to call the installation script with **before** instead of **init**:

```yml
- name: terraform
    before: |
      source ./bin/install_terraform_cli
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    before: |
      source ./bin/install_aws_cli
```

## Project Environment Variables

- List out all Environment Variables using the `env` command

- Filter specific env vars using `grep` eg. `env | grep AWS_`

Let's create a new project environment variable called **PROJECT_ROOT** referring to the root directory.

- We can set environment variables by exporting them to the terminals:

```bash
export PROJECT_ROOT=/workspace/terraform-beginner-bootcamp-2023
```

- We can also unset environment variables:

```bash
unset PROJECT_ROOT
```

- We can set an env var temporarily when just running a command

```bash
HELLO='world' ./bin/print_message
```

- Within a bash script we can set env without writing export eg.

```bash
#!/usr/bin/env bash

HELLO='world'

echo $HELLO
```

- To print an env var, the `echo` command is used eg. `echo $HELLO`

- By default, env vars are not persisted. So, on opening up a new bash terminal, the env vars set in another terminal window are not seen.

- To persist an env var across all future bash terminals, it must be set in bash profile. eg. `.bash_profile`

- It's possible to persist env vars into gitpod by storing them in Gitpod Secrets Storage.
```
gp env HELLO='world'
```

- It's also possible to set env vars in the `.gitpod.yml` but this can only contain **non-sensitive** env vars.

### AWS CLI Configuration

- AWS CLI is installed for the project via the bash script [`./bin/install_aws_cli`](./bin/install_aws_cli)
[AWS CLI Env Vars](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)

- This AWS CLI command is used to see the AWS credentials configured:
```bash
aws sts get-caller-identity
```

- On success, there is a json payload returned:

```json
{
    "UserId": "AIEAVUO15ZPVHJ5WIJ5KR",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-bootcamp-user"
}
```

- We'll need to generate AWS CLI credits from IAM User in order to the user AWS CLI.

..* First, let's create a new user in IAM console with admin privileges for the bootcamp that will call `terraform-bootcamp-user`.
..* Then, we'll generate access keys
..* Finally, we'll put the access keys in the `.env` file and the gitpod environment with `gp env`

## Terraform Basics

### Terraform Registry


Terraform sources their providers and modules from the Terraform registry which located at [registry.terraform.io](https://registry.terraform.io/)

- **Providers** is an interface to APIs that will allow to create resources in terraform.
- **Modules** are a way to make large amount of terraform code modular, portable and sharable.

[Random Terraform Provider](https://registry.terraform.io/providers/hashicorp/random)

### Terraform Console

- List all the Terraform commands by simply typing `terraform`

#### Terraform Init

At the start of a new terraform project, run `terraform init` to download the binaries for the terraform providers that will be used in this project.

#### Terraform Plan

`terraform plan`

- This will generate out a changeset about the state of our infrastructure and what will be changed.
- This changeset can be output ie. "plan" to be passed to an apply, but it's often ignored.

#### Terraform Apply

`terraform apply`

- This will run a plan and pass the changeset to be executed by terraform. Apply should prompt **yes** or **no**.
- To automatically approve an apply, the auto approve flag can be set eg. `terraform apply --auto-approve`

#### Terraform Destroy

`terraform destroy`
- This will destroy resources.
- The auto approve flag can also be used here to skip the approve prompt eg. `terraform apply --auto-approve`

#### Terraform Lock Files

`.terraform.lock.hcl` contains the locked versioning for the providers or modules that should be used with this project.

- The Terraform Lock File **should be committed** to your Version Control System (VSC) eg. Github

#### Terraform State Files

`.terraform.tfstate` contains information about the current state of your infrastructure.

- This file **should not be commited** to your VCS.
- This file can contain sensentive data.
- If this file is lost, the state of your infrastructure will be unknown.

`.terraform.tfstate.backup` is the previous state file state.

#### Terraform Directory

`.terraform` directory contains binaries of terraform providers.

## Issues with Terraform Cloud Login and Gitpod Workspace

When attempting to run `terraform login`, it will launch bash a wiswig view to generate a token. However, it does not work as expected in Gitpod VsCode in the browser.

- The workaround is to manually generate a token in Terraform Cloud: https://app.terraform.io/app/settings/tokens?source=terraform-login

- Then, create and open the file manually here:

```bash
touch /home/gitpod/.terraform.d/credentials.tfrc.json
open /home/gitpod/.terraform.d/credentials.tfrc.json
```

- Provide the following code (replace your token in the file):

```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "YOUR-TERRAFORM-CLOUD-TOKEN"
    }
  }
}

- A workaround for automating the generation of the credentials for terraform with the following bash script [bin/generate_tfrc_credentials](bin/generate_tfrc_credentials)