# COVID-19 Classifier from Brazil's OpenDataSUS SRAG data
This repository creates a XGBoost classification model for COVID-19 using Brazil's OpenDataSUS data as base. The is described in [this medium post](https://medium.com/@ptcar2009/building-a-covid-19-classifier-for-brazils-opendatasus-data-bd365b529b1b).

The code is in the two notebooks in the repo, the data can be downloaded from running the [GET_DATA.sh](./GET_DATA.sh) on a `bash` terminal with `curl` installed. If running on windows or if you don't have `curl` installed, either install it or download the data from these links:
    
- https://s3-sa-east-1.amazonaws.com/ckan.saude.gov.br/SRAG/2020/INFLUD-29-07-2020.csv
    - save it as data/2020.csv, inside the cloned repo
- https://opendatasus.saude.gov.br/dataset/bd-srag-2012-a-2018
    - this contains the other years. Go to 'Explorar' -> 'Baixar' and download each year's data with the name data/{year}.csv

The data can also be downloaded by running `make get-data`.

The project uses `python3` and the libs `jupyter`, `pandas`, `numpy`, `plotly`, `sagemaker`, `boto3`, `chart_studio` and `matplotlib`. To install everything, either install it via the `requirements.txt` file or run `make deps`.

If running everything at once, run `make init`.