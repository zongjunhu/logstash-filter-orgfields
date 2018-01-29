load sample custom template

```
curl -H 'Content-Type: application/json' -XPUT http://es-m1:9200/_template/advancement -d @custom_mapping.json
```

fix csv with new line separated content in cell. original csv file: `test.csv`, new csv file: `test1.csv`

```
ruby clean_csv.rb test.csv test1.cvs
```
