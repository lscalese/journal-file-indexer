/// Basic Listener for demo purpose<br/>
/// Open a terminal: <br/>
/// Set listener = ##class(dc.observer.BasicListener).%New()<br/>
/// Do listener.Listen()<br/>
/// or in one line : Do ##class(dc.observer.BasicListener).%New().Listen()<br/>
/// Type ctrl+c to stop.<br/>
/// Open anoter terminal:<br/>
/// Do ##class(dc.observer.Manager).Notify("Demo:OnTestString","This is string notification")<br/>
/// Do ##class(dc.observer.Manager).Notify("Demo","This is a demo notification")<br/>
/// Do ##class(dc.observer.Manager).Notify("Demo:OnTestObject",{"object":"demo"})<br/>
Class dc.observer.BasicListener Extends dc.observer.ListenerAbstract
{

Parameter EVENTTYPE = "Demo";

Parameter VERBOSE = 1;

Method Listen() As %Status
{
    Set sc = $$$OK
    $$$QuitOnError(..OnStartListen())
    Try {
        Write:..Verbose !,$zdt($h,3,1)," + Type < ctrl+c > to stop listening."
        For  If ..Wait() = -1 $$$ThrowStatus($$$ERROR($$$GeneralError,$$$FormatText("Resource %1 deleted.",..ResourceName)))
    } Catch Ex {
        If Ex.Name '[ "<INTERRUPT>" Set sc = Ex.AsStatus()
        If ..Verbose, $$$ISERR(sc) Do $SYSTEM.Status.DisplayError(sc)
        Do ..OnStopListen()
    }
    Quit sc
}

Method Update(
	Event As %DynamicObject,
	Data As %DynamicObject,
	Context As %DynamicObject) As %Status
{
    Set dt = $ZDateTime($Horolog, 3, 1)
    Write:..Verbose !,dt," + Update received!"
    Write !,dt, " = Event : ", !
    Do ##class(%JSON.Formatter).%New().Format(Event)
    Write !,dt, " = Conext : ", !
    Do ##class(%JSON.Formatter).%New().Format(Context)
    Write !,dt, " = Data : ", !
    Do ##class(%JSON.Formatter).%New().Format(Data)
    Quit $$$OK
}

ClassMethod Test() As %Status
{
    Quit ..%New().Listen()
}

}
