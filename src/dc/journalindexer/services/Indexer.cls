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

    Set name = ##class(%File).GetFilename(JournalFile)
    
    Set currentLastJrnId = $Order(^IRIS.Temp.data.FileD(""),-1)

    Do:'$SYSTEM.Event.Defined(resourceName) $SYSTEM.Event.Create(resourceName)
    Job ..Index(JournalFile, name, resourceName)
    Set PIDIndexer = $ZChild

    Write !
    Write !, "Index process started Type (P)ause, (R)esume, (C)ancel."

    Set state = "running"

    For  {

        Read *x:0
        
        If $Test {  ; check pause, resume cancel instruction
            Set x = $$$LOWER($Char(x))
            
            If x = "p", state = "running" { ; pause -> suspend process
                Set sc = ..ProcessAction(PIDIndexer, "suspend")
                If $$$ISOK(sc) Set state = "pause"
            } ElseIf x = "r", state '= "running" { ; resume -> resume process
                Set sc = ..ProcessAction(PIDIndexer, "resume")
                If $$$ISOK(sc) Set state = "running"
            } ElseIf x = "c" { ; cancel -> terminate process
                Set sc = ..ProcessAction(PIDIndexer, "terminate")
                If $$$ISOK(sc) Set state = "terminate" Quit
            }
        }

        Set returnList = $SYSTEM.Event.WaitMsg(resourceName, 2)
        
        Set returnState = $ListGet(returnList, 1)

        If returnState = 1 {
            
            Set msg = {}.%FromJSON($ListGet(returnList,2))
            
            If msg.Action = "Load Journal" {
                Do showProgression
            } Else {
                Do ShowMessage
            }

            Quit:msg.Status="Done"||(msg.Status="ERR")
            
            Continue
        }

        If returnState = -1 Set sc = $$$ERROR($$$GeneralError, "Ressource deleted.") Quit

        If returnState = 0, '##class(%SYS.ProcessQuery).%ExistsId(PIDIndexer) Set sc = $$$ERROR($$$GeneralError, "Index process not found") Quit 
        
    }
    Write !

    Do $SYSTEM.Event.Delete(resourceName)

    If $$$ISERR(sc) Do $SYSTEM.Status.DisplayError(sc)

    If state = "terminate" Do CleanInconsistentData
    
    Quit sc

showProgression
    Set showProgression = $Justify(msg.Journal.CurrentAddress, 12) _ " / " _ msg.Journal.LastAddress_"  "
    Write showProgression
    For i=1:1:$Length(showProgression) Write $c(8)

    Quit

ShowMessage

    Write !," * ",msg.Action," ", msg.Message
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
    Set sc = ..DeleteJournal(currentLastJrnId)
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
    New $Namespace Set $Namespace = "%SYS"
    Set sc = $$$OK

    Set process = ##class(SYS.Process).%OpenId($ZChild,,.sc)
    If $$$ISERR(sc) Write ! Do $SYSTEM.Status.DisplayError(sc) Quit sc

    If Action = "suspend" {
        Set sc = process.Suspend()
        Write !, $Select($$$ISOK(sc): "Process suspended.", 1: $SYSTEM.Status.GetOneErrorText(sc))
    } ElseIf Action = "resume" {
        Set sc = process.Resume()
        Write !, $Select($$$ISOK(sc): "Process resumed.", 1: $SYSTEM.Status.GetOneErrorText(sc))
    } ElseIf Action = "terminate" {
        Set sc = process.Terminate()
        Write !, $Select($$$ISOK(sc): "Process terminated.", 1: $SYSTEM.Status.GetOneErrorText(sc))
    }
    Quit sc
}

