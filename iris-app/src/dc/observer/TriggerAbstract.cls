Class dc.observer.TriggerAbstract [ Abstract ]
{

Parameter EVENTTYPE;

ClassMethod Update(
	EventObject As %DynamicObject,
	Data As %DynamicObject,
	Context As %DynamicObject) As %Status
{
	Quit $$$OK
}

ClassMethod ToClean(
	Event As %DynamicObject,
	Context As %DynamicObject) As %Boolean
{
    Quit $$$NO
}

}
