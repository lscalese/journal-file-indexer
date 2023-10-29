 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/journal-file-indexer)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fjournal-file-indexer&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fjournal-file-indexer)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fjournal-file-indexer&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fjournal-file-indexer)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

# IRIS Journal file indexer

**Important** : *It is not ready to use. This package is currently on OEX only to facilitate iterative reviews during development. Consider it will be ready only from version 1.0.0.*

## Description

The log file search functionality integrated into the management portal is currently experiencing response time problems on large files. The objective is to temporarily index the data in a log file in a database in order to improve search performance.  


## Release note

**Versions 0.7.0***

Front-end :

 * Add form to search data in indexed journal.
 * Add a form to restore old value or new value of a global in indexed journal.  
 * UI improvements.  

**Version 0.6.0**

First version with web front-end Angular

 * Some change in REST api
 * Auth REST API using JWT

Interface to: 
 * index a journal file
 * upload and index a journal file
 * list indexed journal
 * show stats about indexed journal

**Version 0.5.0**

New features:
 * Open API Specification.
 * REST services for all existing features.  
 * WebSocket to listen indexer progression.

Improvements:
 * Event management to attach an observer. 

**Version 0.4.0**

New features:

 * Restore from indexed journal.  
 * Command line wizard to create a search filter.

Improvements:

 * Calculated property Subscripts size in dc.journalindexer.data.SetKillRecord  
 * Storage optimization for persistent class dc.journalindexer.data.SetKillRecord.    
   Property GlobalName is now calculated from GlobalNode.  
   Database path is now in another table and SetKillRecord keep only a referece.  
   DatabaseName is a calculated property.  
   GlobalReference is now a calculated property from DatabaseName and GlobalNode.  


