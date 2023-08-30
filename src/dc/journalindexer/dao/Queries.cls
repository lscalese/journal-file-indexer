Class dc.journalindexer.dao.Queries
{

Query JournalFile() As %SQLQuery(ROWSPEC = "RecordJSON:%String") [ SqlProc ]
{
SELECT JSON_OBJECT('ID': ID, 'FirstRecord': FirstRecord, 'LastRecord': LastRecord, 'Name' : Name, 'UserDefinedName' :UserDefinedName) As RecordJSON
FROM dc_journalindexer_data.File
}

Query GetFirstAddress(
	JournalFile,
	TimeStamp) As %SQLQuery(ROWSPEC = "ID:%Integer,Address:%Integer") [ SqlProc ]
{
SELECT TOP 1 ID, Address INTO :ID,:FirstAddress FROM dc_journalindexer_data.Record WHERE TimeStamp >= :TimeStamp AND FILE = :JournalFile
}

Query GetLastAddress(
	JournalFile,
	TimeStamp) As %SQLQuery(ROWSPEC = "ID:%Integer,Address:%Integer") [ SqlProc ]
{
SELECT TOP 1 ID, Address INTO :ID,:LastAddress FROM dc_journalindexer_data.Record WHERE TimeStamp <= :TimeStamp AND FILE = :JournalFile ORDER BY ID DESC
}

Query SearchRecord(Filter As %DynamicObject) As %Query(CONTAINID = 1, ROWSPEC = "ID:%Integer,File:%String,TypeName:%String,TimeStamp:%TimeStamp,InTransaction:%Boolean,ProcessID:%Integer,DatabaseName:%String,NumberOfValues:%Integer,GlobalNode:%String,Address:%Integer,FormattedOldValue:%String,FormattedNewValue:%String") [ SqlProc ]
{
}

ClassMethod SearchRecordExecute(
	ByRef qHandle As %Binary,
	Filter As %DynamicObject) As %Status
{
    If '$IsObject(Filter) Set Filter = {}.%FromJSON(Filter)

    Set sql($Increment(sql)) = "SELECT ID, File, TypeName, TimeStamp, InTransaction, ProcessID, DatabaseName, NumberOfValues, GlobalNode, Address "
                                _ ", dc_journalindexer_dao.Queries_FormatString(OldValue) As FormattedOldValue, dc_journalindexer_dao.Queries_FormatString(NewValue) As FormattedNewValue "
    Set sql($Increment(sql)) = "FROM dc_journalindexer_data.SetKillRecord "
    Set sql($Increment(sql)) = "WHERE "
    $$$QuitOnError(..SearchQueryBuilder(Filter, .args, .sql))
    
    If $Get(%zDebug,1) {
        s strSql = "", k = "" f  { s k = $o(sql(k),1,item) q:k=""  s strSql = strSql_item }
        s ^dc.journalindexer("last-sql") = strSql
        f  { s k = $o(args(k),1,v) q:k=""  s strSql = $Replace(strSql, "?", $s($isvalidnum(v):v,1:"'"_v_"'"), , 1) }
        s ^dc.journalindexer("last-sql-resolved") = strSql
    }

    Set tResult = ##class(%SQL.Statement).%ExecDirect(.tStatement, .sql, args...)
    If tResult.%SQLCODE '= 0 , tResult.%SQLCODE '= 100 Return $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)
    
    Set qHandle("t") = tResult

    Return $$$OK
}

ClassMethod SearchRecordFetch(
	ByRef qHandle As %Binary,
	ByRef Row As %List,
	ByRef AtEnd As %Boolean) As %Status [ PlaceAfter = SearchRecordExecute ]
{
    #dim tResult As %SQL.StatementResult = qHandle("t")

    Set sc = $$$OK

    If tResult.%GetRow(.Row, .sc) Set AtEnd = $$$NO Return $$$OK
    
    Set Row = "", AtEnd = $$$YES

    If tResult.%SQLCODE < 0 Return $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)

    Return sc
}

ClassMethod SearchRecordClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = SearchRecordExecute ]
{
	Kill qHandle Quit $$$OK
}

