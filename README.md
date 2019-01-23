# HPE-Chef-ILO-automation
This repo contains the powershell scripts and Chef cookbooks for ILO SNMP settings automation.

# DISCLAIMER
Solution works only for iLO 5.
For setting up SNMP alert destinations user has to add the destination manually through UI and later can be updated (PATCH) 
any time using chef recipe.
User should provide SNMP Alert Destination number which has be checked and patched as part of input.

## Getting Started

System requirements :- 
Windows server 2008 or 2012 r2
Chef workstation installed on Windows server

### Setting up the Environment
 
```
1. clone git repository and extract it.

2. Launch Powershell as administrator and run follwoing to install HPERedfishCmdlets
	$ Install-Module -Name HPERedfishCmdlets

3. Change working dir to directory where the git repository extracted
	$ cd \path\to\repo\hpe-ilo-chef-automation
	
4. Edit cookbook accordingly for inputs
	file "cookbook_ILO_configure_SNMP.rb"
```

## Deployment

> After updating inputs in file ***cookbook_ILO_configure_SNMP.rb***.

Execute as follows:-

```
$ chef-client --local-mode .\cookbook_ILO_configure_SNMP.rb
```

## Built With

* Chef
* Powershell 3 or above


## Versioning

We use [GitHub](http://github.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **GSE Team, Bangalore** 

See also the list of [contributors](https://github.com/prakashmirji/hpe-ilo-chef-automation/graphs/contributors) who participated in this project.

## License

(C) Copyright (2019) Hewlett Packard Enterprise Development LP

## Acknowledgments
