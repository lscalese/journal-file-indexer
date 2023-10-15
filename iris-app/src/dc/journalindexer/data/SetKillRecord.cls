Class dc.journalindexer.data.SetKillRecord Extends dc.journalindexer.data.Record
{

/// Cluster journal sequence number of the record on a clustered system or 0 otherwise
Property ClusterSequence As %Integer;

/// Directory path of the database updated by the SET or KILL 
Property DatabaseName As %String [ Calculated, SqlComputeCode = { Set {*} = ##class(dc.journalindexer.data.DB).GetDbName({Database})}, SqlComputed ];

/// Mirror database name of the database updated by the SET or KILL if it is a mirrored database
Property MirrorDatabaseName As %String;

/// Extended global reference of the SET or KILL
Property GlobalReference As %VarString [ Calculated, SqlComputeCode = {Set {*} = "^[""^^"_{DatabaseName}_"""]"_$Extract({GlobalNode},2,*)}, SqlComputed ];

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
Property GlobalName As %String(COLLATION = "EXACT") [ Calculated, SqlComputeCode = {Set {*} = $QSubscript({GlobalNode},0)}, SqlComputed ];

Property Subscripts As list Of %String(MAXLEN = "");

/// If BITSET : Bit position of the BITSET
Property Position As %Integer;

/// If BITSET : The length of the bit string prior to the BITSET
Property OldLength As %Integer;

Property Database As dc.journalindexer.data.DB;

Property FormattedOldValue As %String [ SqlComputeCode = { Set {*} = ##class(%Utility).FormatString({OldValue})}, SqlComputed, Transient ];

Property FormattedNewValue As %String [ SqlComputeCode = { Set {*} = ##class(%Utility).FormatString({NewValue})}, SqlComputed, Transient ];

Property ExistsNewValue As %Boolean [ SqlComputeCode = { Set {*} = ({Type}=$$$JRNSET)||({Type}=$$$JRNBITSET)||({Type}=$$$JRNNSET)||({Type}=$$$JRNMIRSET)||({Type}=$$$JRNQADD)}, SqlComputed, Transient ];

Property ExistsOldValue As %Boolean [ SqlComputeCode = { Set {*} = ({NumberOfValues}>1)||((({TypeName}["KILL")||({Type}=$$$JRNQREM))&&{NumberOfValues})}, SqlComputed, Transient ];

Property SubscriptsSize As %String [ SqlComputeCode = { Set {*} = $QLength({GlobalNode})}, SqlComputed, Transient ];

Index GlobalNameI On GlobalName [ Type = bitmap ];

Index SubscriptsI On Subscripts(ELEMENTS);

Index DatabaseI On Database [ Type = bitmap ];

Method FormattedOldValueGet() As %String [ CodeMode = expression ]
{
##class(%Utility).FormatString(..OldValue)
}

Method FormattedNewValueGet() As %String [ CodeMode = expression ]
{
##class(%Utility).FormatString(..NewValue)
}

Method ExistsNewValueGet() As %Boolean [ CodeMode = expression ]
{
(i%Type=$$$JRNSET)||(i%Type=$$$JRNBITSET)||(i%Type=$$$JRNNSET)||(i%Type=$$$JRNMIRSET)||(i%Type=$$$JRNQADD)
}

/// TRUE if there is an <property>OldValue</property> (including "") in the record
Method ExistsOldValueGet() As %Boolean [ CodeMode = expression ]
{
(..NumberOfValues>1)||(((..TypeName["KILL")||(i%Type=$$$JRNQREM))&&..NumberOfValues)
}

Method SubscriptsSizeGet() As %String [ CodeMode = expression ]
{
$QLength(..GlobalNode)
}

Method GlobalReferenceGet() As %String [ CodeMode = expression ]
{
"^[""^^"_..Database.DatabaseName_"""]"_$Extract(i%GlobalNode,2,*)
}

Method GlobalNameGet() As %String [ CodeMode = expression ]
{
$QSubscript(i%GlobalNode,0)
}

Storage Default
{
<Data name="SetKillRecordDefaultData">
<Subscript>"SetKillRecord"</Subscript>
<Value name="1">
<Value>ClusterSequence</Value>
</Value>
<Value name="2">
<Value>Database</Value>
</Value>
<Value name="3">
<Value>MirrorDatabaseName</Value>
</Value>
<Value name="4">
<Value>GlobalNode</Value>
</Value>
<Value name="5">
<Value>NumberOfValues</Value>
</Value>
<Value name="6">
<Value>NewValue</Value>
</Value>
<Value name="7">
<Value>OldValue</Value>
</Value>
<Value name="8">
<Value>Collation</Value>
</Value>
<Value name="9">
<Value>Subscripts</Value>
</Value>
<Value name="10">
<Value>Position</Value>
</Value>
<Value name="11">
<Value>OldLength</Value>
</Value>
</Data>
<DefaultData>SetKillRecordDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
