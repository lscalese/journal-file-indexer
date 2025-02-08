/// This class contains methods to export\import data<br/>
/// from an indexed journal into a xml file.<br/>
/// 
Class dc.journalindexer.services.Data
{

/// Retore value and export into a xlm file using $SYSTEM.OBJ.Export<br/>
/// Data won't be restored to the original global, but in ^jrnindxer.tmprestore<br/>
/// When the export is done the temp global will be Kill.
/// RestoreValue : newvalue or oldvalue<br/>
/// FileName to export data<br/>
ClassMethod RestoreAndExportToFile(
	Filter As %DynamicObject,
	RestoreValue As %String,
	FileName As %String,
	RedirectTo As %String = {$Name(^jrnindxer.tmprestore)}) As %Status
{
    Set:$Extract(RedirectTo)'="^" RedirectTo = "^" _ RedirectTo
    
    Set sc = $$$OK
    Try {
        Lock +^jrnindxer.tmprestore:10
        If '$Test $$$ThrowStatus($$$ERROR($$$GeneralError,"Fail to acquire a lock on ^jrnindxer.tmprestore"))
        Kill:$Data(^jrnindxer.tmprestore) ^jrnindxer.tmprestore
        Set sc = ..RestoreGlobal(Filter, RestoreValue, RedirectTo, .errors)
        Quit:$$$ISERR(sc)
        Set sc = $SYSTEM.OBJ.Export($Extract(RedirectTo, 2, *) _ ".GBL", FileName)
        Kill @(RedirectTo)
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Lock -^jrnindxer.tmprestore
    Quit sc
}

/// Filter:<br/>
/// {"File": { "Value": 1},"GlobalName":{"Value":"dc.journalindexer.testD"}}<br/>
/// RestoreValue : newvalue or oldvalue<br/>
/// RedirectTo : destination global for restore.<br/>
/// To avoid dramatic mistake, the system does not restore directly the values to the original global.<br/>
/// Value are restored to another global<br/>
/// OverrideIfTargetExists: If false (default) return an error if the global specified in RedirectTo already exists.<br/>
/// err: array contains errors if there is any...<br/>
ClassMethod RestoreGlobal(
	Filter As %DynamicObject = {{}},
	RestoreValue As %String = "newvalue",
	RedirectTo As %String,
	ByRef msg As %Binary,
	OverrideIfTargetExists As %Boolean = {$$$NO},
	ResourceName As %String = "",
	TestOnly As %Boolean = {$$$NO},
	Verbose As %Boolean = {$$$NO}) As %Status
{
    Set:$Extract(RedirectTo)'="^" RedirectTo = "^" _ RedirectTo
    Set sc = $$$OK, RestoreValue = $$$LOWER(RestoreValue), hasResourceName = ResourceName '= ""
    Set (errors,msg) = 0

    Do validate If $$$ISERR(sc) Do:ResourceName'="" $SYSTEM.Event.Signal(ResourceName,$Lb("END",sc)) Quit sc

    Set operationSet = "Set %1 = %2", operationBitSet = "Set $Bit(%1,%2) = %3"

    Set tResult = ##class(dc.journalindexer.dao.Queries).SearchRecordFunc(Filter)
    If tResult.%SQLCODE < 0 Return $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)

    Set IsRestoreNewValue = RestoreValue = "newvalue"

    Set errMsg = $Replace("Cannot restore %1 record(s) because the journal entry has no %2","%2",$s(IsRestoreNewValue:"NewValue",1:"OldValue"))

    While tResult.%Next() {
        
        Set targetNode = tResult.GlobalNode, $Piece(targetNode, "(", 1) = RedirectTo

        If IsRestoreNewValue Do restoreNewValue Continue
        
        Do restoreOldValue
    }

    If errors Set msg($Increment(msg)) = $Replace(errMsg, "%1", errors)
    If 'hasResourceName Return sc

    Set keyMsg = ""
    For  {
        Set keyMsg = $Order(msg(keyMsg), 1, value)
        Quit:keyMsg=""
        Do $SYSTEM.Event.Signal(ResourceName,$Lb("MSG",value))
    }
    Do $SYSTEM.Event.Signal(ResourceName,$Lb("END",sc))

    Return sc

restoreOldValue
    If 'tResult.ExistsOldValue {
        Do $Increment(errors) 
        Write:Verbose&&'hasResourceName !,"! Record ",tResult.Address," has no OldValue." 
        Do:ResourceName'="" $SYSTEM.Event.Signal(ResourceName,$Lb("ERR","Record "_tResult.Address_" has no OldValue.",tResult.Address))
        Quit
    }
    If 'TestOnly {
        If tResult.TypeName = "BitSET" {
            Set $Bit(@targetNode, tResult.Position) = ##class(dc.journalindexer.data.SetKillRecord).OldValueGetStored(tResult.ID) 
        } Else {
            Set @targetNode = ##class(dc.journalindexer.data.SetKillRecord).OldValueGetStored(tResult.ID) 
        }
    }

    Write:Verbose&&'hasResourceName !, $Select(tResult.TypeName="BitSET":$$$FormatText(operationBitSet,targetNode,tResult.Position,tResult.FormattedOldValue),1:$$$FormatText(operationSet,targetNode,tResult.FormattedOldValue))
    Do:ResourceName'="" $SYSTEM.Event.Signal(ResourceName,$Lb("SET",targetNode,tResult.FormattedOldValue))
    Quit

