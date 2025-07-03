USE WEBCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetState' and type = 'p')
   drop proc spWebGetState
go

CREATE PROC spWebGetState 
(
 @UserID int,
 @AddAll bit = 0
)
AS

 SET NOCOUNT ON

 --get structure
 CREATE TABLE #myState (Seq tinyint identity, 
		[State] varchar(3) collate database_default, 
		StateFullName varchar(50) collate database_default)

 if @AddAll = 1 
    INSERT INTO #myState ([State], StateFullName) VALUES ('ALL', 'All States')

 INSERT INTO #myState ([State], StateFullName)
  SELECT [State],
	StateFullName 
  FROM CAMS.dbo.tblState
 ORDER BY [State]
   

 SELECT [State],
	StateFullName
 FROM #myState
 ORDER BY Seq


/*
use Webcams
exec spWebGetState 1, 1
*/

Go

GRANT EXEC ON spWebGetState TO eCAMS_Role
go

use CAMS
Go

Grant select on tblState to eCAMS_Role
go



