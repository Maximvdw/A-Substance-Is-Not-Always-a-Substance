#!/bin/bash

echo "construct file exact_match_chebi.ttl"

#pushd data/source/chebi
echo "Download chebi owl"
curl https://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi.owl.gz -o data/source/chebi/chebi.owl.gz
gzip -dc data/source/chebi/chebi.owl.gz > data/source/chebi/chebi.owl
#popd
/opt/apache-jena-5.6.0/bin/riot --formatted=turtle data/source/chebi/chebi.owl > data/source/chebi/chebi.ttl
rm data/source/chebi/chebi.owl
rm data/source/chebi/chebi.owl.gz

echo "merge chebi and chemical substance"

/opt/apache-jena-5.6.0/bin/riot --output=TURTLE data/source/chebi/chebi.ttl  data/processed/rdf/substances_taxonomy.ttl >  /tmp/chebi.ttl
echo "query exact match"
/opt/apache-jena-5.6.0/bin/sparql --results=TURTLE --data=/tmp/chebi.ttl  --query bash/exact_match_chebi.rq  > data/processed/rdf/exact_match_chebi.ttl

/opt/apache-jena-5.6.0/bin/riot --output=turtle /tmp/chebi.ttl data/processed/rdf/exact_match_chebi.ttl  > /tmp/chebiplusskos.ttl

echo "query annotations"
/opt/apache-jena-5.6.0/bin/sparql --results=TTL --data=/tmp/chebiplusskos.ttl  --query bash/chebi_annotaties.rq  > data/processed/rdf/chebi_annotations.ttl

/opt/apache-jena-5.6.0/bin/riot --formatted=TURTLE data/processed/rdf/substances_taxonomy.ttl  data/processed/rdf/chebi_annotations.ttl  data/processed/rdf/exact_match_chebi.ttl > /tmp/merged.ttl

cp /tmp/merged.ttl data/processed/rdf/substances_taxonomy.ttl

/opt/apache-jena-5.6.0/bin/sparql --results=CSV --data=data/processed/rdf/substances_taxonomy.ttl --query bash/chebi_to_table.rq > data/processed/chebi.csv