See progression on this [GitHub project DashBoard](https://github.com/users/lscalese/projects/2/views/6)

**Version 0.3.0**

New features:

 * Stats Size and counter by pid, database, global, journal record type.

Improvements:

 * Command line tools are gathered in ^JRNINDEXER routine.  

**Version 0.2.0**

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

*Note* : the front-end is an Angular application (repository [link](https://github.com/lscalese/journal-indexer-ui)).  It can't be deployed by zpm.  If you use `docker-compose up -d`  a container with the front-end application will be started.

## Run Unit Tests
  
```objectscript
zpm "test journal-indexer"
```

## Front End

Front end Angular starts with docker. use this url [http://localhost:8090/login](http://localhost:8090/login)

![login](https://github.com/lscalese/journal-file-indexer/blob/master/img/login.png?raw=true)


## Index a journal file

There 2 ways to index a journal file.  
If the journal is on the IRIS server use `New` and fill the path of the journal file.
You have to give also a "user defined name".  It's just a name to recognize easily this indexed journal.  

![new](https://github.com/lscalese/journal-file-indexer/blob/master/img/new.png?raw=true)

Or, if the journal file is not on the server, you can upload by a simple drag and drop using `Upload` menu.

![upload](https://github.com/lscalese/journal-file-indexer/blob/master/img/upload.png?raw=true)

Then a page with the indexing progress will be opened.  The indexing take a while depending the size of the journal file.

![load](https://github.com/lscalese/journal-file-indexer/blob/master/img/load.png?raw=true)

## List indexed journal file

Use the menu `List` to show the list of indexed journal.  From this page, you can delete a item

![list](https://github.com/lscalese/journal-file-indexer/blob/master/img/list.png?raw=true)

Use the button the `stats` to show statistics about this indexed journal. You can see stats by global, database or process id : 

![stats](https://github.com/lscalese/journal-file-indexer/blob/master/img/stats.png?raw=true)

## Search data

An advanced form filter is available form the `search` menu to search data in the indexed journal file : 

![search](https://github.com/lscalese/journal-file-indexer/blob/master/img/search.png?raw=true)

To have a good response time, it's better to select global name if you want to filter on : old value, new value or global subscript.

![table](https://github.com/lscalese/journal-file-indexer/blob/master/img/search.png?raw=true)

If your filter contain a global name, the button `restore` will be available.  It allows to restore the new or value of a global to a new location.  
To protect your data against restore mistake this tool allows only restore to a non existing global.  

![restore](https://github.com/lscalese/journal-file-indexer/blob/master/img/restore.png?raw=true)


## Usage with command line tools

All tools are gathered in routine ^JRNINDEXER

```objectscript
Do ^JRNINDEXER
```

```
                              Journal File Indexer
                              --------------------

 1) Show list of indexed journal files.
 2) Navigate.
 3) Search (list view).
 4) Search (detail view).
 5) Index a journal file in database.
 6) Show stats.

(Q)uit or (#) Menu item => 
```

### Store data from a journal file in database

Select option 5 and choose your journal file to index.  
Typing `?` display the list of journal on this system and just type the number to start indexing.  
To index a journal file from another system simply type the full path.  

**Note:** *If journal file are zipped either `/usr/irissys/mgr/journal/20230805.004` or `/usr/irissys/mgr/journal/20230805.004z` work as well. No matter about the suffix `z`.*  


```
Journal file path (? help, q quit): ?
  1) /usr/irissys/mgr/journal/20230805.003
  2) /usr/irissys/mgr/journal/20230805.004
  3) /usr/irissys/mgr/journal/20230806.001
  4) /usr/irissys/mgr/journal/20230807.001
  5) /usr/irissys/mgr/journal/20230808.001
Journal file path (? help, q quit): 64

Apply filter routine ^JRNFILT (Y)es or (N)o  default:(No) ?  

Index process started Type (P)ause, (R)esume, (C)ancel.
 * File Validation /usr/irissys/mgr/journal/20230808.001z exists.
 * File Validation /usr/irissys/mgr/journal/20230808.001z is a valid journal file.
 * Stop Journaling 
 * Starting load journal file ...        484152 / 484152  
 * Flush Flush Buffer ...
 * Build Indices ...
 * Delete old journal ...
 * Restore journal state ...
 * ENDED with status : OK

                                Press <any key>
```

**Note:** If the routine `^JRNFILT` exists, you can use it to filter journal entries to index. This message is not show if the routine does not exist.  
It's pretty similar to [journal restore](https://docs.intersystems.com/iris20232/csp/docbook/DocBook.UI.Page.cls?KEY=GCDI_journal#GCDI_journal_util_ZJRNFILT) but here, the process index or not depending the value of `restmode`.

#### About the storage

We consider these data are temporary.  
The usual use case is to index a journal file, perform searches and then delete them.  
So, all data are physically stored in IRISTEMP to avoid indexing a journal file generate a new journal file ...
However, If you prefer store data in another database, you create a global mapping in %ALL namespace with these globals:

 * ^IRIS.Temp.data.Record*
 * ^IRIS.Temp.data.Stats*
 * ^IRIS.Temp.data.File*


By default, the process keep maximum 5 indexed journal files.  
If 6th is indexed the oldest is automatically removed from the database.  

Yon can increase or decrease this value with this config :  
  
```objectscript
Do ##class(dc.journalindexer.services.Config).SetConfig("MaxJournalRetention", 5)
```


#### Programmatically
  
```objectscript
Set sc = ##class(dc.journalindexer.services.Indexer).Index("/usr/irissys/mgr/journal/20230805.004", "20230805.004")
```

The first argument is the path of the journal file to store in database.  
The second is optional, this is the name of the journal file (by default: `##class(%File).GetFilename(JournalFile)`).  

### View indexed data

Data can be displayed from `^JRNINDEXER` option 2, 3 or 4.  

Option 2 allows to navigate in indexed journal file, ex:

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

With the options 3 and 4 allow to perform a search, a filter can be specified (optional)

```
                                 Filter Wizard

	1) Set database filter.
	2) Set global name filter.
	3) Set process id filter.

	4) Set Address range filter.
	5) Set TimeStamp range filter.
	6) Set Journal type entry filter.
	7) Set Global Subscripts Size filter.

	8) Set Subscripts filter by position.

  Current filter : {"DatabaseName":{"Value":"/usr/irissys/mgr/irisapp/data/"},"GlobalName":{"Value":"^tmp.lsc"}}

(Q)uit (C)ancel (V)iew current Filter (X)Clear Filter (#)Menu item => 

```
Use the wizard to set your filter and then type `q`.  

```
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

### Show stats

Some stats are available: 

 * Size by global
 * Size by database
 * Size by process id

For each, the number of journal entries and also the number of journal entries grouped by type (SET,KILL,ZKILL,...).

Stats can bel displayed using the routine `Do ^JRNINDEXER` option 6.

```
              Top Size by Global unit_test_Test01IndexFile [ 17 ]
              ---------------------------------------------------
  1) Global ^["^^/usr/irissys/mgr/irisapp/data/"]dc.journalindexer.testI
     Size:     156064 Count: 2000 (SET:2000,blkhdr:0,dirtab:0)
  2) Global ^["^^/usr/irissys/mgr/irisapp/data/"]dc.journalindexer.testD
     Size:     131504 Count: 1001 (KILL:1,SET:1000,blkhdr:0,dirtab:0)
  3) Global ^["^^/usr/irissys/mgr/irisapp/data/"]rINDEXSQL
     Size:       4400 Count: 13 (KILL:1,SET:12,blkhdr:0,dirtab:0)
  4) Global ^["^^/usr/irissys/mgr/"]SYS
     Size:       2308 Count: 23 (KILL:7,SET:15,ZKILL:1,blkhdr:0,dirtab:0)
  5) Global ^["^^/usr/irissys/mgr/irisaudit/"]IRIS.AuditD
     Size:       1776 Count: 8 (SET:8,blkhdr:0,dirtab:0)

 (G)lobal stats, (P)rocess ID stats, (D)atabase stats (Q)uit => 

             Top Size by Process ID unit_test_Test01IndexFile [ 17 ]
            -------------------------------------------------------
  1) Process ID 17108
     Size:     292616 Count: 3016 (KILL:2,SET:3014,blkhdr:0,dirtab:0)
  2) Process ID 46978
     Size:       2308 Count: 23 (KILL:7,SET:15,ZKILL:1,blkhdr:0,dirtab:0)
  3) Process ID 46979
     Size:        376 Count: 2 (SET:2,blkhdr:0,dirtab:0)
  4) Process ID 46981
     Size:        376 Count: 2 (SET:2,blkhdr:0,dirtab:0)
  5) Process ID 46982
     Size:        376 Count: 2 (SET:2,blkhdr:0,dirtab:0)

 (G)lobal stats, (P)rocess ID stats, (D)atabase stats (Q)uit => 

             Top Size by Database unit_test_Test01IndexFile [ 17 ]
             -----------------------------------------------------
  1) Database /usr/irissys/mgr/irisapp/data/
     Size:     291968 Count: 3014 (KILL:2,SET:3012,blkhdr:0,dirtab:0)
  2) Database /usr/irissys/mgr/
     Size:       2308 Count: 23 (KILL:7,SET:15,ZKILL:1,blkhdr:0,dirtab:0)
  3) Database /usr/irissys/mgr/irisaudit/
     Size:       1776 Count: 8 (SET:8,blkhdr:0,dirtab:0)

 (G)lobal stats, (P)rocess ID stats, (D)atabase stats (Q)uit => 
