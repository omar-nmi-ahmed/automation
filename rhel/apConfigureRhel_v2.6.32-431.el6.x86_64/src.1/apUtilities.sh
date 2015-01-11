#!/bin/bash
set +x

# Script definitions.
#
_ApOutput=on # Debug Information
_ApExecute=false # Debug Information
AP_EXIT_STATUS=true
AP_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_VERSION="v0.0.1"
AP_BIN=$AP_HOME/bin
CURRENT_RHEL_VERSION=`rpm -q --whatprovides /etc/redhat-release`
TARGET_RHEL_VERSION="redhat-release-server-6Server-6.5.0.1.el6.x86_64"

SCRIPT_NAME=`basename $(readlink -nf $0) .sh`
SCRIPT_START_TIME=0
SCRIPT_END_TIME=""

# Helper Functions
#
function ApOutput()
{
    [ "$_ApOutput" == "on" ] && echo -e [${SCRIPT_NAME}] $@
}

function ApCleanup()
{
    ApOutput "... Performing script post processing cleanup."
}

function ApBegin()
{
    SCRIPT_START_TIME=`date +%s.%N`
    ApOutput "Beginning script execution at: `(date)`"
}

function ApExit()
{
    # Check that the ApBegin function has been called.  It needs to be invoked at some point
    # prior to this function so that the time calculations function properly.
    #
    if [ "${SCRIPT_START_TIME}" == 0 ]; then
        ApOutput "ERROR: ApBegin was not called prior to calling ApExit."
        ApOutput "ERROR: Script execution elapsed times are invalid."
        AP_EXIT_STATUS=false
    fi

    # The AP_EXIT_STATUS indicates if there is an ERROR in the script.
    #
    if [ "$AP_EXIT_STATUS"  == false ]; then
        ApOutput "ERROR: Script execution is unsuccessful and is aborting."
    else
        ApOutput "Script execution is successful."
    fi
        
    # Display script summary information.
    #
    ApOutput "Ending script execution at: `(date)`"
    SCRIPT_END_TIME=`date +%s.%N`
    SCRIPT_ELAPSED_TIME=""
    ApElapsedTime $SCRIPT_START_TIME $SCRIPT_END_TIME SCRIPT_ELAPSED_TIME
    ApOutput "Elapsed script execution time: $SCRIPT_ELAPSED_TIME"
    exit `$AP_EXIT_STATUS`
}
function ApExitSuccess()
{
    AP_Exit_STATUS=true
    ApExit
}

function ApExitFailure()
{
    AP_EXIT_STATUS=false
    ApExit
}

function ApRunningAsRoot()
{
    if [[ $EUID -ne 0 ]]; then
      return true
    else
      return false
    fi
}

function ApExecute()
{
    [ "$_ApExecute" == true ] && `$@`
}

function ApGetExecute()
{
    "$_ApExecute"
}

function ApSetExecute()
{
    _ApExecute=$1
}

function ApFormatTime() {
# TODO: This function needs to be refactored.
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    echo "$day"d "$hour"h "$min"m "$sec"s
}

function ApElapsedTime ()
{
    # Description: Function to compute elapsed time:
    # $1 = input, the start time, in format (date +%s.%N)
    # $2 = input, the ending time in format (date +%s.%N)
    # $3 = output, the elapsed time, in format (date +%s.%N)

    # **** TODO: check for null values.

    # Use local variables to hold the input parameters.
    #
    local StartTime=$1
    local StopTime=$2
    NumberOfSecondsPerMinute=60
    NumberOfSecondsPerHour=60*$NumberOfSecondsPerMinute
    NumberOfSecondsPerDay=24*$NumberOfSecondsPerHour

    # Time calculations
    #
    DeltaTime=$(echo "$StopTime - $StartTime" | bc)
    DeltaDays=$(echo "$DeltaTime/$NumberOfSecondsPerDay" | bc)
    DeltaTimeLessDays=$(echo "$DeltaTime-$NumberOfSecondsPerDay*$DeltaDays" | bc)
    DeltaHours=$(echo "$DeltaTimeLessDays/$NumberOfSecondsPerHour" | bc)
    DeltaTimeLessDaysAndHours=$(echo "$DeltaTimeLessDays-$NumberOfSecondsPerHour*$DeltaHours" | bc)
    DeltaMinutes=$(echo "$DeltaTimeLessDaysAndHours/$NumberOfSecondsPerMinute" | bc)
    DeltaSeconds=$(echo "$DeltaTimeLessDaysAndHours-$NumberOfSecondsPerMinute*$DeltaMinutes" | bc)
    ElapsedTime=`printf "%d:%02d:%02d:%02.4f\n" $DeltaDays $DeltaHours $DeltaMinutes $DeltaSeconds`
    eval "$3='$ElapsedTime'"
}   

