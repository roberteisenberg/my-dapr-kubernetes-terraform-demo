# this assumes service principal is created and configured.
# https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?tabs=bash&pivots=development-environment-azure-cli#authenticate-to-azure-via-a-microsoft-account

dapr uninstall all
az login

# make sure azure configured properly
printenv | grep ^ARM*

#if not already done, first four steps of https://learn.microsoft.com/en-us/azure/aks/dapr?tabs=cli article to update the azure kubernetes extension


# perform these commands from cloud shell or from command pallette
# cd to directory
terraform init -upgrade
terraform plan -out main.tfplan
terraform apply main.tfplan

# follow instructions in verify results section
# https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?tabs=bash&pivots=development-environment-azure-cli#verify-the-results


# follow remainder of this article after dapr init -kubernetes --wait
# https://github.com/diagrid-labs/dapr-on-aks?tab=readme-ov-file#2-setup-dapr-on-aks
