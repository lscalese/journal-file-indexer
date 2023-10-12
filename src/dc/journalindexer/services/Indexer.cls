Include journalindexer

Class dc.journalindexer.services.Indexer
{

Parameter STEPSIGNAL = 10000;

Parameter SRCNAME = "idx";

ClassMethod RunIndex() As %Status
{
    Set resourceName = ..#SRCNAME, list=""
    Do $SYSTEM.Event.Delete(resourceName)

    Set sc = $$$OK
    
    For  {
        Write !,"Journal file path (? help, q quit): " Read JournalFile

        Return:$Extract($$$LOWER(JournalFile))="q"

        If JournalFile = "?" Do ShowHelp Continue

        If JournalFile?1.N, $Data(list(JournalFile), value) Set JournalFile = $Piece(value, ",", 2)

        If '##class(%File).Exists(JournalFile) {
            Set JournalFile = JournalFile _ "z" 
            If '##class(%File).Exists(JournalFile) Write !, "Journal file not found." Continue
        }

        If '##class(%SYS.Journal.File).IsValidJournal(JournalFile) Write !,"File ", JournalFile, " is not a valid journal file." Continue

        Quit
    }

    Set filter = $$$NO

    If $Data(^ROUTINE("ZJRNFILT")) {
        Write !,!,"Apply filter routine ^JRNFILT (Y)es or (N)o  default:(No) ? " Read filter
        Set filter = $Select($$$LOWER($Extract(filter))="y":$$$YES,1:$$$NO)
    }

    Set name = ##class(%File).GetFilename(JournalFile)
    
    Set currentLastJrnId = $Order(^IRIS.Temp.data.FileD(""),-1)
    
    Set indexerListener = ##class(dc.journalindexer.events.IndexerListener).%New()
    Do indexerListener.OnStartListen()

    Job ..Index(JournalFile, name, "", filter)
    Set PIDIndexer = $ZChild

    Write !
    Write !, "Index process started Type (P)ause, (R)esume, (C)ancel."

    Set state = "running", firstLoad = $$$YES

    

    For  {

        Read *x:0
        
        If $Test {  ; check pause, resume cancel instruction
            Set x = $$$LOWER($Char(x))
            
            If x = "p", state = "running" { ; pause -> suspend process
                Set sc = ##class(dc.journalindexer.services.Utils).ProcessAction(PIDIndexer, "suspend")
                If $$$ISOK(sc) Set state = "pause"
            } ElseIf x = "r", state '= "running" { ; resume -> resume process
                Set sc = ##class(dc.journalindexer.services.Utils).ProcessAction(PIDIndexer, "resume")
                If $$$ISOK(sc) Set state = "running"
            } ElseIf x = "c" { ; cancel -> terminate process
                Set sc = ##class(dc.journalindexer.services.Utils).ProcessAction(PIDIndexer, "terminate")
                If $$$ISOK(sc) Set state = "terminate" Quit
            }
        }

        Set returnState = indexerListener.WaitEvent(.EventObject, 2)

        If returnState = 1 {
            
            Set msg = EventObject.Data
            
            If msg.Action = "Load" {
                If firstLoad Write !," * Load journal file: "
                Do showProgression
                Set:firstLoad firstLoad = $$$NO
            } ElseIf msg.Action = "FE" {
                Write !," * File ",JournalFile, " exists: ", $Select(+msg.FileExists=1:"YES",1:"NO")
            } ElseIf msg.Action = "FV" {
                Write !," * File ",JournalFile, " is a valid journal file: ", $Select(+msg.IsValid=1:"YES",1:"NO")
            } ElseIf msg.Action = "FB" {
                If msg.Flush = "" {
                    Write !," * Flush buffer ... "
                } Else {
                    Write " ", msg.Flush
                }
            } ElseIf msg.Action = "BI" {
                If msg.BuildIndices = "" {
                    Write !," * Build Indices ... "
                } Else {
                    Write " ", msg.BuildIndices
                }
            } ElseIf msg.Action = "DO" {
                Write !," * Delete old indexed journal"
            }

            If msg.Status="Done" {
                Write !," = ", msg.Message
                Write !,!," Would you like to RUN a Tune table on schema dc_journalindexer_data (Y)es (No) (Default: No)=> ? "
                Read tune
                Set:$$$LOWER($Extract(tune))="y" sc = $SYSTEM.SQL.Stats.Table.GatherSchemaStats("dc_journalindexer_data")
                Quit
            } ElseIf msg.Status = "ERR" {
                Write !," ! ERROR: ", msg.Message
                Quit
            }
            
            Continue
        }

        If returnState = -1 Set sc = $$$ERROR($$$GeneralError, "Ressource deleted.") Quit

        If returnState = 0, '##class(%SYS.ProcessQuery).%ExistsId(PIDIndexer) Set sc = $$$ERROR($$$GeneralError, "Index process not found") Quit 
        
    }
    Write !

    Do indexerListener.OnStopListen()

    If $$$ISERR(sc) Do $SYSTEM.Status.DisplayError(sc)

    If state = "terminate" Do CleanInconsistentData
    
    Quit sc

