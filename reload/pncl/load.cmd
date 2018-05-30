curl -H "Content-Type: application/json" -X POST -d@./srce.json http://localhost:81/srce_set
curl -v -F upload=@//mnt/c/Users/ptrowbridge/Downloads/pncl.csv http://localhost:81/import?srce=PNCL