```

### Restore data from indexed journal.

There is a feature to restore data (OldValue or NewValue) from the indexed journal.  
So, to avoid any problem (data override...) data are not restored directory to the original global.  
It means to restore data for a global from the indexed journal you have to choice another non existing global to redirect the restore.

Example: 

If we restore from indexed journal:
```
^MyData(1)="value 1"
^MyData(2)="value 2"
^MyData(3)="value 3"
```
And we choose the global `^Restore.MyData`, the restore result will be: 

```
^Restore.MyData(1)="value 1"
^Restore.MyData(2)="value 2"
^Restore.MyData(3)="value 3"
```

The global `^MyData` won't be modified by the restore process.  
If the result of the restore is correct `^Restore.MyData` you can do it by yourself with a Merge command.  

To start a restore use the menu item `7) Restore data.` from `^JRNINDEXER` and follow the wizard.  
Select the journal file, select your filter (with the filter wizard).  

```
                       Restore data from indexed journal.
                       ----------------------------------

 Filter : {"DatabaseName":{"Value":"/usr/irissys/mgr/irisapp/data/"},"GlobalName":{"Value":"^MyData"}}

 Restore from Indexed journal file : unit_test_Test01IndexFile [25]

 Restore (N)ew value or (O)ld value ? (Default: Old value) => N

 ! Data are not directly restored to the original global to prevent override !
 ! Please provide a non existing global name to reste data !

 Restore redirect to global => ^Restore.MyData

Test only (Y)es (N)o (simulate the restore without SET operation) (Default: No) => No
Verbose (Y)es (N)o (Write on current device all operations) (Default: No) => No

 The global ^MyData in indexed journal unit_test_Test01IndexFile will be restored in global ^Restore.MyData

Confirm start restore (Y)es (N)o (Default: No) => Yes
Start restore ...
SET:       2000    ERR:          1
Cannot restore 1 record(s) because the journal entry has no NewValue

 Restore finished with status: OK

```

If a journal entry has no value to restore, a warning message can be displayed with the number of skipped indexed journal entries.  

