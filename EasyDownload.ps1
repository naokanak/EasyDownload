# This sample script downloads poweroff vApps in vCloud Air to local 
# It requires powercli, ovftool to be installed on the system  

Function LocalPath() {
	##########
	#Check local path for download
	##########
	Write-Host "Please specify Local Directory for downlaod" -foregroundcolor black  -backgroundcolor yellow
	$script:DownloadPath = Read-Host "Directory"
	While (1){
		if (test-path $DownloadPath){
			break;
		}
		Write-Host "The Path doesn't exist. Please enter again" -foregroundcolor black  -backgroundcolor yellow
		$DownloadPath = Read-Host "Directory"
	}
}

Function ConnectVCHS {
	##########
	# Connect vCloud Air Dedicated/VPC
	##########
	Write-Host "Please specify "User Name" and "Password" to connect Source Env" -foregroundcolor black  -backgroundcolor yellow
	$script:SourceUser = Read-Host "User Name"
	$SourcePass = Read-Host "Password" -AsSecureString

	$p = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SourcePass)
	$script:SourcePlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($p)

	try {
		disconnect-piserver * -Force -Confirm:$false -ErrorAction "silentlycontinue"
	}
	catch{
	}
	While (1){
		if (Connect-PIServer -user $SourceUser -password $SourcePlain -ErrorAction SilentlyContinue){
			break;
		}
		Write-Host "Cannot login to vCloud Air. Try again" -foregroundcolor black  -backgroundcolor yellow
		$SourceUser = Read-Host "User Name"
		$SourcePass = Read-Host "Password" -AsSecureString
		$p = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SourcePass)
		$SourcePlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($p)
	}

	# Connect Compute Instance
	$CI = Get-PIDatacenter | Out-GridView -Title "Please Choose Reagion to connect" -OutputMode Single

	try {
		disconnect-ciserver * -Force -Confirm:$false -ErrorAction "silentlycontinue"
	}
	catch {
	}
	$CIServer = $CI | Connect-CIServer
	if ($CIServer){
		$script:Region=$CIServer.Name
	}else{
		echo "Sorry, couldn't connect vCloud Air. Please try again"
		Exit
	}
	$script:org = get-org
}



Function ConnectVCA {
	##########
	# Connect vCloud Air OnDemand
	##########
	Write-Host "Please specify "User Name" and "Password" to connect Source Env" -foregroundcolor black  -backgroundcolor yellow
	$script:SourceUser = Read-Host "User Name"
	$SourcePass = Read-Host "Password" -AsSecureString

	$p = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SourcePass)
	$script:SourcePlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($p)
	
	try {
		disconnect-piserver * -Force -Confirm:$false -ErrorAction "silentlycontinue"
	}
	catch{
	}
	While (1){
		if (Connect-PIServer -user $SourceUser -password $SourcePlain -ErrorAction SilentlyContinue -vca){
			break;
		}
		Write-Host "Cannot login to vCloud Air. Try again" -foregroundcolor black  -backgroundcolor yellow
		$SourceUser = Read-Host "User Name"
		$SourcePass = Read-Host "Password" -AsSecureString
		$p = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SourcePass)
		$SourcePlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($p)
	}

	# Connect Compute Instance
	$CI = Get-PIComputeInstance | Out-GridView -Title "Please Choose Reagion to connect" -OutputMode Single

	try {
		disconnect-ciserver * -Force -Confirm:$false -ErrorAction "silentlycontinue"
	}
	catch {
	}
	If ($CI | Connect-CIServer){
		$script:Region=$CI.Region
	}else{
		echo "Sorry, couldn't connect vCloud Air. Please try again"
		Exit
	}
	$script:org = get-org 
}

Function DownloadvApps {
	# Select target vDC
	$orgVDC = Get-OrgVDC | Out-GridView -Title "Please Choose VDC for this operation" -OutputMode Single
	if(!$orgVDC){
		echo "Sorry, couldn't get VDC info. Please try again"
		Exit
	}

	$selection = Get-CIvApp -orgVDC $orgVDC | ? {$_.Status -eq "PoweredOff"} | ? {$_.ExtensionData.Deployed -eq 0}
	if (!$selection){
		echo "No Powered off vApps. Please Poweroff vApps on vCloud Air and try again."
		Exit
	}

	While(1){
		Write-Host "The following vApps has been chosen for download" -foregroundcolor black  -backgroundcolor yellow
		$selection | ForEach-Object {
			Write-Host . $_.Name -foregroundcolor red
		}
		Write-Host "Total number:" $selection.length 

		Write-Host "Are you sure to download all of selected vApps? If you agree, please type 'Y'" -foregroundcolor black  -backgroundcolor yellow
		$Final = Read-Host "Are you sure?"

		if ($Final -eq "Y") {
			break;
		}
		$selection = Get-CIvApp -orgVDC $orgVDC | ? {$_.Status -eq "PoweredOff"} | ? {$_.ExtensionData.Deployed -eq 0} | Out-GridView  -Title "Please Choose vApp for download" -OutputMode Multiple
	}

	$selection | ForEach-Object {
		$LogFilename = Get-Date -Format "yyyy-MMdd-HHmmss"
		$SourceFull = "vcloud://$SourceUser`:$SourcePlain@$Region`?org=$Org&vdc=$orgVDC&vapp=$_"
		$SourceFull
		& $OVFPath --X:logFile="$LogFilename.log" --X:logLevel=verbose $SourceFull $DownloadPath
	}	
}

