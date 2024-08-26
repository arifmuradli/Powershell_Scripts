# 1. Disable inheritance but keep existing permissions as explicit permissions
# 2. Add group based permissions: PermissionGroup_XXX_Folder1_W is modify right group, PermissionGroup_XXX_Folder1_R is readonly group



# Define the folder path
$Folder1 = "D:\BRANCHA\Folder1_XXX"

# Get the current ACL of the folder
$aclFolder1 = Get-Acl -Path $Folder1

# Disable inheritance but keep existing permissions as explicit permissions
$aclFolder1.SetAccessRuleProtection($true, $true) # Disable inheritance and convert inherited permissions to explicit

# Apply the updated ACL
Set-Acl -Path $Folder1 -AclObject $aclFolder1

Write-Output "Inheritance disabled and inherited permissions converted to explicit permissions for $folderPath."
# Define the folder path and group permissions

# Define groups and permissions
$modifyGroupFolder1 = "domain\PermissionGroup_XXX_Folder1_W"
$readonlyGroupFolder1 = "domain\PermissionGroup_XXX_Folder1_R"

# Define access rules
$modifyRuleFolder1 = New-Object System.Security.AccessControl.FileSystemAccessRule($modifyGroupFolder1, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$readonlyRuleFolder1 = New-Object System.Security.AccessControl.FileSystemAccessRule($readonlyGroupFolder1, "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")

# Get the current ACL of the folder
$acl = Get-Acl -Path $Folder1

# Add access rules
$acl.AddAccessRule($modifyRuleFolder1)
$acl.AddAccessRule($readonlyRuleFolder1)

# Apply the updated ACL
Set-Acl -Path $Folder1 -AclObject $acl

Write-Output "Permissions added for groups $modifyGroup and $readonlyGroup on $folderPath."


Write-Output "Permissions added for groups $modifyGroup and $readonlyGroup on $folderPath."
