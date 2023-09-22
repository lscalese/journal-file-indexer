Class dc.journalindexer.WebSocket Extends %CSP.WebSocket
{

Method OnPreServer() As %Status
{
    Set sc = $$$OK
    If ..WebSocketID = "" Quit sc
    Set ..SharedConnection = 1
    Set ^dc.journalindexer.wsid(..WebSocketID) = $ListBuild($ZDateTime($Horolog,3,1))
    Quit sc
}

Method Server() As %Status
{
   Quit $$$OK
}

Method OnPostServer() As %Status
{
    Kill ^dc.journalindexer.wsid(..WebSocketID)
	Quit $$$OK
}

ClassMethod BroadcastMessage(Message As %String) As %Status
{
    Set MessageStr = Message
    If $IsObject(Message) Set MessageStr = Message.%ToJSON()
    
    Set WebSocketID = "", sc = $$$OK
    For  {
        Set WebSocketID = $Order(^dc.journalindexer.wsid(WebSocketID))
        Quit:WebSocketID=""
        If $get($$$CSPWebSocket("SERVER",WebSocketID)) = "" Kill ^dc.journalindexer.wsid(WebSocketID) Continue
        Set ws=##class(%CSP.WebSocket).%New()
        Set scO = ws.OpenServer(WebSocketID)
        If $$$ISERR(scO) Set sc = $$$ADDSC(sc,scO) Continue
        Set scO = ws.Write(MessageStr)
        If $$$ISERR(scO) Set sc = $$$ADDSC(sc,scO)
    }
    Quit sc
}

}
