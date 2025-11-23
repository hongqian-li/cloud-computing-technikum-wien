"""An Azure RM Python Pulumi program"""

import pulumi
from pulumi_azure_native import storage
from pulumi_azure_native import resources

# load configuration
config = pulumi.Config("pulumi-assignment-02")
storage_account_name = config.require("storageAccountName")
storage_sku = config.require("storageSku")

# global location from azure-native provider
location = pulumi.Config("azure-native").require("location")

# Create an Azure Resource Group
resource_group = resources.ResourceGroup("resource_group")
#resource_group = resources.ResourceGroup(
#    "resource_group",
#    resource_group_name="my-rg-pulumi-demo"  # <-- if you want to specify a name
#)

# Create an Azure resource (Storage Account)
account = storage.StorageAccount(
    "storage_account",
    resource_group_name=resource_group.name,
    location=resource_group.location,
    account_name=storage_account_name,
    sku=storage.SkuArgs(name=storage_sku),
    kind=storage.Kind.STORAGE_V2,
)

# Export the primary key of the Storage Account
primary_key = (
    pulumi.Output.all(resource_group.name, account.name)
    .apply(
        lambda args: storage.list_storage_account_keys(
            resource_group_name=args[0], account_name=args[1]
        )
    )
    .apply(lambda accountKeys: accountKeys.keys[0].value)
)

pulumi.export("primary_storage_key", primary_key)
