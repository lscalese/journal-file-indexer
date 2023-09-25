Include eventobserver

Class dc.observer.Event Extends %RegisteredObject
{

ClassMethod Subscribe(
	Event As %String,
	ResourceName As %String,
	Context As %DynamicObject = {{}}) As %Status
{
    Set $$$Subscribed(Event, ResourceName) = $ListBuild(Event,ResourceName,$zdt($H,3,1),$Job,Context.%ToJSON())
    Quit $$$OK
}

ClassMethod UnSubscribe(
	Event As %String,
	ResourceName As %String) As %Status
{
    Kill $$$Subscribed(Event, ResourceName)
    Quit $$$OK
}

ClassMethod Notify(
	Event,
	Message As %DynamicObject = {{}}) As %Status
{
    Set NotifyObject = ##class(dc.observer.Manager).GenEventObject(Event)
    Set NotifyObject.Data = Message
    Set resourceName = ""
    For  {
        Set resourceName = $Order($$$Subscribed(NotifyObject.EventType,resourceName),1,value)
        Quit:resourceName=""

        ; check if the resource still valid, if not we unsubscribe
        If '$System.Event.Defined(resourceName) Do ..UnSubscribe(NotifyObject.EventType, resourceName) Continue
        If $ListGet(value, 4) '= "", '$Data(^$JOB($ListGet(value, 4))) Do ..UnSubscribe(NotifyObject.EventType, resourceName) Continue
        
        Set NotifyObject.Context = {}.%FromJSON($ListGet(value, 5))
        Try { 
            Do $SYSTEM.Event.Signal(resourceName, NotifyObject.%ToJSON())
        } Catch Ex {
            Do ..UnSubscribe(NotifyObject.EventType, resourceName)
        }
    }

    Quit $$$OK
}

ClassMethod GetSubscribed(Event As %String) As %List
{
    Set list = "", resourceName = ""
    For  {
        Set resourceName = $Order($$$Subscribed(Event,resourceName),1,value)
        Quit:resourceName=""

        ; check if the resource still valid, if not we unsubscribe
        If '$System.Event.Defined(resourceName) Do ..UnSubscribe(Event, resourceName) Continue
        If $ListGet(value, 4) '= "", '$Data(^$JOB($ListGet(value, 4))) Do ..UnSubscribe(Event, resourceName) Continue
        
        Set $List(list,*+1) = resourceName
    }
    Quit list
}

ClassMethod Start(
	Event As %String,
	Output ResourceName As %String) As %Status
{
    Set ResourceName = ..GenResourceName(Event)
    Do $SYSTEM.Event.Create(ResourceName), ..Subscribe(Event, ResourceName)
    Quit $$$OK
}

ClassMethod Stop(
	EventType As %String,
	ResourceName As %String) As %Status
{
    Do ..UnSubscribe(EventType, ResourceName)
    Do:$SYSTEM.Event.Defined(ResourceName) $SYSTEM.Event.Clear(ResourceName), $SYSTEM.Event.Delete(ResourceName)
    Quit $$$OK
}

ClassMethod StopByName(ResourceName As %String) As %Status
{
    Set node = $Name($$$Subscribed)
    For  {
        Set node = $Query(@node,1,value)
        Quit:node=""
        Do ..Stop($QSubscript(node,1), $QSubscript(node,2))
    }
    Quit $$$OK
}

ClassMethod GenResourceName(EventType As %String) As %String
{
    Quit $tr($SYSTEM.Encryption.Base64Encode($Job_$zcrc(EventType_$ZDT($H,3,1),7)),"=")
}

ClassMethod Clean() As %Status
{
    Set node = $Name($$$Subscribed)
    For  {
        Set node = $Query(@node,1,value)
        Quit:node=""
        Set event = $QSubscript(node,1), resourceName = $QSubscript(node,2)
        If '$SYSTEM.Event.Defined(resourceName) Do ..Stop(event, resourceName) Continue
        If $ListGet(value, 4) '= "", '$Data(^$JOB($ListGet(value, 4))) Do ..Stop(event, resourceName)
    }
    Quit $$$OK
}

ClassMethod ShowSubscribed()
{
    Set node = $Name($$$Subscribed)
    For  {
        Set node = $Query(@node,1,value)
        Quit:node=""
        Write !," * Event: ", $QSubscript(node,1), "  ResourceName: ", $QSubscript(node,2)
        Write !,"   Date time:",$Lg(value,3)
        Write !,"   PID: ", $Lg(value,4)
        Write !,"   Context: ",$Lg(value,5)
    }
    Quit
}

ClassMethod Kill() As %Status [ Internal ]
{
    Kill $$$Subscribed
    Quit $$$OK
}

}
