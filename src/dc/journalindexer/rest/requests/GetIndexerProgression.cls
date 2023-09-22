Class dc.journalindexer.rest.requests.GetIndexerProgression Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "get";

Parameter URL = "/file/progression/{token}";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

Property pathtoken As %String;

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
	;pathtoken must be set out of this method
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
