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

/// ---- METHOD REPLACED BY SetRecordInBuffer FOR FAST INSERT ----<br/>
/// Set a journal entry into the database<br/>
/// FileId is the idenfier of the related journal file in dc.journalindexer.data.File <br/>
/// It improves the performance but need to rebuild indices.<br/>
ClassMethod SetRecord(
	Record As %SYS.Journal.Record,
	FileId As %Integer,
	Output RecordId As %Integer) As %Status
{
    #dim instance As dc.journalindexer.data.Record
    #dim instanceSetKill As dc.journalindexer.data.SetKillRecord
    #dim instanceBitSet As dc.journalindexer.data.BitSetRecord

    Set sc = $$$OK

    Set instance = $Case($Classname(Record),"%SYS.Journal.SetKillRecord":##class(dc.journalindexer.data.SetKillRecord).%New(),"%SYS.Journal.BitSetRecord":##class(dc.journalindexer.data.BitSetRecord).%New(),:"")
    
    If instance = "" Quit sc ; not supported entry

    Set instance.File = FileId
    Set instance.Address = Record.Address
    Set instance.Type = Record.Type
    Set instance.PrevAddress = Record.PrevAddress
    Set instance.NextAddress = Record.NextAddress
    Set instance.TimeStamp = Record.TimeStamp
    Set instance.InTransaction = Record.InTransaction
    ;Set instance.ProcessID = Record.ProcessID
    Set instance.JobID = Record.JobID
    Set instance.RemoteSystemID = Record.RemoteSystemID
    Set instance.ECPSystemID = Record.ECPSystemID

    If $Classname(Record) = "%SYS.Journal.SetKillRecord" {
        Do SetKillProperties
    } ElseIf $Classname(Record) = "%SYS.Journal.BitSetRecord" {
        Do BitSetProperties
    }

    Set sc = instance.%Save(), RecordId = instance.%Id()

    Quit sc

SetKillProperties
    Set instanceSetKill = instance

    Set instanceSetKill.ClusterSequence = Record.ClusterSequence
    Set instanceSetKill.DatabaseName = Record.DatabaseName
    Set instanceSetKill.MirrorDatabaseName = Record.MirrorDatabaseName
    Set instanceSetKill.GlobalReference = Record.GlobalReference
    Set instanceSetKill.GlobalNode = Record.GlobalNode
    Set instanceSetKill.NumberOfValues = Record.NumberOfValues
    Set instanceSetKill.NewValue = Record.NewValue
    Set instanceSetKill.OldValue = Record.OldValue
    Set instanceSetKill.Collation = Record.Collation

    Quit

BitSetProperties
    Do SetKillProperties

    Set instanceBitSet = instance
    Set instanceBitSet.Position = Record.Position
    Set instanceBitSet.OldLength = Record.OldLength
    Quit
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
    Set RecordId = $Sequence(^IRIS.Temp.data.RecordD)

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
    Set %zinstance(RecordId, "SetKillRecord") = $ListBuild(Record.ClusterSequence,Record.DatabaseName,Record.MirrorDatabaseName,Record.GlobalReference,Record.GlobalNode,Record.NumberOfValues,Record.NewValue,Record.OldValue,Record.Collation,$QSubScript(Record.GlobalNode,0))
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
    Set sc = ##class(dc.journalindexer.data.Record).%BuildIndices($ListBuild("$Record","FileI", "ProcessID", "TimeStampI", "AdressI"), 1, 0, 0, startId, lastId),
        sc = $$$ADDSC(sc,##class(dc.journalindexer.data.SetKillRecord).%BuildIndices($ListBuild("$SetKillRecord","GlobalNameI"), 1, 0, 0, startId, lastId)),
        sc = $$$ADDSC(sc,##class(dc.journalindexer.data.BitSetRecord).%BuildIndices($ListBuild("$BitSetRecord"), 1, 0, 0, startId, lastId))

    Quit sc
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

    Quit
}

}
