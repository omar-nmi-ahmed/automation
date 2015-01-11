#!/bin/bash
# Trace control, +x is off, -x is on
#
set +x
  
# Include Automation Framework functions.
#
source apUtilities.sh

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
    
    # Ensure version of target product is correct for this script.
    #
    ApOutput "... Validating target is running the correct version of RHEL for this configuration."
    ApOutput "... Current version of RHEL is \"$CURRENT_RHEL_VERSION\"."
    if [ "$CURRENT_RHEL_VERSION" != "$TARGET_RHEL_VERSION" ]; then
        ApOutput "ERROR: Invalid target version of RHEL."
        ApCleanup
        ApExitFailure
    else
        ApOutput "... Current version of RHEL is correct."
    fi
    ApOutput "Step 1 of 3: PASSED."
}

function ExecuteInstallationConfigurationSteps()
{
    # Step 2 of 3: Installation/Configuration Steps.
    #
    ApOutput " Step 2 of 3: Installation/Configuration Steps."
    
    cd $AP_HOME
    ApOutput "... Copying public-yum-ol6 to /etc/yum.repos.d."
    ApExecute cp -f public-yum-ol6 /etc/yum.repos.d/public-yum-ol6
    
    ApOutput "... Copying RPM-GPG-KEY-oracle to /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle."
    ApExecute cp -f RPM-GPG-KEY-oracle /etc/yum.repos.d/public-yum-ol6
    
    ApOutput "... Copying RPM-GPG-KEY-oracle-ol6 to /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle-ol6."
    ApExecute cp -f RPM/RPM-GPG-KEY-oracle-ol6 /etc/pki/rpm-gpg
    
    # List all ICAM rpms.
    ApOutput "... Listing all RHEL required RPMs:"
    while read package
    do
      ApOutput "...... Installing package: $package"
    done < `(pwd)`/rhelRpmList.txt
    
    # Install all the RHEL RPMs.
    ApExecute yum -y install $(cat rhelRpmList.txt)
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
    ApOutput "     1  if ERROR"
}

# Main Script Body
#
ApOutput "Automation System $SCRIPT_VERSION"
ApOutput "================================================================"
ApOutput "Oracle Identity Management Installation and Configuration Script"
ApOutput "================================================================"
ApOutput "Release Date: 10-29-2014"
ApOutput "------------------------"
ApOutput "Target Platform: Host: `(hostname -f)` at IP: `(hostname -I)`"
ApOutput "Target Product: RHEL v2.6.32-431.el6.x860"
ApOutput "Current Script Execution Directory:"
ApOutput "`(pwd)`"
ApOutput "------------------------"

# Set default script execution mode, testing : False means test, True means execute all commands.
#
ApSetExecute false

# All scripts must start with this call to setup the Automation Project's Framework.
#
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
                ApOutput "${0} ERROR: Invalid parameter specified: '${1}'"
                OutputHelpUsage
		ApExitFailure
                ;;
        esac
    done
else
    ApOutput "${0} ERROR: Execution mode is required to be specified."
    OutputHelpUsage
    ApExitFailure
fi

ExecutePreScriptSteps
ExecuteInstallationConfigurationSteps
ExecutePostScriptSteps
ApExit
set +x
