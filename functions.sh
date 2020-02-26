## Cloud Installer Helper Functions

dprint() {
    if [ "$DEBUG" == 'true' ]
    then
        echo "$@" 1>&2
    fi
}

cloud_cli_available() {
    # return true if CLI stuff is found
    case "$1" in
        Azure|azure|Az|AZ|az)
            # check for Azure CLI
            myaz=`az --version | grep azure-cli`
            if [ ! -z "$myaz" ]
            then
                CLOUD_FOUND="True"
                dprint "Found Azure ($myaz)"
            fi
            ;;
        GCP|gcp)
            # check for GCP CLI
            ;;
        AWS|aws)
            # check for AWS CLI
            ;;
    esac

    return
}

function get_vms() {
    #
    return 0
}

function get_resource_groups() {
    #
    case "$CLOUD" in
    Azure)
        # Get Azure RGs
        
        ;;
    AWS)
        # Get AWS RGs

        ;;
    GCP)
        # Get GCP RGs

        ;;
    (*) break;;
    esac

    return 0
}

function get_vnets() {
    #
    return 0
}

function get_pips() {
    #
    return 0
}

function get_lbs() {
    #
    return 0
}

function get_route_tables() {
    #
    return 0
}

function get_routes() {
    #
    return 0
}

function get_available_cpus() {
    # How many vCPUs available to deploy in this region
    return 1
}

function get_regions() {
    #
    return 0
}
