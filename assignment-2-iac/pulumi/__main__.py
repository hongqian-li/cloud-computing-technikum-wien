"""
Assignment 2: Infrastructure as Code with Pulumi
Provisions Azure Resource Group and Storage Account
Course: Cloud Computing - UAS Technikum Wien
"""

import pulumi
from pulumi_azure_native import storage, resources

# ============================================
# Configuration
# ============================================

config = pulumi.Config()

# Get configuration values with defaults
storage_account_name = config.get("storageAccountName") or "stassignment2pulumi"
storage_sku = config.get("storageSku") or "Standard_ZRS"
resource_group_name = config.get("resourceGroupName") or "rg-assignment2-pulumi"

# Get Azure location from provider config
azure_config = pulumi.Config("azure-native")
location = azure_config.get("location") or "norwayeast"

# Common tags for all resources
common_tags = {
    "Environment": "Development",
    "Assignment": "2-IaC",
    "ManagedBy": "Pulumi",
    "Course": "Cloud-Computing",
    "Tool": "Pulumi-Python"
}

# ============================================
# Resources
# ============================================

# Create Azure Resource Group
resource_group = resources.ResourceGroup(
    "assignment2_resource_group",
    resource_group_name=resource_group_name,
    location=location,
    tags=common_tags
)

# Create Azure Storage Account with security settings
storage_account = storage.StorageAccount(
    "assignment2_storage_account",
    resource_group_name=resource_group.name,
    location=resource_group.location,
    account_name=storage_account_name,
    sku=storage.SkuArgs(
        name=storage_sku
    ),
    kind=storage.Kind.STORAGE_V2,
    
    # Security settings
    minimum_tls_version=storage.MinimumTlsVersion.TLS1_2,
    allow_blob_public_access=False,
    enable_https_traffic_only=True,
    
    tags={
        **common_tags,
        "Purpose": "Assignment 2 Storage"
    }
)

# ============================================
# Retrieve Storage Account Keys
# ============================================

primary_key = pulumi.Output.all(
    resource_group.name,
    storage_account.name
).apply(
    lambda args: storage.list_storage_account_keys(
        resource_group_name=args[0],
        account_name=args[1]
    )
).apply(
    lambda keys: keys.keys[0].value
)

# ============================================
# Exports (Outputs)
# ============================================

pulumi.export("resource_group_name", resource_group.name)
pulumi.export("resource_group_id", resource_group.id)
pulumi.export("resource_group_location", resource_group.location)

pulumi.export("storage_account_name", storage_account.name)
pulumi.export("storage_account_id", storage_account.id)
pulumi.export("storage_account_primary_location", storage_account.primary_location)

pulumi.export(
    "storage_account_primary_blob_endpoint",
    storage_account.primary_endpoints.apply(lambda ep: ep.blob)
)

pulumi.export("primary_storage_key", pulumi.Output.secret(primary_key))

pulumi.export("configuration", {
    "location": location,
    "sku": storage_sku,
    "resource_group": resource_group_name,
    "storage_account": storage_account_name
})