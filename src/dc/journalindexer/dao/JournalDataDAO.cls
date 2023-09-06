Class dc.journalindexer.dao.JournalDataDAO
{

ClassMethod SetFile(
	Journal As %SYS.Journal.File,
	Name As %String,
	Output id As %Integer = "") As %Status
{
    Set sc = $$$OK

    Set file = ##class(dc.journalindexer.data.File).%New()
    Set file.UserDefinedName = Name
    Set file.Name = Journal.Name
    Set file.FirstRecord = Journal.FirstRecord.Address
    Set file.LastRecord = Journal.LastRecord.Address
    Set file.ClusterStartTime = Journal.ClusterStartTime
    Set file.ClusterStartTime0 = Journal.ClusterStartTime0
    
    Set sc = file.%Save()
    Set id = file.%Id()

    Return sc
}

/// This is the same of "SetRecord" but data are stored in the buffer array %zinstance<br/>.
/// You need to use the FlushBuffer() method to store data in database and then<br/>
/// rebuild indices with RebuildIndices(firstId, lastId).<br/>
/// 
ClassMethod SetRecordInBuffer(
	Record As %SYS.Journal.Record,
	FileId As %Integer,
	Output RecordId As %Integer) As %Status
{
    Set RecordId = $Increment(^IRIS.Temp.data.RecordD)

    Set class = ""

    If $Classname(Record) = "%SYS.Journal.SetKillRecord" {
        Do SetKillProperties
        Set class = "~dc.journalindexer.data.SetKillRecord~"
    } ElseIf $Classname(Record) = "%SYS.Journal.BitSetRecord" {
        Do BitSetProperties
        Set class = "~dc.journalindexer.data.SetKillRecord~dc.journalindexer.data.BitSetRecord~"
    }

    Set %zinstance(RecordId) = $ListBuild(class,Record.Address,Record.Type,Record.PrevAddress,Record.NextAddress,Record.TimeStamp,Record.InTransaction,Record.ProcessID,Record.JobID,Record.RemoteSystemID,Record.ECPSystemID,+FileId)
    
    Quit $$$OK

SetKillProperties
    For i=1:1:$QLENGTH(Record.GlobalNode) Set $List(Subscripts, i) = $QSubscript(Record.GlobalNode, i)
    Set %zinstance(RecordId, "SetKillRecord") = $ListBuild(Record.ClusterSequence,Record.DatabaseName,Record.MirrorDatabaseName,Record.GlobalReference,Record.GlobalNode,Record.NumberOfValues,Record.NewValue,Record.OldValue,Record.Collation,$QSubScript(Record.GlobalNode,0),$Get(Subscripts))
    Quit

BitSetProperties
    Do SetKillProperties
    Set %zinstance(RecordId, "BitSetRecord") = $ListBuild(Record.Position,Record.OldLength)
    Quit
}

ClassMethod FlushBuffer() As %Status
{
    Quit:'$Data(%zinstance) $$$OK
    Merge ^IRIS.Temp.data.RecordD = %zinstance
    Kill %zinstance
    Quit $$$OK
}

ClassMethod RebuildIndices(
	startId As %Integer,
	lastId As %Integer) As %Status
{
    Set sc = ##class(dc.journalindexer.data.Record).%BuildIndices($ListBuild("$Record","FileI", "ProcessID", "TimeStampI", "AddressI", "TypeI", "FileAddr"), 1, 0, 0, startId, lastId),
        sc = $$$ADDSC(sc,##class(dc.journalindexer.data.SetKillRecord).%BuildIndices($ListBuild("$SetKillRecord", "GlobalNameI", "SubscriptsI"), 1, 0, 0, startId, lastId)),
        sc = $$$ADDSC(sc,##class(dc.journalindexer.data.BitSetRecord).%BuildIndices($ListBuild("$BitSetRecord"), 1, 0, 0, startId, lastId))

    Quit sc
}

ClassMethod GetJournalFiles(Output sc As %Status) As %DynamicArray
{
    Set tStatement = ##class(%SQL.Statement).%New(), array = []
	Set sc = tStatement.%PrepareClassQuery("dc.journalindexer.dao.Queries", "JournalFile")
    Return:$$$ISERR(sc) array

	Set tResult = tStatement.%Execute()
	If tResult.%SQLCODE'=0, tResult.%SQLCODE '= 100 Return $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)
    
    While tResult.%Next() { Do array.%Push({}.%FromJSON(tResult.%Get("RecordJSON"))) }

    Return array
}

ClassMethod SetStatsInBuffer(
	Record As %SYS.Journal.SetKillRecord,
	ByRef stats As %Binary) As %Status
{

    /// Compute the record size
    /// The logic has been copied from %CSP.UI.System.OpenJournalPane.cls
    Set curlen = $zu(78,42,Record.Address)
    Set size = Record.Address + curlen -(stats("prevaddr") + stats("prevlen"))
    Set stats("prevaddr") = Record.Address, stats("prevlen") = curlen

    Return:'Record.%IsA("%SYS.Journal.SetKillRecord") $$$OK

    If size '> 0 Quit $$$OK
    
    Set node = $Piece(Record.GlobalReference, "(", 1)

    Set key3 = "Type"

    For keys = $Lb("gbl", node), $Lb("pid", Record.ProcessID), $Lb("db", Record.DatabaseName), $Lb("jrn", "Total") {
        
        Set key1 = $Li(keys, 1), key2 = $Li(keys, 2)

        If '$Data(stats(key1, key2), data) Set data = $lb(0,0)
        If '$Data(stats(key1, key2, key3), types) Set types = $lb(0,0)
    
        Set $Li(data, 1) = 1 + $Lg(data, 1), 
            $Li(data, 2) = size + $Lg(data, 2), 
            $Li(types, Record.Type ) = 1 + $Lg(types, Record.Type)
        
        Set stats(key1, key2) = data, stats(key1, key2, key3) = types
    }

    Return $$$OK
}

ClassMethod SaveStats(
	JournalID As %Integer,
	ByRef statsData) As %Status
{
    Set sc = $$$OK, statsOn = ""

    For {
        Set statsOn = $Order(statsData(statsOn), 1)
        Quit:statsOn=""

        Set key = ""
        For  {
            Set key = $Order(statsData(statsOn, key), 1, data)
            Quit:key=""

            Set stat = ##class(dc.journalindexer.data.Stats).%New()
            Set stat.StatsOn = statsOn
            Set stat.Key = key
            Set stat.FileId = JournalID
            Set stat.Hit = $ListGet(data, 1)
            Set stat.Size = $ListGet(data, 2)

            If $Data(statsData(statsOn, key, "Type"), types) Do AlimType

            Set sc = $$$ADDSC(sc, stat.%Save())
        }
    }
    
    ;Merge ^dc.journalindexer.data.Stats(JournalID) = statsData
    
    Return sc

AlimType
    For i=1:1:$ListLength(types) {
        Set item = $ListGet(types, i)
        Continue:item=""
        Set typeName = ##class(%Library.JournalRecordType).LogicalToDisplay(i)
        Do stat.Type.SetAt(item, typeName)
    }
    Quit
}

ClassMethod ClearAll()
{
    Do ##class(dc.journalindexer.data.BitSetRecord).%KillExtent()
    Do ##class(dc.journalindexer.data.SetKillRecord).%KillExtent()
    Do ##class(dc.journalindexer.data.Record).%KillExtent()
    Do ##class(dc.journalindexer.data.File).%KillExtent()
    Do ##class(dc.journalindexer.data.Stats).%KillExtent()
    
    Do ##class(dc.journalindexer.data.BitSetRecord).%PurgeIndices()
    Do ##class(dc.journalindexer.data.SetKillRecord).%PurgeIndices()
    Do ##class(dc.journalindexer.data.Record).%PurgeIndices()
    Do ##class(dc.journalindexer.data.File).%PurgeIndices()
    Do ##class(dc.journalindexer.data.Stats).%PurgeIndices()

    Kill ^IRIS.Temp.data.RecordI, ^IRIS.Temp.data.RecordD, ^dc.journalindexer.data.Stats

    Quit
}

}
