Class tests.dc.journalindexer.services.Restore Extends %UnitTest.TestCase
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

    Kill ^dc.journalindexer.testD, ^dc.journalindexer.testI, ^dc.jrnindexer.testrestore

    Quit $$$OK
}

Method Test001IndexFile() As %Status
{
    Do ..LogMessage("Index journal file " _ ..JournalFile)
    Set sc = ##class(dc.journalindexer.services.Indexer).Index(..JournalFile,"unit_test_TestRestore",.FileId)
    Set:$$$ISOK(sc) ..FileId = FileId
    Do $$$AssertStatusOK(sc, "Insert journal in database using Index method")
    Quit sc
}

Method Test005Restore() As %Status
{
    Set sc = $$$OK

    If $Data(^dc.jrnindexer.testrestore) Kill ^dc.jrnindexer.testrestore

    Set Filter = {"File":{"Value":(..FileId)},"Type":{"Value":"SET"},"GlobalName":{"Value":($Name(^dc.journalindexer.testD))},"Subscripts":[{"Operator":"between","Start":"250","End":"300"}]}
    
    Do ..LogMessage("Start restore with filter:")
    Do ..LogMessage(Filter.%ToJSON())

    Set sc = ##class(dc.journalindexer.services.Data).RestoreGlobal(Filter,"newvalue",$Name(^dc.jrnindexer.testrestore),.msg)

    Do $$$AssertStatusOK(sc, "RestoreGlobal return status ok")

    Quit sc
}

Method Test010CheckRestore() As %Status
{
    Set sc = $$$OK

    Do ..LogMessage("Check restored data...")

    For i=250:1:300 {
        Set value = $Get(^dc.jrnindexer.testrestore(i))
        Do $$$AssertEquals(value,$Get(^dc.journalindexer.testD(i)),$$$FormatText("Check restored value for key %1", i))
        Do ..LogMessage("Restored: "_##class(%Utility).FormatString(value))
        Do ..LogMessage("Expected: "_##class(%Utility).FormatString($Get(^dc.journalindexer.testD(i))))
    }

    Quit sc
}

}
