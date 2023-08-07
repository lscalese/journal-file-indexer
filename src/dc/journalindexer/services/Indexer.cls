Class dc.journalindexer.services.Indexer
{

Parameter STEPSIGNAL = 10000;

ClassMethod RunIndex()
{
    Set resourceName = "idx"
    Do $SYSTEM.Event.Delete(resourceName)

    Set sc = $$$OK
    ; "/usr/irissys/mgr/journal/20230805.004z"
    For  {
        Write !,"Journal file path (q for quit): " Read JournalFile

        Return:$Extract($$$LOWER(JournalFile))="q"

        If '##class(%File).Exists(JournalFile) Write !,"File ", JournalFile, " not found." Continue
        If '##class(%SYS.Journal.File).IsValidJournal(JournalFile) Write !,"File ", JournalFile, " is not a valid journa file." Continue

        Quit
    }

    Set name = ##class(%File).GetFilename(JournalFile)
    

    Do:'$SYSTEM.Event.Defined(resourceName) $SYSTEM.Event.Create(resourceName)
    Job ..Index(JournalFile, name, resourceName)
    
    Write !

    For  {
        Set returnList = $SYSTEM.Event.WaitMsg(resourceName, 10)
        ;zw returnList
        Set returnState = $ListGet(returnList, 1)

        If returnState = 1 {
            
            Set msg = {}.%FromJSON($ListGet(returnList,2))
            
            If msg.Status = "InProgress" {
                Do showProgression
            } Else {
                Do ShowMessage
            }

            Quit:msg.Status="Done"||(msg.Status="ERR")
            
            Continue
        }

        If returnState = -1 Set sc = $$$ERROR($$$GeneralError, "Ressource deleted.") Quit

        If returnState = 0, ##class(%SYS.ProcessQuery).%ExistsId($ZChild) Set sc = $$$ERROR($$$GeneralError, "Index process not found") Quit 
        
    }
    Write !

    Do $SYSTEM.Event.Delete(resourceName)

    If $$$ISERR(sc) Do $SYSTEM.Status.DisplayError(sc)
    
    Quit

showProgression
    Set showProgression = $Justify(msg.CurrentAddress, 12) _ " / " _ msg.LastAddress
    Write showProgression
    For i=1:1:$Length(showProgression) Write $c(8)

    Quit

ShowMessage
    Write msg.Message,!
    ;For i=1:1:$Length(msg.Message) Write $c(8)
    Quit
}

/// Open a journal file and index its content in database.
ClassMethod Index(
	JournalFile As %String = "/usr/irissys/mgr/journal/20230806.001",
	Name As %String = {##class(%File).GetFilename(JournalFile)},
	Notify As %String = "") As %Status
{
    #dim journal As %SYS.Journal.File
    #dim jrnId As %Integer
    #dim jrnRecord As %SYS.Journal.Record

    Set sc = $$$OK

    If '##class(%File).Exists(JournalFile) Quit $$$ERROR($$$GeneralError, "File does not exist.")
    If '##class(%SYS.Journal.File).IsValidJournal(JournalFile) Quit $$$ERROR($$$GeneralError, "Is not a valid journal file.")

    Lock +^dc.journalindexer.services.Indexer:2 ; Only one index process at a time

    Set:'$Test sc = $$$ERROR($$$GeneralError, "An indexer process already running, process id :" _ ^$LOCK($Name(^dc.journalindexer.services.Indexer), "OWNER"))

    If $$$ISERR(sc) Do:Notify'="" $SYSTEM.Event.Signal(Notify, {"Status":"ERR", "Message":($SYSTEM.Status.GetOneErrorText(sc))}.%ToJSON()) Quit sc

    Do ##class(dc.journalindexer.services.Indexer).StopJournal(.transactionMode, .autoCommitMode)

    Try {
        
        Do:Notify'="" $SYSTEM.Event.Signal(Notify,{"Message":"Delete old journal ..."}.%ToJSON())
        Do ##class(dc.journalindexer.services.Indexer).DeleteOld()

        Set journal = ##class(%SYS.Journal.File).%OpenId(JournalFile, , .sc) Quit:$$$ISERR(sc)
        
        Set sc = ##class(dc.journalindexer.dao.JournalDataDAO).SetFile(journal, Name, .jrnId) Quit:$$$ISERR(sc)

        Set jrnRecord = journal.FirstRecord

        Do:Notify'="" $SYSTEM.Event.Signal(Notify, {"Message":"Start read journal"}.%ToJSON())       
        
        Set:Notify'="" msg = {
            "FirstAddress":(journal.FirstRecord.Address),
            "LastAddress":(journal.LastRecord.Address),
            "Name":(journal.Name),
            "Status":"InProgress"
        }
        
        Do:Notify'="" $SYSTEM.Event.Signal(Notify, msg.%ToJSON())

        While $IsObject(jrnRecord) {
            
            Do ##class(dc.journalindexer.dao.JournalDataDAO).SetRecord(jrnRecord, .jrnId, .lastRecordId)
            
            Set msg.CurrentAddress = jrnRecord.Address, jrnRecord = jrnRecord.Next

            If Notify = "" Continue
            If $Increment(i) # ..#STEPSIGNAL Continue

            Do $SYSTEM.Event.Signal(Notify, msg.%ToJSON())
            
        }

        Do:Notify'="" $SYSTEM.Event.Signal(Notify, msg.%ToJSON())
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }

    Lock -^dc.journalindexer.services.Indexer

    Do ##class(dc.journalindexer.services.Indexer).RestoreJournalState(transactionMode, autoCommitMode)

    If Notify '= "" Set msg.Status = $Select($$$ISOK(sc):"Done",1:"ERR"), msg.Message=$Select($$$ISERR(sc):$SYSTEM.Status.GetOneErrorText(sc),1:"OK") Do $SYSTEM.Event.Signal(Notify, msg.%ToJSON())

    Return sc
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
    w
    Quit:LastId="" $$$OK

    Set sc = $$$OK, id = ""
    For  {
        Set id = $Order(^IRIS.Temp.data.FileD(id),1) Quit:id>=LastId||(id="")
        Set sc = $$$ADDSC(sc,##class(dc.journalindexer.services.Indexer).DeleteJournal(id))
    }

    Quit sc
}

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
    Do DISABLE^%NOJRN,
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
