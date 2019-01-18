ilo_ip = '10.188.2.1'
username = 'usradmin'
password = 'HP!nvent'
SNMP_Enabled = 'true' 

powershell_script 'Configure ILO SNMP' do
    code ". C:\\Users\\usradmin\\chef-repo\\ILO_Configure_SNMP_Redfish.ps1 -IloIP #{ilo_ip} -Username #{username} -Password #{password} -SNMPEnabled #{SNMP_Enabled}"
end