Class dc.journalindexer.services.Utils Extends %RegisteredObject
{

ClassMethod ProcessAction(
	PID As %Integer,
	Action As %String) As %Status
{
    New $Namespace Set $Namespace = "%SYS"
    Set sc = $$$OK

    Set process = ##class(SYS.Process).%OpenId(PID,,.sc)
    If $$$ISERR(sc) Write ! Do $SYSTEM.Status.DisplayError(sc) Quit sc

    If Action = "suspend" {
        Set sc = process.Suspend()
        Write !, $Select($$$ISOK(sc): "Process suspended.", 1: $SYSTEM.Status.GetOneErrorText(sc))
    } ElseIf Action = "resume" {
        Set sc = process.Resume()
        Write !, $Select($$$ISOK(sc): "Process resumed.", 1: $SYSTEM.Status.GetOneErrorText(sc))
    } ElseIf Action = "terminate" {
        Set sc = process.Terminate()
        Write !, $Select($$$ISOK(sc): "Process terminated.", 1: $SYSTEM.Status.GetOneErrorText(sc))
    }
    Quit sc
}

}
