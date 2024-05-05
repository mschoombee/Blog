----------------------------------------------------------------------------------------------------------------------------
**** Data Factory ARM Templates - Deployment Guide ****
----------------------------------------------------------------------------------------------------------------------------

The ARM templates in this repo can be deployed either via the Azure portal, or by using PowerShell. More information on how 
to do that can be found here: 

https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/quickstart-create-templates-use-the-portal 

https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-powershell 


*** PLEASE NOTE ***
If an object (Linked Service, Dataset or Pipeline) with the same name exists, it may be replaced when you deploy any of these 
templates.


To deploy the Worker pipeline template, you will need to have the following in place: 

1.  A Data Factory.
2.  Integration Runtime(s) that can facilitate connectivity to your data source, target and metadata.
3.  Metadata tables and stored procedures.
4.  A Linked Service for Azure Key Vault, if you are planning to store connections strings there.
        * See section "Linked Service Template - Azure Key Vault.jsonc".
5.  A Linked Service for the metadata database.
        * See section "Linked Service Template - Azure SQL Database.jsonc".
6.  A Linked Service for the target.
        * The only template provided here is for an Azure SQL Database as target.
        * See section "Linked Service Template - Azure SQL Database.jsonc".
7.  A Linked Service for the source.
        * The only template provided here is for an Azure SQL source.
        * See section "Linked Service Template - Source - Azure SQL Database.jsonc".
8.  A generic Dataset for the metadata database, to execute queries and/or stored procedures.
        * See section "Dataset Template - Azure SQL Database.jsonc".
9.  Two Datasets for the target (staging) database.
        * Generic Dataset to execute queries and/or stored procedures (see section "Dataset Template - Azure SQL Database.jsonc").
        * Parameterized Dataset to use as sink (target) in Copy activities (see section "Dataset Template - Azure SQL Table.jsonc").
10. A Dataset for the source.
        * See section "Dataset Template - Source - Azure SQL Database.jsonc" for details.


See section "Pipeline Template - Worker - Copy Data - Azure SQL.jsonc" for the details of the worker pipeline. 


----------------------------------------------------------------------------------------------------------------------------
* Linked Service Template - Azure Key Vault.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a Linked Service for Azure Key Vault, which you will need if you want to store the 
connection strings (or passwords) of other data sources in it. 


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory 
    ** Integration Runtime


Find the following text and replace with your own values before deployment: 

    @[DataFactory]                  -   The name of your Data Factory resource in Azure.

    @[LinkedService]                -   The name of the Linked Service you are attempting to create. If it already exists, it 
                                        may be replaced.

    @[Url]                          -   URL to your Key Vault. It can be found in the overview section of the resource in the 
                                        Azure portal.




----------------------------------------------------------------------------------------------------------------------------
* Linked Service Template - Azure SQL Database.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a Linked Service for an Azure SQL Database. The Linked Service can be used for the target 
and/or metadata databases. 

By default this template will use a connection string stored in Azure Key Vault, and will use the managed identity of the 
Data Factory to authenticate against the data source. A few other options have been provided in the ARM template and have 
been commented out. Replace the relevant section with your choice of authentication method before deployment, or skip this 
step and create the Linked Service manually. 


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory 
    ** Integration Runtime
    ** Azure Key Vault Linked Service (if you use the default authentication option)
    

Find the following text and replace with your own values before deployment: 

    @[DataFactory]                  -   The name of your Data Factory resource in Azure.

    @[LinkedService]                -   The name of the Linked Service you are attempting to create. If it already exists, it 
                                        may be replaced.

    @[IntegrationRuntime]           -   Name of the Integration Runtime (IR) that will be used by the Linked Service.

    @[KeyVault]                     -   The name of the Linked Service in ADF that points to your Azure Key Vault, where connection 
                                        details are stored. 

    @[KeyVaultSecret]               -   Name of the secret in Azure Key Vault that contains the connection string (or password, 
                                        if that authentication option is used).

    @[ActiveDirectoryTenantId]      -   Unique identifier (GUID) of the Active Directory (or Entra) tenant, if the Service Principal 
                                        option is used for authentication.

    @[ServicePrincipalId]           -   Unique identifier (GUID) of the Service Principal, if that option is used for 
                                        authentication. 

    @[ServicePrincipalSecret]       -   Name of the Azure Key Vault secret that contains the Service Principal key, if that 
                                        option is used for authentication.

    @[ConnectionString]             -   Connection string to the data source, if that option is used. 




----------------------------------------------------------------------------------------------------------------------------
* Linked Service Template - Source - Azure SQL Database.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a Linked Service for an Azure SQL Database and can be deployed if you are planning to use 
Azure SQL as a source. What makes it different from the other Azure SQL Linked Service is that the connection string is 
parameterized and assumed to be stored in a Key Vault secret. 

