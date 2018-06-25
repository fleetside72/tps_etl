curl -H "Content-Type: application/json" -X POST -d@./srce.json http://localhost:81/srce_set
curl -H "Content-Type: application/json" -X POST -d@./map.json http://localhost:81/mapdef_set
curl -H "Content-Type: application/json" -X POST -d@./vals.json http://localhost:81/mapval_set
curl -v -F upload=@//mnt/c/Users/ptrowbridge/Downloads/pncc.csv http://localhost:81/import?srce=PNCC