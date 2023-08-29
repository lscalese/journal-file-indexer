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
    Set sc = ##class(dc.journalindexer.data.Record).%BuildIndices($ListBuild("$Record","FileI", "ProcessID", "TimeStampI", "AddressI", "TypeI"), 1, 0, 0, startId, lastId),
        sc = $$$ADDSC(sc,##class(dc.journalindexer.data.SetKillRecord).%BuildIndices($ListBuild("$SetKillRecord", "GlobalNameI", "SubscriptsI"), 1, 0, 0, startId, lastId)),
        sc = $$$ADDSC(sc,##class(dc.journalindexer.data.BitSetRecord).%BuildIndices($ListBuild("$BitSetRecord"), 1, 0, 0, startId, lastId))

    Quit sc
}

ClassMethod GetNextRecord(record As dc.journalindexer.data.Record) As dc.journalindexer.data.Record
{
    If record.NextAddress = "" Return ""
}

ClassMethod ClearAll()
{
    Do ##class(dc.journalindexer.data.BitSetRecord).%KillExtent()
    Do ##class(dc.journalindexer.data.SetKillRecord).%KillExtent()
    Do ##class(dc.journalindexer.data.Record).%KillExtent()
    Do ##class(dc.journalindexer.data.File).%KillExtent()
    
    Do ##class(dc.journalindexer.data.BitSetRecord).%PurgeIndices()
    Do ##class(dc.journalindexer.data.SetKillRecord).%PurgeIndices()
    Do ##class(dc.journalindexer.data.Record).%PurgeIndices()
    Do ##class(dc.journalindexer.data.File).%PurgeIndices()

    Kill ^IRIS.Temp.data.RecordI, ^IRIS.Temp.data.RecordD

    Quit
}

}
