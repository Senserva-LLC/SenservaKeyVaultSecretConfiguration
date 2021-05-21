#Senserva Key Vault Secret Configuration Script
#Copyright: Senserva LLC
#Author: Senserva
#Requires -RunAsAdministrator
#Requires -Modules Az.KeyVault

Write-Host "Welcome to Senserva!" -ForegroundColor Green
Write-Host "This script will help you set a secret in a desired Key Vault" -ForegroundColor Green

Write-Host "We'll now set the context of your session" -ForegroundColor Green
$userUPN = Read-Host "UserName/UPN"
if(!$userUPN){Throw "You must supply a username of an admin in the tenant"}


$tenantId = (Invoke-RestMethod "https://login.windows.net/$($userUPN.Split("@")[1])/.well-known/openid-configuration" -Method GET).userinfo_endpoint.Split("/")[3]

try{
    $connection = Login-AzAccount -Force -Confirm:$False -SkipContextPopulation -Tenant $tenantId -ErrorAction Stop
    $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
}catch{
    Write-Host "Failed to log in and/or retrieve token, aborting" -ForegroundColor Red
    Write-Host $_
    Exit
}


Write-Host "We will now get some necessary parameters" -ForegroundColor Green

$keyVaultName = Read-Host "Please enter KeyVault name"
if(!$keyVaultName){Throw "You must supply a key vault name for use"}

$keyVaultSecretName = Read-Host "Please enter the name of your Secret"
if(!$keyVaultSecretName){Throw "You must supply a secret name for use"}

$keyVaultSecretValue = Read-Host "Please enter the value of your Secret"
if(!$keyVaultSecretValue){Throw "You must supply a secret value for use"}

$secureSecretVault = ConvertTo-SecureString $keyVaultSecretValue -AsPlainText -Force

try{
    Write-Host "We will now set the secret using the given values" -ForegroundColor Green
    $secret = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSecretName -SecretValue $secureSecretVault -ErrorAction Stop
}catch{
    Write-Host "Failure when trying to set Key Vault Secret, aborting" -ForegroundColor Red
    Write-Host $_
    Exit
}

try{
    Write-Host "Secret has been set" -ForegroundColor Green
    Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSecretName -AsPlainText -ErrorAction Stop
}catch{
    Write-Host "Failure when trying to get Key Vault Secret, exiting" -ForegroundColor Red
    Write-Host $_
    Exit
}

Write-Host "Script has completed" -ForegroundColor Green