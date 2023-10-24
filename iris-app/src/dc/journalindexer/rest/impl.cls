Include journalindexer

Class dc.journalindexer.rest.impl Extends %REST.Impl [ ProcedureBlock ]
{

Parameter ExposeServerExceptions = 1;

/// Service implemntation for delete /file/{fileid}
ClassMethod DeleteIndexedFile(messageRequest As dc.journalindexer.rest.requests.DeleteIndexedFile) As %Status
{
	If '##class(dc.journalindexer.data.File).%ExistsId(messageRequest.pathfileid) Do ..%SetStatusCode(404) Quit ""
	Job ##class(dc.journalindexer.services.Indexer).DeleteIndexedJournalData(messageRequest.pathfileid)
	;If $$$ISERR(sc) $$$ThrowStatus(sc)
	Do ..%SetStatusCode(204)
	Quit ""
}

/// Service implemntation for get /databases/{fileid}
ClassMethod GetDatabases(messageRequest As dc.journalindexer.rest.requests.GetDatabases) As %Status
{
	Quit ##class(dc.journalindexer.dao.JournalDataDAO).GetDistinct("databasename",messageRequest.pathfileid,"",,messageRequest.globalName)
}

/// Service implemntation for get /globals/{fileid}
ClassMethod GetGlobals(messageRequest As dc.journalindexer.rest.requests.GetGlobals) As %Status
{
	Quit ##class(dc.journalindexer.dao.JournalDataDAO).GetDistinct("GlobalName",messageRequest.pathfileid,messageRequest.querydatabasename)
}

/// Service implemntation for get /file/progression/{token}
ClassMethod GetIndexerProgression(messageRequest As dc.journalindexer.rest.requests.GetIndexerProgression) As %Status
{
	If '$Data(^dc.journalindexer.token(messageRequest.pathtoken),value) Do ..%SetStatusCode(404) Quit ""
	Return {}.%FromJSON(value)
}

/// Service implemntation for get /file/{fileid}
ClassMethod GetJournalDetails(messageRequest As dc.journalindexer.rest.requests.GetJournalDetails) As %Status
{
	Set file = ##class(dc.journalindexer.dao.JournalDataDAO).GetJournalFile(messageRequest.pathfileid)
	If $IsObject(file) Quit file
	Do ..%SetStatusCode(404)
	Quit {"message" : "Indexed journal not found."}
}

/// Service implemntation for get /indexedjournals
ClassMethod GetListFiles(messageRequest As dc.journalindexer.rest.requests.GetListFiles) As %Status
{
	s ^lsc=$zdt($h,3,1)
	Set response = ##class(dc.journalindexer.dao.JournalDataDAO).GetJournalFiles()
	s ^lsc(1) = response.%ToJSON()
	Quit response
}

/// Service implemntation for get /record/{fileid}/{address}
ClassMethod GetRecord(messageRequest As dc.journalindexer.rest.requests.GetRecord) As %Status
{
	Set record = ##class(dc.journalindexer.dao.JournalDataDAO).GetRecord(messageRequest.pathfileid,messageRequest.pathaddress)
	If $IsObject(record) Quit record
	Do ..%SetStatusCode(404)
	Quit {"message" : "Record not found."}
}

/// Service implemntation for get /records/{fileid}
ClassMethod GetRecords(messageRequest As dc.journalindexer.rest.requests.GetRecords) As %Status
{
	s ^lsc(1) = messageRequest.filter.%ToJSON()
	Quit ##class(dc.journalindexer.dao.JournalDataDAO).GetRecords(messageRequest.filter, $$$YES, messageRequest.limitRecord, messageRequest.startId, messageRequest.direction)
}

/// Service implemntation for get /serverjrnfile
ClassMethod GetServerJournalFiles(messageRequest As dc.journalindexer.rest.requests.GetServerJournalFiles) As %Status
{
	Do ##class(%SYS.Journal.History).LoadLog(, .list)

	Set array = [], key = ""  
	For  {
		Set key = $Order(list(key), 1, value) 
		Quit:key=""  
		Set fileName = $Piece(value, ",", 2)
		Do:##class(%File).Exists(fileName)||##class(%File).Exists(fileName_"z") array.%Push(fileName)
	}
	
	Quit array
}

/// Service implemntation for get /stats/{fileid}
ClassMethod GetStats(messageRequest As dc.journalindexer.rest.requests.GetStats) As %Status
{
	Quit ##class(dc.journalindexer.dao.JournalDataDAO).GetStats(messageRequest.pathfileid)
}

/// Service implemntation for post /file
ClassMethod IndexFile(messageRequest As dc.journalindexer.rest.requests.IndexFile) As %Status
{
	Set token = $tr($SYSTEM.Encryption.Base64Encode($tr($zdt($h,3,1),"-: "),1),"=")
	Set ^dc.journalindexer.token(token) = {"Status":"In Progress","Action":"Starting"}.%ToJSON()
	Set userDefinedName = messageRequest.IndexFile.userDefinedName
	Set:userDefinedName="" userDefinedName = ##class(%File).GetFilename(messageRequest.IndexFile.path)
    Job ##class(dc.journalindexer.services.Indexer).Index(messageRequest.IndexFile.path,userDefinedName,"",$$$NO,token,$$$NO)::2
	If '$Test Set sc = $$$ERROR($$$GeneralError,"Fail to start indexer job.") Kill ^dc.journalindexer.token(token) $$$ThrowStatus(sc)
	Quit {"Status":"Started","PID":($ZChild),"Token":(token),"Message":""}
}

/// Service implemntation for post /upload
ClassMethod UploadAndIndex(messageRequest As dc.journalindexer.rest.requests.UploadAndIndex) As %Status
{
	Set token = $tr($SYSTEM.Encryption.Base64Encode($tr($zdt($h,3,1),"-: "),1),"=")
	Set filePath = ##Class(%File).TempFilename(messageRequest.filename) ;, fileName = ##class(%File).GetFilename(filePath)
	Set file = ##class(%Stream.FileBinary).%New()
	Do file.LinkToFile(filePath), file.CopyFromAndSave(messageRequest.body) kill file
	Set ^dc.journalindexer.token(token) = {"Status":"In Progress","Action":"Starting"}.%ToJSON()
	Job ##class(dc.journalindexer.services.Indexer).Index(filePath,messageRequest.userDefinedName,"",$$$NO,token,$$$YES)::2
	If '$Test Set sc = $$$ERROR($$$GeneralError,"Fail to start indexer job.") Kill ^dc.journalindexer.token(token) $$$ThrowStatus(sc)
	Quit {"Status":"Started","PID":($ZChild),"Token":(token),"Message":""}
}

/// Service implemntation for post /restore
ClassMethod Restore(messageRequest As dc.journalindexer.rest.requests.Restore) As %Status
{
	#dim restoreConfig As dc.journalindexer.rest.model.RestoreConfig = messageRequest.RestoreConfig
	Set sc = ##class(dc.journalindexer.services.Data).RestoreGlobal(restoreConfig.Filter, restoreConfig.RestoreValue, restoreConfig.RedirectTo, .msg)
	If $$$ISERR(sc) $$$ThrowStatus(sc)
	Set status = { "Message":[], "Status":"OK" }, key = ""
	For  Set key = $Order(msg(key),1,value) Quit:key=""  Do status.Message.%Push(value)
	Quit status
}

/// Service implemntation for get /export/{fileid}
ClassMethod Export(messageRequest As dc.journalindexer.rest.requests.Export) As %Status
{
	#dim %response As %CSP.Response

	#dim restoreConfig As dc.journalindexer.rest.model.RestoreConfig = messageRequest.RestoreConfig

	Set filePath = ##Class(%File).TempFilename("xml")
	Set sc = ##class(dc.journalindexer.services.Data).RestoreAndExportToFile(restoreConfig.Filter, restoreConfig.RestoreValue, filePath, restoreConfig.RedirectTo)
	If $$$ISERR(sc) Do deleteFile $$$ThrowStatus(sc)
	Set stream = ##class(%Stream.GlobalBinary).%New()
	Set file = ##class(%Stream.FileBinary).%New()
	Do file.LinkToFile(filePath)
	Do stream.CopyFrom(file)
	Kill file
	Do deleteFile
	Set attachName = "restore-"_restoreConfig.Filter.GlobalName.Value_".xml"
	Set %response.ContentType= "application/xml"
	Do %response.SetHeader("Content-Disposition",$Replace("attachment; filename=""%1""","%1",attachName))
	Do %response.SetHeader("Content-Transfer-Encoding","binary")
	Do %response.SetHeader("Pragma","no-cache")
	Do %response.SetHeader("Cache-Control","no-cache")
	Set %response.ContentLength = stream.Size
	Set %response.NoCharSetConvert = 1
	Quit stream
deleteFile
	Do:##class(%File).Exists(filePath) ##class(%File).Delete(filePath)
	Quit
}

/// Process request SwaggerSpec /_spec
ClassMethod SwaggerSpec() As %Status
{
	Set spec = {}.%FromJSON(##class(%Dictionary.CompiledXData).%OpenId("dc.journalindexer.rest.Spec||OpenAPI").Data)
	Set url = $Select(%request.Secure:"https",1:"http") _ "://"_$Get(%request.CgiEnvs("SERVER_NAME")) _ ":" _ $Get(%request.CgiEnvs("SERVER_PORT")) _ %request.Application
	Set spec.servers = [{"url" : (url)}]
	Quit spec
}

/// Service implemntation for get /info
ClassMethod info(messageRequest As dc.journalindexer.rest.requests.info) As %Status
{
	Quit { "zv": ($zv), "title": "Journal Indexer", "version": "0.5.0" }
}

ClassMethod IsValidGlobal(messageRequest As dc.journalindexer.rest.requests.IsValidGlobal) As %Status
{
	Set exists = $$$NO
	Set isValidName = $$$YES
	Try {
		Set exists = ''$Data(@messageRequest.globalName)
	} Catch (ex) {
		Set isValidName = $$$NO
	}
	
	Set %response.ContentType = "application/json"

	Quit { 
		"IsValidName" : (isValidName),
		"Exists": (exists),
		"Message": ""
	}
}

}
