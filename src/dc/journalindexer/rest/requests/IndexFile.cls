Class dc.journalindexer.rest.requests.IndexFile Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "post";

Parameter URL = "/file";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

/// Use this property for body content with content-type = application/json.
Property IndexFile As dc.journalindexer.rest.model.IndexFile;

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
	If ..%ContentType = "application/json"{
		Do ..IndexFileNewObject().%JSONImport(request.Content)
	}
	Quit sc
}

/// Load object properties from %CSP.Request object.
Method RequestValidate() As %Status
{
	Set sc = $$$OK
	$$$QuitOnError(..%ValidateObject())
	If ''$ListFind($ListFromString("application/json"), ..%ContentType) {
		Quit:..IndexFile="" $$$ERROR(5659, "IndexFile")
	}
	If $IsObject(..IndexFile) $$$QuitOnError(..IndexFile.%ValidateObject())
	Quit sc
}

}
