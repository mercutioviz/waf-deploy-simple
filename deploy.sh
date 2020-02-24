#!/bin/bash
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
DEPLOY_PASSWORD='1234qwerASDF'

if ! options=$(getopt -o hdvr: -l help,debug,verbose,rg: -- "$@")
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
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done

# while getopts "hdv" option; do
#     case "${option}" in
#         h) 
#             echo "WAF installer"
#             exit 0
#             ;;
#         d) DEUBG='true' ;;
#         v) VERBOSE='true' ;;
#         \?)
#             echo "Invalid option: -$OPTARG" >&2
#             exit 1
#             ;;
#     esac
# done

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
echo "--> Using prefix $prefix for all resources ..."
echo ""

if [ -z "$DEPLOY_PASSWORD" ]
then
    # Input password 
    echo -n "Enter password: "
    stty_orig=`stty -g` # save original terminal setting.
    stty -echo          # turn-off echoing.
    read passwd         # read the password
    stty $stty_orig     # restore terminal setting.
    echo ""
else
    passwd="$DEPLOY_PASSWORD"
    echo ""
    echo "--> Using password found in env variable DEPLOY_PASSWORD ..."
    echo ""
fi
PASSWORD="$passwd"
DB_PASSWORD="$passwd"


rg_cgf="$prefix-RG"
