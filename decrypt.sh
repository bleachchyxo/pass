#!/bin/bash
#decrypt.sh

key="b0578f4319d0d3b8e6dab5b958c43e321680771caf9cf29e5e5755fe442327f0"
dataFile="$(cat foofile | wc -l)"
characterNumber=$dataFile

# key into decimal
for ((i=0; i<$characterNumber; i++)); do
        keyConvertion="$((2#"$(echo "${key:$i:1}" | xxd -b | awk '{print $2}')"))"
        keyArray[$i]="$keyConvertion"
done

# encrypted password into decimal
declare -a words

input_file="foofile"

# decimal into an array
while read -r word; do
        words+=("$((2#$word))")
done < "$input_file"

for ((i=0; i<$characterNumber; i++)); do
        binaryConvertion="$(echo "obase=2;$((${words[$i]}-${keyArray[$i]}))" | bc)" # substract key from encrypted password
        if [ ${#binaryConvertion} -lt 8 ]; then
                # fill missing bits
                missingBits="$((8-${#binaryConvertion}))"
                # binary > ascii
                character="$(echo "$(printf "%0*d" "$missingBits" 0)$binaryConvertion" | perl -lape '$_=pack"(B8)*",@F')"
                printf "$character"
        fi
done

printf "\n"
