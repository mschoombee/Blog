/************************************************************************************
Created By	: 	Martin Schoombee 
Company		:	28twelve consulting
Date		:	4/13/2024
Summary		:	This procedure returns all the queries of a task. 

				Placeholders for dynamic values are denoted by @[...] and logic has to 
                be added for each parameter that needs to be replaced.


*************************************************************************************
-- CHANGE CONTROL --
*************************************************************************************
DevOps Reference		:	
Changed By				:								
Date					:	
Details					:	

*************************************************************************************/
create or alter procedure [ETL].[GetTaskQueries]
    @TaskKey int = -9
,	@TaskName varchar(50) = 'Unknown'
as

----------------------------------------------------------------------------------------------------
-- get the task key if the name was given as parameter
if @TaskKey = -9
begin
	set @TaskKey = (select [TaskKey] from [ETL].[Task] where [TaskName] = @TaskName)
end


----------------------------------------------------------------------------------------------------
-- return all task queries
select	qry.[TaskQueryKey]
	,	qry.[SourceKeyVaultSecret]
	-- example of dynamic value injection
	,	replace
        (
            qry.[SourceQuery]
        ,	'@[LoadStartDate]'
        ,	convert(varchar(200), isnull(LoadStartDate.[QueryText], ''))
        ) as SourceQuery
	,	tsk.[TargetSchema]
	,	tsk.[TargetTable]
    ,   tsk.[ColumnMapping]
	
from	[ETL].[Task] tsk
inner join [ETL].[TaskQuery] qry on qry.[TaskKey] = tsk.[TaskKey]
-- return parameter values to inject in dynamically into source query
outer apply (
				select	top 1 
						'dateadd(day, -' + prm.[ParameterValue] + ', convert(date, getdate()))' as [QueryText]
					
				from	[ETL].[Parameter] prm 

				where	prm.[ParameterName] = 'DaysToLoad'
			) LoadStartDate 

where	qry.[TaskKey] = @TaskKey 
        and qry.[ExecuteQuery] = convert(bit, 1)

order by qry.[TaskQueryKey]
;