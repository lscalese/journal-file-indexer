Class dc.journalindexer.rest.disp Extends %CSP.REST [ ProcedureBlock ]
{

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

Parameter IgnoreWrites = 1;

Parameter SpecificationClass = "dc.journalindexer.rest.Spec";

Parameter HandleCorsRequest = 1;

/// Process request delete /file/{fileid}
ClassMethod DeleteIndexedFile(fileid As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.DeleteIndexedFile).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set requestMessage.pathfileid = fileid
		Set response = ##class(dc.journalindexer.rest.impl).DeleteIndexedFile(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /export/{fileid}
ClassMethod Export(fileid As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.Export).%New()
		Set requestMessage.pathfileid = fileid
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set response = ##class(dc.journalindexer.rest.impl).Export(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /databases/{fileid}
ClassMethod GetDatabases(fileid As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetDatabases).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set requestMessage.pathfileid = fileid
		Set response = ##class(dc.journalindexer.rest.impl).GetDatabases(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /globals/{fileid}
ClassMethod GetGlobals(fileid As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetGlobals).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set requestMessage.pathfileid = fileid
		Set response = ##class(dc.journalindexer.rest.impl).GetGlobals(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /file/progression/{token}
ClassMethod GetIndexerProgression(token As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetIndexerProgression).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set requestMessage.pathtoken = token
		Set response = ##class(dc.journalindexer.rest.impl).GetIndexerProgression(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /file/{fileid}
ClassMethod GetJournalDetails(fileid As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetJournalDetails).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set requestMessage.pathfileid = fileid
		Set response = ##class(dc.journalindexer.rest.impl).GetJournalDetails(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /indexedjournals
ClassMethod GetListFiles() As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetListFiles).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set response = ##class(dc.journalindexer.rest.impl).GetListFiles(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /record/{fileid}/{address}
ClassMethod GetRecord(
	fileid As %String,
	address As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetRecord).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set requestMessage.pathfileid = fileid, requestMessage.pathaddress = address
		Set response = ##class(dc.journalindexer.rest.impl).GetRecord(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /records/{fileid}
ClassMethod GetRecords(fileid As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetRecords).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set requestMessage.pathfileid = fileid
		Set response = ##class(dc.journalindexer.rest.impl).GetRecords(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /serverjrnfile
ClassMethod GetServerJournalFiles() As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetServerJournalFiles).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set response = ##class(dc.journalindexer.rest.impl).GetServerJournalFiles(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /stats/{fileid}
ClassMethod GetStats(fileid As %String) As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.GetStats).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set requestMessage.pathfileid = fileid
		Set response = ##class(dc.journalindexer.rest.impl).GetStats(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request post /file
ClassMethod IndexFile() As %Status
{
	Set sc = $$$OK
	Try{
		Set acceptedMedia = $ListFromString("application/json")
		If '$ListFind(acceptedMedia,$$$LOWER(%request.ContentType)) {
			 Do ##class(%REST.Impl).%ReportRESTError(..#HTTP415UNSUPPORTEDMEDIATYPE,$$$ERROR($$$RESTContentType,%request.ContentType)) Quit
		}
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		If '$isobject(%request.Content) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTRequired,"body")) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.IndexFile).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set response = ##class(dc.journalindexer.rest.impl).IndexFile(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request post /restore
ClassMethod Restore() As %Status
{
	Set sc = $$$OK
	Try{
		Set acceptedMedia = $ListFromString("application/json")
		If '$ListFind(acceptedMedia,$$$LOWER(%request.ContentType)) {
			 Do ##class(%REST.Impl).%ReportRESTError(..#HTTP415UNSUPPORTEDMEDIATYPE,$$$ERROR($$$RESTContentType,%request.ContentType)) Quit
		}
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.Restore).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set response = ##class(dc.journalindexer.rest.impl).Restore(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request SwaggerSpec /_spec
ClassMethod SwaggerSpec() As %Status
{
	Try {
		Do ##class(%REST.Impl).%SetContentType("application/json")
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set response=##class(dc.journalindexer.rest.impl).SwaggerSpec()
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		 Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.disp","ExposeServerExceptions"))
	}
	Quit $$$OK
}

/// Process request post /upload
ClassMethod UploadAndIndex() As %Status
{
	Set sc = $$$OK
	Try{
		Set acceptedMedia = $ListFromString("multipart/form-data")
		If '$ListFind(acceptedMedia,$$$LOWER(%request.ContentType)) {
			 Do ##class(%REST.Impl).%ReportRESTError(..#HTTP415UNSUPPORTEDMEDIATYPE,$$$ERROR($$$RESTContentType,%request.ContentType)) Quit
		}
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.UploadAndIndex).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set response = ##class(dc.journalindexer.rest.impl).UploadAndIndex(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

/// Process request get /info
ClassMethod info() As %Status
{
	Set sc = $$$OK
	Try{
		Do ##class(%REST.Impl).%SetContentType($Get(%request.CgiEnvs("HTTP_ACCEPT")))
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		Set requestMessage = ##class(dc.journalindexer.rest.requests.info).%New()
		Do requestMessage.LoadFromRequest(%request)
		Set scValidateRequest = requestMessage.RequestValidate()
		If $$$ISERR(scValidateRequest) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR(5001,"Invalid requestMessage object.")) Quit
		Set response = ##class(dc.journalindexer.rest.impl).info(requestMessage)
		Do ##class(dc.journalindexer.rest.impl).%WriteResponse(response)
	} Catch(ex) {
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("dc.journalindexer.rest.impl","ExposeServerExceptions"))
	}
	Quit sc
}

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/info" Method="GET" Call="info" />
  <Route Url="/upload" Method="POST" Call="UploadAndIndex" />
  <Route Url="/serverjrnfile" Method="GET" Call="GetServerJournalFiles" />
  <Route Url="/file" Method="POST" Call="IndexFile" />
  <Route Url="/file/:fileid" Method="GET" Call="GetJournalDetails" />
  <Route Url="/file/:fileid" Method="DELETE" Call="DeleteIndexedFile" />
  <Route Url="/file/progression/:token" Method="GET" Call="GetIndexerProgression" />
  <Route Url="/indexedjournals" Method="GET" Call="GetListFiles" />
  <Route Url="/record/:fileid/:address" Method="GET" Call="GetRecord" />
  <Route Url="/records/:fileid" Method="GET" Call="GetRecords" />
  <Route Url="/stats/:fileid" Method="GET" Call="GetStats" />
  <Route Url="/export/:fileid" Method="GET" Call="Export" />
  <Route Url="/restore" Method="POST" Call="Restore" />
  <Route Url="/globals/:fileid" Method="GET" Call="GetGlobals" />
  <Route Url="/databases/:fileid" Method="GET" Call="GetDatabases" />
  <Route Url="/_spec" Method="get" Call="SwaggerSpec" />
</Routes>
}

}
