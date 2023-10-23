Class dc.journalindexer.dao.Queries
{

Query JournalFile() As %SQLQuery(ROWSPEC = "ID:%Integer,RecordJSON:%String") [ SqlProc ]
{
SELECT ID, JSON_OBJECT('ID': ID, 'FirstRecord': FirstRecord, 'LastRecord': LastRecord, 'Name' : Name, 'UserDefinedName' :UserDefinedName) As RecordJSON
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

Query StatsBy(
	FileId As %Integer,
	StatsOn As %String) As %SQLQuery(ROWSPEC = "ID:%Integer,FileId:%Integer,StatsOn:%String,Key:%String,Hit:%Integer,Size:%Integer,TypeJSON:%String") [ SqlProc ]
{
SELECT ID, FileId, StatsOn, Key, Hit, Size, TypeJSON
FROM dc_journalindexer_data.Stats
WHERE FileId = :FileId
AND StatsOn = :StatsOn
ORDER BY Size DESC
}

Query Distinct(
	Field As %String,
	FileId As %Integer,
	DatabaseName As %String = "",
	GlobalName As %String = "") As %Query(ROWSPEC = "DistinctField:%String") [ SqlProc ]
{
}

ClassMethod DistinctExecute(
	ByRef qHandle As %Binary,
	Field As %String,
	FileId As %Integer,
	DatabaseName As %String = "",
	GlobalName As %String = "") As %Status
{
    #Define zgbldistinct ^IRIS.Temp.data.Distinct

    Set lowerField = $$$LOWER(Field)
    Set FieldPosition = $Case(lowerField,"databasename":2,"globalname":3,"processid":4,:-1)
    
    If FieldPosition = -1 Quit $$$ERROR($$$GeneralError,"Not supported field (only DatabaseName, GlobalName or ProcessID)")

    Set qHandle("Key") = ""

    If lowerField = "databasename", GlobalName = "" {
        Set k2 = ""
        For  {
            Set k2 = $Order($$$zgbldistinct(FileId,k2))
            Quit:k2=""
            Set qHandle("Distinct", k2) = ""
        }
        Quit $$$OK
    }

    if lowerField = "globalname", DatabaseName '= "" {
        Set k2 = DatabaseName, k3 = ""
        For  {
            Set k3 = $Order($$$zgbldistinct(FileId,k2,k3))
            Quit:k3=""
            Set qHandle("Distinct", k3) = ""
        }
        Quit $$$OK
    }

    Set node = $Name(@$Name($$$zgbldistinct)@(FileId))

    If DatabaseName '= "" Set node = $Name(@node@(DatabaseName))

    If DatabaseName '= "", GlobalName '= "" Set node = $Name(@node@(GlobalName))

    For  {
        Set node = $Query(@node)
        Quit:node=""
        Quit:$QSubscript(node,1)'=FileId

        If DatabaseName '= "", $QSubscript(node,2) '= DatabaseName Quit
        If DatabaseName '= "", GlobalName '= "", $QSubscript(node,3) '= GlobalName Quit
        If GlobalName '= "", $QSubscript(node,3) '= GlobalName Continue

        Set qHandle("Distinct", $QSubscript(node,FieldPosition)) = ""
    }

    Quit $$$OK
}

ClassMethod DistinctFetch(
	ByRef qHandle As %Binary,
	ByRef Row As %List,
	ByRef AtEnd As %Boolean) As %Status [ PlaceAfter = DistinctExecute ]
{
    Set sc = $$$OK

    Set qHandle("Key") = $Order(qHandle("Distinct",qHandle("Key")))

    If qHandle("Key") '= "" Set AtEnd = $$$NO, Row = $Lb(qHandle("Key")) Quit $$$OK

    Set Row = "", AtEnd = $$$YES

    Quit sc
}

ClassMethod DistinctClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = DistinctExecute ]
{
	Kill qHandle Quit $$$OK
}

Query SearchRecord(
	Filter As %DynamicObject,
	PaginateMode As %Boolean = {$$$NO},
	ResultPerPage As %Integer = 250,
	StartId As %Integer = 0,
	Direction As %Integer = 1,
	KeepOrdered As %Boolean = {$$$YES}) As %Query(CONTAINID = 1, ROWSPEC = "ID:%Integer,File:%String,TypeName:%String,TimeStamp:%TimeStamp,InTransaction:%Boolean,ProcessID:%Integer,DatabaseName:%String,NumberOfValues:%Integer,GlobalNode:%String,Address:%Integer,FormattedOldValue:%String,FormattedNewValue:%String,ExistsOldValue:%Boolean,ExistsNewValue:%Boolean,Position:%Integer") [ SqlProc ]
{
}

