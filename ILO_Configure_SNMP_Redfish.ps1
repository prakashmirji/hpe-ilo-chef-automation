param([String] $IloIP, [String] $Username, [String] $Password, [String] $SNMPEnabled)

$Address = $IloIP
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

function Set-SNMPExample21
{
    param
    (
        [System.String]
        $Address,

        [PSCredential]
        $Credential,

        [System.String]
        $Mode, # Agentless or Passthru

        [System.Object]
        $AlertsEnabled = $null #use true or false only


    )
    Write-Host 'Example 21: Configure iLO SNMP settings.'

    # Ignore SSL check
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

    # Create session
    $session = Connect-HPERedfish -Address $Address -Credential $Credential
    
    Write-Host 'Connection established'

    # retrieve list of managers
    $managers = Get-HPERedfishDataRaw -odataid '/redfish/v1/Managers/' -Session $session
    foreach($mgr in $managers.Members.'@odata.id')
    {
        # retrieve settings of NetworkService data
        $mgrData = Get-HPERedfishDataRaw -odataid $mgr -Session $session
        $netSerOdataId = $mgrData.NetworkProtocol.'@odata.id'
        $netSerData = Get-HPERedfishDataRaw -odataid $netSerOdataId -Session $session
        
        if($netSerData.Oem.Hpe.Links.PSObject.properties.name -notcontains 'SNMPService')
        {
            Write-Host 'SNMP services not available in Manager Network Service'
        }
        else
        {
            $snmpSerOdataId = $netSerData.Oem.Hpe.Links.SNMPService.'@odata.id'
            
            $snmpSerData = Get-HPERedfishDataRaw -odataid $snmpSerOdataId -Session $session

            # create hashtable object according to the parameters provided by user
            $snmpSetting = @{}
            if($AlertsEnabled -ne $null)
            {
                $snmpSetting.Add('AlertsEnabled',[System.Convert]::ToBoolean($AlertsEnabled))
            }

            # PATCh the settings using Set-HPERedfishData cmdlet
            $ret = Set-HPERedfishData -odataid $snmpSerOdataId -Setting $snmpSetting -Session $session

            # Process message(s) returned from Set-HPERedfishData cmdlet
            if($ret.error.'@Message.ExtendedInfo'.Count -gt 0)
            {
                foreach($msgID in $ret.error.'@Message.ExtendedInfo')
                {
                    $status = Get-HPERedfishMessage -MessageID $msgID.MessageID -MessageArg $msgID.MessageArgs -Session $session
                    $status
                }
            }
        }
    }
    # Disconnect the session after use
    Disconnect-HPERedfish -Session $session
}
## Call the function with required parameters
Set-SNMPExample21 -Address $Address -Credential $cred -Mode Agentless -AlertsEnabled $SNMPEnabled