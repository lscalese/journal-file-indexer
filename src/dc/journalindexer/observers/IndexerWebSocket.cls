Include eventobserver

Class dc.journalindexer.observers.IndexerWebSocket Extends dc.observer.Abstract
{

ClassMethod Update(
	Event As %DynamicObject,
	Data As %DynamicObject,
	Context As %DynamicObject) As %Status
{
    Set ws = ##class(%CSP.WebSocket).%New()
    Set sc = ws.OpenServer(Context.WebSocketID)
    If $$$ISERR(sc) Quit sc
    Quit ws.Write(Data.%ToJSON())
}

ClassMethod ToClean(
	Event As %DynamicObject,
	Context As %DynamicObject) As %Boolean
{
    If $$$ISERR(##class(%CSP.WebSocket).%New().OpenServer(Context.WebSocketID)) Quit $$$YES
    Quit $$$NO
}

}
