

deps:
	pip3 install -r requirements.txt

get-data:
	bash GET_DATA.sh

init: deps get-data