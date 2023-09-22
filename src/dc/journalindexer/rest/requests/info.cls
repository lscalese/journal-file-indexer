Class dc.journalindexer.rest.requests.info Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "get";

Parameter URL = "/info";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
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
