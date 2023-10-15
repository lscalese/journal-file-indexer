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

Property userDefinedName As %String;

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
	;$Get(request.MimeData("userDefinedName",1)) ; does not work to check  with front app...
	Set ..userDefinedName = $Get(request.Data("userDefinedName",1),$Get(request.MimeData("userDefinedName",1)))

	If ..userDefinedName = "" Set ..userDefinedName = ##class(%File).GetFilename(..filename)
	
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
