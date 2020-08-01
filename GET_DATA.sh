#!/bin/bash

BLUE="\e[1;34m"
WHITE="\e[1;37m"
RED="\e[1;31m"
GREEN="\e[1;32m"

MESSAGE="${BLUE} -> "
ERROR="${RED}ERROR: ${WHITE}"
SUCCESS="${GREEN}"

# This scripts gets all the data from the SRAG databases from Brazil's OpenDataSUS. The script verifies if the files exist and verifies the SHA256 sums.
echo
echo -e "${MESSAGE}Creating data directory..."
echo 
mkdir -p data

sums=(`cat sums | awk '{print $1}'`)

# The 2020 data constantly moves between adresses, since it's updated every few days, containing the new data. To get the data
# we use some grep magic
link2020=`curl -kL https://opendatasus.saude.gov.br/dataset/bd-srag-2020 | grep -o "https:.*\.csv"`

links=("https://opendatasus.saude.gov.br/dataset/e6b03178-551c-495c-9935-adaab4b2f966/resource/2182aff1-4e8b-4aee-84fc-8c9f66378a2b/download/influd14_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/e6b03178-551c-495c-9935-adaab4b2f966/resource/97cabeb6-f09e-47a5-8358-4036fb10b535/download/influd15_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/e6b03178-551c-495c-9935-adaab4b2f966/resource/dbb0fd9b-1345-47a5-86db-d3d2f4868a11/download/influd16_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/e6b03178-551c-495c-9935-adaab4b2f966/resource/aab28b3c-f6b8-467f-af0b-44889a062ac6/download/influd17_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/e6b03178-551c-495c-9935-adaab4b2f966/resource/a7b19adf-c6e6-4349-a309-7a1ec0f016a4/download/influd18_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/e99cfd21-3d8c-4ff9-bd9c-04b8b2518739/resource/9d1165b3-80a3-4ec4-a6ad-e980e3d354b2/download/influd19_limpo-27.04.2020-final.csv")

YEAR=("201"{4..9})

for i in "${!links[@]}"; do
    echo -e "${MESSAGE}Checking if already exists..."
    if test -f "data/${YEAR[$i]}.csv"; then
        current_sum=`sha256sum "data/${YEAR[$i]}.csv" | awk '{print $1}'`
        if [ $current_sum == "${sums[$i]}" ]; then
            echo -e "${SUCCESS}data/${YEAR[$i]}.csv already exists!"
            continue
        fi
    fi
    echo -e "${MESSAGE}Downloading the ${WHITE}${YEAR[$i]} ${BLUE}data...${WHITE}"
    
    curl -Lko "data/${YEAR[$i]}.csv" "${links[$i]}"
    
    echo
    echo -e "${MESSAGE}Checking sha256 sum for ${WHITE}${YEAR[$i]} ${BLUE}file..."
    
    current_sum=`sha256sum "data/${YEAR[$i]}.csv" | awk '{print $1}'`
    
    if [ $current_sum != "${sums[$i]}" ]; then
        echo -e "${ERROR}Checksum failed! Try downloading again..."
        exit 1
    else
        echo
        echo -e "${SUCCESS}Successfully downloaded files for year ${WHITE}${YEAR[$i]}${SUCCESS}!"
        echo 
    fi
done

echo -e "${MESSAGE}Downloading the ${WHITE}2020 ${BLUE}data..."
curl -Lo data/2020.csv $link2020

echo -e "${SUCCESS}Successfully downloaded all files!"