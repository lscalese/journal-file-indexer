Class dc.journalindexer.services.Config
{

ClassMethod MaxJournalRetention() As %Integer [ CodeMode = expression ]
{
..GetConfig("MaxJournalRetention")
}

ClassMethod SetMaxJournalRetention(value As %Integer) As %Status [ CodeMode = expression ]
{
..SetConfig("MaxJournalRetention", value)
}

ClassMethod SetConfig(
	key As %String,
	value As %String) As %Status
{
    If '..IsValidKey(.key) Return $$$ERROR(5001, key _ " is not a valid configuration key.")

    Set ^dc.journalindexer("config", key) = value
    Return $$$OK
}

ClassMethod GetConfig(key As %String) As %String
{
    If $Get(key) = "" Return ""

    Return $Get(^dc.journalindexer("config", key))
}

ClassMethod Reset() As %Status [ CodeMode = objectgenerator ]
{
    #dim json As %DynamicObject = {}.%FromJSON(##class(%Dictionary.XDataDefinition).%OpenId("dc.journalindexer.services.Config||Description").Data)

    #dim iter As %Iterator.Object = json.%GetIterator()

    Do %code.WriteLine( $Char(9) _ "Kill ^dc.journalindexer(""config"")")

    While iter.%GetNext(.key, .value, .type) {
        Do %code.WriteLine( $Char(9) _ $$$FormatText("Do ..SetConfig(""%1"", ""%2"")", key, value.Default))
    }

    Do %code.WriteLine( $Char(9) _ "Return $$$OK")

    Return $$$OK
}

ClassMethod IsValidKey(key As %String) As %Boolean [ CodeMode = expression ]
{
''$ListFind(..GetListConfigKey(), key)
}

ClassMethod GetListConfigKey() As %List [ CodeMode = objectgenerator ]
{
    
    #dim json As %DynamicObject = {}.%FromJSON(##class(%Dictionary.XDataDefinition).%OpenId("dc.journalindexer.services.Config||Description").Data)

    #dim iter As %Iterator.Object = json.%GetIterator()

    Set list = ""

    While iter.%GetNext(.key, .value, .type) {
        Set $List(list, $ll(list)+1) = key
    }

    Do %code.WriteLine($Char(9) _ "Return $ListFromString(""" _ $ListToString(list) _ """)")
    
    Return $$$OK
}

ClassMethod Initialize() As %Status [ CodeMode = objectgenerator ]
{
    #dim json As %DynamicObject = {}.%FromJSON(##class(%Dictionary.XDataDefinition).%OpenId("dc.journalindexer.services.Config||Description").Data)

    #dim iter As %Iterator.Object = json.%GetIterator()

    While iter.%GetNext(.key, .value, .type) {
        Do %code.WriteLine( $Char(9) _ $$$FormatText("Do:'$Data(^dc.journalindexer(""config"", ""%1"")) ..SetConfig(""%1"", ""%2"")", key, value.Default))
    }

    Do %code.WriteLine( $Char(9) _ "Return $$$OK")

    Return $$$OK
}

XData Description [ MimeType = application/json ]
{
{
        "MaxJournalRetention" : {
            "Default" : "5",
            "Description" : "Maximum of journal indexed in database."
        }
    }
}

}
