Class dc.journalindexer.rest.requests.Restore Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "post";

Parameter URL = "/restore";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

/// Use this property for body content with content-type = application/json.
Property RestoreConfig As dc.journalindexer.rest.model.RestoreConfig;

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
	If ..%ContentType = "application/json" {
		Do ..RestoreConfigNewObject().%JSONImport(request.Content)
		Set ..RestoreConfig = {}.%FromJSON(request.Content)
	}
	Quit sc
}

/// Load object properties from %CSP.Request object.
Method RequestValidate() As %Status
{
	Set sc = $$$OK
	;$$$QuitOnError(..%ValidateObject())
	;If $IsObject(..RestoreConfig) $$$QuitOnError(..RestoreConfig.%ValidateObject())
	Quit sc
}

}
