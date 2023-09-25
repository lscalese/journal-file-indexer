Class dc.observer.Manager
{

ClassMethod Notify(
	Event As %String,
	Data As %DynamicObject) As %Status
{
    Set sc = ##class(dc.observer.Classes).Notify(Event, Data)
    Set sc = $$$ADDSC(sc, ##class(dc.observer.Event).Notify(Event, Data))
    Quit sc
}

ClassMethod GenEventObject(Event As %String) As %DynamicObject
{
    Quit {"Event":(Event),"EventType":($Piece(Event,":",1)),"EventName":($Piece(Event,":",2)),"PIDSource":($JOB),"Timestamp":($ZDateTime($Horolog,3,1))}
}

ClassMethod ShowSubscribed()
{
    Do ##class(dc.observer.Event).ShowSubscribed()
    Do ##class(dc.observer.Classes).ShowSubscribed()
    Quit
}

ClassMethod Kill() As %Status [ Internal ]
{
    Do ##class(dc.observer.Classes).Kill(), ##class(dc.observer.Event).Kill()
    Quit $$$OK
}

}
