Class dc.journalindexer.rest.requests.DeleteIndexedFile Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "delete";

Parameter URL = "/file/{fileid}";

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
	;pathfileid must be set out of this method
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