showProgression
    Set showProgression = $Justify(msg.Load,6,2)_"%"
    Write showProgression
    For i=1:1:$Length(showProgression) Write $c(8)
    Quit

ShowHelp
    Kill list
    Do ##class(%SYS.Journal.History).LoadLog(, .list)
    Set key = ""
    For  {
        Set key = $Order(list(key), 1, value) 
        Quit:key=""  
        Write !,$Justify(key,3),") ",$Piece(value, ",", 2)

        If key#20 = 0, key '= $Order(list(""), -1) {
            Write !, "Press <any key> to display next 20 records or (q) to stop." 
            Read *x Quit:x=$a("q")
        }
    }
    Write !
    Quit

CleanInconsistentData

    Set startId = $Get(^dc.journalindexer("startIndexId", PIDIndexer))

    If currentLastJrnId = $Order(^IRIS.Temp.data.FileD(""),-1,data) Quit

    Set currentLastJrnId = $Order(^IRIS.Temp.data.FileD(""),-1)

    Write !, "!! Terminate the indexer process cause inconsistent data and index corruption !!"
    Write !, "Would you like clean indexed data for journal ", $lg(data,2), " (Y)es, (N)o ? "
    Read x Set x = $$$LOWER($Extract(x))

    If x '= "y" Quit
    
    Write !,!,"Start clean data for ",$lg(data,2)
    If startId '= "" {
        Write !, $Char(9), "Rebuild File index starting at id ",startId," ... "
        Set sc = ##class(dc.journalindexer.data.Record).%BuildIndices($ListBuild("FileI"),,,0,startId)
        If $$$ISOK(sc) {
            Write "OK"
        } Else {
            Do $SYSTEM.Status.DisplayError(sc)
        }
    }
    Write !, $Char(9), "Delete indexed data ... "
    Set sc = ..DeleteIndexedJournalData(currentLastJrnId)

    Kill ^IRIS.Temp.data.Distinct(currentLastJrnId)
    
    If $$$ISOK(sc) {
        Write "OK"
    } Else {
        Do $SYSTEM.Status.DisplayError(sc)
    }
    Quit
}

ClassMethod ProcessAction(
	PID As %Integer,
	Action As %String) As %Status [ Private ]
{
    /// code moved
    Quit ##class(dc.journalindexer.services.Utils).ProcessAction()
}

