Class dc.journalindexer.data.DB Extends %Persistent
{

Property DatabaseName As %SysPath(COLLATION = "EXACT") [ Required ];

Index UniqueI On DatabaseName [ Unique ];

ClassMethod GetId(
	ByRef DatabaseName As %String,
	NoCreate As %Boolean = {$$$NO}) As %Integer
{
    Quit:$Data(%ztemp("db",DatabaseName), Id) Id
    If ..UniqueIExists(DatabaseName,.Id) Set %ztemp("db",DatabaseName) = Id Quit Id
    Quit:NoCreate -1
    Set entry = ..%New(DatabaseName) 
    Do entry.%Save()
    Set %ztemp("db",DatabaseName) = entry.%Id()
    Quit entry.%Id()
}

ClassMethod GetDbName(Id As %Integer) As %String
{
    Quit:$Data(%ztemp("dbname",Id), DatabaseName) DatabaseName
    Set %ztemp("dbname",Id) = ..DatabaseNameGetStored(Id)
    Quit %ztemp("dbname",Id)
}

Method %OnNew(DatabaseName As %String) As %Status
{
    Set ..DatabaseName = DatabaseName
    Quit $$$OK
}

Storage Default
{
<Data name="DBDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DatabaseName</Value>
</Value>
</Data>
<DataLocation>^IRIS.Temp.data.DBD</DataLocation>
<DefaultData>DBDefaultData</DefaultData>
<IdLocation>^IRIS.Temp.data.DBD</IdLocation>
<IndexLocation>^IRIS.Temp.data.DBI</IndexLocation>
<StreamLocation>^IRIS.Temp.data.DBS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
