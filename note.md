To test later

```
ClassMethod SetRecordByGlobalAccess(
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

    Set instance = $ListBuild(class,Record.Address,Record.Type,Record.PrevAddress,Record.NextAddress,Record.TimeStamp,Record.InTransaction,Record.ProcessID,Record.JobID,Record.RemoteSystemID,Record.ECPSystemID,+FileId)
    
    Merge ^IRIS.Temp.data.RecordD(RecordId) = instance

    Quit $$$OK

SetKillProperties
    Set instance("SetKillRecord") = $ListBuild(Record.ClusterSequence,Record.DatabaseName,Record.MirrorDatabaseName,Record.GlobalReference,Record.GlobalNode,Record.NumberOfValues,Record.NewValue,Record.OldValue,Record.Collation,$QSubScript(Record.GlobalNode,0))
    Quit

BitSetProperties
    Do SetKillProperties
    Set instance("BitSetRecord") = $ListBuild(Record.Position,Record.OldLength)
    Quit
}
```