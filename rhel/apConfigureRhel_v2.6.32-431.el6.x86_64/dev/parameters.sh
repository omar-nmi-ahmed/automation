#!/bin/bash
(
unset VAR
if [ -z "${VAR+xxx}" ]; then echo JL:1 VAR is not set at all; fi
if [ -z "${VAR}" ];     then echo MP:1 VAR is not set at all; fi
VAR=
if [ -z "${VAR+xxx}" ]; then echo JL:2 VAR is not set at all; fi
if [ -z "${VAR}" ];     then echo MP:2 VAR is not set at all; fi
)


unset VAR
if [ -n "${VAR-}" ]; then
    echo "VAR is set and is not empty"
elif [ "${VAR+DEFINED_BUT_EMPTY}" = "DEFINED_BUT_EMPTY" ]; then
    echo "VAR is set, but empty"
else
    echo "VAR is not set"
fi
VAR=
function ApVariableDefinedAndSet()
{
    # Returns true if the variable is defined and has a value
    # Returns false otherwise.
    #
    if [ -n "${1}" ]; then
        return 0
    fi
    return 1
}    

function x() 
{
if [ -n "${VAR-}" ]; then
    echo "VAR is set and is not empty"
    return 1
elif [ "${VAR+DEFINED_BUT_EMPTY}" = "DEFINED_BUT_EMPTY" ]; then
    echo "VAR is set, but empty"
    return 0
else
    echo "VAR is not set"
    return 0
fi
}
echo "new test"
unset VAR
if [ "ApVariableDefinedAndSet" == true ]; then
  echo "error"
fi
echo "this is the value of VAR ${x}"
