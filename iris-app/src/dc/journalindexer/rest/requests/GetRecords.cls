Class dc.journalindexer.rest.requests.GetRecords Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "get";

Parameter URL = "/records/{fileid}";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

/// Indexed journal ID.  See GET /indexedjournals to retrieve the list of indexed journal in DB.
Property pathfileid As %String;

/// Must be a stringify /components/schemas/Filter object
Property queryfilter As %String;

Property filter As %DynamicObject [ InitialExpression = {{}} ];

Property limitRecord As %Integer [ InitialExpression = 250 ];

Property direction As %Integer [ InitialExpression = 1 ];

Property startId As %Integer [ InitialExpression = 0 ];

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
	;pathfileid must be set out of this method
	Set:$Data(request.Data("filter",1),value)&&(value'="") ..filter = {}.%FromJSON(value)
	Set:$Data(request.Data("limitRecord",1),value)&&(value'="") ..limitRecord = value
	Set:$Data(request.Data("direction",1),value)&&(value'="") ..direction = value
	Set:$Data(request.Data("startId",1),value)&&(value'="") ..startId = value
	Set ..filter.File = {"Value":(..pathfileid)}
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
