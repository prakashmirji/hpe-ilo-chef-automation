ilo_ip = '10.188.2.1'
username = 'usradmin'
password = 'HP!nvent'
SNMP_Enabled = 'false' 
script_location = 'C:\\Users\\usradmin\\Documents\\hpe-ilo-chef-automation\\ILO_Configure_SNMP_Redfish.ps1'

powershell_script 'Configure ILO SNMP' do
    code ". #{script_location} -IloIP #{ilo_ip} -Username #{username} -Password #{password} -SNMPEnabled #{SNMP_Enabled}"
end
