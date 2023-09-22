Class dc.journalindexer.rest.requests.UploadAndIndex Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter METHOD = "post";

Parameter URL = "/upload";

Property %Consume As %String;

Property %ContentType As %String;

Property %URL As %String [ InitialExpression = {..#URL} ];

/// Use this property for body content with content-type = application/octet-stream.
Property body As %Stream.GlobalBinary;

Property queryrunTuneTable As %Boolean;

Property filename As %String;

/// Load object properties from %CSP.Request object.
Method LoadFromRequest(request As %CSP.Request = {%request}) As %Status
{
	Set sc = $$$OK
	Set ..%ContentType = $Piece(request.ContentType, ";", 1)
	Set ..queryrunTuneTable = +$Get(request.Data("runTuneTable",1))
	Set jrnFile = $Get(request.MimeData("journalfile",1))
	If ..%ContentType = "multipart/form-data", $IsObject(jrnFile) {
		Do ..body.CopyFrom(jrnFile)
		Set ..filename = jrnFile.FileName
	}
	Quit sc
}

/// Load object properties from %CSP.Request object.
Method RequestValidate() As %Status
{
	Set sc = $$$OK
	If ..body.Size = 0 Quit $$$ERROR($$$GeneralError,"Journal file is mandatory.")
	$$$QuitOnError(..%ValidateObject())
	Quit sc
}

}
