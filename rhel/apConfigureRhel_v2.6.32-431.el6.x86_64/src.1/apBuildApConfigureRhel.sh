#!/bin/bash
# Trace control, +x is off, -x is on
#
set +x

# Include Automation Framework functions.
#
source apUtilities.sh

# Script definitions.
#
AP_HOME=/opt/aproject/ap_v0.0.1/rhel/apConfigureRhel_v2.6.32-431.el6.x86_64
AP_SRC=$AP_HOME/src
AP_BIN=$AP_HOME/bin
AP_RELEASE=$AP_HOME/release
AP_SCRIPT_NAME=apConfigureRhel_v2.6.32-431.el6.x86_64.tar

function ExecutePreScriptSteps()
{
    # Step 1 of 3: Pre-script Steps.
    #
    ApOutput " Step 1 of 3: Pre-script Steps."
    #
    # Validate Script Parameters
    #
    ApOutput "... Validating script input parameters."
    ApOutput "... Input parameters are valid."
    
    # Validate Prerequisites
    #
    # This script must be run as root.
    #
    ApOutput "... Validating script prerequisites."
    ApOutput "... Checking that script is running as root."
    if [ "ApGetExecute" == true ]; then 
        if [ ApRunningAsRoot != true ]; then
            ApOutput "ERROR: Script must be run as root."
            ApExitFailure
        fi
    fi
}
    
function ExecuteInstallationConfigurationSteps()
{
    # Step 2 of 3: Installation/Configuration Steps.
    #
    ApOutput " Step 2 of 3: Installation/Configuration Steps."
    
    # This script executes in the source directory.
    #
    cd $AP_SRC

    # Verify that the release directory is available.  The release directory contains the 
    # product version of the apConfigureRhel.sh script.
    #
    ApOutput "... Verifying location of release directory.."
    if [ ! -d "$AP_RELEASE" ]; then
        ApOutput "ERROR: The release directory is missing. Cannot find the following directory:"
        ApOutput "ERROR: $AP_RELEASE."
        ApOutput "ERROR: Please provide the location of the release directory."
        ApExitFailure
    fi
    ApOutput "... The release directory is valid. The directory is:"
    ApOutput "... $AP_RELEASE."

    # Make the bin directory.  The bin directory contains the product version of 
    # the apConfigureRhel.sh script.
    #
    ApOutput "... Making bin directory."
    if [ -d "$AP_BIN" ]; then
        ApOutput "ERROR: Bin directory already exists."
        ApOutput "ERROR: Please save or delete the directory prior to running this script."
        ApExitFailure
    else
        mkdir $AP_BIN
	chown aproject:aproject $AP_BIN
	chmod 755 $AP_BIN
	if [ "$?" -ne 0 ]; then 
            ApOutput "ERROR: Directory creation failed."
            ApExitFailure
	fi
        ApOutput "... Bin directory created successfully."
    fi

    ApOutput "... Copying public-yum-ol6 to"
    ApOutput "... $AP_BIN."
    ApOutput "... The repo, public-yum-ol6, contains the RPMs to be installed on RHEL."
    ApExecute cp -f public-yum-ol6.repo $AP_BIN
    ApExecute chown aproject:aproject $AP_BIN/public-yum-ol6.repo
    ApExecute chmod 644 $AP_BIN/public-yum-ol6.repo
   
    ApOutput "... Copying RPM-GPG-KEY-oracle to"
    ApOutput "... $AP_BIN."
    ApExecute cp -f RPM-GPG-KEY-oracle $AP_BIN
    ApExecute chown aproject:aproject $AP_BIN/RPM-GPG-KEY-oracle
    ApExecute chmod 644 $AP_BIN/RPM-GPG-KEY-oracle

    ApOutput "... Copying RPM-GPG-KEY-oracle-ol6 to"
    ApOutput "... $AP_BIN."
    ApExecute cp -f RPM-GPG-KEY-oracle-ol6 $AP_BIN
    ApExecute chown aproject:aproject $AP_BIN/RPM-GPG-KEY-oracle-ol6
    ApExecute chmod 644 $AP_BIN/RPM-GPG-KEY-oracle-ol6

    ApOutput "... Copy RhelRPmList to"
    ApOutput "... $AP_BIN."
    ApOutput "... RhelRpmList.txt contains the list of RPMs to be installed on RHEL."
    ApExecute cp -f rhelRpmList.txt $AP_BIN
    ApExecute chown aproject:aproject $AP_BIN/rhelRpmList.txt
    ApExecute chmod 644 $AP_BIN/rhelRpmList.txt

    ApOutput "... Copying apConfigureRhel.sh to"
    ApOutput "... $AP_BIN."
    ApExecute cp -f apConfigureRhel.sh $AP_BIN
    ApExecute chown aproject:aproject $AP_BIN/apConfigureRhel.sh
    ApExecute chmod 644 $AP_BIN/apConfigureRhel.sh

    ApOutput "... Building script payload."
    ApExecute tar -C $AP_HOME -cf $AP_RELEASE/$AP_SCRIPT_NAME bin
    ApExecute chown aproject:aproject $AP_RELEASE/$AP_SCRIPT_NAME
    ApExecute chmod 644 $AP_RELEASE/$AP_SCRIPT_NAME
    ApOutput "Step 2 of 3: PASSED."
}


