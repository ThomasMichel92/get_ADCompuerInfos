# get_ADCompuerInfos
Load from an Active Directory Informations of the Computers ans save it as CSV

All **** Sections should be edited because they hold confidential informations.

This Tool load following Datas from the Active Directory:
ComputerName
Location
AdmPwd
LastLogon
LastLogonTimestamp
PwdLastSet
PasswordLastSet

The Location or Office in this context is a Computer which is allocated to a office in a company.
The Offices in this Environment are saved as an own OU Group
This Tools get this Informations with an Filter set in the first lines.

Also this tools writes the Output in a CSV File and Loading it in to a Nextcloud Domain.
Username, Password and URL has to be set manually.
