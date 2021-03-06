--Create a stored procedure that returns the variable information for mink
--the begin and end keywords are optional, but it's good practice to include them for clarity
--Remember that creating a stored procedure creates it, but does not execute the stored procedure
Create Procedure workArea.VarLookup as
	Begin
		SELECT *
		  FROM [FarmIncomeInternal].[lookups].[Variable]
		  where VariableDescription like '%mink%'
	End
	--To run the stored procedure, we use the Exec keyword
	Exec WorkArea.VarLookup
--Alter the stored procedure above to have the stored procedure lookup the variable information for hazelnuts
Alter Procedure  workArea.VarLookup as
	Begin
			SELECT [VGroup]
				  ,[Vtype]
				  ,[VDesc1]
				  ,[VDesc2]
				  ,[VariableDescription]
				  ,[VGroupDescription]
				  ,[VTypeDescription]
				  ,[VDesc1Description]
				  ,[CommodityCode]
				  ,[Variable_ID]
				  ,[Grouping1]
				  ,[Grouping2]
				  ,[BEA_US_Code]
				  ,[BEA_ST_Code]
			  FROM [FarmIncomeInternal].[lookups].[Variable]
			  where VariableDescription like '%hazelnuts%'
		End

		Exec WorkArea.VarLookup

		--Now let's add a parameter to dynamically choose the variable you want to lookup
Alter Procedure  workArea.VarLookup 
	@Var varchar(120) 
	as
	Begin
			SELECT [VGroup]
				  ,[Vtype]
				  ,[VDesc1]
				  ,[VDesc2]
				  ,[VariableDescription]
				  ,[VGroupDescription]
				  ,[VTypeDescription]
				  ,[VDesc1Description]
				  ,[CommodityCode]
				  ,[Variable_ID]
				  ,[Grouping1]
				  ,[Grouping2]
				  ,[BEA_US_Code]
				  ,[BEA_ST_Code]
			  FROM [FarmIncomeInternal].[lookups].[Variable]
			  where VariableDescription like '%'+@Var+'%'
		End

		Exec WorkArea.VarLookup
		@Var='apple'

				--You can add a defualt value for the parameter that will be the value of the parameter if no value is set when the procedure is executed
Alter Procedure  workArea.VarLookup 
	@Var varchar(120) ='corn'
	as
	Begin
			SELECT [VGroup]
				  ,[Vtype]
				  ,[VDesc1]
				  ,[VDesc2]
				  ,[VariableDescription]
				  ,[VGroupDescription]
				  ,[VTypeDescription]
				  ,[VDesc1Description]
				  ,[CommodityCode]
				  ,[Variable_ID]
				  ,[Grouping1]
				  ,[Grouping2]
				  ,[BEA_US_Code]
				  ,[BEA_ST_Code]
			  FROM [FarmIncomeInternal].[lookups].[Variable]
			  where VariableDescription like '%'+@Var+'%'
		End

		Exec WorkArea.VarLookup
		@Var='soy'


		--You can also use a local variable outside of a stored procedure
		--This is useful particularly if you don't have access to create a stored procedure 
		--In this case you can just save the query on your computer and update the local variables any time you need
		Declare @FirstYr int,@LastYr int
		Set @FirstYr=2014
		Set @LastYr=2015

		Select * From [ERS_wide_access].[public_data]
		where YYYY between @FirstYr and @LastYr
