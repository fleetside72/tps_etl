curl -H "Content-Type: application/json" -X POST -d@./srce.json http://localhost/source
curl -H "Content-Type: application/json" -X POST -d@./map.json http://localhost/regex
curl -H "Content-Type: application/json" -X POST -d@./vals.json http://localhost/mapping
curl -v -F upload=@./d.csv http://localhost/import?srce=dcard