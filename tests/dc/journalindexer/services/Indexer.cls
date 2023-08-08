Class tests.dc.journalindexer.services.Indexer Extends %UnitTest.TestCase
{

Method OnBeforeAllTests() As %Status
{
    Set sc = $$$OK
    $$$QuitOnError(..GenerateJournalFile(.JournalFile))
    Set %ztests("JournalFile") = JournalFile
    Quit sc
}

Method OnAfterAllTests() As %Status
{
    Kill %ztests("JournalFile")
    Quit $$$OK
}

Method Test01IndexFile() As %Status
{
    Do ..LogMessage("Index journal file " _ %ztests("JournalFile"))
    Set sc = ##class(dc.journalindexer.services.Indexer).Index(%ztests("JournalFile"),"unit_test_Test01IndexFile","",.FileId)
    Set:$$$ISOK(sc) %ztests("FileId", FileId) = $lb(FileId, %ztests("JournalFile"))

    Do $$$AssertStatusOK(sc, "Insert journal in database using Index method")

    Quit sc
}

Method Test05IndexFileWizard() As %Status
{
    Set sc = $$$OK
    Do ..LogMessage("Index journal file " _ %ztests("JournalFile")_ " using wizard")

    Set inputFile = ##class(%File).TempFilename("test"), outputFile = inputFile_".out"
    Set file = ##class(%Stream.FileCharacter).%New()
    $$$QuitOnError(file.LinkToFile(inputFile))
    Do file.WriteLine(%ztests("JournalFile"))

    Set sc = file.%Save()

    Do $$$AssertStatusOK(sc, $Replace("Create temp input file %1.", "%1", inputFile))

    Set ressource = "UnitTestRunIndex"

    Do:$SYSTEM.Event.Defined(ressource) $SYSTEM.Event.Delete(ressource)
    Do $SYSTEM.Event.Create("UnitTestRunIndex")

    Job ..UnitTestRunIndex(ressource):(::inputFile:outputFile)

    Set returnList = $SYSTEM.Event.WaitMsg(ressource, 25)

    Set state = $ListGet(returnList, 1)
    
    If state = -1 {
        Set sc = $$$ERROR($$$GeneralError, "Ressource deleted.")
    } ElseIf state = 0 {
        Set sc = $$$ERROR($$$GeneralError, "Wait Message timeout.")
    } Else {
        Set sc = $ListGet(returnList, 2)

        Set out = ##class(%Stream.FileCharacter).%New()
        Do out.LinkToFile(outputFile)
        
        Do ..LogMessage("Output : ")
        Do ..LogMessage("----------------------------------")
        While 'out.AtEnd {
            Set line = out.ReadLine() Do ..LogMessage($Select($Length(line)>512:$Extract(line,1,512)_"...",1:line))
        }
        Do ..LogMessage("----------------------------------")
        
        Kill out
        Do ##class(%File).Delete(inputFile), ##class(%File).Delete(outputFile)
    }

    Do $$$AssertStatusOK(sc, "Index using wizard.")
    
    Do $SYSTEM.Event.Delete(ressource)
    
    Quit sc
}

ClassMethod UnitTestRunIndex(Notify As %String) As %Status [ Internal ]
{
    Set sc = ##class(dc.journalindexer.services.Indexer).RunIndex()
    Do $SYSTEM.Event.Signal(Notify, sc)
    Quit sc
}

Method Test99DeleteJournal() As %Status
{
    Set sc = $$$OK, id = ""
    For  Set id = $Order(%ztests("FileId", id)) Quit:id=""  Set sc = $$$ADDSC(sc,##class(dc.journalindexer.services.Indexer).DeleteJournal(id))
    Do $$$AssertStatusOK(sc, "Delete indexed journal in database")
    Quit sc
}

ClassMethod GenerateJournalFile(Output JournalFile As %String) As %Status
{
    Set sc = $$$OK
    
    Kill ^dc.journalindexer.testD

    $$$QuitOnError(##class(%SYS.Journal.System).RollToNextFile(1, .JournalFile))

    Set n = 10000
    For i=1:1:n {
        Set data = $ListBuild(##class(%PopulateUtils).LastName(), 
                        ##class(%PopulateUtils).FirstName(), 
                        ##class(%PopulateUtils).Street(),
                        ##class(%PopulateUtils).City(),
                        ##class(%PopulateUtils).USZip(),
                        ##class(%PopulateUtils).USState(),
                        ##class(%PopulateUtils).SSN(),
                        $Random(1000))
        
        Set ^dc.journalindexer.testD(i) = data
    }

    For i=1:1:n/2 Kill ^dc.journalindexer.testD(i)

    For i=n/2+1:1:n TSTART  Kill ^dc.journalindexer.testD(i)  TCOMMIT


    Do ##class(%SYS.Journal.System).RollToNextFile(1)

    Quit sc
}

}
