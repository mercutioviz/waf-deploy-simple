# Azure env functions
function get_rg_list {
    param (
        $location
    )
    $rg_list = az group list --query "[?location=='${location}']" | json_pp | jq -r '.[] | .name'
    return $rg_list
}

function get_vnets {
    param (
        $location
    )
    $vnet_json=az network vnet list --query "[?location=='${location}']" | json_pp
    $vnets = $vnet_json | ConvertFrom-Json
    return $vnets
}