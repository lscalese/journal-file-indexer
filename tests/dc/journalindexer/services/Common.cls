Class tests.dc.journalindexer.services.Common
{

Parameter NSETKILL = 1000;

ClassMethod GenerateJournalFile(Output JournalFile As %String) As %Status
{
    Set sc = $$$OK
    
    $$$QuitOnError(##class(%SYS.Journal.System).RollToNextFile(1, .JournalFile))
    
    Set n = ..#NSETKILL
    For i=1:1:n {
        Set data(i) = $ListBuild(##class(%PopulateUtils).LastName(), 
                        ##class(%PopulateUtils).FirstName(), 
                        ##class(%PopulateUtils).Street(),
                        ##class(%PopulateUtils).City(),
                        ##class(%PopulateUtils).USZip(),
                        ##class(%PopulateUtils).USState(),
                        ##class(%PopulateUtils).SSN(),
                        $Random(1000))

        Set indices("USStateI", " " _ $List(data(i), 6), i) = ""
        Set indices("SSNI", " " _ $List(data(i), 7), i) = ""
    }
    
    TSTART
    Merge ^dc.journalindexer.testD = data, ^dc.journalindexer.testI = indices
    TCOMMIT

    Do ##class(%SYS.Journal.System).RollToNextFile(1)
    
    Quit sc
}

}
