#! /bin/bash
# Finding all the common words in text

tmpfile=$(mktemp)
if [[ "$#" -eq 0 ]]
then  
  echo "Usage: $0 [-w word | -nth N] <directory of text files>" > /dev/stderr
  exit 0
elif [[ "$#" -eq 1 ]]
then
    for f in $1/*.txt
    do
        if [[ -s ${f} ]]
        then
            sed 's/[^a-zA-Z]/ /g' < ${f} | tr -s ' ' '\012' | sort | uniq -c | sort -k 1nr | head -1 >> "$tmpfile"
        fi
    done
    result=$(cat "$tmpfile" | sed 's/[^a-zA-Z]//g' | tr -s " " '\012' | sort | uniq -c | sort -k 1nr | head -1)
    echo "The 1th most common word is \"$(echo $result | cut -d" " -f2)\" across $(echo $result | cut -d" " -f1) files"
    exit 0
elif [[ "$#" -eq 3 ]]
then 
    if [[ "$2" =~ ^[0-9]+$ ]]
    then 
        for f in $3/*.txt
        do
            if [[ -s ${f} ]]
            then
                sed 's/[^a-zA-Z]/ /g' < ${f} | tr -s ' ' '\012' | sort | uniq -c | sort -k 1nr | tail -n +$2 | head -1 >> "$tmpfile"
            fi
        done
        result2=$(cat "$tmpfile" | sed 's/[^a-zA-Z]//g' | tr -s " " '\012' | sort | uniq -c | sort -k 1nr | head -1)
        echo "The $2th most common word is \"$(echo $result2 | cut -d" " -f2)\" across $(echo $result2 | cut -d" " -f1) files"
        exit 0
    else
        for f in $3/*.txt
        do
            if [[ -s ${f} ]]
            then
                sed 's/[^a-zA-Z]/ /g' < ${f} | grep -o -F "$2" | uniq -c >> "$tmpfile"
                echo "${f}" >> "$tmpfile"
            fi
        done
        exit 0
    fi
else
    echo "Invalid arguments" > /dev/stderr
    exit 1
fi

rm "$tmpfile"
