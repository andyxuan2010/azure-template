# Cloud Resource Naming Convention

## Background

Naming things is hard. Finding resources in the AWS console is harder.

Let's solve the harder problem by doing the hard thing and come up with an easy to follow naming convention for our AWS resources going forward.

## Proposed convention for AWS environment

### Implemetation Notes

#### Making Use of the **Name** Tag

- We can utilize the **Name** tag to optionally provide a name for our resources(the resources ID is the only identifier that really matters ). Doing so creates a tag with a key of `Name` and the value that we can specify.

- According to AWS's [tagging restrictions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html#tag-restrictions), we have a maximum key length of 128 Unicode characters and a maximum value length of 256 Unicode characters (both in UTF-8). According to Azure's [tagging restrictions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources), we have a maximum key length of 512 characters and a maximum value length of 256 characters (both in UTF-8). For storage accounts, the tag name has a limit of 128 characters and the tag value has a limit of 256 characters.
- Although EC2 allows for any character in its tags, other services are more restrictive. The allowed characters across services are: **letters, numbers, and spaces representable in UTF-8, and the following characters: + - = . _ : / @**.
- Tag keys and values are *case-sensitive*.
- The tags we assign are available only to your AWS account and not to the other accounts sharing the resource.

#### Restrictive Resource Names

Different resources in AWS/Azure, such as S3 buckets, lambdas and IAM roles, have different maximum lengths and different character sets which they accept.