restoreNewValue
    If 'tResult.ExistsNewValue {
        Do $Increment(errors) 
        Write:Verbose&&'hasResourceName !,"! Record ",tResult.Address," has no NewValue." 
        Do:ResourceName'="" $SYSTEM.Event.Signal(ResourceName,$Lb("ERR","Record "_tResult.Address_" has no NewValue.",tResult.Address))
        Quit
    }

    If 'TestOnly {
        If tResult.TypeName = "BitSET" {
            Set $Bit(@targetNode, tResult.Position) = ##class(dc.journalindexer.data.SetKillRecord).NewValueGetStored(tResult.ID) 
        } Else {
            Set @targetNode = ##class(dc.journalindexer.data.SetKillRecord).NewValueGetStored(tResult.ID) 
        }
    }
    
    Write:Verbose&&'hasResourceName !, $Select(tResult.TypeName="BitSET":$$$FormatText(operationBitSet,targetNode,tResult.Position,tResult.FormattedNewValue),1:$$$FormatText(operationSet,targetNode,tResult.FormattedNewValue))
    Do:ResourceName'="" $SYSTEM.Event.Signal(ResourceName,$Lb("SET",targetNode,tResult.FormattedNewValue))
    Quit

validate
    If '$IsObject(Filter) Set Filter = {}.%FromJSON(Filter)
    If $Extract(RedirectTo) '= "^" Set RedirectTo = "^" _ RedirectTo
    If $Data(@RedirectTo), 'OverrideIfTargetExists Set sc = $$$ERROR($$$GeneralError, $$$FormatText("The global %1 already exists.", RedirectTo))
    If 'Filter.%IsDefined("File") Set sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError, "Filter File is manatory."))
    If 'Filter.%IsDefined("GlobalName") Set sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError, "Filter GlobalName is mandatory."))
    If Filter.%IsDefined("File"), Filter.File.Value = "" Set sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError, "Filter File is mandatory."))
    If Filter.%IsDefined("GlobalName"), Filter.GlobalName.Value = "" Set sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError, "Filter GlobalName is mandatory."))
    If Filter.%IsDefined("GlobalName"), Filter.GlobalName.Value '= $TR(Filter.GlobalName.Value,"?*","") Set sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError, "Wildcard are not permitted here for Filter GlobalName."))
    If '##class(dc.journalindexer.data.File).%ExistsId(Filter.File.Value) Set sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError, $$$FormatText("FileId %1 does not exist.", Filter.File.Value)))
    If '$ListFind($Lb("oldvalue","newvalue"), RestoreValue) Set sc = $$$ADDSC(sc, "Bad value for RestoreValue argument.")
    If ResourceName '= "", '$SYSTEM.Event.Defined(ResourceName) Set sc = $$$ADDSC(sc, $$$FormatText("ResourceName %1 does not exist.", ResourceName))
    Quit
}

}
