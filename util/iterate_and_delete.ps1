# Powershell - iterate over files in a directory and delete or move them
# Usage: iterate_and_delete.ps1 -directory <directory> [-moveDirectory <move directory>]

param(
    [string]$directory,
    [string]$moveDirectory
)

# Help message
if ($directory -eq $null -or $directory -eq "-h" -or $directory -eq "--help") {
    Write-Host "Iterate over files in a directory and delete or move them"
    Write-Host "Usage: iterate_and_delete.ps1 -directory <directory> [-moveDirectory <move directory>]"
    exit 0
}

$filesToDelete = @()
$filesToMove = @()
$spaceReclaimed = 0

Set-Location $directory

# Iterate over files and let user decide if to mark file for deletion or to be moved and  move the path to a list
Get-ChildItem $directory -File |
ForEach-Object {

    $currentFile = $_

    $Title = "File: " + $currentFile.Name + " (" + $currentFile.Length + " bytes)" + " " + $currentFile.LastWriteTime
    $Prompt = "Delete, move, or skip? (d/m/s): "
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&d", "&m", "&s")
    $Default = 2

    $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

    switch($Choice)
    {
        0 {
            $filesToDelete += $currentFile.Name
            Write-Host "File marked for deletion: ", $currentFile.Name
            $spaceReclaimed += $_.Length
        }
        1 {
            $filesToMove += $currentFile.Name
            Write-Host "File marked for move: ", $currentFile.Name
        }
        2 {
            # Do nothing since that case is handled in the default case
        }
        $Default {
            Write-Host "Skipping file."
        }
    }
}

# Display all files that will be deleted
if ($filesToDelete.Count -gt 0) {
    Write-Host ""
    Write-Host "Files to delete:"
    foreach ($file in $filesToDelete) {
        Write-Host $file
    }
}

# Ask for confirmation
    # Otherwise, exit the script and make no changes
# If there is no files to delete, skip this step
if ($filesToDelete.Count -gt 0) {
    $Title = "Deleting {0} files" -f $filesToDelete.Count
    $Prompt = "Are you sure you want to delete these files? (y/n): "
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&y", "&n")
    $Default = 1

    # Prompt for the choice
    $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

    # Action based on the choice
    switch($Choice)
    {
        0 {
            # Delete files
            foreach ($file in $filesToDelete) {
                Write-Host "Deleting file: ", $file
                Remove-Item $file
            }

            # List the reclaimed space
            $spaceReclaimedInMB = $spaceReclaimed / 1MB
            Write-Host "Space reclaimed: $spaceReclaimedInMB MB ($spaceReclaimed bytes)"
        }
        1 {
            # Do nothing
        }
        $Default {
            # Invalid choice
            Write-Host "Files not deleted."
        }
    }

}

# Display all files that will be moved
if ($filesToMove.Count -gt 0) {
    Write-Host ""
    Write-Host "Files to move:"
    foreach ($file in $filesToMove) {
        Write-Host $file
    }
}

# Ask for confirmation
    # Otherwise, exit the script and make no changes
if ($filesToMove.Count -gt 0) {
    $Title = "Moving {0} files" -f $filesToMove.Count
    $Prompt = "Are you sure you want to move these files? (y/n): "
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&y", "&n")
    $Default = 1

    $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

    switch($Choice)
    {
        0 {
            foreach ($file in $filesToMove) {
                Move-Item -Path $file -Destination $moveDirectory
            }
        }
        1 {
            # Do nothing, since that case is handled in the default case
        }
        $Default {
            Write-Host "Files not moved."
        }
    }
}

Set-Location $PSScriptRoot