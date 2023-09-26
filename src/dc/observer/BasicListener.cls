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
        For  {
            Set code = ..Wait(.EventObject)
            If 'code Continue
            If code = -1 $$$ThrowStatus($$$ERROR($$$GeneralError,$$$FormatText("Resource %1 deleted.",..ResourceName)))
            Set sc = ..OnNotify(EventObject)
            If $$$ISERR(sc) $$$ThrowStatus(sc)
        }
    } Catch Ex {
        If Ex.Name '[ "<INTERRUPT>" Set sc = Ex.AsStatus()
        If ..Verbose, $$$ISERR(sc) Do $SYSTEM.Status.DisplayError(sc)
        Do ..OnStopListen()
    }
    Quit sc
}

Method OnNotify(Event As %DynamicObject) As %Status
{
    Do ##class(%JSON.Formatter).%New().FormatToString(Event.%ToJSON(), .out) 
    Write !,$ZDateTime($Horolog, 3, 1), " = Event received: ", !, out
    Quit $$$OK
}

ClassMethod Test() As %Status
{
    Quit ..%New().Listen()
}

}
