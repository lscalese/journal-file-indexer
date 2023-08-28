Class dc.journalindexer.data.Record Extends %Persistent
{

Property File As %Integer [ Required ];

/// Location of the record in the journal file
Property Address As %String [ Required ];

/// Type of the record in numeric form
Property Type As %Library.JournalRecordType;

/// Type of the record in string form
Property TypeName As %String [ Calculated, SqlComputeCode = { Set {*} = ##Class(%Library.JournalRecordType).LogicalToDisplay({Type})}, SqlComputed ];

/// Location of previous record or 0 if this is the first record in the file
Property PrevAddress As %Integer;

/// Location of next record or 0 if this is the last record in the file
Property NextAddress As %Integer;

/// Time stamp of the record (not necessarily the creation time of the record)
Property TimeStamp As %TimeStamp;

/// Whether the record is part of a transaction
Property InTransaction As %Integer;

/// Operating system process id for the process which created the journal record.
/// This is calculated by taking the jobid stored in the journal record and
/// looking up the corresponding process id in a translation table maintained by
/// the system. If the process id cannot be calculated, the jobid with the string
/// "(jid") appended is returned.
Property ProcessID As %Integer;

/// Internal jobid stored with each journal record in the journal file
Property JobID As %Integer;

/// 	Use RemoteSystemID if you're comparing records to ensure that two 
/// 	identical process IDs refer to the same real process/transaction.
/// 
Property RemoteSystemID As %Integer;

/// 	ECPSystemID is <property>RemoteSystemID</property> with the top
/// 	bits masked off. <br>
/// 	Use ECPSystemID if the only thing of interest is whether it came 
/// 	from an ECP client, etc.
/// 
Property ECPSystemID As %Integer;

/// Description
ForeignKey FileKey(File) References dc.journalindexer.data.File() [ OnDelete = cascade ];

Index FileI On File [ Type = bitmap ];

Index ProcessID On ProcessID [ Type = bitmap ];

Index TimeStampI On TimeStamp;

Index AddressI On Address [ Type = bitslice ];

Index TypeI On Type [ Type = bitmap ];

Method TypeNameGet() As %String
{
	Quit ##Class(%Library.JournalRecordType).LogicalToDisplay(..Type)
}

Storage Default
{
<Data name="RecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Address</Value>
</Value>
<Value name="3">
<Value>Type</Value>
</Value>
<Value name="4">
<Value>PrevAddress</Value>
</Value>
<Value name="5">
<Value>NextAddress</Value>
</Value>
<Value name="6">
<Value>TimeStamp</Value>
</Value>
<Value name="7">
<Value>InTransaction</Value>
</Value>
<Value name="8">
<Value>ProcessID</Value>
</Value>
<Value name="9">
<Value>JobID</Value>
</Value>
<Value name="10">
<Value>RemoteSystemID</Value>
</Value>
<Value name="11">
<Value>ECPSystemID</Value>
</Value>
<Value name="12">
<Value>File</Value>
</Value>
</Data>
<DataLocation>^IRIS.Temp.data.RecordD</DataLocation>
<DefaultData>RecordDefaultData</DefaultData>
<IdLocation>^IRIS.Temp.data.RecordD</IdLocation>
<IndexLocation>^IRIS.Temp.data.RecordI</IndexLocation>
<StreamLocation>^IRIS.Temp.data.RecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
