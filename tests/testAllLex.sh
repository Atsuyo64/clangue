#!/usr/bin/env bash

for e in `ls tests/incorrect-examples`
do
    tput setaf 111
    cat tests/incorrect-examples/$e
    echo ''
    tput setaf 230
    echo Result:
	build/lex.out < tests/incorrect-examples/$e
    tput sgr0
    echo ''
done


for e in `ls tests/correct-examples`
do
    tput setaf 111
    cat tests/correct-examples/$e
    echo ''
    tput setaf 230
    echo Result:
	build/lex.out < tests/correct-examples/$e
    tput sgr0
    echo ''
done