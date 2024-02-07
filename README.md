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
2. Adjust the config values in `variables.pkrvars.hcl` accordingly.
3. Create an SSH key-pair to let Packer access the temporary system during the build process:
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
1. Create the Terraform module wrapper for your platform. Replace `VARIANT` with an available platform name. No adjustments need to be done in this file.
```shell
cp nodes.VARIANT_vm.tf.dist nodes.tf
```
2. Create a config file to hold all custom settings:
```shell
cp terraform.tfvars.dist terraform.tfvars
```
3. Uncomment all settings for the chosen platform and set their values in `terraform.tfvars`.

### Build
```shell
terraform apply
```

