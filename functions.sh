## Cloud Installer Helper Functions

function cloud_cli_available() {
    # return true if CLI stuff is found
    found_it=0
    case $1 in
        Azure|azure|Az|AZ|az)
            # check for Azure CLI
            myaz=`az --version 2>&1 | grep azure-cli`
            if [ ! -z "$myaz" ]
            then
                found_it=1
            fi
            ;;
        GCP|gcp)
            # check for GCP CLI
            ;;
        AWS|aws)
            # check for AWS CLI
            ;;
    esac
    return "$found_it"
}

function get_vms() {}

function get_resource_groups() {}

function get_vnets() {}

function get_pips() {}

function get_lbs() {}

function get_route_tables() {}

function get_routes() {}

function get_available_cpus() {
    # How many vCPUs available to deploy in this region

}

function get_regions() {}