Function DownloadCatalogs {
	While(1){
		# Select Catalogs
		$Catalogs = Get-Catalog | Out-GridView -Title "Please Choose Catalog for this operation" -OutputMode Single
		if(!$Catalogs){
			echo "Sorry, couldn't get Catalog info. Please Choose again"
			continue;
		}


		# Template? Media? 
		Write-Host "Choose Template or Media(iso) for download" -foregroundcolor black  -backgroundcolor yellow
		Write-Host "[1] Download Template" -foregroundcolor black  -backgroundcolor yellow
		Write-Host "[2] Download Media" -foregroundcolor black  -backgroundcolor yellow

		$Type = Read-Host "Select"
		switch ($Type)
		{
		  1 {
				# Select Template
				# $selection = $Catalogs | Get-CIVAppTemplate | Out-GridView  -Title "Please Choose Templates for download" -OutputMode Multiple
				$selection = $Catalogs | Get-CIVAppTemplate
				if (!$selection){
					continue;
				}
				$selection = $Catalogs | Get-CIVAppTemplate | Out-GridView  -Title "Please Choose Templates for download" -OutputMode Multiple
		 	 }
		  2 {
				# Select Media
				# $selection = $Catalogs | Get-Media | Out-GridView  -Title "Please Choose Media for download" -OutputMode Multiple
				$selection = $Catalogs | Get-Media
				if (!$selection){
					continue;
				}
				$selection = $Catalogs | Get-Media | Out-GridView  -Title "Please Choose Media for download" -OutputMode Multiple
		  	}
		  default {
		  		echo "Please select 1 or 2. Please try again"
		  		continue;
		 	}
		}

		if (!$selection){
			Write-Host "There is no item to be selected. Please type return key to select again" -foregroundcolor black  -backgroundcolor yellow
			Read-Host "Type Return"
			continue;
		}

		Write-Host "The following Items has been chosen for download" -foregroundcolor black  -backgroundcolor yellow

		$selection | ForEach-Object {
			Write-Host . $_.Name -foregroundcolor red
		}

		Write-Host "Are you sure to download all of selected items? If you agree, please type 'Y'" -foregroundcolor black  -backgroundcolor yellow
		$Final = Read-Host "Are you sure?"

		if ($Final -ne "Y") {
			Write-Host "Please type return key to select again" -foregroundcolor black  -backgroundcolor yellow
			Read-Host "Type Return"
			continue;
		}
		break;
	}
	switch ($Type)
	{
	  1 {	  
			$selection | ForEach-Object {
				$LogFilename = Get-Date -Format "yyyy-MMdd-HHmmss"
				$SourceFull = "vcloud://$SourceUser`:$SourcePlain@$Region`?org=$Org&vappTemplate=$_&catalog=$Catalogs"
				& $OVFPath --X:logFile="$LogFilename.log" --X:logLevel=verbose $SourceFull $DownloadPath
			}
		}
	  2 {
			$selection | ForEach-Object {
				$LogFilename = Get-Date -Format "yyyy-MMdd-HHmmss"
				$SourceFull = "vcloud://$SourceUser`:$SourcePlain@$Region`?org=$Org&media=$_&catalog=$Catalogs"
				$DownloadPath = $DownloadPath + "`\" + $_.name
				& $OVFPath --X:logFile="$LogFilename.log" --X:logLevel=verbose $SourceFull $DownloadPath.ToLower()
			}
	  	}
	}	
}

##########
#Check the version of PowerCLI
##########
$version = Get-PowerCLIVersion
If ($version.build -lt "3205540"){
	Write-Host "Please update more than PowerCLI 6.0 Release 3 " -foregroundcolor black  -backgroundcolor yellow
	Exit
}

##########
#Check ovftool can be executed
##########

$OVFPath = "ovftool"
While (1){
	if (Get-Command $OVFPath -ErrorAction SilentlyContinue){ 
		break;
		}
	Write-Host "Cannot execute ovftool. Please enter directory path for ovftool.exe" -foregroundcolor black  -backgroundcolor yellow
	$OVFPath = Read-Host "Path"
	$OVFPath = Join-Path $OVFPath ovftool.exe
}

##########
#Check the service
##########
$SVC = 0
Write-Host "Choose what you would like to perform" -foregroundcolor black  -backgroundcolor yellow
Write-Host "[1] Download PowerOff vApps on Dedicated/VPC Service" -foregroundcolor black  -backgroundcolor yellow
Write-Host "[2] Download OVF/ISOs from Catalogs on Dedicated/VPC Service" -foregroundcolor black  -backgroundcolor yellow
Write-Host "[3] Download PowerOff vApps on OnDemand Service" -foregroundcolor black  -backgroundcolor yellow
Write-Host "[4] Download OVF/ISOs from Catalogs on OnDemand Service" -foregroundcolor black  -backgroundcolor yellow

$SVC = Read-Host "Select"

switch ($SVC)
{
  1 {
		# Set Download Path
  		LocalPath

		# Connect vCHS and set ($SourceUser,$SourcePlain,$Region)
		ConnectVCHS
		
		# Download vApps
		DownloadvApps		
 	 }
  2 {
		# Set Download Path
  		LocalPath

		# Connect vCHS and set ($SourceUser,$SourcePlain,$Region)
		ConnectVCHS
		
		# Download Catalogs
		DownloadCatalogs	
	 }
  3 {
		# Set Download Path
		LocalPath

		# Connect vCA and set ($SourceUser,$SourcePlain,$Region)
		ConnectVCA
		
		# Download vApps
		DownloadvApps
	}
  4 {
		# Set Download Path
		LocalPath

		# Connect vCA and set ($SourceUser,$SourcePlain,$Region)
		ConnectVCA
		
		# Download Catalogs
		DownloadCatalogs
  	}
  default {
  		echo "Please select 1-4. Please try again"
  		exit
 	 }
}