Following the advice of [this answer](https://stackoverflow.com/questions/46052869/what-are-the-most-restrictive-aws-resource-name-limitations-e-g-characters-and) on Stackoverflow, we should utilize the most restrictive convention for any name that AWS/Azure requires when creating a resource:

- Only lowercase alphanumeric characters and hyphens.
- **Minimum of 3 characters and maximum of 32**.
  - [AWS Target Groups](https://docs.aws.amazon.com/cli/latest/reference/elbv2/create-target-group.html#options) and [Elastic Load Balancers](https://docs.aws.amazon.com/cli/latest/reference/elb/create-load-balancer.html#options) and  are limited to 32 characters in their names
- First character must be a letter, cannot end with a hyphen or contain two consecutive hyphens.

### Minimum information needed

At the very least, we'll want the following information made available in a resource's name:

1. The owner of the resource

   This can be one of:

   - The **service** associated with the resource
   - The intended **purpose** (for ACLs and Security Groups)

2. The environment that the resource is associated (if any)

   - Environment should be **one** of production, demo, or staging
   - Production can be truncated to "prod" to save characters

3. Abbreviated Region (e.g. `ue1` for us-east-1)

4. The availability zone should also be included in the resource name for resources in multiple availability zones

5. For ACLs, Security Groups, and Subnets:

   - The word "internal" can be abbreviated as `int` in ACLs and Security Groups
   - The word "external" can be abbreviated as `ext` in ACLs and Security Groups
   - We should spell out out the words "private" and "public"

6. Abreviated resource type (e.g. `sg` for security group)

   - We should spell out `instance` and `subnet` and other words that would be confusing to abbreviate

### Format

Going forward, we prefer our resource names to be formatted following these guidelines:

- Do not use whitespace characters
- Concatenate name parameters with a hyphen (`-`)
- Only lowercase alphanumeric characters and hyphens.
- Minimum of 3 characters and maximum of 32
- First character must be a letter, cannot end with a hyphen or contain two consecutive hyphens.

### Order

In an effort to format resource names in a way that _quickly_ provides the information that humans care about, we've order the components in a resource name to have the owner/purpose first, then environment and region, followed by the resource type:

```
<service/purpose>-<environment>-<region_abbreviation>-<resource_type_abbreviation>
```

## Examples by Resource Type

Given, for example, a service called `windbreaker` created by the `outerwear` application team, here's how you would name resources in the `demo` environment in the `us-west-2` region:

### VPC Resource Naming Standards

| Resource Type    | Resource Name                                                | Comment                                                      | Example Resource Name                       |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------- |
| VPC              | {{service}}-{{environment}}-{{region}}-vpc<br />or<br />{{service}}-{{environment}}-{{region}}-vpc |                                                              | `windbreaker`-demo-uw2-vpc`                 |
| Security Group   | {{service}}-environment-{{ext\|int}}-{{purpose}}-{{ResourceName}}-sg | ResourceName should be one of:<br />• elb<br />• instance<br />• db | `windbreaker-demo-int-postgres-instance-sg` |
| Subnet           | {{service}}-{{environment}}-{{region}}-{{routeType}}-{{subnetType}}-{{az}}-subnet | Subnet Type should be one of:<br />• app<br />• elb<br />• data<br />• db<br />• cache<br />• nat<br />• web | `windbreaker-demo-uw2-private-db-2a-subnet` |
| VPC Peering Link | {{service}}-{{environment}}-{{region}}-vpc-peerlink          | The items to be written should be that of the **remote** end of the VPC Peering Link | `windbreaker`-demo-ue1-vpc-peerlink`        |
| Route Tables     | {{service}}-{{environment}}-{{region}}-{{routeType}}-rt      | Route type is one of the following:<br />• public<br />• private<br />If the route table is distinct for each AZ (e.g. you are routing to different NATs), you must add the Zone (e.g 1a, 1b, 1c, 1d, 1e) | `windbreaker`-demo-uw2-private-rt`          |



### RDS Resource Naming Standards

| Resource Type                  | Resource Name                                                | Comment                                                      | Example Resource Name                   |
| ------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | --------------------------------------- |
| RDS (Cluster Name)             | {{service}}-{{environment}}-{{region}}-{{engine}}{{version}} | Version is the version of the engine                         | `windbreaker-demo-uw2-aurora-mysql57`   |
| RDS (DB Cluster Instance Name) | {{service}}-{{environment}}-{{region}}-{{engine}}{{version}}-{{number}} | Engine should be one of the following:<br />• aurora<br />• aurora-mysql <br />• aurora-postgresql<br /><br /><br />If multiple are needed, increment number. | `windbreaker-demo-uw2-aurora-mysq57l-1` |



### ElastiCache Resource Naming Standards

We are purposefully violating our [Restrictive Resource Names policy](#restrictive-resource-names) in the case of ElastiCache for the sake of clarity. Also, Amazon ElastiCache [now supports up to 50 characters in cluster name](https://aws.amazon.com/about-aws/whats-new/2019/08/elasticache_supports_50_chars_cluster_name/). Identifiers must begin with a letter. They must contain only ASCII letters, digits, and hyphens, and must not end with a hyphen or contain two consecutive hyphens.

#### Service's with a single cluster

| Resource Type                             | Resource Name                                                | Comment                                                      | Example Resource Name                |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------ |
| ElastiCache (Cluster Name)                | {{service}}-{{environment}}-{{region}}-{{engine}}-{{unique_id}} | Version is the version of the engine                         | `windbreaker-demo-uw2-random123`     |
| ElastiCache (Cache Cluster Instance Name) | {{service}}-{{environment}}-{{region}}-{{engine}}-{{unique_id}}-{{number}} | Engine should be one of the following:<br />• redis<br />• memcached <br /><br /><br />If multiple are needed, increment number. | `windbreaker-demo-uw2-random123-001` |

#### Service's with multiple clusters

Service's with multiple ElastiCache clusters should include the purpose of the cluster in the resource name.

| Resource Type                             | Resource Name                                                | Comment                                                      | Example Resource Name                                      |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------------------- |
| ElastiCache (Cluster Name)                | {{service}}-{{environment}}-{{region}}-{{engine}}-{{purpose}}--{{unique_id}} | Version is the version of the engine                         | `windbreaker-demo-uw2-3rd-party-api-limiter-random123`     |
| ElastiCache (Cache Cluster Instance Name) | {{service}}-{{environment}}-{{region}}-{{engine}}-{{purpose}}-{{unique_id}}-{{number}} | Engine should be one of the following:<br />• redis<br />• memcached <br /><br /><br />If multiple are needed, increment number. | `windbreaker-demo-uw2-3rd-party-api-limiter-random123-001` |



## Proposed convention for Azure environment

### Implemetation Notes

#### Making Use of the **Name** Tag

- We can utilize the **Name** tag to optionally provide a name for our resources(the resources ID is the only identifier that really matters ). Doing so creates a tag with a key of `Name` and the value that we can specify.

-  According to Azure's [tagging restrictions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources), we have a maximum key length of 512 characters and a maximum value length of 256 characters (both in UTF-8). For storage accounts, the tag name has a limit of 128 characters and the tag value has a limit of 256 characters.
- Although VM allows for any character in its tags, other services are more restrictive. The allowed characters across services are: **letters, numbers, and spaces representable in UTF-8, and the following characters: + - = . _ : / @**.
- Tag keys and values are *case-sensitive*.
- The tags we assign are available only to your AWS account and not to the other accounts sharing the resource.

#### Restrictive Resource Names

Different resources in Azure, such as storage account, have different maximum lengths and different character sets which they accept.

Following the advice of [this answer](https://stackoverflow.com/questions/46052869/what-are-the-most-restrictive-aws-resource-name-limitations-e-g-characters-and) on Stackoverflow, we should utilize the most restrictive convention for any name that Azure requires when creating a resource:

- First character must be a letter, cannot end with a hyphen or contain two consecutive hyphens.

### Minimum information needed

At the very least, we'll want the following information made available in a resource's name:

1. The owner of the resource

   This can be one of:

   - The **service** associated with the resource
   - The intended **purpose** (for ACLs and Security Groups)

2. The environment that the resource is associated (if any)

   - Environment should be **one** of production, demo, or staging
   - Production can be truncated to "prod" to save characters

3. Abbreviated Region (e.g. `ue1` for us-east-1)

4. The availability zone should also be included in the resource name for resources in multiple availability zones

5. For ACLs, Security Groups, and Subnets:

   - The word "internal" can be abbreviated as `int` in ACLs and Security Groups
   - The word "external" can be abbreviated as `ext` in ACLs and Security Groups
   - We should spell out out the words "private" and "public"

6. Abreviated resource type (e.g. `sg` for security group)

   - We should spell out `instance` and `subnet` and other words that would be confusing to abbreviate

### Format

Going forward, we prefer our resource names to be formatted following these guidelines:

- Do not use whitespace characters
- Concatenate name parameters with a hyphen (`-`)
- Only lowercase alphanumeric characters and hyphens.
- Minimum of 3 characters and maximum of 32
- First character must be a letter, cannot end with a hyphen or contain two consecutive hyphens.

### Order

In an effort to format resource names in a way that _quickly_ provides the information that humans care about, we've order the components in a resource name to have the owner/purpose first, then environment and region, followed by the resource type:

```
<service/purpose>-<environment>-<region_abbreviation>-<resource_type_abbreviation>
```

## Examples by Resource Type

Given, for example, a service called `windbreaker` created by the `outerwear` application team, here's how you would name resources in the `demo` environment in the `us-west-2` region:

### VPC Resource Naming Standards

| Resource Type    | Resource Name                                                | Comment                                                      | Example Resource Name                       |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------- |
| VPC              | {{service}}-{{environment}}-{{region}}-vpc<br />or<br />{{service}}-{{environment}}-{{region}}-vpc |                                                              | `windbreaker`-demo-uw2-vpc`                 |
| Security Group   | {{service}}-environment-{{ext\|int}}-{{purpose}}-{{ResourceName}}-sg | ResourceName should be one of:<br />• elb<br />• instance<br />• db | `windbreaker-demo-int-postgres-instance-sg` |
| Subnet           | {{service}}-{{environment}}-{{region}}-{{routeType}}-{{subnetType}}-{{az}}-subnet | Subnet Type should be one of:<br />• app<br />• elb<br />• data<br />• db<br />• cache<br />• nat<br />• web | `windbreaker-demo-uw2-private-db-2a-subnet` |
| VPC Peering Link | {{service}}-{{environment}}-{{region}}-vpc-peerlink          | The items to be written should be that of the **remote** end of the VPC Peering Link | `windbreaker`-demo-ue1-vpc-peerlink`        |
| Route Tables     | {{service}}-{{environment}}-{{region}}-{{routeType}}-rt      | Route type is one of the following:<br />• public<br />• private<br />If the route table is distinct for each AZ (e.g. you are routing to different NATs), you must add the Zone (e.g 1a, 1b, 1c, 1d, 1e) | `windbreaker`-demo-uw2-private-rt`          |




## some Terraform Naming Conventions in practice

### For Terraform Variable Names Use underscores (_)
exampe:
```
variable "app_sqlmi" {  # ✅ Underscore is Terraform-compliant
  type = string
}
```

### For Terraform Resource Names (resource "<type>" "<name>" {}) Use underscores (_)
example:
```
resource "azurerm_sql_managed_instance" "app_sqlmi" {  # ✅ Uses underscore
  name = "app-sqlmi"  # Hyphen allowed in Azure name fields
}
```

###  For Resource Names, Tags, and Resource Group Names Use hyphens (-)
example:
```
resource "azurerm_sql_managed_instance" "app_sqlmi" {
  name = "app-sqlmi"  # ✅ Hyphen is best practice for Azure resource names
}
```


