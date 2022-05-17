# aws-adlab #

This terraform project launches a Windows lab in AWS with a domain controller and a member server added to the domain.

Powershell setup scripts for AD and other servers is located in the [aws-adlab-powershell repo](https://github.com/cthare/aws-adlab-powershell)

Currently this expects a secret under the name "ad-winlab" to be present in the region you are deploying to.