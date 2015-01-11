#!/bin/bash
# Script data
_DEBUG=on # Debug Information
SCRIPT_NAME=`basename $(readlink -nf $0)`
TMP_TIMESTAMP=`date +%s`
MW_HOME=$1
ORACLE_HOME=$1/$2
OPATCH_DIR=$ORACLE_HOME/OPatch
OPATCH_REQ_VERSION=111082 # This OPatch version requires OPatch version of 11.1.0.8.2 or higher.
PATCH_ZIPFILE=p13973356_111160_Generic.zip
PATCH_NUMBER=13973356
PATCH_RESPONSE_FILENAME=opatch_response.rsp.ocm
PATCH_HOME="${depot_root}/patches"
PATCH_TOP=$PATCH_HOME/PATCH_TOP
PATCH_SCRIPT_HOME=`dirname $(readlink -nf $0)`

function DEBUG()
{
    [ "$_DEBUG" == "on" ] && echo [${SCRIPT_NAME}] $@
}

function CLEANUP()
{
    DEBUG "Cleaning up temporary storage."
#   rm -rf $PATCH_TOP
}

function EXIT_SUCCESS()
{
    DEBUG "Patch installation is successful. Please restart all servers."
    exit 0
}

function EXIT_FAILURE()
{
    DEBUG "Script is unsuccessful and is aborting."
    exit 1
}

# Patch Information
DEBUG "==============================================================================="
DEBUG "ICAM AUTOMATION SYSTEM"
DEBUG "Installation and Configuration Script"
DEBUG "Date: Fri Oct 24 15:59 2014"
DEBUG "Product being installed: RHEL"
DEBUG "Product Version being installed: v2.6.32-431.el6.x86_64"
DEBUG "==============================================================================="

# Step 0: Validate Script Parameters
if [ ! "$#" -eq 2 ]; then
    DEBUG "Usage:  install_p13973356_111160_Generic.sh <middleware home path> <oracle home>"
    EXIT_FAILURE
fi

if [ ! -d $MW_HOME ]; then
    DEBUG "Error: MW_HOME cannot be found:" $MW_HOME
    EXIT_FAILURE
fi

if [ ! -d $ORACLE_HOME ]; then
    DEBUG "Error: ORACLE_HOME cannot be found:" $ORACLE_HOME
    EXIT_FAILURE
fi

# Step 1: Prerequisites Validation
# Validate the correct version of OPatch is available for this patch.
CURRENT_PWD=$PWD
cd $OPATCH_DIR
#PATCH_VERSION=`./opatch version 2>&1 | grep "OPatch Version:" | awk '{print $3}' | tr -d \" | tr -d \. | tr -d \_`
cd $CURRENT_PWD
if [ ${OPATCH_VERSION} -lt ${OPATCH_REQ_VERSION} ]; then
    DEBUG "Error: The current version of OPatch will not install this patch. OPatch version 11.1.x or greater is required."
    EXIT_FAILURE
fi

# Validate OPatch has access to a valid OUI inventory to apply patches.
CURRENT_PWD=$PWD
cd $OPATCH_DIR
./opatch lsinventory >& /dev/null
status=$?
if [ $status -ne 0 ]; then
    DEBUG "Error: OPatch does not have access to a valid OUI inventory." $status
    EXIT_FAILURE
fi

# Validate OPatch is available in the PATH.
export PATH=$PATH:$OPATCH_DIR
which opatch  >& /dev/null
status=$?
if [ $status -ne 0 ]; then
    DEBUG "Error: This script does not have access to opatch: " $status
    EXIT_FAILURE
fi

# Validate unzip is available in the PATH.
which unzip >& /dev/null
status=$?
if [ $status -ne 0 ]; then
    DEBUG "Error: This script does not have access to unzip: " $status
    EXIT_FAILURE
fi

# Step 2: Pre-installation instructions.
# Setup the location to unzip the patch files.
# *** IMPORTANT: ORACLE_HOME is set in the data section.
#m -rf $PATCH_TOP
#kdir $PATCH_TOP

# Step 3: Installation instructions.
# Unzip the patch zip file into the PATCH_TOP.
#nzip -d ${PATCH_TOP} ${PATCH_HOME}/${PATCH_ZIPFILE}
status=$?
if [ $status -ne 0 ]; then
    DEBUG "Error: unzip failed with error:" $status
    CLEANUP
    EXIT_FAILURE
fi

# Set current directory to the directory where the patch is located.
CURRENT_PWD=$PWD
cd $PATCH_TOP/$PATCH_NUMBER

# Apply patch
#patch apply -silent -ocmrf $PATCH_SCRIPT_HOME/$PATCH_RESPONSE_FILENAME
status=$?
if [ $status -ne 0 ]; then
    DEBUG "Error: OPatch failed to apply the patch: " $status
    CLEANUP
    EXIT_FAILURE
fi

# Step 4: Post installation insructions.
# Cleanup patch remants.
#d $CURRENT_PWD
CLEANUP
EXIT_SUCCESS
