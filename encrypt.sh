#!/bin/bash
#encrypt.sh

read -sp 'Insert key:' key # The password for decrypting
echo " "
read -sp 'Insert password:' password # The actual password being ecrypted
echo " "
echo Key: $key
echo Password: $password

# Making the file where the password will be stored
echo "pass " > foofile

# Compares lenght between keypass and password
if [ ${#key} -lt ${#password} ]; then
        echo "password is bigger"
fi

for ((i=0; i<${#password}; i++)); do

        keyConvertion="$((2#"$(echo "${key:i:1}" | xxd -b | awk '{print $2}')"))" # ASCII > BINARY > DECIMAL
        passwordConvertion="$((2#"$(echo "${password:i:1}" | xxd -b | awk '{print $2}')"))" # ASCII > BINARY > DECIMAL
        addition="$(($keyConvertion+$passwordConvertion))" # Adds the two decimal values

        if [ $addition -lt 255 ]; then

                binaryConvertion="$(echo "obase=2;$addition" | bc)" # Sum result > BINARY

                if [ ${#binaryConvertion} -eq 8 ]; then

                        character="$(echo "$binaryConvertion")"
                        string="$(echo "character" | perl -lape '$_=pack"(B8)*",@F')" # BINARY > ASCII
                        sed "s/\$/${string}/" -i foofile
                        
                else
                        #Filling the missing bits
                        missingBits="$((8-${#binaryConvertion}))"
                        character="$(echo "$(printf "%0*d" "$missingBits" 0)$binaryConvertion")"
                        string="$(echo "$character" | perl -lape '$_=pack"(B8)*",@F')" # BINARY > ASCII
                        sed "s/\$/${string}/" -i foofile

                fi


        fi


done
