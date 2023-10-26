To test later

Set tResult = ##class(dc.journalindexer.dao.Queries).SearchRecordFunc({"File":{"Value":1}})



ROUTINE ZJRNFILT
ZJRNFILT(jidsys,dir,glo,type,restmode,addr,time)    /*Filter*/
    Set restmode=0                                  /*Return 0 for restore*/
    If glo["SYS" Set restmode=1                     /*except when it is ^XYZ*/
    if $i(cntt)<20 w
    Quit


## About Unit Tests

### Indexer Process

The unit tests cover the `Index`, `DeleteIndexedJournalData` methods.  
A journal file is generated with 10000 SET and 10000 KILL on the global `^dc.journalindexer.testD`.  

The interactive menu (method `RunIndex`) is also covered using Job, input\output files and `$SYSTEM.Event` utils (syntax `Job classmethod:(::inputFile:outputFile)` )


```objectscript
zpm "test journal-indexer"
```

s file = "file.xml"
s ^lsc("a")="new val a"
s ^lsc("b")="val b"
s ^lsc("c")="val c"
s ^lsc("d")="val d"
s ^lsc("e")="val e"
s ^lsc("f")="val f"
s ^lsc("g")="val g"
s ^lsc("h")=$lb("azer","uiop")
s ^lsc("i")=$zwc(414,1,1)/*$bit(1)*/
s ^lsc("j")=$c(9,0,27)_"A"

Set sc = $SYSTEM.OBJ.Export("lsc.GBL",.file)
$cat /usr/irissys/mgr/irisapp/data/lsc.xml



/home/irisowner/dev/20230911.002z



ERROR #5002: ObjectScript error: <LIST>%FileIndicesBuffered+68^dc.journalindexer.data.BitSetRecord.1



Row count: 26 Performance: 0.3487 seconds  127802 global references 1299001 commands executed 3 disk read latency (ms)  Cached Query: %sqlcq.IRISAPP.cls13  Last update: 2023-09-13 14:22:45.447

avec timestamp 16 mo d'index
avec bitslice  5 Mo

zn "%SYS"
Do ##class(Config.NLS.Locales).Install("fraw")
Do ##class(Config.NLS.Locales).Install("enuw")
zn "irisapp"

Set packageName = "dc.journalindexer.rest" 
Set features("simpleHttpClientOnly") = 1 
Set sc = ##class(dc.openapi.client.Spec).generateApp(packageName, "/home/irisowner/dev/oas.yml", .features)

Set packageName = "dc.journalindexer.rest", webApplication = "/jrnindexer/api" 
Set sc = ##class(dc.openapi.server.ServerAppGenerator).Generate(packageName, "/home/irisowner/dev/oas.yml", webApplication)


http://localhost:49172/jrnindexer/api/_spec


test restore : 

{"DatabaseName":{"Value":"c:\\cache_db\\irishealth\\2203\\v2203caredata\\"},"GlobalName":{"Value":"^Di.RoomD"},"SubscriptsSize":{"Start":"1","End":"9","Operator":"between"}}



    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri $uri/ /index.html =404;
    }

    location /jrnindexer/api {
        proxy_pass http://iris:52773/jrnindexer/api;
    }

nginx -s reload -c /conf/nginx/nginx.conf


d ##class(dc.observer.BasicEventListener).StartListen("IndexerEvent")

d ##class(dc.observer.Manager).Notify("IndexerEvent",{"Hello":"it's me"})
