Class dc.journalindexer.rest.requests.Export Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "get";

Parameter URL = "/export/{fileid}";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

/// Indexed journal ID.  See GET /indexedjournals to retrieve the list of indexed journal in DB.
Property pathfileid As %String;

/// Must be a stringify /components/schemas/Filter object
Property queryfilter As %String;

Property filter As %DynamicObject;

Property restorevalue As %String;

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
	Set ..queryfilter = $Get(request.Data("filter",1))
	Set ..restorevalue = $Get(request.Data("restorevalue",1))
	If ..queryfilter '= "" {
		Set ..filter = {}.%FromJSON(..queryfilter)
		Set ..filter.File = {"Value":(..pathfileid)}
	}
	Quit sc
}

/// Load object properties from %CSP.Request object.
Method RequestValidate() As %Status
{
	Set sc = $$$OK
	;$$$QuitOnError(..%ValidateObject())
	Quit sc
}

}