/// Open a journal file and index its content in database.
ClassMethod Index(
	JournalFile As %String,
	Name As %String = {##class(%File).GetFilename(JournalFile)},
	Output FileId As %Integer = "",
	ApplyZJRNFILT As %Boolean = {$$$NO},
	Token As %String = "",
	deleteFileAfterIndex As %Boolean = {$$$NO}) As %Status
{
    #dim journal As %SYS.Journal.File
    #dim jrnRecord As %SYS.Journal.Record

    Set sc = $$$OK, applyFilter = $$$NO

    If ApplyZJRNFILT, $Data(^ROUTINE("ZJRNFILT")) Set applyFilter = $$$YES

    Set progression = {"Status":"In Progress","FileExists":"","IsValid":"","Load":0,"Flush":"","BuildIndices":"","Action":"FE","Message":"","JournalFile":(JournalFile),"Token":(Token)}
    If '##class(%File).Exists(JournalFile) Set JournalFile = JournalFile _ "z"     
    If '##class(%File).Exists(JournalFile) Set sc = $$$ERROR($$$GeneralError, "File does not exist."),progression.FileExists = $$$NO Do EventSignalStatus Quit sc
    Set progression.FileExists = $$$YES Do EventSignal

    Set progression.Action = "FV"
    If '##class(%SYS.Journal.File).IsValidJournal(JournalFile) Set sc = $$$ERROR($$$GeneralError, "Is not a valid journal file."), progression.IsValid = $$$NO Do EventSignalStatus Quit sc
    Set progression.IsValid = $$$YES Do EventSignal
    
    Lock +^dc.journalindexer.services.Indexer:2 ; Only one index process at a time

    Set:'$Test sc = $$$ERROR($$$GeneralError, "An indexer process already running, process id :" _ ^$LOCK($Name(^dc.journalindexer.services.Indexer), "OWNER"))

    If $$$ISERR(sc) Do EventSignalStatus Quit sc

    Do ##class(dc.journalindexer.services.Indexer).StopJournal(.transactionMode, .autoCommitMode)

    Try {

        Set progression.Action = "Load" Do EventSignal
        
        Set journal = ##class(%SYS.Journal.File).%OpenId(JournalFile, , .sc) Quit:$$$ISERR(sc)
        
        Set sc = ##class(dc.journalindexer.dao.JournalDataDAO).SetFile(journal, Name, .FileId) Quit:$$$ISERR(sc)

        Set jrnRecord = journal.FirstRecord, lastAddress = journal.LastRecord.Address

        Do EventSignal

        Set startIndexId = $Get(^IRIS.Temp.data.RecordD, 0) + 1
        Set ^dc.journalindexer("startIndexId", $job) = startIndexId
        Set restmode = 1

        Set startStorage = $ZStorage
        ; Set a limit usage memory flus if less than 20% is available
        Set limitBeforeFlush = startStorage * 0.2   
        ; force a flush to 512 Mb used even if the available memory is greather than 20 %
        If startStorage - (1024**2 * 512) > limitBeforeFlush Set limitBeforeFlush = startStorage - (1024**2 * 512)
        
        Set addr = 131072
        Set statsData("prevlen") = $zu(78,42,addr), statsData("prevaddr") = addr

        While $IsObject(jrnRecord) {
            
            Set progression.Load = $Normalize(jrnRecord.Address/lastAddress*100,2)

            If applyFilter {
                Set restmode = 1
                Do:jrnRecord.%IsA("%SYS.Journal.SetKillRecord") ^ZJRNFILT(jrnRecord.JobID_","_jrnRecord.RemoteSystemID,jrnRecord.DatabaseName,jrnRecord.GlobalNode,$Extract(jrnRecord.TypeName),.restmode,jrnRecord.Address,$zdth(jrnRecord.TimeStamp,3,1))
            }
            
            Do:restmode ##class(dc.journalindexer.dao.JournalDataDAO).SetRecordInBuffer(jrnRecord, .FileId, .lastRecordId)
            Do ##class(dc.journalindexer.dao.JournalDataDAO).SetStatsInBuffer(jrnRecord, .statsData)

            ; we use the process memory until 80% before flush the buffer
            If $Storage < limitBeforeFlush Do ##class(dc.journalindexer.dao.JournalDataDAO).FlushBuffer()
            
            Set jrnRecord = jrnRecord.Next
            
            If $Increment(i) # ..#STEPSIGNAL Continue
            Do EventSignal

        }

        Do:$Data(statsData) ##class(dc.journalindexer.dao.JournalDataDAO).SaveStats(FileId, .statsData)

        Do EventSignal
        
        Set progression.Action = "FB"
        Do EventSignal, ##class(dc.journalindexer.dao.JournalDataDAO).FlushBuffer()
        Set progression.Flush = "OK" Do EventSignal
        
        Set progression.Action = "BI" Do EventSignal
        Set sc = ##class(dc.journalindexer.dao.JournalDataDAO).RebuildIndices(startIndexId,lastRecordId)
        Set progression.BuildIndices = $Select($$$ISOK(sc):"OK",1:$SYSTEM.Status.GetOneErrorText(sc)) Do EventSignal

        Set progression.Action = "DO" Do EventSignal
        Job ##class(dc.journalindexer.services.Indexer).DeleteOld()

        If deleteFileAfterIndex {

            ; Delete is allowed only for uploaded journal file, check the log to avoid a mistake ...
            Do ##class(%SYS.Journal.History).LoadLog(, .list)
            Set key = "", found = $$$NO
            
            For  {
                Set key = $Order(list(key), 1 ,value)
                Quit:key=""
                Set found = $Piece(value, ",", 2) = JournalFile
                Quit:found
            }

            If 'found, ##class(%File).Exists(JournalFile) Do ##class(%File).Delete(JournalFile)
        }

    } Catch ex {
        Set sc = ex.AsStatus()
    }

    Lock -^dc.journalindexer.services.Indexer

    Do ##class(dc.journalindexer.services.Indexer).RestoreJournalState(transactionMode, autoCommitMode)

    Set progression.Action = "END", 
        progression.Status = $Select($$$ISOK(sc):"Done",1:"ERR"), 
        progression.Message="Done with status : "_$Select($$$ISERR(sc):$SYSTEM.Status.GetOneErrorText(sc),1:"OK")
    Do EventSignal

    Return sc

EventSignal
    Set:Token'="" progression.MessageType="INDEXER", str = progression.%ToJSON(), ^dc.journalindexer.token(Token) = str
    Do ##class(dc.observer.Manager).Notify($$$IndexerEvent,progression)
    Quit
EventSignalStatus
    Set progression.Status = "ERR", progression.Message = $SYSTEM.Status.GetOneErrorText(sc)
    Do EventSignal
    Quit
}

ClassMethod IndexStream(
	Stream As %Stream.GlobalBinary,
	Name As %String) As %Status
{
    Set sc = $$$OK,
        path = ##class(%File).TempFilename("tmpjrn"), ^dc.journalindexer("temp-file",$Increment(^dc.journalindexer("temp-file"))) = path,
        journalFile = ##class(%Stream.FileBinary).%New()
    
    $$$QuitOnError(journalFile.LinkToFile(path))
   
    $$$QuitOnError(journalFile.CopyFromAndSave(Stream))
    
    Set sc = ..Index(journalFile)

    Do ##class(%File).Delete(path)

    Return sc
}

/// Delete old indexed journal in database.<br/>
/// "Max" is the number of journal in retention.<br>
/// ex: if max = 5, only 5 most recent journals will be keep.<br/>
ClassMethod DeleteOld(Max As %Integer = {##class(dc.journalindexer.services.Config).MaxJournalRetention()}) As %Status
{

    Set LastId = ""
    For  Set LastId = $Order(^IRIS.Temp.data.FileD(LastId),-1) Quit:$Increment(i)=Max||(LastId="")
    
    Quit:LastId="" $$$OK

    Set sc = $$$OK, id = ""
    For  {
        Set id = $Order(^IRIS.Temp.data.FileD(id),1) Quit:id>=LastId||(id="")
        Set sc = $$$ADDSC(sc,##class(dc.journalindexer.services.Indexer).DeleteIndexedJournalData(id))
    }

    Quit sc
}

/// Delete journal indexed in databaseJob ..Index(JournalFile, userDefinedName, resourceName, "", useJrnFilter) 
ClassMethod DeleteIndexedJournalData(JournalId As %Integer) As %Status
{
    Lock +%zLockDelJournal(JournalId):2
    If '$Test $$$ThrowStatus($$$ERROR($$$GeneralError, "Delete already in progress for " _ JournalId))

    Set sc = $$$OK
    
    Do ..StopJournal(.transactionMode, .autoCommitMode)
        
    Try {
        
        Set tResult = ##class(%SQL.Statement).%ExecDirect(.statement, "DELETE %NOLOCK FROM dc_journalindexer_data.Record WHERE File = ?", JournalId)

        Set:(tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) sc = $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message) 

        Set:##class(dc.journalindexer.data.File).%ExistsId(JournalId) sc = $$$ADDSC(sc, ##class(dc.journalindexer.data.File).%DeleteId(JournalId))

    } Catch ex {
        Set sc = $$$ADDSC(sc,ex.AsStatus())
    }
    
    Lock -%zLockDelJournal(JournalId)

    Do ..RestoreJournalState(transactionMode, autoCommitMode)

    Return sc
}

ClassMethod StopJournal(
	Output transactionMode As %Integer,
	Output autoCommitMode As %Integer) [ Internal, Private ]
{
    Do DISABLE^%NOJRN,##class(%SYSTEM.SQL.Util).SetOption("AutoCommit", 0, .autoCommitMode)
    Set transactionMode = $SYSTEM.OBJ.SetTransactionMode(0)

    Quit
}

ClassMethod RestoreJournalState(
	transactionMode As %Integer = 1,
	autoCommitMode As %Integer = 1) [ Internal, Private ]
{
    Do ENABLE^%NOJRN,
        $SYSTEM.OBJ.SetTransactionMode(transactionMode),
        ##class(%SYSTEM.SQL.Util).SetOption("AutoCommit", autoCommitMode)
    Quit
}

/// Check if temp journal files exist and delete them.
/// The path of each journal file is stored in ^dc.journalindexer("temp-file").
ClassMethod CheckAndCleanTempFiles() As %Status
{
    Set key = "", sc = $$$OK

    For  {
        Set key = $Order(^dc.journalindexer("temp-file", key), 1, path) Quit:key=""

        If '##class(%File).Exists(path) Kill ^dc.journalindexer("temp-file", key) Continue

        Kill:##class(%File).Delete(path) ^dc.journalindexer("temp-file", key)
    }

    Return sc
}

}
