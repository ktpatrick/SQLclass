--We are going to create a table with four columns
--CustomerID is the primary keyy and will be integer datatype and can not have a null value
--FirstName will be character format up to 30 characters and can be null
--LastName will be character format up to 50 characters and can be null
--State will be character format and needs to be two characters, can be null and has a default value of california

Create Table WorkArea.Customers
(CustomerID int Primary Key Not Null,
 FirstName VarChar (30),
 LastName VarChar (50),
 State Char(2) NULL Default ('CA')  )


 --Let's add a city column to our newly created table
 Alter Table WorkArea.Customers
	Add City VarChar(75) NULL 

	--Now let's change the state column so it can't be null
	Alter Table WorkArea.Customers
	Alter Column State Char(2) Not NULL 

	--Remove the city column
	Alter Table WorkArea.Customers
	Drop column City 

	--There are two main ways to insert data into a table:
	--1. using the insert into with the values keyword
	--2. Using the insert into with the select statement
	--Let's add data to our customers table
	Insert into WorkArea.Customers
	(CustomerID,FirstName,LastName,State)
	Values(1, 'Michael', 'Headlee','OH'),
		   (2, 'Kevin', 'Patrick', 'IL')


--You don't need to include all columns or list them in the same order as they appear in the table
	Insert into WorkArea.Customers
	(FirstName,LastName,CustomerID)
	Values ('Ryan','Kuhns',3)


	--Insert using the select statement
	Insert into WorkArea.Customers (CustomerID,FirstName)
	SELECT distinct 5, new_Vdesc3description
  FROM [FarmIncomeInternal].[ERS_wide_access].[public_data_view]
  where new_Vgroup='CR' and new_Vtype='CO' and new_Vdesc1='FN' and new_Vdesc2='FR' and new_Vdesc3='AP'


	--You can also update records within a table using the update and set keywords
	--becareful that you are seleting only the rows you want to update. There is no CTL-Z
	Update WorkArea.Customers
	set state='TX'
	where FirstName='Michael'

	--remove all of the rows with the state as Illinois
	--becareful that you are seleting only the rows you want to delete. There is no CTL-Z
	Delete From WorkArea.Customers
	Where State='IL'


	--remove all rows from the customers table
	Truncate Table WorkArea.Customers



	--completely delete the customers table
	Drop Table WorkArea.Customers