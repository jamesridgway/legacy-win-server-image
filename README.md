# Legacy Windows Server 2012 with SQL Server Express 2012 and .Net Core 3.1
This project shows how to setup a Windows Server 2012 image using packer.

The setup includes:

* Configuring OpenSSH
* Installing SQL Server Express 2012
* .Net Core 3.1

## Building the Image
Ensure that packer is installed and available on your `PATH`.

Run:

    ./build.sh

This will generate:

* an SSH keypair used for the OpenSSH setup
* a password for the Windows Administrator account

The build process will use Pakcer to produce an AMI in your AWS account.

## Connecting to the Server
Launch an EC2 Instance from the AMI image. Choose an instance type with enough memeory (e.g. t3a.large - 8GB RAM).

One the instance has launched you will be able to connect using RDP or SSH.

RDP:

    Username: Administrator
    Password: [PROVIDED BY build.sh]

SSH:

    ssh -i ssh-key Administrator@[IP ADDRESS]
