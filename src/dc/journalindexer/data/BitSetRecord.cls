Class dc.journalindexer.data.BitSetRecord Extends dc.journalindexer.data.SetKillRecord
{

/// Bit position of the BITSET
Property Position As %Integer;

/// The length of the bit string prior to the BITSET
Property OldLength As %Integer;

Storage Default
{
<Data name="BitSetRecordDefaultData">
<Subscript>"BitSetRecord"</Subscript>
<Value name="1">
<Value>Position</Value>
</Value>
<Value name="2">
<Value>OldLength</Value>
</Value>
</Data>
<DefaultData>BitSetRecordDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
