Class dc.journalindexer.rest.requests.IsValidGlobal Extends %RegisteredObject
{

Parameter METHOD = "get";

Parameter URL = "/isvalidglobal";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

Property globalName As %String;

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
    Set ..globalName = $Get(%request.Data("globalName", 1))
    Set:$Extract(..globalName)'="^" ..globalName = "^" _ ..globalName
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
