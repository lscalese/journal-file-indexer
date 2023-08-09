 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/journal-file-indexer)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fjournal-file-indexer&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fjournal-file-indexer)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fjournal-file-indexer&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fjournal-file-indexer)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)
# IRIS Journal file indexer

**Important : *It is not ready to use. This package is currently on OEX only to facilitate iterative reviews during development. Consider it will be ready only from version 1.0.0.***

## Description

The log file search functionality integrated into the management portal is currently experiencing response time problems on large files. The objective is to temporarily index the data in a log file in a database in order to improve search performance.

## Release note

**Version 0.1.0**

See the progression [here](https://github.com/users/lscalese/projects/2/views/1?filterQuery=milestone%3A%22Journal+File+Indexer+Version+0.1.0%22)  

This version include : 

* Tables to store journal file data into the IRISTEMP database.  
* Process to read a journal file and store its content in database.  
* Unit tests of indexer process.  

It does not include yet efficient index to have a fast response time for searching by "value". This feature will be added in version 0.2.0 (may be with a functionnal index or iFind index, to analysis...).  

## Installation

```
zpm "install journal-indexer"
```

Or using docker:

```
git clone https://github.com/lscalese/journal-file-indexer.git
cd journal-file-indexer
docker-compose up -d
```

## Run Unit Tests

```
zpm "test journal-indexer"
```

## Usage

### Store data from a journal file in database

#### Using a wizard in the terminal

```Objectscript
Do ##class(dc.journalindexer.services.Indexer).RunIndex()

Journal file path (? help, q quit): ?
```

Type the path of a journal file or `?` to show list of journal files on this system:

```
Journal file path (? help, q quit): ?
  1) /usr/irissys/mgr/journal/20230805.003
  2) /usr/irissys/mgr/journal/20230805.004
  3) /usr/irissys/mgr/journal/20230806.001
  4) /usr/irissys/mgr/journal/20230807.001
  5) /usr/irissys/mgr/journal/20230808.001
Journal file path (? help, q quit): 
```

Then type a path or just a number related to a journal file, typing `2` is similar to `/usr/irissys/mgr/journal/20230805.004`:
```
Journal file path (? help, q quit): 2
Start read journal    17087424 / 17087424  
FlushBuffer...
BuildIndices...
Delete old journal ...
OK
```

Now data are available in `dc_journalindexer_data` schema.

**Note:** *If journal file are zipped either `/usr/irissys/mgr/journal/20230805.004` or `/usr/irissys/mgr/journal/20230805.004z` work as well. No matter about the suffix `z`.*  


#### Programmatically

```
Set sc = ##class(dc.journalindexer.services.Indexer).Index("/usr/irissys/mgr/journal/20230805.004", "20230805.004", "")
```

The first argument is the path of the journal file to store in database.  
The second is optional, this is the name of the journal file (by default: `##class(%File).GetFilename(JournalFile)`).  
The third is also optional, this is the ressource name if you would like to wake up process with `$SYSTEM.Event`. It's used by `RunIndex` to show the progression.  See the [official documentation](https://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?LIBRARY=%25SYS&PRIVATE=1&CLASSNAME=%25SYSTEM.Event) for more information about `$SYSTEM.Event`.  

## About Unit Tests

### Indexer Process

The unit tests cover the `Index`, `DeleteJournal` methods.  
A journal file is generated with 10000 SET and 10001 KILL on the global `^dc.journalindexer.testD`.  

The interactive menu (method `RunIndex`) is also covered using Job, input\output files and `$SYSTEM.Event` utils (syntax `Job classmethod:(::inputFile:outputFile)` )

```
zpm "test journal-indexer"
```