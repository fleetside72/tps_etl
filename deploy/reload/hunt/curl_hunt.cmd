curl -H "Content-Type: application/json" -X POST -d@./srce.json http://localhost:81/srce_set
curl -H "Content-Type: application/json" -X POST -d@./mapdef.json http://localhost:81/mapdef_set
curl -v -F upload=@//mnt/c/Users/fleet/Downloads/hunt.csv http://localhost:81/import?srce=hunt