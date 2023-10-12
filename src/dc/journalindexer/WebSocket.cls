Include (journalindexer, eventobserver)

Class dc.journalindexer.WebSocket Extends %CSP.WebSocket
{

Method OnPreServer() As %Status
{
    Do %session.Login("wsuser",,1)
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

Method OnClientMessage(
	data As %String = "",
	close As %Integer) As %Status
{
    If $Get(close) = 1 {
        Do %session.Logout()
        Set %session.EndSession = 1
        Do ..EndServer()
    }

	Quit 0
}

Method OnPostServer() As %Status
{
    
    Do ##class(dc.observer.Manager).UnSubscribe("dc.journalindexer.events.WebSocketListener",{"WebSocketID":(..WebSocketID)})
	Quit $$$OK
}

}
