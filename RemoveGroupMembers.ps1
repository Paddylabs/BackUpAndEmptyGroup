<#

  .SYNOPSIS

  Backs up and then empties the AD Group Specified.

  .DESCRIPTION

  Backs up the "Group of your choice" and then empties it every night at 23.59 (set by Scheduled Task) and sends a results email.

  .PARAMETER

  None

  .EXAMPLE

  None

  .INPUTS

  None

  .OUTPUTS

  \Backup\GroupName_Membership_DateandTime.txt
  \Logs\ErrorLog_DateandTime.txt

  .NOTES

  Author:        Patrick Horne

  Creation Date: 19/03/20

  Requires:      ActiveDirectory Module

  Change Log:

  V1.0:         Initial Development

#>

#Requires -Modules ActiveDirectory

# Define variables

$SuccessCount = 0
$FailureCount = 0
$Group        = Get-ADGroup "Name of Group Here" -Properties Members
$GroupName    = $Group.Name
$Members      = $Group | Select-Object -ExpandProperty members
$ScriptDir    = "C:\Users\Patrick\Documents\Scripts\BackUpandEmptyGroup"
$BackUpDir    = $ScriptDir + "\Backup"
$LogDir       = $ScriptDir + "\Logs"
$ExportTofile = $BackUpDir + "\$GroupName" + "_Membership_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).txt"
$ErrorLog     = $LogDir + "\ErrorLog_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).txt"

# Email Variables

$EmailTo      = "EmailRecipient@company.com"
$EmailFrom    = "EmailFrom@company.com"
$SmptServer   = "SmtpServer.company.com"

# Set Script location

Set-Location $ScriptDir

# Export the current group membership to backup file

$Members | Out-File $ExportTofile

# Remove each member from the group and if successful delete backup files older than 7 days.

Foreach ($Member in $Members) {

Try {

Remove-ADGroupMember -Identity $Group.DistinguishedName -Members $Member -Confirm:$false -ErrorAction Stop

$SuccessCount++

}

Catch {

$_.Exception.message | Out-File $ErrorLog -Append
$FailureCount++

}

}

# Delete Backup files older than 7 days

Get-ChildItem -Path $BackUpDir -Filter *.txt | Where-Object { ((Get-Date)-$_.LastWriteTime).Days -gt 7 } | Remove-Item -Force

# Delete Error logs older than 7 days

Get-ChildItem -Path $LogDir BackUpDir -Filter *.txt | Where-Object { ((Get-Date)-$_.LastWriteTime).Days -gt 7 } | Remove-Item -Force

if ($FailureCount -ge 1) {

  $FailureEmailSplat = @{
    To         = $EmailTo
    From       = $EmailFrom
    SmtpServer = $SmptServer
    Subject    = "$GroupName group member removal results"
    Body       = "There was an error removing users from $GroupName. Please check the error log."
        
}

Send-Mailmessage  @FailureEmailSplat

}

Else {

$SuccessEmailSplat = @{

    To         = $EmailTo
    From       = $EmailFrom
    SmtpServer = $SmptServer
    Subject    = "$GroupName member removal results"
    Body       = "$SuccessCount Users removed from $GroupName"
   
}

Send-Mailmessage  @SuccessEmailSplat

}