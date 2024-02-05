# ECM on Proxmox

## Packer

### Build
```shell
cd packer
packer build -var-file="variables.pkrvars.hcl" .
```

## Terraform

### Build
```shell
cd terraform
terraform apply
```
