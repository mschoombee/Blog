/************************************************************************************
Created By	: 	Martin Schoombee 
Company		:	28twelve consulting
Date		:	4/13/2024
Summary		:	This script will be called by an Azure Data Factory pipeline, and 
				returns a unique list of execution sequences that will be used to 
				facilitate parallel or serial execution of ETL tasks. 

				Note that only execution sequences of "active" processes and tasks 
				will be returned.

				Parameters: 
				@Environment	-	Development/Production/etc.
				@ProcessName	-	Name of the process to execute, if you want to 
									execute an entire process. Use 'All' (or omit) to 
									execute all processes or process a single task. 
				@TaskName		-	Name of the task to execute, if a single task 
									should be executed. Use 'All' (or omit) if an 
									entire process should be executed.


*************************************************************************************
-- CHANGE CONTROL --
*************************************************************************************
DevOps Reference		:
CO Number				:	
Changed By				:	
Date					:	
Details					:	

*************************************************************************************/
create or alter procedure [ETL].[GetExecutionSequences] 
	@Environment varchar(20) = 'Development'
,	@ProcessName varchar(50) = 'All' 
,	@TaskName varchar(50) = 'All'
as

----------------------------------------------------------------------------------------------------
-- get unique list of execution sequences to execute 

select	distinct
		convert
		(
			int 
		,	(prc.[ProcessExecutionSequence] * 10000) + tsk.[TaskExecutionSequence]
		) as [ExecutionSequence] 

from	[ETL].[Process] prc 
inner join [ETL].[Task] tsk on tsk.[ProcessKey] = prc.[ProcessKey]

where	prc.[Environment] = @Environment
		and prc.[ExecuteProcess] = convert(bit, 1) 
		and tsk.[ExecuteTask] = convert(bit, 1)
		and 
		(
			@ProcessName = 'All'
			or prc.[ProcessName] = @ProcessName
		)
		and 
		( 
			@TaskName = 'All'
			or tsk.[TaskName] = @TaskName
		)

order by [ExecutionSequence]
;