ClassMethod SearchRecordExecute(
	ByRef qHandle As %Binary,
	pFilter As %DynamicObject,
	PaginateMode As %Boolean = {$$$NO},
	ResultPerPage As %Integer = 250,
	StartId As %Integer = 0,
	Direction As %Integer = 1,
	KeepOrdered As %Boolean = {$$$YES}) As %Status
{
    If '$IsObject(pFilter) {
        Set Filter = {}.%FromJSON(pFilter)
    } Else {
        ; copy the filter to avoid a change in the original object reference
        Set Filter = {}.%FromJSON(pFilter.%ToJSON())
    }

    If PaginateMode, +StartId Set Filter.ID = {"Value":(StartId), "Operator":($Select(Direction=1:">",1:"<"))}

    Set:Direction=-1&&PaginateMode&&KeepOrdered sql($Increment(sql)) = "SELECT * FROM ("
    Set sql($Increment(sql)) = "SELECT"
    Set:PaginateMode sql($Increment(sql)) = " TOP "_ ResultPerPage
    Set sql($Increment(sql)) = " ID, File, TypeName, TimeStamp, InTransaction, ProcessID, DatabaseName, NumberOfValues, GlobalNode, Address "
    Set sql($Increment(sql)) = ", FormattedOldValue, FormattedNewValue, ExistsOldValue, ExistsNewValue, Position "
    Set sql($Increment(sql)) = "FROM dc_journalindexer_data.SetKillRecord "
    Set sql($Increment(sql)) = "WHERE "
    $$$QuitOnError(..SearchQueryBuilder(Filter, .args, .sql))
    
    ; Trick to retrieve previous record correctly ordered
    Set:Direction=-1&&PaginateMode sql($Increment(sql)) = " ORDER BY ID DESC) "_$s(KeepOrdered:"ORDER BY ID ASC",1:"")  

    If $Get(%zDebug,1) {
        Set strSql = "", k = "" For  s k = $o(sql(k),1,item) Quit:k=""  Set strSql = strSql_item
        Set ^dc.journalindexer("last-sql") = strSql
        For  Set k = $Order(args(k),1,v) Quit:k=""  Set strSql = $Replace(strSql, "?", $Select($isvalidnum(v):v,1:"'"_v_"'"), , 1)
        Set ^dc.journalindexer("last-sql-resolved") = strSql
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
    #define ZIsAllowedOperator(%operator) (''$ListFind($ListBuild("between",">",">=","<","<=","[","="),$$$LOWER(%operator)))
    
    Set iter = Filter.%GetIterator()
    While iter.%GetNext(.k, .v, .t) {
        If $Isobject(v), v.%IsDefined("Start") Set v.Value = v.Start
    }

    /// display to logical
    For key = "Type" {
        Continue:'$$$ZCanAddToWhereClause(key)
        Set Filter.%Get(key).Value = ##class(%Library.JournalRecordType).DisplayToLogical(Filter.%Get(key).Value)
    }

    /// Where condition for simple property with "equals" operator.
    For key = "InTransaction", "File", "MirrorDatabaseName", "Type", "ProcessID" {
        Continue:'$$$ZCanAddToWhereClause(key)

        Set sql($Increment(sql)) = $$$ZADDAND _ key _ " = ?",
            args($Increment(args)) = Filter.%Get(key).Value
    }

    For key =  "DatabaseName" {
        Continue:'$$$ZCanAddToWhereClause(key)

        Set sql($Increment(sql)) = $$$ZADDAND _ "Database" _ " = ?",
            args($Increment(args)) = ##class(dc.journalindexer.data.DB).GetId(Filter.%Get(key).Value,$$$YES)
    }

    

    /// Where condition for properties with '*' and '?' allowed
    For key = "GlobalName" {
        Continue:'$$$ZCanAddToWhereClause(key)

        Set condition = "", value = Filter.%Get(key).Value Do ProcessCondition
        Set sql($Increment(sql)) = $$$ZADDAND _ key _ condition, args($Increment(args)) = value
    }

    /// Where condition for List Of String properties (using predicate FOR SOME %ELEMENT ...)
    For key = "Subscripts" {
        Continue:'Filter.%IsDefined(key)

        If Filter.%Get(key).%IsA("%DynamicArray") {
            Set tmpArray = Filter.%Get(key)
        } Else {
            Set tmpArray = [].%Push(Filter.%Get(key))
        }
        Continue:tmpArray.%Size()=0

        #dim tmpArray As %DynamicArray
        #dim iter As %Iterator.Array = tmpArray.%GetIterator()
        
        set hasWhereSubscripts = $$$NO

        While iter.%GetNext(.iterKey,.tmp) {
            
            Set condition = "", value = tmp.Value, tmp.Operator = $$$LOWER(tmp.Operator)
            
            If value = "", tmp.Start '= "" {
                Set value = tmp.Start
            }

            Continue:value=""

            Set:'hasWhereSubscripts sql($Increment(sql)) = $$$ZADDAND _"("
            Set:'hasWhereSubscripts hasWhereSubscripts = $$$YES
        
            Set tmp.Logical = $Case($$$UPPER(tmp.Logical), "AND":"AND", "OR":"OR", :"") ; injection protect

            Set sql($Increment(sql)) = tmp.Logical _ " FOR SOME %ELEMENT("_key_") ("

            If tmp.Operator = "" {
                Do ProcessCondition
                Set args($Increment(args))  = value
            } Else {
                
                If '$$$ZIsAllowedOperator(tmp.Operator) $$$ThrowStatus($$$ERROR(5002,"Operator "_tmp.Operator_" is not allowed."))

                If tmp.Operator = "between" {
                    Set condition = " BETWEEN ? AND ? "
                    Set args($Increment(args)) = tmp.Start,
                        args($Increment(args)) = tmp.End,
                        value = tmp.Start
                    
                } Else {
                    Set condition = " "_tmp.Operator _ " ? "
                    Set args($Increment(args)) = value
                }
            }

            If $IsValidNum(value) {
                Set sql($Increment(sql)) = "CAST(%VALUE AS NUMERIC)" _  condition
            } Else {
                Set sql($Increment(sql)) = "%VALUE" _  condition
            }
            
            Set:tmp.Position'="" sql($Increment(sql)) = "AND %KEY = ?", args($Increment(args)) = tmp.Position
            
            Set sql($Increment(sql)) = ")"
        }
        Set:hasWhereSubscripts sql($Increment(sql)) = ")"
    }

    /// Condition with Range
    For key = "Address", "TimeStamp", "SubscriptsSize", "ID" {
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
