Class dc.journalindexer.services.Search
{

ClassMethod SearchInIndexedJournal() As %Status
{
    #dim JournalFiles As %DynamicArray
    #dim iter As %Iterator.Array
    Set sc = $$$OK, jrn="", detailView = $$$NO

    Try {

        For  {
            Write #
            Write !, ##class(%Utility).Center("Search in indexed journal files")
            Write !, ##class(%Utility).Center("-------------------------------")
            
            Write !,!," 1) Show list of indexed journal files."
            Write !," 2) Navigate."
            Write !," 3) Search (list view)."
            Write !," 4) Search (detail view)."
            Write !," 5) Index a journal file in database."
            Write !,!, "(Q)uit or (#) Menu item => "

            Read *Item Set Item = $Char(Item)
        
            If $$$LOWER($Extract(Item)) = "q" Quit

            Do ProcessSelect
        }

    } Catch ex {
        Set sc = ex.AsStatus()
        Do $SYSTEM.Status.DisplayError(sc)
    }

    Return sc

ProcessSelect
    If +Item = 1 Do ListJournalIndexed Write !,!," Press <any key> to return to main menu." Read *x
    If +Item = 2 Set detailView = $$$YES Do ListJournalIndexed, Navigate
    If +Item = 3 Set detailView = $$$NO Do ShowRecords
    If +Item = 4 Set detailView = $$$YES Do ShowRecords
    If +Item = 5 Do ##class(dc.journalindexer.services.Indexer).RunIndex() Write !,##class(%Utility).Center("Press <any key>") Read *x
    Quit

ListJournalIndexed
    Kill jrn, i

    Set JournalFiles = ##class(dc.journalindexer.dao.Queries).GetJournalFiles(.sc)
    
    If $$$ISERR(sc) Do $SYSTEM.Status.DisplayError(sc) Quit

    Set iter = JournalFiles.%GetIterator()
    
    Write #
    Write !,!, ##class(%Utility).Center("Indexed journal files")
    Write !, ##class(%Utility).Center("---------------------")

    While iter.%GetNext(.key, .journalInfo, .type) {
        Write !," ",$Justify($Increment(i), 3), ") ", journalInfo.Name, $Replace(" (%1)", "%1", journalInfo.UserDefinedName), $Replace(" [%1]", "%1", journalInfo.ID)
        Set jrn(i) = $ListBuild(journalInfo.ID,journalInfo.UserDefinedName,journalInfo.FirstRecord,journalInfo.LastRecord)
    }

    Quit

Navigate
    Write !,!, "Select a journal file # => " Read x
    Quit:x=""

    If '$Data(jrn($p(x," ")),FileInfo) Write !,"Item ", $p(x," "), " not found." Quit

    Set journalEntry = ##class(dc.journalindexer.data.Record).FileAddrOpen($LG(FileInfo,1),$LG(FileInfo,3)),x = "n"

    While $IsObject(journalEntry) {
        
        If 'journalEntry.%IsA("dc.journalindexer.data.SetKillRecord") {
            Set journalEntryD = {}
            For propertyName = "Address", "TypeName", "PrevAddress", "NextAddress", "TimeStamp", "InTransaction", "ProcessID", "RemoteSystemID", "ECPSystemID" {
                Do journalEntryD.%Set(propertyName, $Property(journalEntry, propertyName))
            }
            Set journalEntry = journalEntryD
        }
        
        Do DisplayDetailView
        
        Write !, "(P)revious (Q)uit (N)ext (or <any other key>)." 
        Read *x Set x = $$$LOWER($c(x)) Quit:x="q"
        
        Set goToAddr = +$Select(x="p": journalEntry.PrevAddress, 1: journalEntry.NextAddress)

        Continue:goToAddr=0
        Set journalEntry = ##class(dc.journalindexer.data.Record).FileAddrOpen($LG(FileInfo,1), goToAddr)
    }

    Set journalEntry = ""

    Quit

ShowRecords
    Do ListJournalIndexed

    Write !,!, "Select a journal file # => " Read x
    Quit:x=""

    If '$Data(jrn($p(x," ")),FileInfo) Write !,"Item ", $p(x," "), " not found." Quit

    
    Set filter = {}
    Do {
        Set stop = $$$YES

        Write !,!,"Put your filter in JSON format, empty string allowed (see documentation for more details). "
        Write !, "    ex : ", {"GlobalName":{"Value":"^SYS"},"Subscripts":{"Value":"HistoryD","Position":2}}.%ToJSON()
        Write !,!,"Filter => " Read filterStr

        Quit:filterStr=""

        Try {
            Set filter = {}.%FromJSON(filterStr)
        } Catch(ex) { 
            Do $SYSTEM.Status.DisplayError(ex.AsStatus())
            Set stop = $$$NO
        }
        
    } While 'stop
    
    

    Set filter.File = {"Value" : ($ListGet(FileInfo,1))}

    #dim tResult As %SQL.StatementResult
    Set tResult = ##class(dc.journalindexer.dao.Queries).SearchRecordFunc(filter)
    
    Set cnt = 0

    Set titles = $ListToString($ListBuild("Address", "TimeStamp", "Type", "Transaction", "Global", "Database"), $Char(9))
    
    Write:'detailView # Do WriteTitles

    Kill colNames Merge colNames = tResult.%GetMetaData().columnIndex

    While tResult.%Next(.sc) {
        
        Kill journalEntry Set journalEntry = {}
        Set key = "" For  Set key = $Order(colNames(key), 1, d) Quit:key=""  Do journalEntry.%Set($LG(d,2), tResult.%Get($LG(d,2)))
        
        If detailView {
            Do DisplayDetailView 
            Write !, "Press <any key> to display the next record or <q> to stop." Read *x Quit:x=$a("q")
            Continue
        }

        Do DisplayListView

        If $Increment(cnt) #20 '= 0 Continue
        
        Write !, "Press <any key> to display next 20 records or (Q) to stop." Read *x Quit:x=$a("q")
        Write # Do WriteTitles
        
    }

    If x'=$a("q") Write !,"  End Of Data.  Press <any key>." Read *x Quit
    

    kill tResult
    Quit

WriteTitles
    Write !, titles, !
    For i=1:1:80 Write "-"
    Quit

DisplayListView
    Write !
    For columnName = "Address", "TimeStamp", "TypeName", "InTransaction", "GlobalNode", "DatabaseName" {
        Write journalEntry.%Get(columnName), $Char(9)
    }
    Quit

DisplayDetailView
    #Define ZLEFTALIGN(%1,%2)  $Reverse($Justify($Reverse(%1),%2))
    Write #
    For i=1:1:80 Write "-"
    Write !,$$$ZLEFTALIGN("File: "_$ListGet(FileInfo, 2),25)
    Write ##class(%Utility).Center("First Address: "_$ListGet(FileInfo,3),25)
    Write $Justify("Last Address: "_$ListGet(FileInfo,4),30), !
    For i=1:1:80 Write "-"
    Write !, $$$ZLEFTALIGN("Address:",20), journalEntry.Address
    Write ##class(%Utility).Center("Next: "_journalEntry.NextAddress,25)
    Write $Justify("Previous: "_journalEntry.PrevAddress,20)
    Write !, $$$ZLEFTALIGN("TimeStamp:",20), journalEntry.TimeStamp
    Write !, $$$ZLEFTALIGN("Type:",20), journalEntry.TypeName
    Write !, $$$ZLEFTALIGN("In Transaction: ",20), $Select(journalEntry.InTransaction:"YES",1:"NO")
    Write !, $$$ZLEFTALIGN("Process ID: ",20), journalEntry.ProcessID
    Write !, $$$ZLEFTALIGN("Database:",20) , journalEntry.DatabaseName
    Write !, $$$ZLEFTALIGN("Global Node:",20) , journalEntry.GlobalNode
    Write !,!,$$$ZLEFTALIGN("Nbr of values:",20) , journalEntry.NumberOfValues
    Write !,$$$ZLEFTALIGN("Old Value:",20), journalEntry.FormattedOldValue
    Write !,$$$ZLEFTALIGN("New Value:",20), journalEntry.FormattedNewValue
    Write !,!
    Quit
}

}
