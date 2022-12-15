#!/bin/bash
#encrypt.sh

read -sp 'Insert key:' key # Encrypting/Decrypting key
echo " "
read -sp 'Insert password:' password # Password
echo " "
echo Key: $key
echo Password: $password

# file that stores the password
echo "pass " > foofile

# compares lenght between keypass and password
if [ ${#key} -lt ${#password} ]; then
        echo "password is bigger"
fi

for ((i=0; i<${#password}; i++)); do

        keyConvertion="$((2#"$(echo "${key:i:1}" | xxd -b | awk '{print $2}')"))" # ascii > binary > decimal
        passwordConvertion="$((2#"$(echo "${password:i:1}" | xxd -b | awk '{print $2}')"))" # ascii > binary > decimal
        addition="$(($keyConvertion+$passwordConvertion))" # adds the two decimal values
        binaryConvertion="$(echo "obase=2;$addition" | bc)" # decimal > binary

        if [ ${#binaryConvertion} -lt 8 ]; then

                # filling the missing characters in the octet
                missingBits="$((8-${#binaryConvertion}))"
                character="$(echo "$(printf "%0*d" "$missingBits" 0)$binaryConvertion")"
                string="$(echo "$character" | perl -lape '$_=pack"(B8)*",@F')" # binary > ascii
                sed "s/\$/${string}/" -i foofile
        else
                character="$(echo "$binaryConvertion")"
                string="$(echo "character" | perl -lape '$_=pack"(B8)*",@F')" # binary > ascii
                sed "s/\$/${string}/" -i foofile
        fi
done