/// Open a journal file and index its content in database.
ClassMethod Index(
	JournalFile As %String,
	Name As %String = {##class(%File).GetFilename(JournalFile)},
	Notify As %String = "",
	Output FileId As %Integer = "") As %Status
{
    #dim journal As %SYS.Journal.File
    #dim jrnRecord As %SYS.Journal.Record

    Set sc = $$$OK

    Set msg = {"Action" : "File Validation", "Status" : "", "Message" : "", "Journal": {"FirstAddress":"", "LastAddress" : "", "CurrentAddress": ""}}

    If '##class(%File).Exists(JournalFile) Set JournalFile = JournalFile _ "z" Set:'##class(%File).Exists(JournalFile) sc = $$$ERROR($$$GeneralError, "File does not exist.") Do EventSignalStatus Quit sc
    If '##class(%SYS.Journal.File).IsValidJournal(JournalFile) Set sc = $$$ERROR($$$GeneralError, "Is not a valid journal file.") Do EventSignalStatus Quit sc

    Set msg.Message = JournalFile _ " exists." Do EventSignal
    Set msg.Message = JournalFile _ " is a valid journal file." Do EventSignal Set msg.Message = ""

    Lock +^dc.journalindexer.services.Indexer:2 ; Only one index process at a time

    Set:'$Test sc = $$$ERROR($$$GeneralError, "An indexer process already running, process id :" _ ^$LOCK($Name(^dc.journalindexer.services.Indexer), "OWNER"))

    If $$$ISERR(sc) Do EventSignalStatus Quit sc

    Set msg.Action = "Stop Journaling" Do EventSignal
    Do ##class(dc.journalindexer.services.Indexer).StopJournal(.transactionMode, .autoCommitMode)

    Try {

        Set msg.Action = "Starting load journal file ... " Do EventSignal
        
        Set journal = ##class(%SYS.Journal.File).%OpenId(JournalFile, , .sc) Quit:$$$ISERR(sc)
        
        Set sc = ##class(dc.journalindexer.dao.JournalDataDAO).SetFile(journal, Name, .FileId) Quit:$$$ISERR(sc)

        Set jrnRecord = journal.FirstRecord

        Set msg.Action = "Load Journal", 
            msg.Status = "InProgress", 
            msg.Journal = {"FirstAddress":(journal.FirstRecord.Address), "LastAddress" : (journal.LastRecord.Address), "CurrentAddress": ""}
        
        Do EventSignal

        ; if $ZStorage is less than 1Gb, we flush when 80% of the process memory is reached.
        ; if $ZStorage is greather than 1Gb, we force the limit before flush to 800Mb
        Set limitBeforeFlush = $Select($zstorage > 1073741824: 1024**4, 1: $zstorage*1024) * .2

        Set startIndexId = $Get(^IRIS.Temp.data.RecordD, 0) + 1
        Set ^dc.journalindexer("startIndexId", $job) = startIndexId

        While $IsObject(jrnRecord) {
            
            Set:Notify'="" msg.Journal.CurrentAddress = jrnRecord.Address
            
            Do ##class(dc.journalindexer.dao.JournalDataDAO).SetRecordInBuffer(jrnRecord, .FileId, .lastRecordId)
            
            ; we use the process memory until 80% before flush the buffer
            If $Storage < limitBeforeFlush Do ##class(dc.journalindexer.dao.JournalDataDAO).FlushBuffer()
            
            Set jrnRecord = jrnRecord.Next
            
            If $Increment(i) # ..#STEPSIGNAL Continue
            Do EventSignal

        }

        Do EventSignal

        Set msg.Action = "Flush", msg.Message= "Flush Buffer ..."
        Do EventSignal, ##class(dc.journalindexer.dao.JournalDataDAO).FlushBuffer()
        
        Set msg.Action = "Build Indices", msg.Message= "..." Do EventSignal
        Set sc = ##class(dc.journalindexer.dao.JournalDataDAO).RebuildIndices(startIndexId,lastRecordId)

        Set msg.Action= "Delete old journal", msg.Message= "..." Do EventSignal
        Job ##class(dc.journalindexer.services.Indexer).DeleteOld()

    } Catch ex {
        Set sc = ex.AsStatus()
    }

    Lock -^dc.journalindexer.services.Indexer

    Set msg.Action = "Restore journal state", msg.Message = "..." Do EventSignal
    Do ##class(dc.journalindexer.services.Indexer).RestoreJournalState(transactionMode, autoCommitMode)

    Set msg.Status = $Select($$$ISOK(sc):"Done",1:"ERR"), msg.Message="with status : "_$Select($$$ISERR(sc):$SYSTEM.Status.GetOneErrorText(sc),1:"OK")

    Set msg.Action = "ENDED" Do EventSignal

    Return sc

EventSignal
    Quit:Notify=""
    Do $SYSTEM.Event.Signal(Notify, msg.%ToJSON())
    Quit
EventSignalStatus
    Set msg.Status = "ERR", msg.Message = $SYSTEM.Status.GetOneErrorText(sc)
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
        Set sc = $$$ADDSC(sc,##class(dc.journalindexer.services.Indexer).DeleteJournal(id))
    }

    Quit sc
}

/// Delete journal indexed in database
ClassMethod DeleteJournal(JournalId As %Integer) As %Status
{
    Set sc = $$$OK

    Do ..StopJournal(.transactionMode, .autoCommitMode)

    Try {
        
        Set tResult = ##class(%SQL.Statement).%ExecDirect(.statement, "DELETE %NOLOCK FROM dc_journalindexer_data.Record WHERE File = ?", JournalId)

        Set:(tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) sc = $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message) 

        Set:##class(dc.journalindexer.data.File).%ExistsId(JournalId) sc = $$$ADDSC(sc, ##class(dc.journalindexer.data.File).%DeleteId(JournalId))

    } Catch ex {
        Set sc = $$$ADDSC(sc,ex.AsStatus())
    }

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
