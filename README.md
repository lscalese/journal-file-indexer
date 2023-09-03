 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/journal-file-indexer)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fjournal-file-indexer&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fjournal-file-indexer)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fjournal-file-indexer&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fjournal-file-indexer)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

# IRIS Journal file indexer

**Important** : *It is not ready to use. This package is currently on OEX only to facilitate iterative reviews during development. Consider it will be ready only from version 1.0.0.*

## Description

The log file search functionality integrated into the management portal is currently experiencing response time problems on large files. The objective is to temporarily index the data in a log file in a database in order to improve search performance.

## Release note

**Version 0.2.0**

See progression on this [GitHub project DashBoard](https://github.com/users/lscalese/projects/2/views/5)

New features: 
 
 * Search indexed journal entries (in terminal mode).  
 * ^ZJRNFILT routine can be used to filter journal entries to index (or not).  

Improvements:

 * During the indexer process we can pause\resume or cancel the operation.  
 * Add index on global subscript.  

**Version 0.1.0**

This version includes : 

* Tables to store journal file data into the IRISTEMP database.  
* Process to read a journal file and store its content in database.  
* Unit tests of indexer process.  

## Installation

```objectscript
zpm "install journal-indexer"
```
Or using docker:  

```bash
git clone https://github.com/lscalese/journal-file-indexer.git
cd journal-file-indexer
docker-compose up -d
```

## Run Unit Tests
  
```objectscript
zpm "test journal-indexer"
```

## Usage

### Store data from a journal file in database

#### Using a wizard in the terminal  
  
```objectscript
Do ##class(dc.journalindexer.services.Indexer).RunIndex()
```

Type the path of a journal file or `?` to show list of journal files on this system:
  
```
Journal file path (? help, q quit): ?
  1) /usr/irissys/mgr/journal/20230805.003
  2) /usr/irissys/mgr/journal/20230805.004
  3) /usr/irissys/mgr/journal/20230806.001
  4) /usr/irissys/mgr/journal/20230807.001
  5) /usr/irissys/mgr/journal/20230808.001
Journal file path (? help, q quit): 2
Apply filter routine ^JRNFILT (Y)es or (N)o  default:(No) ? 
```
  
Then type a path or just a number related to a journal file, typing `2` is similar to `/usr/irissys/mgr/journal/20230805.004`:

If the routine `^JRNFILT` exists, you can use it to filter journal entries to index. This message is not show if the routine does not exist.  
  
```
Journal file path (? help, q quit): 2
Start read journal    17087424 / 17087424  
FlushBuffer...
BuildIndices...
Delete old journal ...
OK
```

**Note:** *If journal file are zipped either `/usr/irissys/mgr/journal/20230805.004` or `/usr/irissys/mgr/journal/20230805.004z` work as well. No matter about the suffix `z`.*  


#### Programmatically
  
```objectscript
Set sc = ##class(dc.journalindexer.services.Indexer).Index("/usr/irissys/mgr/journal/20230805.004", "20230805.004", "")
```

The first argument is the path of the journal file to store in database.  
The second is optional, this is the name of the journal file (by default: `##class(%File).GetFilename(JournalFile)`).  
The third is also optional, this is the ressource name if you would like to wake up process with `$SYSTEM.Event`. It's used by `RunIndex` to show the progression.  
See the [official documentation](https://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?LIBRARY=%25SYS&PRIVATE=1&CLASSNAME=%25SYSTEM.Event) for more information about `$SYSTEM.Event`.  


#### About the storage

We consider these data are temporary.  
The usual use case is to index a journal file, perform searches and then delete them.  
So, all data are physically stored in IRISTEMP to avoid indexing a journal file generate a new journal file ...
By default, the process keep maximum 5 indexed journal files.  
If 6th is indexed the oldest is automatically removed from the database.  

Yon can increase or decrease this value with this config :  
  
```objectscript
Do ##class(dc.journalindexer.services.Config).SetConfig("MaxJournalRetention", 5)
```

### View indexed data

### Command line tool

A command line tool is available to navigate in indexed journal file data and also make a search.  

```objectscript
Do ##class(dc.journalindexer.services.Search).SearchInIndexedJournal()
```

```
                        Search in indexed journal files
                        -------------------------------
 1) Show list of indexed journal files.
 2) Navigate.
 3) Search (list view).
 4) Search (detail view).
 5) Index a journal file in database.

(Q)uit or (#) Menu item =>
```

If you select the option 2, 3, or 4, you have to select an indexed journal file.  
The option 5 is just a shortcut to `Do ##class(dc.journalindexer.services.Indexer).RunIndex()`.  

Example with the option 2 Navigate: 

```
                             Indexed journal files
                             ---------------------
   1) /usr/irissys/mgr/journal/20230901.058 (20230901.058) [88]
   2) /usr/irissys/mgr/journal/20230901.060 (unit_test_Test01IndexFile) [89]
   3) /usr/irissys/mgr/journal/20230901.062 (20230901.062) [91]
   4) /usr/irissys/mgr/journal/20230901.064 (unit_test_Test01IndexFile) [92]
   5) /usr/irissys/mgr/journal/20230830.011z (20230830.011z) [93]

Select a journal file # => 1

--------------------------------------------------------------------------------
File: 20230901.058         First Address: 131088         Last Address: 2815232
--------------------------------------------------------------------------------
Address:            131088      Next: 131196         Previous: 0
TimeStamp:          2023-09-01 15:23:58
Type:               SET
In Transaction:     NO
Process ID:         162619
Database:           /usr/irissys/mgr/irisapp/data/
Global Node:        ^rMAP("tests.dc.journalindexer.services.Search.1","INT","CLS",130,5)

Nbr of values:      1
Old Value:          ""
New Value:          $lb(,5,5,47,42)


(P)revious (Q)uit (N)ext (or <any other key>).
```

If you perform a search (option 3 or 4), you can specify a filter in JSON Format.  

```
Put your filter in JSON format, empty string allowed (see documentation for more details). 
    ex : {"GlobalName":{"Value":"^SYS"},"Subscripts":{"Value":"HistoryD","Position":2}}

Filter => {"GlobalName": {"Value":"^dc.journalindexer.testI"}, "Subscripts": {"Value": " AK","Position":2}}

--------------------------------------------------------------------------------
File: unit_test_Test01IndexFile  First Address: 131312          Last Address: 484076
--------------------------------------------------------------------------------
Address:            408032         Next:           Previous: 
TimeStamp:          2023-09-01 15:24:04
Type:               SET
In Transaction:     YES
Process ID:         139889
Database:           /usr/irissys/mgr/irisapp/data/
Global Node:        ^dc.journalindexer.testI("USStateI"," AK",53)

Nbr of values:      1
Old Value:          ""
New Value:          ""


Press <any key> to display the next record or <q> to stop.
```

The json filter below 
```json
{"GlobalName": {"Value":"^dc.journalindexer.testI"}, "Subscripts": {"Value": " AK","Position":2}}
```
means select all indexed journal entries for the global `^dc.journalindexer.testI` with a subscript in position 2 equal ` AK` (like `^dc.journalindexer.testI("USStateI"," AK",53)`).  

It's also possible to search by old value or new value, hower it's recommanded to filter also by GlobalName for performance reasons.

```json
{"GlobalName": {"Value":"^dc.journalindexer.testD"}, "NewValue": {"Value": "Newton","Position":4}}
```
```
New Value:          $lb("Pantaleo","Jane","9255 Second Blvd","Newton",75154,"VA","767-91-2936",918)
```

If the entry in journal file is a list, you can specify the position to search the value.
The wildcard `*?` are allowed.  

| Name | Operator | Example | Comment |
|------|----------|---------|---------|
|  Address    | =         | `{"Address":{"Value":123456}}`        | Allowed operator `between,>,>=,<,<=`        |
|      | between         |  `{"Address":{"Start":1,"End":999999,"Operator":"between"}}`       |         |
|      | >         |  `{"Address":{"Value":123456, "Operator":">"}}`       |         |
| DatabaseName     | =         | `{"DatabaseName":{"Value":"/usr/irissys/mgr/irisapp/data/"}}`        |         |
| GlobalName     | =         | `{"GlobalName": {"Value":"^dc.journalindexer.testD"}}`        |  Wildcard allowed `*?`       |
|      | %STARTSWITH         | `{"GlobalName": {"Value":"^dc.journalindexer.*"}}`        |         |
|      | [ (contain)         | `{"GlobalName": {"Value":"*journalindexer*"}}`        |         |
|      | LIKE         |  `{"GlobalName": {"Value":"*journa?ind?xer.*"}}`       |         |
| InTransaction    | =         | `{"Address":{"Value":1}}`        |         |
| NewValue     | =         | `{"NewValue": {"Value": " Newton","Position":4}`        | Wildcard allowed (Position make sense for List value)      |
| OldValue     | =         | `{"OldValue": {"Value": " Newton","Position":4}`        | Wildcard allowed (Position make sense for List value)      |
| ProcessID     | =         | `{"ProcessID":{"Value":2455}}`        |         |
| Subscripts     | =         | `{"GlobalName": {"Value":"^dc.journalindexer.testI"}, "Subscripts": {"Value": " AK","Position":2}}`        | Wildcard allowed       |
| TimeStamp     | between         | `{"TimeStamp":{"Start":"2023-08-24 00:00:22","End":"2023-08-24 02:00:22","Operator":"between"}}`        | Allowed operator `between,>,>=,<,<=`        |
| Type     | =         | `{"Type":{"Value":"KILL"}}`        |         |


**Note** : Search in terminal mode is not very convenient, later a web interface will be developped.  


#### SQL

Data are available in `dc_journalindexer_data` schema.  
You can view data using query like:
  
```sql
SELECT * FROM dc_journalindexer_data.Record
SELECT * FROM dc_journalindexer_data.SetKillRecord
SELECT * FROM dc_journalindexer_data.BitSetRecord

SELECT * 
FROM dc_journalindexer_data.SetKillRecord 
WHERE File = 89 
AND GlobalName = '^dc.journalindexer.testI' 
AND FOR SOME %ELEMENT(Subscripts) (%VALUE = ' AK' AND %KEY = 2)

SELECT * 
FROM dc_journalindexer_data.SetKillRecord 
WHERE File = 89 
AND GlobalName = '^dc.journalindexer.testD'
AND Type = 'SET'
AND dc_journalindexer_dao.Queries_GetListPosition(NewValue,4) = 'Newton' "
```

The class `dc.journalindexer.dao.Queries` contains the custom class query `SearchRecord`.  
You can use in parameter the filter in JSON format, so the query : 

```sql
SELECT * 
FROM dc_journalindexer_dao.Queries_SearchRecord('{"GlobalName": {"Value":"^dc.journalindexer.testI"}, "Subscripts": {"Value": " AK","Position":2}}') 
```

Is the same that the following query : 
```sql
SELECT * 
FROM dc_journalindexer_data.SetKillRecord 
WHERE File = 89 
AND GlobalName = '^dc.journalindexer.testI' 
AND FOR SOME %ELEMENT(Subscripts) (%VALUE = ' AK' AND %KEY = 2)
```


## About Unit Tests

### Indexer Process

The unit tests cover the `Index`, `DeleteIndexedJournalData` methods.  
A journal file is generated with 10000 SET and 10000 KILL on the global `^dc.journalindexer.testD`.  

The interactive menu (method `RunIndex`) is also covered using Job, input\output files and `$SYSTEM.Event` utils (syntax `Job classmethod:(::inputFile:outputFile)` )


```objectscript
zpm "test journal-indexer"
```
