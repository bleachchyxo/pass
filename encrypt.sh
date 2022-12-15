#!/bin/bash
#encrypt.sh

read -sp 'Insert key:' keypass
echo " "
read -sp 'Insert password:' password
echo " "
echo Key: $keypass
echo Password: $password

# Compares lenght between keypass and password

if [ ${#keypass} -lt ${#password} ]; then
        echo "password is bigger"
fi

for ((i=0; i<${#password}; i++)); do

        keypassBinarytoDecimal="$((2#"$(echo "${keypass:i:1}" | xxd -b | awk '{print $2}')"))"
        passwordBinarytoDecimal="$((2#"$(echo "${password:i:1}" | xxd -b | awk '{print $2}')"))"

        if [ $(($keypassBinarytoDecimal+$passwordBinarytoDecimal)) -lt 255 ]; then

                wordsAdd="$(($keypassBinarytoDecimal+$passwordBinarytoDecimal))"
                decimalToBinary="$(echo "obase=2;$wordsAdd" | bc)"

                if [ ${#decimalToBinary} -lt 8 ]; then
                        missingBits="$((8-${#decimalToBinary}))"
                        # Filling the missing bits

                        character="$(echo "$(printf "%0*d" "$missingBits" 0)$decimalToBinary")"
                        string="$(echo "$character" | perl -lape '$_=pack"(B8)*",@F')"
                        sed "s/\$/${string}/" -i foofile
                 else
                        character="$(echo "$decimalToBinary")"
                        string="$(echo "character" | perl -lape '$_=pack"(B8)*",@F')"
                        sed "s/\$/${string}/" -i foofile
                        echo "$string"


                fi


        fi


done
