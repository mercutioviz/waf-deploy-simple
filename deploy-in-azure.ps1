# deploy-in-azure.ps1
#
# Deploy Barracuda WAF or CGF into azure
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $location,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $deploy_method,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [switch]
    $nogreeting = $false,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [switch]
    $noninteractive = $false,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [switch]
    $ha = $false,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [validateset("WAF","CGF")]
    [string]
    $product
)

if ( $noninteractive -eq $true ) {
    $nogreeting = $true
}
# Welcome message
if ( $nogreeting -eq $false ) {
    Write-Host "Welcome to the Barracuda WAF and CGF deployment script for Azure."
    Write-Host "This script will assist with deploying WAF or CGF into an Azure environment."
    Write-Host "You will need to supply the following information:"
    Write-Host "  Product to deploy (WAF or CGF)"
    Write-Host "  Location (i.e. region)"
    Write-Host "  Deployment type: standalone or high availability pair"
    Write-Host "  Deployment methond: all new infrastructure or use existing VNet"
    Write-Host
    Read-Host "Press <Enter> to continue"    
}

if ( $location -eq '' ) {
    $location = Read-Host "Enter location (ex: westus, eastus2)"
} elseif ( $noninteractive -eq $false ) {
    $answer = Read-Host "Enter location (<enter> = $location)"
    if ( $answer -ne '' ) {
        $location = $answer
    }
}
Write-Host "Location: " $location -ForegroundColor Green

if ( $product -eq '' ) {
    $product = Read-Host "Select product (WAF or CGF)"
} elseif ( $noninteractive -eq $false ) {
    $answer = Read-Host "Select product (<enter> = $product)"
    if ( $answer -ne '' ) {
        $product = $answer
    }
}
Write-Host "Product: " $product -ForegroundColor Green

if ( $deploy_method -eq '' ) {
    $deploy_method = Read-Host "Create (N)ew infrastructure or use (E)xisting VNet (N or E, <enter>=New)"
    if ( $deploy_method -eq '' ) {
        $deploy_method = 'new'
    }
} elseif ( $noninteractive -eq $false ) {
    $answer = Read-Host "Select product (<enter> = $deploy_method)"
    if ( $answer -ne '' ) {
        $deploy_method = $answer
    }
}
Write-Host "Deploy Method: " $deploy_method -ForegroundColor Green

if ( $noninteractive -eq $false ) {
    Write-Host "Deployment type: single unit or high availability (HA) pair."
    $answer = Read-Host "Would you like to deploy an HA Pair? (Y/N <enter>=No)"
    #Write-Host "'$answer'" -ForegroundColor Magenta
    if ( $answer -eq '' -or $answer -match "^[Nn]" ) {
        $ha = $false
    } else {
        $ha = $true
    }
}
Write-Host "HA Deployment: " $ha -ForegroundColor Green
