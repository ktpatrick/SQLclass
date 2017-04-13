--Lesson 2 Functions and sorting

--functions are just rules to transform a value or set of values to another value
--There are 4 types of functions
--Character,Numeric, Date/Time, and Conversion. 
--multiple functions can be nested to create a composite function

--Character functions
--transform character data

--The left() function accepts a text string and returns 
--the specified number of characters starting from the left
Select left('sunlight',3) as Answer

--Similarly, the right() function returns the speficied characters starting from the right
select right('George Washington   ',10) as LastName
--Be careful of leading or trailing blanks. You may not get what you expect

--you can use rtrim() and right() to create a composite function
select right(rtrim('George Washington   '),10) as LastName

--Returns the number of characters of the specified string expression, excluding trailing blanks.
select len('George Washington   ') as Numletters

--the upper() function converts all lowercase characters to uppercase
Select upper('George Washington') as AllCaps

--Date/Time functions
--transforms date/time data

--getDate() function returns today's date and time
select getDate() as TodaysDate

--DatePart() accepts a date string and returns the part of the date requested
--you can choose to return the year, month, week, day, dayofyear,weekday, hour, minute, etc....
Select DatePart(day, getDate()) as TodaysYear

--The DateDiff() function calculates the time that's passed between two input dates
--In this case, we calculate the years since the last cubs world series
select Datediff(week,'1908-10-14', getdate()) as CubsLastWS




--Numeric functions
--transform numeric data

--the round() function returns a number rounded to a specified number or decimal places
select round(157.365,1) as TheAnswer

--you can also choose -1 to round to the tens place 
select round(157.365,-1) as TheAnswer

--Don't worry about the specifics of the following code
--just know that its creating a temporary table called @TempTable
--with one column and three values(5, 6, and 4)
declare @TempTable table (SomeNumbers int)
insert into @TempTable values (5),(6),(4)

--The sum() function is an aggregate function that sums the values from a column and returns a value
select sum(SomeNumbers) as Summed
From @TempTable

--the max() function is an aggregate function that returns the maximum value
select max(SomeNumbers) as MaxValue
From @TempTable

--you can return a random between 0 and 1 exclusive
select rand() as PseudoRandom

--you can also return the value of pi
select pi() as pi

--You can also nest functions (i.e.: use a "composite" function)
declare @temptable2 Table (DecNumbers decimal(4,1))
Insert into @Temptable2 values (5.3),(10.9),(7.2), (-3.7)

Select Sum(DecNumbers) As Sum
From @TempTable2
--This returns the rounded sum
Select Round(Sum(DecNumbers),0) As RoundedSum
From @TempTable2

--You can also nest other functions
Select sqrt(Avg(Power(DecNumbers, 1/2))) As [Root Mean Squared Error],
		sqrt(Avg(Square(DecNumbers))) As RMSE
From @TempTable2

--Conversion functions
--convert data from one data type to another

--converts a numeric input to a character
select cast(2016 as char) as CharacterYear

select cast('2016' as int) as NumericYear
--convert is has similar functionality to cast
select convert(int,'2016') as NumericYear

--You can convert from one character datatype to another character data type
select cast('George Washington' as char(6)) as FirstName


--Ordering your queries
Use FarmIncomeInternal
Go

--This orders by the Two digit state code
Select St, StateName, TenRegionCode
From lookups.St
Order By St

--This orders by Fips code, which is in the table but not in the results returned by our query
Select St, StateName, TenRegionCode
From lookups.St
Order By Fips

--You can also order by in descending order
Select St, StateName, TenRegionCode
From lookups.St
Order By St Desc

--Remember we said ordering can affect query results
--Here's an example
Select Top 5 St, StateName, TenRegionCode
From lookups.St
Order By St

Select Top 5 St, StateName, TenRegionCode
From lookups.St
Order By TenRegionCode