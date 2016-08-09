<#
.Synopsis
    Script for get all locked accounts in the last 24 hours
.DESCRIPTION
    Script for get all locked accounts in the last 24 hours. You need to have access to your PDC Emulator event log.
.EXAMPLE
    C:\Scripts\Export-AccountLockout.ps1
.EXAMPLE
    Export-AccountLockout
.NOTES
    Created:	 2016-08-09
    Version:	 1.0

    Author - François LEON
    Linkedin: https://fr.linkedin.com/in/françois-leon-127913107
    Blog   : https://scomnewbie.wordpress.com/

    Disclaimer:
    This script is provided "AS IS" with no warranties, confers no rights and 
    is not supported by the authors or Deployment Artist.
.LINK
    https://scomnewbie.wordpress.com/
#>
function Export-AccountLockout {
	$ErrorActionPreference = "Silentlycontinue"
	$results = @()
	[string]$PDCEmulator = (Get-ADDomain).PDCEmulator

$query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (EventID=4740) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
  </Query>
</QueryList>
"@

	$AccountLocks = Get-WinEvent -FilterXml $query -ComputerName $PDCEmulator
	Foreach($AccountLock in $AccountLocks){

    	$SplitMessage = $AccountLock.Message -split '\r\n'
    	Foreach ($line in $SplitMessage){
        	Switch -regex ($line ) {
			 #The substring is is remove all white spaces + column name
           	 'Account Name:*' {$AccountLockName = $line.Substring(16)}
           	 'Caller Computer Name:*' {$CallerName = $line.Substring(23)}
      	  	}

  	  	}

    	$LockTime = $AccountLock.TimeCreated

    	if($CallerName -eq $null){
     	   $CallerName = 'Empty string'
    	}

    	$Results += New-Object PSObject -Property @{LockTime=$LockTime;AccountLock=$AccountLockName;CallerComputer=$CallerName}
	}
	return $Results
}

Export-AccountLockout



