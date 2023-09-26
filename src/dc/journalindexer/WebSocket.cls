Include (journalindexer, eventobserver)

Class dc.journalindexer.WebSocket Extends %CSP.WebSocket
{

Method OnPreServer() As %Status
{
    Set sc = $$$OK
    If ..WebSocketID = "" Quit sc
    Set ..SharedConnection = 1
    Do ##class(dc.observer.Manager).Subscribe("dc.journalindexer.events.WebSocketListener",{"WebSocketID":(..WebSocketID)})
    Quit sc
}

Method Server() As %Status
{
   Quit $$$OK
}

Method OnPostServer() As %Status
{
    Do ##class(dc.observer.Manager).UnSubscribe("dc.journalindexer.events.WebSocketListener",{"WebSocketID":(..WebSocketID)})
	Quit $$$OK
}

}
