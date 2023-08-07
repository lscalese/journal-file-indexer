Class dc.journalindexer.data.File Extends %Persistent
{

/// Path of the journal file
Property Name As %SysPath(MAXLEN = 512);

/// Object reference to the first record in the journal file (applicable to open file only)
Property FirstRecord As %Integer;

/// Object reference to the last record in the journal file (applicable to open file only)
Property LastRecord As %Integer;

/// Cluster start time in time(0) format (i.e., # of seconds since the Epoch)
/// or 0 if not a cluster journal file
Property ClusterStartTime0 As %Integer;

/// Cluster start time in %TimeStamp format or "" if not a cluster journal file
Property ClusterStartTime As %String;

Property UserDefinedName As %String(MAXLEN = 128, TRUNCATE = 1);

Storage Default
{
<Data name="FileDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>FirstRecord</Value>
</Value>
<Value name="4">
<Value>LastRecord</Value>
</Value>
<Value name="5">
<Value>ClusterStartTime0</Value>
</Value>
<Value name="6">
<Value>ClusterStartTime</Value>
</Value>
<Value name="7">
<Value>UserDefinedName</Value>
</Value>
</Data>
<DataLocation>^IRIS.Temp.data.FileD</DataLocation>
<DefaultData>FileDefaultData</DefaultData>
<IdLocation>^IRIS.Temp.data.FileD</IdLocation>
<IndexLocation>^IRIS.Temp.data.FileI</IndexLocation>
<StreamLocation>^IRIS.Temp.data.FileS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

/// User defined name

}