In order for this framework to function, you will need Linked Services for all sources and destinations.


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory
    ** Integration Runtime
    ** Azure Key Vault Linked Service (if you use the default authentication option)
    

Find the following text and replace with your own values before deployment:

    @[DataFactory]                  -   The name of your Data Factory resource in Azure.

    @[LinkedService]                -   The name of the Linked Service you are attempting to create. If it already exists, it 
                                        may be replaced.

    @[IntegrationRuntime]           -   Name of the Integration Runtime (IR) that will be used by the Linked Service.

    @[KeyVault]                     -   The name of the Linked Service in ADF that points to your Key Vault, where connection 
                                        details are stored. 

    @[ActiveDirectoryTenantId]      -   Unique identifier (GUID) of the Active Directory (or Entra) tenant, if the Service Principal 
                                        option is used for authentication.

    @[ServicePrincipalId]           -   Unique identifier (GUID) of the Service Principal, if that option is used for 
                                        authentication. 

    @[ServicePrincipalSecret]       -   Name of the Azure Key Vault secret that contains the Service Principal key, if that 
                                        option is used for authentication.

    @[ConnectionString]             -   Connection string to the data source, if that option is used.




----------------------------------------------------------------------------------------------------------------------------
* Dataset Template - Azure SQL Database.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a generic Dataset associated with an Azure SQL Database, that can be used to execute stored 
procedures or queries. If you have separate Azure SQL Linked Services for both your metadata and target databases in Azure 
SQL, then you will need to deploy a Dataset for each. 


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory 
    ** Integration Runtime
    ** Linked Service


Find the following text and replace with your own values before deployment:

    @[DataFactory]                  -   The name of your Data Factory resource in Azure.

    @[Dataset]                      -   The name of the Dataset you are attempting to create. If it already exists, it 
                                        may be replaced.

    @[Folder]                       -   The folder in which you want this Dataset to be placed. The folder will be created 
                                        if it doesn't exist.

    @[LinkedService]                -   The name of the Linked Service this Dataset should be associated with.




----------------------------------------------------------------------------------------------------------------------------
* Dataset Template - Azure SQL Table.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a Dataset associated with an Azure SQL table you want to use as a target. It contains parameters 
for the schema and table, and typically used as sink (target) in Copy activities.


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory 
    ** Integration Runtime
    ** Linked Service


Before deploying the template, you will need to find the following text and replace with your own values: 

    @[DataFactory]                  -   The name of your Data Factory resource in Azure.

    @[Dataset]                      -   The name of the Dataset you are attempting to create. If it already exists, it 
                                        may be replaced.

    @[Folder]                       -   The folder in which you want this Dataset to be placed. The folder will be created 
                                        if it doesn't exist.

    @[LinkedService]                -   The name of the Linked Service this Dataset should be associated with.




----------------------------------------------------------------------------------------------------------------------------
* Dataset Template - Source - Azure SQL Database.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a Dataset associated with an Azure SQL Database, and can be deployed if you are planning to use 
Azure SQL as a source. What makes it different from the other Azure SQL Database Dataset is that it accounts for the fact that 
the connection string of the associated Linked Service will be parameterized (and assumed to be stored in a Key Vault secret).


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory 
    ** Integration Runtime
    ** Linked Service


Before deploying the template, you will need to find the following text and replace with your own values: 

    @[DataFactory]                  -   The name of your Data Factory resource in Azure.

    @[Dataset]                      -   The name of the Dataset you are attempting to create. If it already exists, it 
                                        may be replaced.

    @[Folder]                       -   The folder in which you want this Dataset to be placed. The folder will be created 
                                        if it doesn't exist.

    @[LinkedService]                -   The name of the Linked Service this Dataset should be associated with.




----------------------------------------------------------------------------------------------------------------------------
* Pipeline Template - Worker - Copy Data - Azure SQL.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a worker pipeline that extracts data from an Azure SQL database as source, and populate a 
staging table also hosted in Azure SQL.

The naming convention for the pipeline will by default be "Copy Data - <Source System>", and a folder named "Workers" will 
be created if it doesn't exist. 


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory
    ** Linked Services for all sources (including the metadata database) and targets
    ** Datasets for all sources (including the metadata database) and targets
    

Before deploying the template, you will need to find the following text and replace with your own values:

    @[DataFactory]                  -   The name of your Data Factory resource in Azure. 

    @[SourceSystem]                 -   Name of the source system, which will be used in the name of the deployed pipeline. 

    @[SourceDataset]                -   Name of the Dataset created for the source system.

    @[AdminDataset]                 -   The name of the Dataset that points to the database where the metadata is stored. This 
                                        Dataset will be used to execute stored procedures to extract the required metadata.

    @[StagingLinkedService]         -   The name of the Linked Service associated with the staging database (or target).

    @[StagingTableDataset]          -   Name of the Dataset created for staging tables. This Dataset should have parameters for 
                                        the schema & table, and will be used as the Copy activity's sink.


