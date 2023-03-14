$dateString = Get-Date -Format "yyyy-MM-dd_HHmmss"
$filename = "ComputerInformations_$dateString.csv"
$outputFile = "C:\PowershellScripts\Output\ComputerInformations_$dateString.csv"
 
#Import used Module
Import-Module AdmPwd.PS

# Setting Imported Properties
$computers = Get-ADComputer -Filter * -Properties LastLogon, LastLogonTimeStamp, PwdLastSet, PasswordLastSet
#Setting Filter for Groups
$ouGroupFilter = @("OU=****", "OU=****")
#Create Empty Array to Store Results  
$results = @()

#Loop over every Computer
$output = foreach ($computer in $computers) {
    #Get All Groups of the Device
    $ou = (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$($computer.DistinguishedName.Split(',')[1..$($computer.DistinguishedName.Split(',').Length - 1)] -join ','))").DistinguishedName
    #Loop over every Group
    foreach ($ouGroup in $ouGroupFilter) {

    # Check if the OU group name is in the distinguished name of the user's OU
    if ($ou -like "*$ouGroup*") {

      # Add the user's name and the OU group name to the filtered results array
      $ouGroupName = $ouGroup -replace "^OU=",""
      $filteredResults = $ouGroupName
      break
    }
    else {
      $filteredResults = "other"  
    }
    }
    # Get the value of the ms-Mcs-AdmPwd attribute
    $password = (Get-AdmPwdPassword -ComputerName $computer).Password

    #Setting The Output
    [PSCustomObject]@{
        ComputerName = $computer.Name
        Standort = $filteredResults
        AdmPwd = $password
        LastLogon = if ($computer.LastLogon) { [DateTime]::FromFileTime($computer.LastLogon) } else { $null }
        LastLogonTimestamp = if ($computer.LastLogonTimeStamp) { [DateTime]::FromFileTime($computer.LastLogonTimeStamp) } else { $null }
        PwdLastSet = $computer.PwdLastSet
        PasswordLastSet = $computer.PasswordLastSet
    }
}
$output | Export-Csv $outputFile -NoTypeInformation


#Uplaod to Nextcloud
$nc_url="https://****"
$nc_dir ="/IT-Themen/AD-Übersicht"
$username="****"
$pwd="****"

$fileBytes = [System.IO.File]::ReadAllBytes($outputFile)
$uploadUrl = "$nc_url/remote.php/dav/files/$username/$nc_dir/$filename"

#Write-Output $uploadUrl

$headers = @{
    Authorization = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username+":"+$pwd))
}
Invoke-WebRequest -Uri $uploadUrl -Headers $headers -Method PUT -InFile $outputFile
