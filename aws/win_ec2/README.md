# IaC
#install aws cli
#install terraform

#Terraform IaC Example for creating Windows Virtual Machine & VPC on demand
#Access Internet and perform simple browsing tasks
#Destroy when done, repeat process as needed

terraform init
terraform fmt
terraform validate
terraform plan -out main.tfplan
terraform apply main.tfplan

terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan


#terraform destroy -auto-approve
