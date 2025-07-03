Use CAMS
Go

Alter Procedure dbo.spWebGetFSPJobSheetList 
	(
		@UserID int,
		@JobIDList varchar(4000)
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 11/04/06 4:23p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobSheetList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON

 CREATE TABLE #JobData (
			JobID bigint)

 INSERT #JobData
	SELECT * FROM dbo.fnConvertListToTable(@JobIDList)

 SELECT @UserID as UserID,
	JobID
   FROM #JobData


/*


spWebGetFSPJobSheetList 199513, '20031002611,235606'

spWebGetFSPJobSheetList 199513, '20031002611'

spWebGetFSPJobSheetList 199649, '20031002611'


*/
GO

Grant EXEC on spWebGetFSPJobSheetList to eCAMS_Role
Go


USE webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPJobSheetList')
 drop proc spWebGetFSPJobSheetList
go


Create Procedure dbo.spWebGetFSPJobSheetList 
	(
		@UserID int,
		@JobIDList varchar(4000)
	)
	AS
 EXEC CAMS.dbo.spWebGetFSPJobSheetList 
		@UserID = @UserID,
		@JobIDList = @JobIDList
Go

Grant EXEC on spWebGetFSPJobSheetList to eCAMS_Role
Go
