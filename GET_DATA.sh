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

links=("https://opendatasus.saude.gov.br/dataset/18254c56-0859-4073-a6ea-977c8b85bd28/resource/861e8067-a23d-49f6-93a7-9b83c2f802ac/download/influd14_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/18254c56-0859-4073-a6ea-977c8b85bd28/resource/e5f0102f-a2e5-41d9-ac05-88e438c578ce/download/influd15_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/18254c56-0859-4073-a6ea-977c8b85bd28/resource/4b45e6f9-556e-49af-b806-be9b79ca2730/download/influd16_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/18254c56-0859-4073-a6ea-977c8b85bd28/resource/7b586a1c-6a9d-455c-8503-726bc8157344/download/influd17_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/18254c56-0859-4073-a6ea-977c8b85bd28/resource/cce2d3de-4fd4-4e40-937d-140abf032c8c/download/influd18_limpo-final.csv" "https://opendatasus.saude.gov.br/dataset/b80b639a-1f0a-4712-a997-0b8a65662a06/resource/fe995608-bf72-42c4-bb20-3ad76766745f/download/influd19_limpo-27.04.2020-final.csv")

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