ClassMethod SearchQueryBuilder(
	Filter As %DynamicObject,
	Output args As %Binary,
	Output sql As %Binary) As %String
{
    Set startIndice = $Get(sql,0)
    #define ZADDAND $Select($Get(sql,0)>(startIndice+1):" AND ",1:"")
    #define ZCanAddToWhereClause(%key) (Filter.%IsDefined(%key) && (Filter.%Get(%key).Value '= "")) 
    #define ZIsAllowedOperator(%operator) (''$ListFind($ListBuild("between",">",">=","<","<=","["),$$$LOWER(%operator)))
    /*
    Set:$g(Filter)="" Filter = {
        "DatabaseName": {
            "Value": "/iris/blabla/"
        },
        "Subscripts": {
            "Value": "mysub",
            "Position": "2"
        },
        "GlobalName": {
            "Value": ""
        },
        "InTransaction": {
            "Value": "1"
        },
        "File": {
            "Value": "1"
        },
        "MirrorDatabaseName": {
            "Value": "mirrordbname"
        },
        "Type": {
            "Value": "SET"
        },
        "ProcessID": {
            "Value" : 1234
        },
        "Address": {
            "Value": "1",
            "Start": "1",
            "End": "9999999",
            "Operator": "between"
        },
        "TimeStamp": {
            "Value": "2023-08-24 00:00:22",
            "Start": "2023-08-24 00:00:22",
            "End": "",
            "Operator": ""
        },
        "OldValue": {
            "Value": ""
        },
        "NewValue": {
            "Value": ""
        }
    }
    */

    /// display to logical
    For key = "Type" {
        Continue:'$$$ZCanAddToWhereClause(key)
        Set Filter.%Get(key).Value = ##class(%Library.JournalRecordType).DisplayToLogical(Filter.%Get(key).Value)
    }

    /// Where condition for simple property with "equals" operator.
    For key = "InTransaction", "DatabaseName", "File", "MirrorDatabaseName", "Type", "ProcessID" {
        Continue:'$$$ZCanAddToWhereClause(key)

        Set sql($Increment(sql)) = $$$ZADDAND _ key _ " = ?",
            args($Increment(args)) = Filter.%Get(key).Value
    }

    /// Where condition for properties with '*' and '?' allowed
    For key = "GlobalName" {
        Continue:'$$$ZCanAddToWhereClause(key)

        Set condition = "", value = Filter.%Get(key).Value Do ProcessCondition
        Set sql($Increment(sql)) = $$$ZADDAND _ key _ condition, args($Increment(args)) = value
    }

    /// Where condition for List Of String properties (using predicate FOR SOME %ELEMENT ...)
    For key = "Subscripts" {
        Continue:'(Filter.%IsDefined(key) && (Filter.%Get(key).Value '= ""))
        Set tmp = Filter.%Get(key)
        Set condition = "", value = tmp.Value 
        
        Set sql($Increment(sql)) = $$$ZADDAND _ "FOR SOME %ELEMENT("_key_") ("

        If tmp.Operator = "" {
            Do ProcessCondition
            Set args($Increment(args))  = value
        } Else {
            
            If '$$$ZIsAllowedOperator(tmp.Operator) $$$ThrowStatus($$$ERROR(5002,"Operator "_tmp.Operator_" is not allowed."))

            If $$$LOWER(tmp.Operator) = "between" {
                Set condition = " BETWEEN ? AND ? "
                Set args($Increment(args)) = tmp.Start,
                    args($Increment(args)) = tmp.End
            } Else {
                Set args($Increment(args))  = value
            }
        }

        Set sql($Increment(sql)) = "%VALUE" _  condition
        
        Set:Filter.Subscripts.Position'="" sql($Increment(sql)) = "AND %KEY = ?", args($Increment(args)) = Filter.Subscripts.Position
        
        Set sql($Increment(sql)) = ")"
    }

    /// Condition with Range
    For key = "Address", "TimeStamp" {
        Continue:'(Filter.%IsDefined(key) && (Filter.%Get(key).Value '= ""))

        Set tmp = Filter.%Get(key)
        Continue:'$$$ZIsAllowedOperator(tmp.Operator)
        
        If $$$LOWER(tmp.Operator) = "between" {
            Set sql($Increment(sql)) = $$$ZADDAND _ key _ " BETWEEN ? AND ? ",
                args($Increment(args)) = tmp.Start,
                args($Increment(args)) = tmp.End
        } Else {
            Set sql($Increment(sql)) = $$$ZADDAND _ key _ " " _ tmp.Operator _ " ? ",
                args($Increment(args)) = tmp.Value
        }

    }

    /// old value and new value
    For key = "OldValue", "NewValue" {
        Continue:'(Filter.%IsDefined(key) && (Filter.%Get(key).Value '= ""))
        Set position = $Select(+Filter.%Get(key).Position>0:+Filter.%Get(key).Position,1:1)
        Set condition = "", value = Filter.%Get(key).Value Do ProcessCondition
        Set sql($Increment(sql)) = $$$ZADDAND _ $$$FormatText("dc_journalindexer_dao.Queries_GetListPosition(%1,%2)", key, position) _ condition, args($Increment(args)) = value
    }

    Return $$$OK

ProcessCondition
    If $Extract(value, *) = "*", $Length(value, "*") = 2, value '[ "?" {
        Set condition = " %STARTSWITH ? ", value = $Translate(value, "*")
    } ElseIf value '[ "*", value '[ "?" {
        Set condition = " = ? "
    } ElseIf $Extract(value, 1) = "*", $Extract(value, *) = "*", $Extract(value, 2, *-1) = $Translate($Extract(value, 2, *-1), "*?") {
        Set condition = " [ ? ", value = $Translate(value, "*")
    } Else {
        Set condition = " LIKE ? ", value = $Translate(value, "*", "%")
    }

    Quit
}

ClassMethod GetAddressByTS(
	JournalFile As %Integer,
	TimeStamp As %TimeStamp,
	First As %Boolean = {$$$YES},
	Output Id As %Integer,
	Output Sc As %Status) As %Integer
{
    Set tStatement = ##class(%SQL.Statement).%New(), queryName = $Select(First: "GetFirstAddress", 1: "GetLastAddress"), address = -1

    Set Sc = tStatement.%PrepareClassQuery($ClassName(), queryName)
    Return:$$$ISERR(Sc) address

    Set tResult = tStatement.%Execute(JournalFile, TimeStamp)
	If tResult.%SQLCODE '= 0, tResult.%SQLCODE '= 100 Set Sc = $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message) Return address
    
    If tResult.%SQLCODE = 100 Return address

    Do tResult.%Next()

    Set Id = tResult.%Get("ID"), address = tResult.%Get("Address")
    
    Return address
}

ClassMethod GetListPosition(
	Property As %VarString,
	Position As %Integer = 1) As %String [ SqlProc ]
{
    Return:'$ListValid(Property) Property
    Return $ListGet(Property, Position)
}

ClassMethod FormatString(Property As %String) As %String [ SqlProc ]
{
    Return ##class(%Utility).FormatString(Property)
}

}
