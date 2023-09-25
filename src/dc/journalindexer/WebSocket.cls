Include (journalindexer, eventobserver)

Class dc.journalindexer.WebSocket Extends %CSP.WebSocket
{

Method OnPreServer() As %Status
{
    Set sc = $$$OK
    If ..WebSocketID = "" Quit sc
    Set ..SharedConnection = 1
    Do $$$SubscribeClass($$$IndexerEvent,$$$WebSocketObserver,{"WebSocketID":(..WebSocketID)})
    Quit sc
}

Method Server() As %Status
{
   Quit $$$OK
}

Method OnPostServer() As %Status
{
    Do $$$UnSubscribeClass($$$IndexerEvent,$$$WebSocketObserver,{"WebSocketID":(..WebSocketID)})
	Quit $$$OK
}

}
