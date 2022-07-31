#! /bin/bash
# Exploring Malaria Incidence Data and giving results to enquiries
file=incedenceOfMalaria.csv

if [[ "$#" -eq 0 ]]
then  
  echo "Usage: $0 <country_name> or <year>" > /dev/stderr
  exit 0
elif [[ "$#" -gt 1 ]]
then 
  echo "Only 1 argument needed, either <country_name> or <year>" > /dev/stderr
  exit 1
elif [[ "$1" =~ ^[0-9]+$ ]]
then
  if [[ "$1" -ge 2000 ]] && [[ "$1" -le 2018 ]]
  then
    result1=$(tail -n +2 $file | grep -i $1 | cut -d, -f1,3,4 | sort -t, -k3V | tail -1)
    echo "For the year $1, the country with the highest incidence was $(echo $result1 | cut -d, -f1), with a rate of $(echo $result1 | cut -d, -f3) per 1,000"
    exit 0
  else
    echo "Invalid year number" > /dev/stderr
    exit 1
  fi
else
  result2=$(tail -n +2 $file | grep -i -w "$@" | cut -d, -f1,3,4 | sort -t, -k3V | tail -1)
  if [[ ${#result2} -eq 0 ]]
  then
    echo "Invalid country name" > /dev/stderr
    exit 1
  else
    echo "For the country $(echo $result2 | cut -d, -f1), the year with the highest incidence was $(echo $result2 | cut -d, -f2), with a rate of $(echo $result2 | cut -d, -f3) per 1,000"
    exit 0
  fi
fi
