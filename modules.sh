#!/bin/bash

REPOQUERY='repoquery --disablerepo=* --enablerepo=rawhide'

mkdir -p out
rm -f out/*

function output() {
    rpms=$1
    prefix=$2
    
    touch out/${prefix}.txt 
    touch out/${prefix}-rpm.txt
    
    for rpm in $rpms; do
        npm=$($REPOQUERY --provides $rpm | grep -oP '(?<=npm\().*(?=\))')
        if [[ $? -eq 0 ]]; then
            echo $npm >> out/${prefix}.txt
            echo $npm $rpm >> out/${prefix}-rpm.txt
        fi
    done
}

output "$($REPOQUERY --qf='%{name}' --whatrequires nodejs)" modules
output "$($REPOQUERY --qf='%{name}' --whatrequires 'nodejs(abi)')" native

awk 'FNR==NR { a[$0]; next } !($0 in a)' out/native.txt out/modules.txt > out/purejs.txt
awk 'FNR==NR { a[$0]; next } !($0 in a)' out/native-rpm.txt out/modules-rpm.txt > out/purejs-rpm.txt

python reviews.py

cat out/modules.txt > out/all.txt
cat out/reviews.txt >> out/all.txt

cat out/modules-rpm.txt > out/all-rpm.txt
cat out/reviews-rpm.txt >> out/all-rpm.txt

echo -e "purejs\t$(cat out/purejs.txt | wc -l)" > out/counts.txt
echo -e "native\t$(cat out/native.txt | wc -l)" >> out/counts.txt
echo -e "reviews\t$(cat out/reviews.txt | wc -l)" >> out/counts.txt
echo -e "total\t$(cat out/all.txt | wc -l)" >> out/counts.txt
