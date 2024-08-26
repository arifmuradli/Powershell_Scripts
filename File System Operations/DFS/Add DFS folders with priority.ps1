### Considering you have created DFS Namespace for BranchA:

New-DfsnFolder -Path '\\nameserver.domain.local\BranchA\Folder1'  -EnableTargetFailback $true  -TargetPath '\\fileserver-NODE01-P\BranchA\Folder1' -ReferralPriorityClass GlobalHigh -ReferralPriorityRank 0
New-DfsnFolderTarget -Path '\\nameserver.domain.local\BranchA\Folder1' -TargetPath '\\fileserver-NODE02-P\BranchA\Folder1'  -ReferralPriorityClass GlobalLow  -ReferralPriorityRank 5
