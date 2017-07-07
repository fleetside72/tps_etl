Concepts
======================================

pull various static files into postgres and do basic transformation without losing the original document
or getting into custom code for each scenario

## Storage
all records are jsonb
applied mappings are in associated jsonb documents

## Import
`COPY` function utilized

## Mappings
1. regular expressions are used to extract pieces of the json objects
2. the results of the regular expressions are bumped up against a list of basic mappings and written to an associated jsonb document

## Transformation tools
* `COPY`
* `regexp_matches()`

## Difficulties
Non standard file formats will require additional logic
