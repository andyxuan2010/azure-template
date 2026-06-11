# Code Standards

This is an attempt to codify standards for our terraform repo. (Or: when you code review, consider these things.)


## General

* Use terraform 0.12, preferably 0.12.6+
* We always should have at least three files: `inputs.tf` (for `variable`s), `ouputs.tf` (for `output`s) and a `main.tf` or `<module_name>.tf`
    - Terraform doesn’t care how you organize your code. (It builds an Acyclic Graph after looking into all `.tf` files, to determine what needs to be done and in which order) But humans, that will need to read and understand the code, do.
    - As in any programming language, organize your files according to “business needs”
        - It is way better to have 10 files with 40 lines each than 1 file with 400 lines
            - But don’t use this as a hard limit. If you need to have a 100+ lines file because it makes sense, so be it.
        - Remember that if you are repeating something too often, maybe it can become a module
* When defining a variable explicitly define its [type](https://www.terraform.io/docs/configuration/variables.html#type-constraints) (more type info [here](https://www.terraform.io/docs/configuration/types.html))
    - Finally (0.12) terraform has [rich-types](https://www.hashicorp.com/blog/terraform-0-12-rich-value-types)!
* If it's on AWS, when writing IAM policies prefer to use [IAM Policy Document](https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html) instead of heredocs (`<<EOF`)
    - This makes the code more readable and easier to diff (and less dependable on JSON)
* *Always* `terraform fmt` your code.
    * Ideally, validating that your code is formatted correctly should be the first step on a CI pipeline. And it should break if it is not.
    * As terraform is code, some linting tools like [tflint](https://github.com/wata727/tflint) exist and could be used on a pipeline
* Use [snake_case](https://en.wikipedia.org/wiki/Snake_case) for all names
    * Preferably for directory names too
    * Snake casing is the default for terraform names in resources/modules/data etc.

## Resources

* `variables.tf` and `providers.tf` are symlinks from `shared/variables.tf` and `shared/providers.tf`. For static global variables, we tend to put in variables.tf, rather dynamic variables are placed in providers.tf.
* Internal references are used wherever possible. (No hard-coded AWS entity strings!)
* Resources/modules are ordered “logically”, i.e. if you had to lay the system out linearly on a whiteboard, that’s the order things should exist in.
* Your resource should be able to be destroyed and recreated without multiple iterations. There are cases where this isn’t possible.
* Your resource should have a remote state file with a name that doesn’t clash with other resources
* Your resource should be aware of its external dependencies. (eg if you are setting up a set of ec2 instances, that depends on subnets and security groups and vpcs and so on…)
* `#ignore`’d resources are a bug. (`#ignore` is a flag used internally by our `terraform-diff` process)
* Any resource that holds data should have a lifecycle rule that disallow its deletion.
    - If the aws entity has an option for disabling deletion, that should also be enabled.

## Modules

* Use the ‘[description](https://www.terraform.io/docs/configuration/variables.html#input-variable-documentation)’ field in variables even if it seems obvious what the variable is for.
* Use variables and interpolation to simplify the task of using your module. Modules should contain all of the ‘implementation details’.
    - [`local` variables](https://www.terraform.io/docs/configuration/locals.html) should be used for internal logic/trickery/magic
* Use the power of open-source. Always take a look, at least for inspiration, on [Terraform's Registry](https://registry.terraform.io/) and [GitHub](github.com). There is always opportunity to learn there.
* Do not symlink to the shared/variables.tf in the module’s subfolder - if you need something, ask for it as a module variable without default value
* Emphasize YAGNI: Do not overcomplicate your module with features that might be necessary.
* Use modules to follow DRY principle.
* Write good documentation for your module, tools like [terraform-docs](https://github.com/segmentio/terraform-docs) and [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) make the basic documentation be automatically generated
* A module can use another module
    * BUT take care to not go too deep into the dependencies (up to 1 level of hierarchy is ok)
        * Using a module that do not depend on other modules is super ok (0 level)
        * Using a module that depends on another module is ok (1 level)
        * Using a module that depends on another module that depends on another module is not so ok (2 levels)
        * Using a module that depend on another module that depend on another module that depend on another module is not ok (3 levels)
    * Maybe, due to the usage of this other module, you’ll have to “export” this inner module variables
    * Not beautiful but sometimes necessary.
    * Example:
        - `M2` is the module responsible for finding AMIs
        - `M1` creates EC2 instances and uses `M2` to find the right AMI
        - `R` is a resource that needs one EC2 instance but needs to use a specific AMI (`ami_id`)
        - For this `ami_id` to flow from `R` to `M2`, `M1` will need to receive it, through its `variable`s, and pass it when it (`M1`) invokes `M2`. Even though `M1` has no knowledge about AMIs
    * The deeper you go, the harder it becomes to reference specific resources/modules
    * `terraform taint`, specifically, can get [confused](https://github.com/hashicorp/terraform/issues/12235)

## Importing existing resources

1. Write the terraform you want to define the system.
2. Import the live objects from AWS/Azure.
3. Modify the terraform to match the live objects, unless the terraform is more correct/better. (eg if you import an IAM role and it has something totally bad in it, use the terraform version.)

## Interpolation

* Avoid interpolation in resources, keep it in modules and keep it well away from anything a user needs to know/understand. (ie use it to support multiple variants of an aws object in the same module, like rds vs aurora)
    * Use features like [count](https://www.terraform.io/docs/configuration/resources.html#count-multiple-resource-instances-by-count)
    * Use new features like [for_each](https://www.terraform.io/docs/configuration/resources.html#for_each-multiple-resource-instances-defined-by-a-map-or-set-of-strings) and [dynamic blocks](https://www.terraform.io/docs/configuration/expressions.html#dynamic-blocks)

