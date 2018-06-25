curl -H "Content-Type: application/json" -X POST -d@./srce.json http://localhost/srce_set
curl -H "Content-Type: application/json" -X POST -d@./map.json http://localhost/mapdef_set
curl -H "Content-Type: application/json" -X POST -d@./vals.json http://localhost/mapval_set
curl -v -F upload=@./d.csv http://localhost/import?srce=dcard