select * 
from Student_rooster.dbo.['1-ROSTER-Roster$']

--first checking all column names and correcting them from columns folder

<-- checking data type of table
select DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS 
Where table_name = '1-ROSTER-Roster$'

<--removing time from date of visit  column 
ALTER TABLE Student_rooster.dbo.['1-ROSTER-Roster$']
ADD [Date of visit] DATE;

UPDATE Student_rooster.dbo.['1-ROSTER-Roster$']
SET [Date of visit] = CONVERT(Date, Date_of_visit )


<--removing time from date of birth column 
select CONVERT(Date, [Date of Birth] )
from Student_rooster.dbo.['1-ROSTER-Roster$']

ALTER TABLE Student_rooster.dbo.['1-ROSTER-Roster$']
ADD DOB DATE;

UPDATE Student_rooster.dbo.['1-ROSTER-Roster$']
SET DOB = CONVERT(Date, [Date of Birth] )

-- emis code is a must so rows with no emis code are deleted. 3 rows were deleted which were at the top
DELETE FROM Student_rooster.dbo.['1-ROSTER-Roster$']
WHERE [School EMIS code ] is null 


--making a new column for student gender 
ALTER TABLE Student_rooster.dbo.['1-ROSTER-Roster$']
ADD Gender_Child nvarchar(255);

-- there were a lot of nulls in male and female, so added 2 other statements regarding school_type
Update Student_rooster.dbo.['1-ROSTER-Roster$']
SET Gender_Child = CASE 
	WHEN Male = '1' THEN 'Male' 
	WHEN FEMALE = '1' THEN 'Female' 
	WHEN School_Type = 'Boys' THEN 'Male'
	WHEN School_Type = 'Girls' THEN 'Female'
	ELSE Gender_Child 
	END


select school_type, Gender_child 
from Student_rooster.dbo.['1-ROSTER-Roster$']
WHERE school_type = 'Boys' and Gender_Child = 'Male'

-- Removing duplicate B form # as it is unique for every person
WITH RowNumCTE AS (
select * , 
ROW_NUMBER() OVER (
	Partition  by [B form #]
				 order by 
					[B form #]
					) row_num
from Student_rooster.dbo.['1-ROSTER-Roster$']

)
DELETE FROM RowNumCTE
WHERE row_num > 1;

select  *
from Student_rooster.dbo.['1-ROSTER-Roster$']

