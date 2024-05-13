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


To deploy the Orchestrator pipeline templates, you will need to have the following in place: 

1.  A Data Factory.
2.  Integration Runtime(s) that can facilitate connectivity to your data source, target and metadata.
3.  Metadata tables and stored procedures.
4.  A Linked Service for Azure Key Vault, if you are planning to store connections strings there.
        * See section "Linked Service Template - Azure Key Vault.jsonc".
5.  A Linked Service for the metadata database.
        * See section "Linked Service Template - Azure SQL Database.jsonc".
6.  A generic Dataset for the metadata database, to execute queries and/or stored procedures.
        * See section "Dataset Template - Azure SQL Database.jsonc".
7.  Appropriate permissions to use the Data Factory API.
        The Data Factory's managed identity needs the "Data Factory Contributor" role in the Data Factory resource in Azure.


Because of dependencies the orchestrator pipelines have to be deployed in the order in which they appear in this document. 
Linked Services & Datasets can be skipped if already deployed.


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
* Pipeline Template - Orchestrator - Execute Task.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a orchestration pipeline that initiates a worker pipeline (via the API), and monitor the 
execution until there is a result.

The naming convention for the pipeline will by default be "Orchestrator - Execute Task", and a folder named "Orchestrators" will 
be created if it doesn't exist. 


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory
    ** Linked Service for the metadata database
    ** Generic Dataset for the metadata database, to execute queries or stored procedures
    ** Metadata tables and stored procedures
    

Before deploying the template, you will need to find the following text and replace with your own values:

    @[DataFactory]                  -   The name of your Data Factory resource in Azure. 




----------------------------------------------------------------------------------------------------------------------------
* Pipeline Template - Orchestrator - Get Tasks to Execute.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a orchestration pipeline that gets all tasks with a certain sequence order, which will ultimately 
be executed in parallel.

The naming convention for the pipeline will by default be "Orchestrator - Get Tasks to Execute", and a folder named "Orchestrators" will 
be created if it doesn't exist. 


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory
    ** Linked Service for the metadata database
    ** Generic Dataset for the metadata database, to execute queries or stored procedures
    ** Metadata tables and stored procedures
    ** "Orchestrator - Execute Task" pipeline
    

Before deploying the template, you will need to find the following text and replace with your own values:

    @[DataFactory]                  -   The name of your Data Factory resource in Azure. 

    @[Dataset]                      -   The name of the Dataset that points to the database where the metadata is stored. This 
                                        Dataset will be used to execute stored procedures to extract the required metadata. 




----------------------------------------------------------------------------------------------------------------------------
* Pipeline Template - Orchestrator - Main.jsonc *
----------------------------------------------------------------------------------------------------------------------------

This ARM template will deploy a orchestration pipeline that will be the main entry point for all executions.

The naming convention for the pipeline will by default be "Orchestrator - Main", and a folder named "Orchestrators" will 
be created if it doesn't exist. 


The following resources have to exist before you attempt to deploy the template: 

    ** Data Factory
    ** Linked Service for the metadata database
    ** Generic Dataset for the metadata database, to execute queries or stored procedures
    ** Metadata tables and stored procedures
    ** "Orchestrator - Get Tasks to Execute" pipeline
    

Before deploying the template, you will need to find the following text and replace with your own values:

    @[DataFactory]                  -   The name of your Data Factory resource in Azure. 

    @[SubscriptionId]               -   Unique ID (GUID) of the Azure subscription in which our Data Factory resource 
                                        was created.

    @[ResourceGroup]                -   Name of the Resource Group in which your Data Factory was created.

    @[Dataset]                      -   The name of the Dataset that points to the database where the metadata is stored. This 
                                        Dataset will be used to execute stored procedures to extract the required metadata. 
