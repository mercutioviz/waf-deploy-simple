#!/bin/bash
. ./functions.sh

echo "
##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#
# Quickstart WAF deployment in Microsoft Azure using Terraform and Ansible
#
##############################################################################################################
"

# Stop running when command returns error
set -e

PLAN="terraform.tfplan"
ANSIBLEINVENTORYDIR="ansible/inventory"
ANSIBLEINVENTORY="$ANSIBLEINVENTORYDIR/all"
DEBUG='false'
VERBOSE='false'
DEPLOY_LOCATION='eastus2'
DEPLOY_PREFIX=''
DEPLOY_TYPE=''
RESOURCE_GROUP='rg-cuda-waf'
CLOUD='Azure'
CLOUD_FOUND='False'

if ! options=$(getopt -o hdvr:p:l:c:t: \
        -l help,debug,verbose,rg:,password:,location:,cloud:,type: \
        -- "$@") #"
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
    -h|--help) 
                echo "WAF installer" 
                exit 0
                ;;
    -d|--debug) DEBUG='true' ;;
    -v|--verbose) DEBUG='true' ;;
    # for options with required arguments, an additional shift is required
    -r|--rg) RESOURCE_GROUP="$2" ; shift;;
    -l|--location) DEPLOY_LOCATION="$2" ; shift;;
    -p|--password) DEPLOY_PASSWORD="$2" ; shift;;
    -c|--cloud) CLOUD="$2" ; shift;;
    -t|--type) DEPLOY_TYPE="$2" ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done

dprint "Debug on..."

## Verify cloud
cloud_cli_available "$CLOUD"
if [[ "$CLOUD_FOUND" -eq "False" ]]
then
    dprint "$CLOUD availability: $CLOUD_FOUND"
else
    echo "Did not find commands for cloud: $CLOUD"
    exit 1
fi

## Choose deployment type: new or existing infrastructure?
if [ -z "$DEPLOY_TYPE" ]
then
    # Input type 
    echo -n "Enter type: [n]ew or [e]xisting (<enter>=new): "
    stty_orig=`stty -g` # save original terminal setting.
    read type           # read the type
    stty $stty_orig     # restore terminal setting.
    if [ -z "$type" ] 
    then
        type="new"
    elif [ "$type" -eq "e" ]
    then
        type='existing'
    else
        type='new'
    fi
else
    if [ "$DEPLOY_TYPE" -eq "e" || "$DEPLOY_TYPE" -eq "existing" ]
    then
        type='existing'
    else
        type='new'
    fi
fi
echo ""
echo "--> Deployment type is $type ..."
echo ""

if [ -z "$DEPLOY_LOCATION" ]
then
    # Input location 
    echo -n "Enter location (e.g. eastus2): "
    stty_orig=`stty -g` # save original terminal setting.
    read location       # read the location
    stty $stty_orig     # restore terminal setting.
    if [ -z "$location" ] 
    then
        location="eastus2"
    fi
else
    location="$DEPLOY_LOCATION"
fi
export TF_VAR_LOCATION="$location"
echo ""
echo "--> Deployment in $location location ..."
echo ""

if [ -z "$DEPLOY_PREFIX" ]
then
    # Input prefix 
    echo -n "Enter prefix: "
    stty_orig=`stty -g` # save original terminal setting.
    read prefix         # read the prefix
    stty $stty_orig     # restore terminal setting.
    if [ -z "$prefix" ] 
    then
        prefix=""
    fi
else
    prefix="$DEPLOY_PREFIX"
fi
export TF_VAR_PREFIX="$prefix"
echo ""
if [ -z "$DEPLOY_PREFIX"]
then
    echo "--> No prefix being used ..."
else
    echo "--> Using prefix $prefix for all resources ..."
fi
echo ""

if [ -z "$DEPLOY_PASSWORD" ]
then
    # Input password 
    echo -n "Enter password: "
    stty_orig=`stty -g` # save original terminal setting.
    stty -echo          # turn-off echoing.
    read passwd         # read the password
    stty $stty_orig     # restore terminal setting.
    if [ -z "$passwd" ] 
    then
        passwd="1234qwerASDF"
    fi
    echo "Using default passwd '$passwd'"
else
    passwd="$DEPLOY_PASSWORD"
    echo ""
    echo "--> Using password found in env variable DEPLOY_PASSWORD ..."
    echo ""
fi
PASSWORD="$passwd"
DB_PASSWORD="$passwd"

rg_cgf="$prefix-RG"

if [ "$type" -eq "new" ]
then
    # Input resource group
    echo -n "Enter resource group (<enter>=$rg_cfg): "
    stty_orig=`stty -g` # save original terminal setting.
    stty -echo          # turn-off echoing.
    read ans            # read the RG
    stty $stty_orig     # restore terminal setting.
    if [ -z "$ans" ] 
    then
        # 
    else
        rg_cfg="$ans"
    fi
    echo "Create resource group named '$rg_cfg'"
else
    # List available RGs and select
    rglist=''
    get_resource_groups
    echo "Select RG:"
    my_selection=''
    get_selection($rglist)
    rg_cfg=my_selection
fi

echo "Using RG '$rg_cfg'"
