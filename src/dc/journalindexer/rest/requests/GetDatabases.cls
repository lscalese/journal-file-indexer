Class dc.journalindexer.rest.requests.GetDatabases Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "get";

Parameter URL = "/databases/{fileid}";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

/// Indexed journal ID.  See GET /indexedjournals to retrieve the list of indexed journal in DB.
Property pathfileid As %String;

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
	;Set ..queryfileid = $Get(request.Data("fileid",1))
	Quit sc
}

/// Load object properties from %CSP.Request object.
Method RequestValidate() As %Status
{
	Set sc = $$$OK
	$$$QuitOnError(..%ValidateObject())
	Quit sc
}

}
