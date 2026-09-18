# Conventions For Tagging AWS Resources

## Background

Amazon Web Services (AWS) allows customers to assign metadata to their AWS resources in the form of *tags*. Each tag is a simple label consisting of a customer-defined key and an optional value that can make it easier to manage, search for, and filter resources. Although there are no inherent types of tags, they enable customers to categorize resources by purpose, owner, environment, or other criteria.

## General Best Practices

In creating Gusto's tagging strategy for AWS resources, we want to make sure that we accurately represent organizationally relevant dimensions. To that end, the infrastructure team recommends we follow tagging best practices:

- Always use a standardized, case-sensitive format for tags, and implement it consistently across **_all_** resource types.
- Consider tag dimensions that support the ability to manage resource access control, cost tracking, automation, and organization.
- Implement automated tools to help manage resource tags. The [Resource Groups Tagging API](http://docs.aws.amazon.com/resourcegroupstagging/latest/APIReference/Welcome.html) enables programmatic control of tags, making it easier to automatically manage, search, and filter tags and resources. It also simplifies backups of tag data across all supported services with a single API call per AWS Region.
- Err on the side of using too many tags rather than too few tags. (But be aware of [AWS's tag restrictions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html#tag-restrictions) – **the maximum number of tags per resource is 50**.)
- Remember that it is easy to modify tags to accommodate changing business requirements, however consider the ramifications of future changes, especially in relation to tag-based access control, automation, or upstream billing reports.

## Resource Tags That We Care About

Here is a minimal list of AWS tags that we should be sure to tag each resource with:

| AWS Tag       | Allowed Values                                               | Comment                                                      |
| ------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `App`         |                                                              | The name of the service running on compute resources or that will be consuming the resource |
| `Environment` | `Environment` should be one of:<br/>• `production` <br/>• `staging` <br/>• `demo` <br/>• `pentest` <br/>• `development` | • `stag`, `prod`, etc are deprecated and should be updated to the allowed values. |
| `Team`        |                                                              | • This should be the name of the team, product line, or mission associated with the resource<br />• This can be `infrastructure` in the generic case |
| `name`        |                                                              | Please follow the [AWS resource naming convention](./aws-naming-convention.md) |
| `region`      |                                                              | • We should use the full region name rather than abbreviation (e.g use `us-east-1` and _not_ `ue1`)<br />• Use the value `global` to denote resources that do not require a region selection |
