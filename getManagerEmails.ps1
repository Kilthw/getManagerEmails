$users = @{}
foreach($line in Get-Content .\users.txt) {
    $user,$domain = $line.split('@')
	$userProperties = Get-ADUser -Identity $user -Server $domain -Properties EmailAddress,Manager,Enabled,Modified,LastLogonDate
	$currentUser = @{}
	$userProperties.PSObject.Properties|%{$currentUser.Add($_.Name, $_.Value)}
	$users[$line] = $currentUser
	try{
		$manager = Get-ADUser $currentUser.manager -Server $domain -Properties EmailAddress
		$managerEmail = $manager.EmailAddress
		$managerName = $manager.Name
	}
	catch {
		$managerEmail = ""
		$managerName = ""
	}
	"-----------------------"
	Write-Host "User: " $line
	Write-Host "User Email: " $currentUser.EmailAddress
	Write-Host "Enabled: " $currentUser.Enabled
	Write-Host "Modified: " $currentUser.Modified
	Write-Host "Manager: " $managerName
	Write-Host "Manager Email: " $managerEmail
	$users[$line]["ManagerEmail"] = $managerEmail
	$users[$line]["ManagerName"] = $managerName
}
Remove-Item –path .\temp.tsv
"AccountName`tUserName`tEmailAddress`tEnabled`tModified`tLastLogonDate`tManagerName`tManagerEmail" | Add-Content -Path .\temp.tsv
foreach($user in $users.Keys) {
	"{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}`t{7}" -f $user,$users[$user]["Name"],$users[$user]["EmailAddress"],$users[$user]["Enabled"],$users[$user]["Modified"],$users[$user]["LastLogonDate"],$users[$user]["ManagerName"],$users[$user]["ManagerEmail"] | Add-Content -Path .\temp.tsv
}
