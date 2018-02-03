load sample custom template

```
curl -H 'Content-Type: application/json' -XPUT http://es-m1:9200/_template/advancement -d @custom_mapping.json
curl -H 'Content-Type: application/json' -XPUT http://es-m1:9200/_template/sparktest -d @sparktest_mapping.json
```

fix csv with new line separated content in cell. original csv file: `test.csv`, new csv file: `test1.csv`

```
ruby clean_csv.rb test.csv test1.cvs
```
force logstash `file` input plugin to reload data.

1. shut down logstash
2. delete index in elasticsearch
3. delete sincedb for file input of interest.

Each file plugin in instance has status recorded by default under `/var/lib/logstash`.

```
ls -l /var/lib/logstash/plugins/inputs/file/.sincedb_*
```
First number in each `sincedb` file is the inode of each input file. 

1. The inode number (or equivalent).
2. The major device number of the file system (or equivalent).
3. The minor device number of the file system (or equivalent).
4. The current byte offset within the file.

more details at https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html.

list all file inodes in input data directory to find a match.

```
for i in /data/*; do echo -n "$i "; ^C -i $i; done
```

to delete an index from elasticsearch.

```
curl -XDELETE http://es-q1:9200/index_name
```

to double check index mapping

```
curl http://es-q1:9200/index_name/_mapping?pretty 
```

to review overall index list in elasticsearch
```
http://es-q1:9200/_cat/indices?v
```

watch logstash live log.

```
tail -f /var/log/logstash/logstash-plain.log
```
