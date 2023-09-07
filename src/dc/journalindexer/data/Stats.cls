Class dc.journalindexer.data.Stats Extends %Persistent
{

Property FileId As %Integer [ Required ];

Property StatsOn As %String;

Property Key As %String(MAXLEN = 2048, TRUNCATE = 1) [ Required ];

Property Hit As %Integer;

Property Size As %Integer;

Property Type As array Of %String;

Property TypeJSON As %String [ Calculated, SqlComputeCode = { Set {*} = ..buildTypeJSON({ID})}, SqlComputed, Transient ];

ForeignKey FileKF(FileId) References dc.journalindexer.data.File() [ OnDelete = cascade ];

Method TypeJSONGet() As %String
{
    Quit ..buildTypeJSON(..%Id())
}

ClassMethod buildTypeJSON(
	StatsID As %Integer,
	Output Type As %DynamicObject) As %String
{
    Set type = {}
    If '$Data(^IRIS.Temp.data.StatsD(StatsID, "Type")) Quit ""
    
    Set typeName = ""
    For  {
        Set typeName = $Order(^IRIS.Temp.data.StatsD(StatsID, "Type", typeName ), 1, value)
        Quit:typeName=""
        Do type.%Set(typeName, value)
    }

    Quit type.%ToJSON()
    
    If '$Quit Quit ""

    Quit type.%ToJSON()
}

Storage Default
{
<Data name="StatsData">
<Attribute>StatsData</Attribute>
<Structure>node</Structure>
<Subscript>"StatsData"</Subscript>
</Data>
<Data name="StatsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FileId</Value>
</Value>
<Value name="3">
<Value>StatsOn</Value>
</Value>
<Value name="4">
<Value>Key</Value>
</Value>
<Value name="5">
<Value>Hit</Value>
</Value>
<Value name="6">
<Value>Size</Value>
</Value>
</Data>
<Data name="Type">
<Attribute>Type</Attribute>
<Structure>subnode</Structure>
<Subscript>"Type"</Subscript>
</Data>
<DataLocation>^IRIS.Temp.data.StatsD</DataLocation>
<DefaultData>StatsDefaultData</DefaultData>
<IdLocation>^IRIS.Temp.data.ata.StatsD</IdLocation>
<IndexLocation>^IRIS.Temp.data.StatsI</IndexLocation>
<StreamLocation>^IRIS.Temp.data.StatsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
