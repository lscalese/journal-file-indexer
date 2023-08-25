Class dc.journalindexer.data.SetKillRecord Extends dc.journalindexer.data.Record
{

/// Cluster journal sequence number of the record on a clustered system or 0 otherwise
Property ClusterSequence As %Integer;

/// Directory path of the database updated by the SET or KILL 
Property DatabaseName As %SysPath;

/// Mirror database name of the database updated by the SET or KILL if it is a mirrored database
Property MirrorDatabaseName As %String;

/// Extended global reference of the SET or KILL
Property GlobalReference As %VarString(MAXLEN = "");

/// Global node of the SET or KILL (<property>GlobalReference</property> minus the namespace)
Property GlobalNode As %VarString;

/// Number of data values stored in the record. It can be 0, 1 or 2 depending on
/// whether the record is a SET or KILL and whether it is in a transaction.
Property NumberOfValues As %Integer;

/// (For SET record only) The value the global node was set to
Property NewValue As %VarString(MAXLEN = "");

/// (For <property>InTransaction</property> record only) The value of the global node prior to the SET or KILL
Property OldValue As %VarString(MAXLEN = "");

/// The collation of the subscripts in <property>GlobalNode</property>
Property Collation As %Integer;

/// GlobalName 
Property GlobalName As %String(MAXLEN = 128);

Property Subscripts As list Of %String;

Index GlobalNameI On GlobalName [ Type = bitmap ];

Index SubscriptsI On Subscripts(ELEMENTS);

Storage Default
{
<Data name="SetKillRecordDefaultData">
<Subscript>"SetKillRecord"</Subscript>
<Value name="1">
<Value>ClusterSequence</Value>
</Value>
<Value name="2">
<Value>DatabaseName</Value>
</Value>
<Value name="3">
<Value>MirrorDatabaseName</Value>
</Value>
<Value name="4">
<Value>GlobalReference</Value>
</Value>
<Value name="5">
<Value>GlobalNode</Value>
</Value>
<Value name="6">
<Value>NumberOfValues</Value>
</Value>
<Value name="7">
<Value>NewValue</Value>
</Value>
<Value name="8">
<Value>OldValue</Value>
</Value>
<Value name="9">
<Value>Collation</Value>
</Value>
<Value name="10">
<Value>GlobalName</Value>
</Value>
<Value name="11">
<Value>Subscripts</Value>
</Value>
</Data>
<DefaultData>SetKillRecordDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
