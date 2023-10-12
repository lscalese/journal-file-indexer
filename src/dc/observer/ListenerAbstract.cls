Class dc.observer.ListenerAbstract Extends %RegisteredObject [ Abstract ]
{

Parameter EVENTTYPE;

Parameter WAITTIMEOUT = 10;

Parameter VERBOSE = 0;

Property ResourceName As %String [ Internal ];

Property Verbose As %Boolean [ InitialExpression = {$Get(%zverbose,..#VERBOSE)}, Internal ];

Property EventType As %String [ InitialExpression = {..#EVENTTYPE} ];

Method OnStartListen(Context As %DynamicObject = {{}}) As %Status
{
    Set ..ResourceName = ..GenResourceName()
    Do $SYSTEM.Event.Create(..ResourceName), ##class(dc.observer.Manager).Subscribe(##this, Context)
    Write:..Verbose !, $zdt($h,3,1), " + Listening ", ..EventType, " with resourcename ", ..ResourceName, " started."
    Quit $$$OK
}

Method Listen() As %Status [ Abstract ]
{
    /// Do ..OnStartListen()
    /// ...
    /// Set result = $SYSTEM.Event.WaitMsg(..ResourceName, TimeOut), returnCode = $ListGet(result,1)
    /// ...
    /// Do OnStopListen()
    Quit $$$OK
}

Method Wait(TimeOut As %Integer = {..#WAITTIMEOUT}) As %Integer
{
    Set result = $SYSTEM.Event.WaitMsg(..ResourceName, TimeOut), returnCode = $ListGet(result,1)

    If returnCode = 0 || (returnCode = -1) Quit returnCode
    
    Set Event = {}.%FromJSON($ListGet(result,2))
    Set Data = Event.Data, Context = Event.Context
    Do Event.%Remove("Data"), Event.%Remove("Context")
    Do ..Update(Event, Data, Context)

    Quit returnCode
}

Method Update(
	EventObject As %DynamicObject,
	Data As %DynamicObject,
	Context As %DynamicObject) As %Status
{
    Quit $$$OK
}

Method WaitEvent(
	Output Event As %DynamicObject,
	TimeOut As %Integer = {..#WAITTIMEOUT}) As %Integer
{
    Set result = $SYSTEM.Event.WaitMsg(..ResourceName, TimeOut), returnCode = $ListGet(result,1), Event = ""

    If returnCode = 0 || (returnCode = -1) Quit returnCode
    
    Set Event = {}.%FromJSON($ListGet(result,2))
    
    Quit returnCode
}

Method OnStopListen(Context As %DynamicObject = {{}}) As %Status
{
    Write:..Verbose !, $zdt($h,3,1), " - Listening ", ..EventType, " with resourcename ", ..ResourceName, " has been STOPPED."
    Quit ##class(dc.observer.Manager).UnSubscribe(##this, Context)
}

Method GenResourceName() As %String [ CodeMode = expression, Private ]
{
$Translate($SYSTEM.Encryption.Base64Encode($Job_$zcrc(..EventType_$ZDT($H,3,1),7)),"=")
}

}
