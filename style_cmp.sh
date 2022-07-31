#! /bin/bash
# 23019722 Isaac Huang
# look for files' stylistic similarities 

profiling() {
    tmpfile=$(mktemp)
    tmpfile2=$(mktemp)
    sed '/[[:punct:]]*/{ s/[^[:alpha:][:space:].!?,;'\''-]//g }' < $1 | sed 's/--/ /g' | sed 's/ - / /g' | tr -s ' ' '\012' >> "$tmpfile"

    # list of words
    keyArray=("also" "although" "and" "as" "because" "before" "but" 
            "for" "if" "nor" "of" "or" "since" "that" "though" "until" 
            "when" "whenever" "whereas" "which" "while" "yet")
    for key in ${keyArray[*]};
    do
        printf "%s\t%s\n" $key "$(tr -d '[:punct:]' < "$tmpfile"| grep -iwc $key)" >> "$tmpfile2"        
    done

    # word
    echo "word $(cat "$tmpfile" | tr -d '[:punct:]' | wc -w)" >> "$tmpfile2"
    # comma
    echo "comma $(cat "$tmpfile" | tr -cd , | wc -c)" >> "$tmpfile2"
    # semicolon
    echo "semi_colon $(cat "$tmpfile" | tr -cd ';' | wc -c)" >> "$tmpfile2"
    # sentence
    echo "sentence $(cat "$tmpfile" | tr -cd '.!?' | wc -c)" >> "$tmpfile2"
    # compound word
    echo "compound_word $(cat "$tmpfile" | grep -Ec "([a-zA-Z'][a-zA-Z]*-[a-zA-Z][a-zA-Z]*)")" >> "$tmpfile2"
    # contraction
    echo "contraction $(($(cat "$tmpfile" | awk 'match($0, /[a-zA-Z]'\''[a-zA-Z-]/) {print($0)}' | wc -w) - $(cat "$tmpfile" | awk 'match($0, /[a-z]'\''s/) {print($0)}' | wc -w)))" >> "$tmpfile2"
    cat "$tmpfile2" | sort
    rm "$tmpfile"
    rm "$tmpfile2"
}

create_profile() {
    tmpfile=$(mktemp)
    tmpfile2=$(mktemp)
    sed '/[[:punct:]]*/{ s/[^[:alpha:][:space:].!?,;'\''-]//g }' < $1 | sed 's/--/ /g' | sed 's/ - / /g' | tr -s ' ' '\012' >> "$tmpfile"

    # list of words
    keyArray=("also" "although" "and" "as" "because" "before" "but" 
            "for" "if" "nor" "of" "or" "since" "that" "though" "until" 
            "when" "whenever" "whereas" "which" "while" "yet")
    for key in ${keyArray[*]};
    do
        printf "%s\t%s\n" $key "$(tr -d '[:punct:]' < "$tmpfile"| grep -iwc $key)" >> "$tmpfile2"        
    done
    
    # word
    echo "word $(cat "$tmpfile" | tr -d '[:punct:]' | wc -w)" >> "$tmpfile2"
    # comma
    echo "comma $(cat "$tmpfile" | tr -cd , | wc -c)" >> "$tmpfile2"
    # semicolon
    echo "semi_colon $(cat "$tmpfile" | tr -cd ';' | wc -c)" >> "$tmpfile2"
    # sentence
    echo "sentence $(cat "$tmpfile" | tr -cd '.!?' | wc -c)" >> "$tmpfile2"
    # compound word
    echo "compound_word $(cat "$tmpfile" | grep -Ec "([a-zA-Z'][a-zA-Z]*-[a-zA-Z][a-zA-Z]*)")" >> "$tmpfile2"
    # contraction
    echo "contraction $(($(cat "$tmpfile" | awk 'match($0, /[a-zA-Z]'\''[a-zA-Z-]/) {print($0)}' | wc -w) - $(cat "$tmpfile" | awk 'match($0, /[a-z]'\''s/) {print($0)}' | wc -w)))" >> "$tmpfile2"
    file=$(echo $1 | cut -d. -f1)
    cat "$tmpfile2" | sort > ${file}_profile.txt
    rm "$tmpfile"
    rm "$tmpfile2"
}

distance() {
    name1=$(echo $1)
    name2=$(echo $2)
    total1=$(cat ./${name1%.txt}_profile.txt | awk 'NR==27 {print $2}')
    total2=$(cat ./${name2%.txt}_profile.txt | awk 'NR==27 {print $2}') 
    sentence1=$(($total1/$(cat ./${name1%.txt}_profile.txt | awk 'NR==17 {print $2}')))
    sentence2=$(($total2/$(cat ./${name2%.txt}_profile.txt | awk 'NR==17 {print $2}')))
    paste ./${name1%.txt}_profile.txt ./${name2%.txt}_profile.txt | 
    awk -v total1=$total1 -v total2=$total2 -v sentence1=$sentence1 -v sentence2=$sentence2 '
        {
            if ($1 == "word")
                n = NR+1
            else if ($1 == "sentence")
                sum += (sentence1-sentence2)^2
            else
                sum += (($2*1000/total1)-($4*1000/total2))^2
        }
        END{print "The Euclidian Distance between the two texts is:", sqrt(sum)}
        '
}

if [[ "$#" -eq 0 ]]
then  
  echo "Usage: $0 <file_name1> <file_name2_optional>" > /dev/stderr
  exit 0
elif [[ "$#" -eq 1 ]]
then
    if [[ -s $1 ]]
    then
        profiling $1
        exit 0
    else
        echo "Empty file or invalid file name." > /dev/stderr
        exit 1
    fi
elif [[ "$#" -eq 2 ]]
then    
    if [[ -s $1 ]] && [[ -s $2 ]]
    then
        create_profile $1
        create_profile $2
        distance $1 $2
        exit 0
    else
        echo "Input contains empty file or invalid file name." > /dev/stderr
        exit 1
    fi
else    
    echo "Invalid usage of function." > /dev/stderr
    exit 1
fi