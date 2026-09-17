# How to Destroy a Resource

## Background
Resources in terraform can be __tainted__ to rebuild the resource or they can be completely __destroyed__ (no longer brought back up).

## Pre-Requisites
1. Access to the devops box (or any VM instance running with the 'admin' IAM role)
2. A clone of this repository.
3. A branch of main.

## Checks before removing a resource

Before you remove a resource, you should check if the resource is being used still. Here's a few ways:

* Search in terraform to see if the resource is being called
* Search in terraform to see if the resource's hard coded values are being called (e.g. search by the resource's specific arn)

* Depending on the resource, check logs, last accessed for keys, CPU usage, etc.
* If your resource has a `lifecycle` with `prevent_destroy = true`, I would recommend getting another set of eyes just to be sure you want the resource destroyed

## Steps
### Go to your resource's directory
In your branch...

1. `cd terraform/myresource`
2. `terraform refresh`

### Taint or Destroy

If you want to [taint](https://www.terraform.io/docs/commands/taint.html) a resource, this would cause the resource to be destroyed and then be recreated on the next apply.
If you want to [destroy](https://www.terraform.io/docs/commands/destroy.html) a resource, this would remove the resource.

#### Taint

An example taint would look like:

* `terraform taint -module=docker-app.docker-worker.ec2-instance aws_instance.instance`
* `terraform plan -out=plan`
* Double check this is the resource(s) you expect to remove (see above 'Checks before removing a resource')
* `terraform apply plan`

#### Destroy

An example destroy of everything in a directory would look like:

* `terraform plan -destroy -out plan`
* Double check this is the resource you expect to remove (see above 'Checks before removing a resource')
* `terraform apply plan`

