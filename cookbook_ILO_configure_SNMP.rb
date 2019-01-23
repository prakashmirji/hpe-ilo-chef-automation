# iLO credentials
ilo_ip = '10.188.2.1'
username = 'usradmin'
password = 'HP!nvent'

# SNMP alerts to be enabled or disabled
SNMPAlerts_Enabled = 'false' 

# SNMP alerts destinations
AlertDestinationID = 3
AlertDestinationIP = '10.1.2.3'
SNMPAlertProtocol = 'SNMPv1Trap'
TrapCommunity = 'Public'
SecurityName = '$null' # '$null' or string val

base_dir = __dir__ # Current working directory

powershell_script 'Configure ILO SNMPAlerts' do
    code ". #{base_dir}\\ILO_Configure_SNMPAlerts_Redfish.ps1 -IloIP #{ilo_ip} -Username #{username} -Password #{password} -SNMPEnabled #{SNMPAlerts_Enabled}"
end

powershell_script 'Configure ILO SNMPAlertDestinations' do

    code ". #{base_dir}\\ILO_Configure_SNMPAlertDestinations_Redfish.ps1 -IloIP #{ilo_ip} -Username #{username} -Password #{password} \
    -AlertDestination @{AlertDestinationID='#{AlertDestinationID}';AlertDestinationIP='#{AlertDestinationIP}';SNMPAlertProtocol='#{SNMPAlertProtocol}';TrapCommunity='#{TrapCommunity}'; SecurityName = #{SecurityName}}"
end


