Include eventobserver

Class dc.observer.Classes Extends %RegisteredObject
{

ClassMethod Subscribe(
	Event As %String,
	Class As %String,
	Context As %DynamicObject = {{}}) As %Status
{
    Set $$$SubscribedClasses($Piece(Event,":",1), Class, ..HashContext(Context)) = $ListBuild(Event,Class,$zdt($H,3,1),$Job,Context.%ToJSON())
    Quit $$$OK
}

ClassMethod UnSubscribe(
	Event As %String,
	Class As %String,
	Context As %DynamicObject = {{}}) As %Status
{
    Kill $$$SubscribedClasses($Piece(Event,":",1), Class, ..HashContext(Context))
    Quit $$$OK
}

ClassMethod UnSubscribeAll(
	Event As %String,
	Class As %String) As %Status
{
    Kill $$$SubscribedClasses($Piece(Event,":",1), Class)
    Quit $$$OK
}

ClassMethod Notify(
	Event As %String,
	Data As %DynamicObject) As %Status
{
    Set EventObject = ##class(dc.observer.Manager).GenEventObject(Event)
    Set Class = "", sc = $$$OK
    For  {
        Set Class = $Order($$$SubscribedClasses(EventObject.EventType, Class), 1)
        Quit:Class=""
        Do NotifyClass
    }
    Quit sc

NotifyClass
    Set key = ""
    For  {
        Set key = $Order($$$SubscribedClasses(EventObject.EventType, Class, key), 1, value)
        Quit:key=""
        Try {
            Set Context = {}.%FromJSON($Lg(value,5))
            If $ClassMethod(Class, $$$ToCleanMethod, EventObject, Context) {
                Kill $$$SubscribedClasses(EventObject.EventType, Class, key)
            }Else {
                Set sc = $$$ADDSC(sc,$ClassMethod(Class, $$$TriggerMethod, EventObject, Data, Context))
            }
        }Catch ex {
            Set sc = $$$ADDSC(sc, ex.AsStatus())
        }
    }
    Quit
}

ClassMethod NotifyContext(
	Event As %String,
	Data As %DynamicObject,
	Context As %DynamicObject) As %Status
{
    Set EventObject = ##class(dc.observer.Manager).GenEventObject(Event)
    Set Class = "", sc = $$$OK, key = ..HashContext(Context)
    For  {
        Set Class = $Order($$$SubscribedClasses(EventObject.EventType, Class), 1)
        Quit:Class=""
        
        Continue:'$Data($$$SubscribedClasses(EventObject.EventType, Class, key))
        If $ClassMethod(Class, $$$ToCleanMethod, EventObject, Context) {
            Kill $$$SubscribedClasses(EventObject.EventType, Class, key)
        } Else {
            Set sc = $$$ADDSC(sc,$ClassMethod(Class, $$$TriggerMethod, EventObject, Data, Context))
        }
    }
    Quit sc
}

ClassMethod HashContext(Context As %DynamicObject) As %String [ CodeMode = expression, Internal, Private ]
{
$ZCRC($Select($IsObject(Context):Context.%ToJSON(),1:Context),7)
}

ClassMethod Kill() As %Status [ Internal ]
{
    Kill $$$SubscribedClasses
    Quit $$$OK
}

ClassMethod ShowSubscribed()
{
    Set node = $Name($$$SubscribedClasses)
    For  {
        Set node = $Query(@node,1,value)
        Quit:node=""
        Write !," * Event: ", $QSubscript(node,1), "  ClassName: ", $QSubscript(node,2)
        Write !,"   Date time:",$Lg(value,3)
        Write !,"   PID: ", $Lg(value,4)
        Write !,"   Context: ",$Lg(value,5)
    }
    Quit
}

}
