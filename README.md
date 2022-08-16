# IaC
#install AZ Cli <br/>
#install terraform <br/>


#install AWS Cli <br/>
#install terraform <br/>

terraform init <br/>
terraform fmt <br/>
terraform validate <br/>
terraform plan -out main.tfplan <br/>
terraform apply main.tfplan <br/>

terraform plan -destroy -out main.destroy.tfplan <br/>
terraform apply main.destroy.tfplan <br/>


terraform destroy -auto-approve <br/>
