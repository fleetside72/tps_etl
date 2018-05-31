curl -H "Content-Type: application/json" -X POST -d@./srce.json http://localhost:81/srce_set
curl -H "Content-Type: application/json" -X POST -d@./mapdef.json http://localhost:81/mapdef_set
curl -H "Content-Type: application/json" -X POST -d@//mnt/c/Users/fleet/Documents/tps_etl/reload/mapval.json http://localhost:81/mapval_set
curl -v -F upload=@//mnt/c/Users/fleet/Downloads/DFS-Search-20180529.csv http://localhost:81/import?srce=dcard