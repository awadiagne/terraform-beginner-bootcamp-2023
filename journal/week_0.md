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