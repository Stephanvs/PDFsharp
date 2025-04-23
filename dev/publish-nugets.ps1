try {
    "nuget packages to publish:"
	dir *.nupkg

	$pkgFiles = Get-ChildItem -Recurse -Path *.nupkg -ErrorAction SilentlyContinue

	if (-not $pkgFiles) {
		throw "No .nupkg files found in the current directory."
	}

	if (-not $env:NEXUS_API_KEY) {
		throw "The environment variable NEXUS_API_KEY is not set."
	}

	Write-Host "Nuget package version to publish: $version"
	dotnet nuget push *.nupkg --api-key $env:NEXUS_API_KEY --source https://nlib-tf.prosim-ar.eu/repository/nuget-hosted/;

	if ($LASTEXITCODE -ne 0) {
	  throw "ERROR Terminating with error " + $LASTEXITCODE
	}
}
Catch {
    # Get the current error
	$ErrorMessage = $_

	# Write a message to stdout to let TeamCity know that the script failed.
	# The exit code is not returned properly to TeamCity due to issues with invoking
	# PowerShell script files using -File
	# Observe that this message is written with Write-Host rather than Write-Error,
	# to make sure the message is written to stdout rather than stderr
	Write-Host "##teamcity[message text='$ErrorMessage' status='FAILURE']"

	Write-Error -Message $ErrorMessage

	exit 1
}
