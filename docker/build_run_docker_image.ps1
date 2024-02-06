# PowerShell - Build and run a Docker image :)
# Parameters: source directory, image name, port number (optional)

param (
  [string]$sourceDir,
  [string]$imageName,
  [string]$portNumber
)

# Help message
if ($sourceDir -eq $null -or $imageName -eq $null -or $sourceDir -eq "-h" -or $sourceDir -eq "--help") {
  Write-Host "Build and run a Docker image"
  Write-Host "Usage: build_run_image.ps1 -sourceDir <source directory> -imageName <image name> [-portNumber <port number>]"
  exit 0
}

# Save the current directory to later return to it
$PSScriptRoot = $PWD

# Build the project using Maven
Set-Location $sourceDir
mvn clean package
if ($LASTEXITCODE -ne 0) {
  Write-Error "Maven build failed. Exiting script."
  exit 1
}

# Create the Docker image
docker build -t $imageName .
if ($LASTEXITCODE -ne 0) {
  Write-Error "Docker image creation failed. Exiting script."
  exit 1
}

# And run it
if ($portNumber) {
  docker run -p ${portNumber}:${portNumber} $imageName
} else {
  docker run $imageName
}

# Return to the original directory
Set-Location $PSScriptRoot
