/************************************************************************************
Created By	: 	Martin Schoombee
Company		:	28twelve consulting
Date		:	7/17/2023
Summary		:	This script will be called by an Azure Data Factory pipeline, and the 
				results used to execute all tasks with the same sequence number in 
				parallel.

				Note that only "active" (ExecuteTask = 1) processes and tasks with be 
                returned in the results.

				Parameters: 
				@Environment		    -	Beta/Production/etc.
				@ProcessName		    -	Name of the process to execute, if you want to 
										    execute an entire process. Use 'All' (default) 
										    to execute all processes, or to process a 
                                            single task. 
				@TaskName			    -	Name of the task to execute, if a single 
										    task should be executed. Use 'All' (or omit) 
										    if an entire process should be executed. 
				@ExecutionSequence	    -	Sequence number of the tasks to execute. Use 
										    -9 (or omit) to return all tasks regardless 
										    of the sequence number.


*************************************************************************************
-- CHANGE CONTROL --
*************************************************************************************
DevOps Reference		:
CO Number				:	
Changed By				:	
Date					:	
Details					:	

*************************************************************************************/
create or alter procedure [ETL].[GetTasksToExecute] 
	@Environment varchar(20) = 'Development'
,	@ProcessName varchar(50) = 'All' 
,	@TaskName varchar(50) = 'All'
,	@ExecutionSequence int = -9
as

if @ProcessName = 'All' and @TaskName = 'All'

	throw 50000, 'Cannot initiate all processes and tasks at the same time', 1;

else
	----------------------------------------------------------------------------------
	-- get all processes and tasks to execute 

	select	distinct -- in case there are duplicates, we don't want to execute a process/task twice
			prc.[ProcessKey] 
		,   prc.[Environment]
		,	prc.[ProcessName]
		,   tsk.[TaskKey]
		,	tsk.[TaskName]
		,	tsk.[TargetSchema]
		,	tsk.[TargetTable]
		,   tsk.[ColumnMapping]
		,	tsk.[DataFactoryPipeline]
		,	((prc.[ProcessExecutionSequence] * 10000) + tsk.[TaskExecutionSequence]) as [ExecutionSequence] 

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
			and	
			( 
				@ExecutionSequence = -9
				or ((prc.[ProcessExecutionSequence] * 10000) + tsk.[TaskExecutionSequence]) = @ExecutionSequence
			)

	order by [ExecutionSequence]
		,	prc.[ProcessName]
		,	tsk.[TaskName]
	;