# Intro
This is a guide how to run your own [dedicated game server](https://github.com/AGOG-Entertainment/brutal-grounds-dedicated-server) of [Brutal Grounds](https://www.brutalgrounds.com/) game, a spiritual successor to the [Babo Violent 2](https://www.baboviolent2.com/).

The server will be created in AWS by using Terraform and Ansible and a couple of manual steps over SSH.
  
# Prerequisites
To run your own Brutal Grounds server you need the following:
- Steam account - go [here](https://store.steampowered.com/) to create one
  - Brutal Grounds game (in Alpha as of writing) - ask on their [Discord server](https://discord.com/invite/mamsmjx) for free access key
- AWS account - go [here](https://aws.amazon.com/) to create one (you will need a credit card) - this is where game server will be hosted
- Git - not a hard requirement but it will be easier to have it
- Terraform - main tool that will create the environment
- Python
  - AWS CLI - not a hard requirement but it will be easier to have it - installed as Python module
  - Ansible - additional tool that will help configure the environment - installed as Python module
- SSH client

The guide is written for Linux, specifically Ubuntu. Modifying it for Windows or macOS should be fairly easy, nothing is strictly Linux specific.

## Setup
First, go to your AWS account to create a new user, you can call it any name, for example `Brutal_Grounds_Deployer`. It will be used by Terraform to create the whole infrastructure. The following steps could be slightly different as I will not keep this up to date with AWS changes in their portal:
- In AWS console navigate to `IAM` and then `Users`, click on `Add users`.
- For `User name` set: `Brutal_Grounds_Deployer`.
- On `Select AWS credential type` select `Access key - Programmatic access`, press `Next: Permissions`.
- For permissions select `Attach existing policies directly` and then find and select `AmazonEC2FullAccess`, press `Next: Tags`.
- (optional) Add a new tag with the `Key` set to `Purpose` and the `Value` set to `brutal_grounds`.
- Press `Next: Review`, and then press `Create user` and be sure to copy both the `Access key ID` and `Secret access key` values.

(for a more advanced but more secure creation of the deployer user check the FAQ)

Run the following to install Git, Terraform, Python and SSH (if not already installed):

```bash
apt-get install git terraform python ssh
```

Next, use Git to download this repository to your local machine:

```bash
git clone https://github.com/zunzoa/brutal-grounds-auto-dedicated-server.git
```

Now, go inside the repository and create Python virtual environment, activate it and install AWS CLI and Ansible as Python modules. The modules are already defined in `requirements.txt` file.

```bash
cd brutal-grounds-auto-dedicated-server
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

In case there are problems with the packages defined in `requirements.txt` try to directly install the latest versions of AWS CLI and Ansible:

```bash
python -m pip install awscli
python -m pip install ansible
```

Once AWS CLI is installed, create the local AWS `config` and `credentials` files. To do that you can run `aws configure` command (while inside the Python virtual environment, using the `source` command from previous step). To not use the default profile use the flag `--profile` with the provided name, in this case we are naming it `bgds`.

```bash
aws configure --profile bgds
```

When you run the command, several information needs to be provided:
- AWS Access Key ID - created when the `Brutal_Grounds_Deployer` user was created in AWS console 
- AWS Secret Access Key - created when the `Brutal_Grounds_Deployer` user was created in AWS console 
- Default region name - we will use `eu-central-1` but you can change this to have the server hosted closer to where you are located (list of possible values can be found [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.Regions))
- Default output format - not important, you can use `json`

After this you should have `~/.aws/config` and `~/.aws/credentials` files created with the information provided in previous step.

Before you start creating infrastructure you need to create SSH key that will be used to later login to the server. By default, keys need to be in the directory called `secrets` which you create inside the repository directory. When you run `ssh-keygen` do not set any passphrase, just hit two times `Enter`.

```bash
mkdir secrets
ssh-keygen -t rsa -b 4096 -f secrets/bg_rsa
```

Alternatively, keep them in some other location, but you need to then change the appropriate values in the `vars.tf` file.

# Create and destroy server
This section describes how to first quickly create a new server and then later quickly destroy it.

To create and destroy the server we will be using Terraform script. The creation is split into three steps: `init`, `plan` and `apply`. The `init` step will configure Terraform to work with AWS. The `plan` and `apply` are connected and are split into two steps as a safe practice. The `plan` will print out all the changes that will be made in your AWS account, and it is always good to check the output before running the `apply` step, which will actually start creating AWS resources that will incur charges. The destruction of the server is done with one command called `destroy`.

Terraform scripts will create the minimal needed infrastructure to host a server:
- Virtual Private Cloud (VPC) - logical unit which will contain the network and the server
- subnet - the local network for our server
- routing table - rules how the packets will be routed in the network
- internet gateway - gives Internet access to the server
- security group - firewall that will allow only game server ports to be publicly accessible
- EC2 instance - the server instance where Brutal Grounds Dedicated Server will be running, we are using an Ubuntu 22.04 server
- key pairs - the SSH keys we created will be uploaded to AWS and automatically added to EC2 instance, so we can remotely connect to it

After infrastructure creation, Terraform scripts will first start the update process so that the Ubuntu EC2 instance is updated to the latest patches. Then it will execute few configuration actions to prepare Ubuntu for Steam installation as well as install some additional optional utility tools (`tmux`). Finally, it will start Ansible script which will execute the Steam installation, specifically the official SteamCMD tool. Once that is finished two manual steps will need to be done. First to install the Brutal Grounds Dedicated Server from Steam and then to actually run the game server.

## Create infrastructure
To run the Terraform script and create the AWS environment run the following three commands from the root directory of the repository:

```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan -out=tf.plan
terraform -chdir=terraform apply tf.plan
```

The `apply` step could take a couple of minutes. If successful, a message similar to the following should be displayed (of course, values like IP address will be different for you):

```bash
[...SNIP...]

null_resource.waiter: Creation complete after 1m25s [id=6501034451101283804]

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

ip = "3.72.81.174"
```

## Download and Start Brutal Grounds Dedicated Server
Once infrastructure is created you need to connect to the server and do two manual steps. To connect you can use the following SSH command which takes the IP address of the created Ubuntu EC2 instance from Terraform output.

```bash
ssh ubuntu@$(terraform -chdir=terraform output ip | tr -d '"') -i secrets/bg_rsa
```

You should see output similar to this:
```bash
(.venv) user@host:~/brutal_grounds_ds (master) $ ssh ubuntu@$(terraform -chdir=terraform output ip | tr -d '"') -i secrets/bg_rsa
Welcome to Ubuntu 22.04.1 LTS (GNU/Linux 5.15.0-1020-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue Oct  4 18:31:42 UTC 2022

  System load:  0.30810546875     Processes:             106
  Usage of /:   26.7% of 7.57GB   Users logged in:       0
  Memory usage: 25%               IPv4 address for eth0: 10.0.0.5
  Swap usage:   0%


0 updates can be applied immediately.


Last login: Tue Oct  4 18:30:45 2022 from 1.2.3.4
ubuntu@ip-10-0-0-5:~$ 
```

Once logged in, there will be two Bash scripts in the home directory. First run the `bg-ds-install.sh` which will use the SteamCMD to install the Brutal Grounds Dedicated Server from the Steam store.

```bash
~/bg-ds-install.sh
```

This will be the moment in time when you will need to provide at minimum your username and password from your Steam account. And if you have turned on the [Steam Guard](https://help.steampowered.com/en/faqs/view/06B0-26E6-2CF8-254C), which you should have, then you will get a prompt for the code which will be sent to your email once you provide the correct username and password. Once all information is provided, the Brutal Grounds Dedicated Server will be installed.

The screen should look something like this:
```bash
ubuntu@ip-10-0-0-5:~$ ~/bg-ds-install.sh 
Enter your Steam username: FakeUser
Running SteamCMD to download Brutal Grounds Dedicated Server, when prompt enter your Steam password and optionally, if you have it enabled, Steam Guard code
Redirecting stderr to '/home/ubuntu/Steam/logs/stderr.txt'
[  0%] Checking for available updates...
[----] Verifying installation...
Steam Console Client (c) Valve Corporation - version 1663887295
-- type 'quit' to exit --
Loading Steam API...OK
Logging in user 'FakeUser' to Steam Public...
password: FakePasswordNotVisibleHere
Message type 9806 wasn't declared, but we registered job CClientJobEnableOrDisableDownloads to handle it?

This computer has not been authenticated for your account using Steam Guard.
Please check your email for the message from Steam, and enter the Steam Guard
 code from that message.
You can also enter this code at any time using 'set_steam_guard_code'
 at the console.
Steam Guard code:FakeCode
OK
Waiting for client config...OK
Waiting for user info...OK
 Update state (0x3) reco
...
<SNIP>
...
Update state (0x81) verifying update, progress: 93.65 (670327427 / 715792446)
Success! App '1123110' fully installed.
Brutal Grounds Dedicated Server installed!
```

Finally, run the `start-bg.sh` to actually start the game server.

```bash
~/start-bg.sh
```

It will ask for the following information:
- server name - this is the server name displayed in the list of servers in game
- host name - this is the name of the person who is hosting the server, again displayed in the list of servers in game (can be anything you want, does not have to be your actual in game name)
- admin ID - Steam account ID of the person who will be administrator of the game server (ability to change game mode and maps) - to find your Steam account ID go [here](https://steamidfinder.com/)
- server password - if you want to run a password protected game server, set the password here, otherwise just leave empty and hit Enter

Done! At this point you should see your server available on Brutal Grounds server list in game.

The `start-bg.sh` script is very simple and if you want to modify how the game server is created just take the last line in the script and edit it how you wish.

## Cleanup
Unless you want to run the server 24/7 for others to use it, it is recommended to destroy the server once you are finished to reduce the costs (more about it in FAQ). To destroy the server and completely remove all the infrastructure run the following command:

```bash
terraform -chdir=terraform destroy
```

When prompted, type `yes`.

If cleanup is successful you should see output similar to this:

```bash
[...SNIP...]
aws_vpc.bg_vpc: Destruction complete after 1s

Destroy complete! Resources: 9 destroyed.
```

If cleanup failed for some reason check out the FAQ for how to manually cleanup your environment.

# FAQ

## Brutal Grounds Dedicated Server?

Go to Brutal Grounds Dedicated Server [GitHub repository](https://github.com/AGOG-Entertainment/brutal-grounds-dedicated-server) for more information.

## Costs?
The only thing that incurs costs is the EC2 instance and the associated EBS volume. The script uses one of the cheapest options which is enough to run a good performance stable server.

At the time of writing this README the prices in EU Frankfurt region for were the following:
- $0.0134 per On Demand Linux `t2.micro` instance per hour
- $0.119 per GB-month of General Purpose SSD (gp2) provisioned storage
During the creation of this script and its testing, together with several played game matches, I got 7.238 hours of server uptime and barely 0.086 GB-Month. Multiplying this with the prices it resulted in $0.11 of cost. If you run the server 24/7 expect that for a month around $10 will be needed. I am sure the costs could be further optimized to be even cheaper.

If you have just created a new AWS account then a free tier will be automatically applied for your account for the first 12 months. Depending on the [conditions](https://aws.amazon.com/free/) and your usage it is possible that you will not have to pay anything at all.

## Manual cleanup?
If for some reason the script fails to delete all the resources you will need to manually delete them in the [AWS Console](https://aws.amazon.com/console/). Most importantly you need to delete EC2 instance which is the main thing that results in costs. After that manually delete the key pair (in the same section where you deleted EC2 instances). Finally, you do not need to delete each part of the infrastructure manually, you only need to go to VPC section and delete the VPC as this will delete also all the infrastructure connected to it (subnet, internet gateway, etc.). To easier identify resources in AWS console everything is created with `Brutal Grounds` in their name and also a tag called `Purpose` which has the value `brutal_grounds`. This tag can also be used to monitor costs and create budget notifications but this is beyond this guide.

## Performance?
The official servers use 0.5 vCPU and 1 GB of RAM. The instance used in this script is `t2.micro` which is 1 vCPU and 1 GB of RAM. The server would probably run perfectly fine even with `t2.nano` which is 0.5 GB of RAM, but I have not tested this.

On the other hand, if you feel you need better performance you could increase the tier of the instance. To do that, edit the `vars.tf` file, specifically the `INSTANCE_TYPE` variable. For any further optimization refer to the individual Terraform scripts and edit where and how it is appropriate for you.

## Least privileged deployer user?
The guide uses a deployer user which has unrestricted permissions on EC2. This can be a problem in case credentials used in the script get compromised as whoever gains access to the credentials has unrestricted access on the EC2 service. To reduce the impact of this scenario it is recommended to have the user with the least privilege.

To do that, in the step where the existing AWS policy `AmazonEC2FullAccess` is being attached to the user, instead of doing that, press `Create policy`. In the new tab, press on `JSON` and copy and paste the following text:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:CreateVpc",
                "ec2:DeleteVpc",
            	"ec2:DescribeVpcAttribute",
            	"ec2:DescribeVpcClassicLink",
            	"ec2:DescribeVpcClassicLinkDnsSupport",
                "ec2:DescribeSubnets",
                "ec2:CreateSubnet",
                "ec2:DeleteSubnet",
            	"ec2:ModifySubnetAttribute",
                "ec2:CreateRoute",
                "ec2:DescribeRouteTables",
                "ec2:CreateRouteTable",
                "ec2:DeleteRouteTable",
                "ec2:AssociateRouteTable",
                "ec2:DisassociateRouteTable",
                "ec2:DescribeInternetGateways",
                "ec2:CreateInternetGateway",
                "ec2:DeleteInternetGateway",
                "ec2:AttachInternetGateway",
                "ec2:DetachInternetGateway",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
            	"ec2:AuthorizeSecurityGroupIngress",
            	"ec2:AuthorizeSecurityGroupEgress",
            	"ec2:RevokeSecurityGroupEgress",
                "ec2:DescribeKeyPairs",
                "ec2:ImportKeyPair",
                "ec2:DeleteKeyPair",
                "ec2:DescribeImages",
            	"ec2:DescribeVolumes",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DescribeInstanceAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeTags",
                "ec2:CreateTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeInstanceCreditSpecifications"
            ],
            "Resource": "*"
        }
    ]
}
```
This is a more or less minimal set of permissions needed for the script to work as intended. Go through the steps to create the policy and then select that policy when creating the user.

This can further be improved by configuring the `Resources` on which this policy is applicable, but I will leave this for your own exercise.

## Full automation?
The manual steps could be avoided and the script could be completely automated if the Steam Guard is not enabled on the account. The username and password could be provided in the script in multiple ways (do not hard code it!), good approach being through environmental variables, and provided to SteamCMD when the Brutal Grounds Dedicated Server is being installed. However, turning off Steam Guard is definitively not recommended.

As an alternative, a dedicated Steam account could be created that will only have Brutal Grounds game in it and which can then be used for full automation. This seemed like too much trouble for little benefit so that is why we have these two manual steps. Another alternative is to have another script which automatically gets the code from the email but that has even worse cost-benefit ratio.

## What are all these files and folders?
Several folders and files will be created on your disk, you can safely ignore them. These are:
- `.venv/` - Python virtual environment
- `secrets`, `secrets/bg_rsa` and `secrets/bg_rsa.pub` - private and public SSH keys used for remote access to the game server
- `terraform/.terraform/`, `terraform/.terraform.lock.hcl`, `terraform/terraform.tfstate`, `terraform/terraform.tfstate.backup` and `terraform/tf.plan` - files needed for Terraform to work as intended, some of them such as `terraform.tfstate` contain sensitive information so be sure not to share them to anybody

## My server crashed because my SSH connection broke!?
When you start the dedicated server it will be running inside the SSH terminal and if it breaks the server will crash. To prevent this happening a helper tool called `tmux` is installed. It has a slight learning curve, but it is highly customizable which makes it a great tool. This tool and a customized configuration file for it is by default deployed on the server. To use it just first run:

```bash
tmux
```

And then run the `~/start-bg.sh` inside of the newly opened terminal. To exit `tmux` terminal press `CTRL-a` and then `d` to detach the session. You can then safely close the SSH connection, your Brutal Grounds server will continue running. For how to use `tmux` refer to online tutorials, keep in mind that by default the main control key is already re-mapped from CTRL-b to CTRL-a. Check the `tmux.conf` file for more details and edit as needed.

## The future?

The game is in Alpha as of the time of publishing this repository. That means that script usage problems are expected. I will do my best to keep up to date with the recent updates to the game.

On the long run this script will probably be outdated as there were few indications from the developers that hosting private servers will eventually be integrated as core game functionality. In that case there will be no point in these scripts. However, until then, I hope it helps you to play more of this awesome game.