# tf-mod-azure-terraform-state-container

Terraform module to manage terraform state containers in Azure

## Resources

Where possible the resources are declared with `lifecycle.prevent_destroy = true` to prevent accidental deletion of resources.

The module creates the following resource types in Azure:

| Resource type                | Example name                             | Tags |
| ---------------------------- | ---------------------------------------- | ---- |
| Resource group               | `rg2-ss1-my-first-web-app-terraform-dev` | X    |
| Storage account              | `strg2ss1mwatfdev`                       | X    |
| Storage account network rule | -                                        | -    |
| Storage container            | `terraform-remote-backend-state`         | -    |

**Note:** Example names are based on the [basic example](#basic-example) further down.

### Tags

The resource are tagged as follows:

| Tag             | Value                                                          |
| --------------- | -------------------------------------------------------------- |
| ApplicationName | `var.application_name`                                         |
| CreatedBy       | `var.created_by_tag`                                           |
| Environment     | `var.environment_name`                                         |
| Description     | Hardcoded with `var.application_friendly_description` appended |

## Usage

### Basic example

Example with minimum set of input parameters.

```terraform
provider "azurerm" {
  features {}
}
module "terraform_state_container" {
  source = "git@github.com:dsb-norge/tf-mod-azure-terraform-state-container.git?ref=v0"

  # minimum information necessary
  subscription_number              = 1
  environment_name                 = "dev"
  application_name                 = "my-web-first-app"
  application_name_short           = "mwa" # for storage account name
  application_friendly_description = "the first web app"
  created_by_tag                   = "Person or code repo"
}
```

### Full example

Example with all possible set of input parameters.

```terraform
provider "azurerm" {
  features {}
}
module "terraform_state_container" {
  source = "git@github.com:dsb-norge/tf-mod-azure-terraform-state-container.git?ref=v0"

  # minimum information necessary
  subscription_number              = 1
  environment_name                 = "dev"
  application_name                 = "my-web-first-app"
  application_name_short           = "mwa" # for storage account name
  application_friendly_description = "the first web app"
  created_by_tag                   = "Person or code repo"

  # optional parameters and their defaults
  azure_region         = "norwayeast"
  state_container_name = "terraform-remote-backend-state"
  network_rules = {
    default_action             = "Deny"
    bypass                     = null
    ip_rules                   = ["91.229.21.0/24"] # allow only DSB public IPs
    virtual_network_subnet_ids = null
  }
}
```

## Development

### Validate your code

```shell
  # Init project, run fmt and validate
  terraform init -reconfigure
  terraform fmt -check -recursive
  terraform validate

  # Lint with TFLint, calling script from https://github.com/dsb-norge/terraform-tflint-wrappers
  alias lint='curl -s https://raw.githubusercontent.com/dsb-norge/terraform-tflint-wrappers/main/tflint_linux.sh | bash -s --'
  lint

```

### Generate and inject terraform-docs in README.md

```shell
# go1.17+
go install github.com/terraform-docs/terraform-docs@v0.18.0
export PATH=$PATH:$(go env GOPATH)/bin
terraform-docs markdown table --output-file README.md .
```

### Release

After merge of PR to main use tags to release.

Use semantic versioning, see [semver.org](https://semver.org/). Always push tags and add tag annotations.

#### Patch release

Example of patch release `v1.0.1`:

```bash
git checkout origin/main
git pull origin main
git tag --sort=-creatordate | head -n 5 # review latest release tag to determine which is the next one
git log v1..HEAD --pretty=format:"%s"   # output changes since last release
git tag -a 'v1.0.1'  # add patch tag, add change description
git tag -f -a 'v1.0' # move the minor tag, amend the change description
git tag -f -a 'v1'   # move the major tag, amend the change description
git push origin 'refs/tags/v1.0.1'  # push the new tag
git push -f origin 'refs/tags/v1.0' # force push moved tags
git push -f origin 'refs/tags/v1'   # force push moved tags
```

#### Major release

Same as patch release except that the major version tag is a new one. I.e. we do not need to force tag/push.

Example of major release `v2.0.0`:

```bash
git checkout origin/main
git pull origin main
git tag --sort=-creatordate | head -n 5 # review latest release tag to determine which is the next one
git log v1..HEAD --pretty=format:"%s"   # output changes since last release
git tag -a 'v2.0.0'  # add patch tag, add your change description
git tag -a 'v2.0'    # add minor tag, add your change description
git tag -a 'v0'      # add major tag, add your change description
git push --tags      # push the new tags
```

**Note:** If you are having problems pulling main after a release, try to force fetch the tags: `git fetch --tags -f`.

## terraform-docs

<!-- BEGIN_TF_DOCS -->



```hcl
locals {
  application_name_full             = "${var.application_name}-terraform"
  application_name_short_full       = "${var.application_name_short}-tf"
  application_name_short_full_alnum = join("", regexall("[[:alnum:]]", local.application_name_short_full))
  environment_name_alnum            = join("", regexall("[[:alnum:]]", var.environment_name))
  resource_group_name               = "rg-ss${var.subscription_number}-${local.application_name_full}-${var.environment_name}"
  storage_account_name              = lower(substr("stss${var.subscription_number}${local.application_name_short_full_alnum}${local.environment_name_alnum}", 0, 24))
  common_tags = {
    ApplicationName = var.application_name
    CreatedBy       = var.created_by_tag
    Environment     = var.environment_name
  }

  # For more information about DSB mandatory tags see confluence page : https://dsbno.atlassian.net/wiki/spaces/DSBTB/pages/2391179644/Bruk+av+tags
  rg_mandatory_tags = {
    costCenter = var.costcenter_tag_value # defaut set to IKT
    #TODO: Uncomment the following lines when the systemId tag is available
    #    systemId   = var.systemid_tag
  }
}
resource "azurerm_resource_group" "tfstate" {
  location = var.azure_region
  name     = local.resource_group_name
  tags = merge(local.common_tags, local.rg_mandatory_tags, {
    Description = "Resource group with terraform backend state for ${var.application_friendly_description}."
  })

  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_storage_account" "tfstate" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.azure_region
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  tags = merge(local.common_tags, {
    Description = "Storage account with terraform backend state for ${var.application_friendly_description}."
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
    prevent_destroy = true
  }
}
resource "azurerm_storage_account_network_rules" "tfstate" {
  count = var.network_rules != null ? 1 : 0

  default_action             = var.network_rules.default_action
  storage_account_id         = azurerm_storage_account.tfstate.id
  bypass                     = var.network_rules.bypass
  ip_rules                   = var.network_rules.ip_rules
  virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
  # tags not supported
}
resource "azurerm_storage_container" "tfstate" {
  name                  = var.state_container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
  # tags not supported
  lifecycle {
    prevent_destroy = true
  }
}
```
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | The ID of the storage container created for terraform backend state. |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the storage container created for terraform backend state. |
| <a name="output_container_resource_manager_id"></a> [container\_resource\_manager\_id](#output\_container\_resource\_manager\_id) | The Resource Manager ID of the storage container created for terraform backend state. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group created for terraform backend state. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the storage account created for terraform backend state. |
<!-- END_TF_DOCS -->