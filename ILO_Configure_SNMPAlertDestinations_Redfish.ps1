param([String] $IloIP, [String] $Username, [String] $Password, [hashtable] $AlertDestination)

$Address = $IloIP
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

function Set-SNMPAlertDestinations
{
    param
    (
        [System.String]
        $Address,

        [PSCredential]
        $Credential
    )
    Write-Host 'Configure iLO SNMPAlertDestinations settings.'

    # Ignore SSL check
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

    # Create session
    $session = Connect-HPERedfish -Address $Address -Credential $Credential

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

			$snmpAlertDestOdataId = $snmpSerData.SNMPAlertDestinations.'@odata.id'
            $DestID = $AlertDestination.AlertDestinationID
            # Modify URI to point to the required item
            $snmpAlertDestOdataId = $snmpAlertDestOdataId+$DestID+'/'

            $snmpAlertDestData = Get-HPERedfishDataRaw -odataid $snmpAlertDestOdataId -Session $session

            if($snmpAlertDestData.AlertDestination -ne $AlertDestination.AlertDestinationIP -OR $snmpAlertDestData.SNMPAlertProtocol -ne $AlertDestination.SNMPAlertProtocol -OR
                $snmpAlertDestData.TrapCommunity -ne $AlertDestination.TrapCommunity -OR $snmpAlertDestData.SecurityName -ne $AlertDestination.SecurityName)
            {
            
                ## Patch alert destination with userdata
                # create hashtable object according to the parameters provided by user
                $snmpDestSetting = @{}
                $snmpDestSetting.Add('AlertDestination',$AlertDestination.AlertDestinationIP)
                $snmpDestSetting.Add('SNMPAlertProtocol',$AlertDestination.SNMPAlertProtocol)
                $snmpDestSetting.Add('TrapCommunity',$AlertDestination.TrapCommunity)
                $snmpDestSetting.Add('SecurityName',$AlertDestination.SecurityName)
            


                # PATCh the settings using Set-HPERedfishData cmdlet
                $ret = Set-HPERedfishData -odataid $snmpAlertDestOdataId -Setting $snmpDestSetting -Session $session

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
    }
    # Disconnect the session after use
    Disconnect-HPERedfish -Session $session
}
## Call function with required values
Set-SNMPAlertDestinations -Address $Address -Credential $cred
