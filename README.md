# ECM on Proxmox (and others)

## Packer
```shell
cd <project-dir>/packer
```

### Setup
1. Create HCL config files. Replace `VARIANT` with an available platform name.
```shell
cp openSUSE_MicroOS-selfinstall.VARIANT.pkr.hcl.dist openSUSE_MicroOS-selfinstall.pkr.hcl
cp variables.pkrvars.proxmox.VARIANT.dist variables.pkrvars.hcl
```
Adjust the config values in `variables.pkrvars.hcl` accordingly.

2. Create an SSH key-pair to let Packer access the temporary system during the build process:
```shell
ssh-keygen -t ed25519 -C "Packer" -f ./ssh_files/packer
```

### Build
```shell
packer build -var-file="variables.pkrvars.hcl" .
```

## Terraform
```shell
cd <project-dir>/terraform
```

### Setup
1. Create the Terraform module wrapper for your platform. Replace `VARIANT` with an available platform name.
```shell
cp nodes.VARIANT_vm.tf.dist nodes.tf
```
No adjustments need to be done in this file.

2. Create a config file to hold all custom settings:
```shell
cp terraform.tfvars.dist terraform.tfvars
```
Uncomment all settings for the chosen platform and set their values.

### Build
```shell
terraform apply
```

