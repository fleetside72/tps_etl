curl -H "Content-Type: application/json" -X POST -d@./srce.json http://localhost:81/srce_set
curl -v -F upload=@//mnt/c/Users/ptrowbridge/Downloads/pnco.csv http://localhost:81/import?srce=PNCO