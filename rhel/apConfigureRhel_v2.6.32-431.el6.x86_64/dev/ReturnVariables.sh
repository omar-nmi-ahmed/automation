#!/bin/bash
set -x
function pass_back_a_string() {
    eval "$1='foo bar rab oof'"
}

return_var=''
pass_back_a_string return_var
echo $return_var
