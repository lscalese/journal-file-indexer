Class dc.observer.Abstract [ Abstract ]
{

ClassMethod Update(
	EventObject As %DynamicObject,
	Data As %DynamicObject,
	Context As %DynamicObject) As %Status
{
	;Set EventType = EventObject.EventType
    ;Set EventName = EventObject.EventName
	;If EventName = "OnComplete" do ...
	Quit $$$OK
}

ClassMethod ToClean(
	Event As %DynamicObject,
	Context As %DynamicObject) As %Boolean
{
    Quit $$$NO
}

}