function ExecutePostScriptSteps()
{
    # Step 3 of 3: Post-script Steps.
    #
    ApOutput " Step 3 of 3: Post-script Steps."
    ApCleanup
    ApOutput "Step 3 of 3: PASSED."
}

function OutputHelpUsage()
{
    ApOutput "${0} Usage $0 --h | --help or --e | --execute or --t or --test"
}

function OutputHelp()
{
    OutputHelpUsage
    
    ApOutput "Automation Project Script to configure RHEL to use the Oracle Identity Management Suite of tools."
    ApOutput "Mandatory arguments to long options are mandatory for short options too."
    ApOutput "--e, --execute           execute all features of the script as opposed to test mode."
    ApOutput "--t, --test              run the script in test mode where only simply bash commands"
    ApOutput "                         are executed and no operational changes are made to RHEL."
    ApOutput "                         Useful for debugging scripts."
    ApOutput "--h, --help              prints this text."
    ApOutput
    ApOutput "Exit status:"
    ApOutput "     0  if OK,"
    ApOutput "     1  if error"
}

# Main Script Body
#
ApOutput "Automation System $SCRIPT_VERSION"
ApOutput "================================================================"
ApOutput "Oracle Identity Management Installation and Configuration Script"
ApOutput "================================================================"
ApOutput "Release Date: 11-04-2014"
ApOutput "------------------------"
ApOutput "Target Platform: Host: `(hostname -f)` at IP: `(hostname -I)`"
ApOutput "Target Product: apConfigureRhel_v2.6.32-431.el6.x86_64"
ApOutput "Current Script Execution Directory:"
ApOutput "`(pwd)`"
ApOutput "------------------------"

# Set testing: False means test, True means execute all commands.
#
ApSetExecute false
ApBegin

# Parse parameters to determine the testing mode.
#
if [ $# -ge 1 ]; then
    for i in "$@"; do
        case $i in
            --h|--help)
	        OutputHelp
	        ApExitFailure
	        ;;
            --e|--execute)
	        ApSetExecute true
                ;;
            --t|--test)
                ApSetExecute false
                ;;
            *)
                ApOutput "${0} Error: Invalid parameter specified: '${1}'"
                OutputHelpUsage
		ApExitFailure
                ;;
        esac
    done
else
    ApOutput "${0} Error: Execution mode is required to be specified."
    OutputHelpUsage
    ApExitFailure
fi

ApOutput "Beginning script execution at: `(date)`"
ExecutePreScriptSteps
ExecuteInstallationConfigurationSteps
ExecutePostScriptSteps
set +x
ApExitSuccess
