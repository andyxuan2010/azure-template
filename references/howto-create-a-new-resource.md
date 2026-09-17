# How to Create a New Resource

## Background
We use resources in terraform to separate logical chunks of our infrastructure.
TBD

### Exceptions
In order to avoid circular dependencies, some lower-level infrastructure components live in their own resources rather than in the resource that "owns" the component. Subnets, Security Groups, and DNS are examples of components that are in 'global' resources that manage all of that type of component in our infrastructure.

## Pre-Requisites
1. Access to the devops box (or any vm instance running with the 'admin' IAM role)
1. A clone of this repository.
1. A branch of main.

## Steps
### Set up your resource's directory
In your branch...
TBD

### Edit terraform.tf
1. Change %RESOURCE_NAME% to whatever you named the directory you made for your new resource.
1. Add the relevant terraform configurations.
1. Validate via the standard `terraform plan` steps as [documented here](../README.md)
1. Commit and push to your branch.
1. Create a pull request.
