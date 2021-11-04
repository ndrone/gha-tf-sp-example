# gha-tf-sp-example
A repository that shows how to do automated service principal password rotation 
with GitHub Actions

## Assumptions
* Knowledge of Terraform
* Knowledge of using Terraform with Azure
* Knowledge of GitHub Actions
* Knowledge of Bash Scripting

## File Structure

### main.tf
This file holds all the Azure resources built out by Terraform. The resource 
group and key vault are not required. It's only to show the storage of the 
service principal password and to show that when a terraform apply -replace is 
done that whatever is consuming the output of that resource is also updated. 
After the resource group and key vault are two service principals examples for 
this example.

### .github/workflows/apply.yml
This is used to create the resources needed for this example

### .github/workflows/rotate.yml
This is the workflow responsible for getting the resource addresses from the 
Terraform state file, iterating over that list, and looking for the resources 
`azuread_service_principal_password`. When finding this resource address, we 
want to have Terraform do a forcing replacement of the resource, causing the 
password to be changed.

expanded single line bash script
```
while read target; do 
	if [[ "${target:0:34}" == "azuread_service_principal_password" ]]; then 
		terraform apply -replace="$target" -input=false -no-color -auto-approve
	fi
done < stateList
```