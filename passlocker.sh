#!/bin/bash

if [ -z "$1" ]
then
        echo "hello world"

elif [ "$1" == "add" ]
then

        if [ -n "$2" ]
        then
                read -sp "Insert key:" key
                echo ""
                read -sp "Reinsert key:" keyConfirm
                echo ""

                key1="$(echo $key | sha256sum | awk '{print $1}')"
                key2="$(echo $keyConfirm | sha256sum | awk '{print $1}')"

                if [ "$key1" != "$key2" ]
                then
                        echo "Key does not match."

                else

                        read -sp "Enter password for $2:" password
                        echo ""
                        read -sp "Retype password for $2:" passwordConfirm
                        echo ""
                        pass1="$(echo $password | sha256sum | awk '{print $1}')"
                        pass2="$(echo $passwordConfirm | sha256sum | awk '{print $1}')"

                        if [ "$pass1" != "$pass2" ]
                        then
                                echo "Password does not match."
                        else
                                mkdir /home/$USER/.passlocker/$2

                                for ((i=0; i<${#password}; i++)); do
                                        keyConvertion="$((2#"$(echo "${key:i:1}" | xxd -b | awk '{print $2}')"))"
                                        passwordConvertion="$((2#"$(echo "${password:i:1}" | xxd -b | awk '{print $2}')"))"
                                        addition="$(($keyConvertion+$passwordConvertion))"
                                        binaryConvertion="$(echo "obase=2;$addition" | bc)"

                                        if [ ${#binaryConvertion} -lt 8 ]; then
                                                missingBits="$((8-${#binaryConvertion}))"
                                                character="$(echo "$(printf "%0*d" "$missingBits" 0)$binaryConvertion")"
                                                echo "$character" >> /home/$USER/.passlocker/$2/password
                                        else
                                                character="$(echo "$binaryConvertion")"
                                                echo "$character" >> /home/$USER/.passlocker/$2/password
                                        fi
                                done

                        fi

                fi

        else
                echo "Usage: passlocker [PASSWORD] [-add] [-ls] [-rm] [--help]"
        fi

elif [ "$1" == "ls" ]
then

        echo "dir"
        
        
elif [ -f "$1" ]
then

        read -sp "Insert you key:" keyText
        key="$(echo $keyText | sha256sum | awk '{print $1}')"
        dataFile="$(cat /home/$USER/.passlocker/$1/password | wc -l)"
        characterNumber=$dataFile

        for ((i=0; i<$characterNumber; i++)); do
                keyConvertion="$((2#"$(echo "${key:$i:1}" | xxd -b | awk '{print $2}')"))"
                keyArray[$i]="$keyConvertion"
        done

        declare -a words

        input_file="/home/$USER/.passlocker/$1/password"

        while read -r word; do
                words+=("$((2#$word))")
        done < "$input_file"

        for ((i=0; i<$characterNumber; i++)); do

                binaryConvertion="$(echo "obase=2;$((${words[$i]}-${keyArray[$i]}))" | bc)"
                if [ ${#binaryConvertion} -lt 8 ]; then
                        missingBits="$((8-${#binaryConvertion}))"
                        character="$(echo "$(printf "%0*d" "$missingBits" 0)$binaryConvertion" | perl -lape '$_=pack"(B8)*",@F')"
                        printf "$character"
                fi
        done
        
        printf "\n"
        
else

        echo "Usage: passlocker [PASSWORD] [-add] [-ls] [-rm] [--help]"

fi
