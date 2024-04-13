-- etl.process
CREATE TABLE [ETL].[Process](
	[ProcessKey] [int] IDENTITY(1,1) NOT NULL,
	[Environment] [varchar](20) NOT NULL,
	[ProcessName] [varchar](50) NOT NULL,
	[ProcessDescription] [varchar](200) NOT NULL DEFAULT ('Unknown'),
	[ProcessExecutionSequence] [smallint] NOT NULL DEFAULT (CONVERT([smallint],(1))),
	[ExecuteProcess] [bit] NOT NULL DEFAULT (CONVERT([bit],(0))),
	[InsertDate] [datetime] NOT NULL DEFAULT (getdate()),
	[UpdateDate] [datetime] NULL, 
    CONSTRAINT [PK_Process] PRIMARY KEY CLUSTERED ([ProcessKey])
) ON [PRIMARY]


-- etl.task
CREATE TABLE [ETL].[Task](
	[TaskKey] [int] IDENTITY(1,1) NOT NULL,
	[ProcessKey] [int] NOT NULL,
	[TaskName] [varchar](50) NOT NULL,
	[TaskDescription] [varchar](200) NOT NULL DEFAULT ('Unknown'),
    [TargetSchema] [varchar](50) NOT NULL DEFAULT ('Unknown'),
    [TargetTable] [varchar](50) NOT NULL DEFAULT ('Unknown'),
    [ColumnMapping] [varchar](MAX) NOT NULL DEFAULT ('{}'),
    [DataFactoryPipeline] [varchar](200) NOT NULL DEFAULT ('Unknown'),
	[TaskExecutionSequence] [smallint] NOT NULL DEFAULT (CONVERT([smallint],(1))),
	[ExecuteTask] [bit] NOT NULL DEFAULT (CONVERT([bit],(0))),
	[InsertDate] [datetime] NOT NULL DEFAULT (getdate()),
	[UpdateDate] [datetime] NULL, 
    CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED ([TaskKey]), 
    CONSTRAINT [FK_Task_Process] FOREIGN KEY ([ProcessKey]) REFERENCES [ETL].[Process]([ProcessKey])
) ON [PRIMARY] 


-- etl.taskquery
CREATE TABLE [ETL].[TaskQuery](
	[TaskQueryKey] [int] IDENTITY(1,1) NOT NULL,
	[TaskKey] [int] NOT NULL,
    [SourceKeyVaultSecret] [varchar](200) NOT NULL DEFAULT ('Unknown'),
    [SourceQuery] [varchar](MAX) NOT NULL DEFAULT ('Unknown'),
	[ExecuteQuery] [bit] NOT NULL DEFAULT (CONVERT([bit],(0))),
	[InsertDate] [datetime] NOT NULL DEFAULT (getdate()),
	[UpdateDate] [datetime] NULL, 
    CONSTRAINT [PK_TaskQuery] PRIMARY KEY CLUSTERED ([TaskQueryKey]), 
    CONSTRAINT [FK_TaskQuery_Task] FOREIGN KEY ([TaskKey]) REFERENCES [ETL].[Task]([TaskKey])
) ON [PRIMARY] 


-- etl.parameter table
CREATE TABLE [ETL].[Parameter](
	[ParameterKey] [int] IDENTITY(1,1) NOT NULL,
	[ParameterName] [varchar](50) NOT NULL,
	[ParameterDescription] [varchar](500) NOT NULL DEFAULT ('Unknown'),
	[ParameterValue] [varchar](200) NOT NULL,
	[InsertDate] [datetime] NOT NULL DEFAULT (getdate()),
	[UpdateDate] [datetime] NULL, 
    CONSTRAINT [PK_Parameter] PRIMARY KEY CLUSTERED ([ParameterKey])
) ON [PRIMARY]