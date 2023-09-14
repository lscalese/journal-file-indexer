Class tests.dc.journalindexer.services.Search Extends %UnitTest.TestCase
{

Parameter NSETKILL = 1000;

Property JournalFile As %String;

Property FileId As %Integer;

Method OnBeforeAllTests() As %Status
{
    Set sc = $$$OK
    Do $SYSTEM.Process.SynchCommit(1)

    Set sc = ##class(tests.dc.journalindexer.services.Common).GenerateJournalFile(.JournalFile), 
        ..JournalFile = JournalFile

    Quit sc
}

Method OnAfterAllTests() As %Status
{
    Do $SYSTEM.Process.SynchCommit(0)

    Kill ^dc.journalindexer.testD, ^dc.journalindexer.testI

    Quit $$$OK
}

Method Test010IndexFile() As %Status
{
    Do ..LogMessage("Index journal file " _ ..JournalFile)
    Set sc = ##class(dc.journalindexer.services.Indexer).Index(..JournalFile,"unit_test_Test01IndexFile","",.FileId)
    Set:$$$ISOK(sc) ..FileId = FileId
    Do $$$AssertStatusOK(sc, "Insert journal in database using Index method")
    Quit sc
}

Method Test015Search() As %Status
{
    Do ..LogMessage("Search in indexed journal file using filter : File, GlobalName, Type and Subscripts.")

    Set sc = $$$OK

    ;USStateI
    Set state = $Order(^dc.journalindexer.testI("USStateI","")), id = "", cpt = 0
    Do $$$AssertNotEquals("",state,"Has value in " _ $Name(^dc.journalindexer.testI("USStateI")))
    Quit:state="" sc

    For  Set id = $Order(^dc.journalindexer.testI("USStateI", state, id), 1) Quit:id=""  Do $Increment(count(state))

    Set filter = {
        "File" : {
            "Value" : (..FileId)
        },
        "GlobalName" : {
            "Value" : ($Name(^dc.journalindexer.testI))
        },
        "Type": {
            "Value": "SET"
        },
        "Subscripts" : {
            "Value" : (state),
            "Position" : 2
        }
    }

    Do ..LogMessage("Filter is --> " _ filter.%ToJSON())
    Do ..LogMessage("Number of result must be : " _ count(state))

    Set tResult = ##class(dc.journalindexer.dao.Queries).SearchRecordFunc(filter)

    Do ..LogMessage("Executed query is : ")
    Do ..LogMessage($Get(^dc.journalindexer("last-sql-resolved")))
    
    While tResult.%Next(.sc) {
        Quit:$$$ISERR(sc)
        Do $Increment(cpt)
        Do ..LogMessage("Match GlobalNode: " _ tResult.%Get("GlobalNode"))
    }

    Kill tResult

    Do $$$AssertEquals(cpt,count(state), $$$FormatText("Check the number of result %1 (expected: %2)", cpt, count(state)))

    /*
        Search by NewValue
    */

    Do ..LogMessage("---------------------")
    Do ..LogMessage("Search in indexed journal file using filter : File, GlobalName, Type and NewValue.")

    Set filter = {
        "File" : {
            "Value" : (..FileId)
        },
        "GlobalName" : {
            "Value" : ($Name(^dc.journalindexer.testD))
        },
        "Type": {
            "Value": "SET"
        },
        "NewValue" : {
            "Value" : ($Extract(state, 2, *)),
            "Position" : 6
        }
    }

    Do ..LogMessage("Filter is --> " _ filter.%ToJSON())
    Do ..LogMessage("Number of result must be : " _ count(state))
    
    Set tResult = ##class(dc.journalindexer.dao.Queries).SearchRecordFunc(filter), cpt = 0
    
    If tResult.%SQLCODE < 0 Set sc = $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message) Do $$$AssertStatusOK(sc, "SQL Error") Quit sc

    Do ..LogMessage("Executed query is : ")
    Do ..LogMessage($Get(^dc.journalindexer("last-sql-resolved")))
    
    While tResult.%Next(.sc) {
        Quit:$$$ISERR(sc)
        Do $Increment(cpt)
        Do ..LogMessage("Match NewValue: " _ tResult.%Get("FormattedNewValue"))
    }

    Do $$$AssertEquals(cpt,count(state), $$$FormatText("Check the number of result %1 (expected: %2)", cpt, count(state)))

    Quit sc
}

Method Test020Menu() As %Status
{
    Set sc = $$$OK

    Set inputFile = ##class(%File).TempFilename("menu-test"), outputFile = inputFile_".out"
    Set file = ##class(%Stream.FileCharacter).%New()
    $$$QuitOnError(file.LinkToFile(inputFile))

    Do file.Write("1")      ; Show list of indexed journal files.
    Do file.Write("q")      ; Quit, return to main menu.
    
    Do file.Write("2")      ; Navigate.
    Do file.WriteLine("1")  ; Select the first file.
    Do file.Write("q")      ; Quit, return to main menu.

    Do file.Write("3")      ; Search (list view).
    Do file.WriteLine("1")  ; Select the first file.
    Do file.WriteLine("q")   ; Empty filter
    Do file.Write("q")      ; Quit, return to main menu.

    Do file.Write("4")      ; Search (list view).
    Do file.WriteLine("1")  ; Select the first file.
    Do file.WriteLine("q")   ; Empty filter
    Do file.Write("q")      ; Quit, return to main menu.

    Do file.Write("q")      ; Quit.

    Set sc = file.%Save()

    Do $$$AssertStatusOK(sc, $Replace("Create temp input file %1.", "%1", inputFile))

    Set ressource = "UnitTestMenu"

    Do:$SYSTEM.Event.Defined(ressource) $SYSTEM.Event.Delete(ressource)
    Do $SYSTEM.Event.Create("UnitTestMenu")

    Job ..UnitTestMenu(ressource):(::inputFile:outputFile)

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

    Do $$$AssertStatusOK(sc, "Test return menu.")
    
    Do $SYSTEM.Event.Delete(ressource)

    Quit sc
}

ClassMethod UnitTestMenu(Notify As %String) As %Status [ Internal ]
{
    Set sc = ##class(dc.journalindexer.services.Search).SearchInIndexedJournal()
    Do $SYSTEM.Event.Signal(Notify,sc)
    Quit sc
}

}
