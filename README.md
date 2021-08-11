# IAC
#install AZ Cli
#install terraform

terraform init
terraform fmt
terraform validate
terraform plan -out main.tfplan
terraform apply main.tfplan

terraform destroy -auto-approve
