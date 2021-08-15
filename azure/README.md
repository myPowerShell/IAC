# IAC
#install AZ Cli
#install terraform

terraform init
terraform fmt
terraform validate
terraform plan -out main.tfplan
terraform apply main.tfplan

terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan


terraform destroy -auto-approve
