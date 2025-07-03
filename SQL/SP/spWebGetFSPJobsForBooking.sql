Use WebCAMS
Go

if exists(select 1 from sys.procedures where name = 'spWebGetFSPJobsForBooking')
 drop proc spWebGetFSPJobsForBooking
Go

create proc dbo.spWebGetFSPJobsForBooking
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/01/16 13:50 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobsForBooking.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 declare @FSPID int,
	@ret int
 --get installerid
 SELECT @FSPID = InstallerID FROM WebCams.dbo.tblUser Where UserID = @UserID


 --select * into #MyFSPFamily
	--from CAMS.dbo.fnGetLocationFamily(@FSPID)

 ----not a FSP, return (Warning? Save WebService respond time, just return)
 --IF @FSPID IS NULL
 -- BEGIN
	--RAISERROR('The user is not a FSP. Abort.', 16, 1)
	--SELECT @ret = -1
	--GOTO Exit_Handle
 -- END

 exec Cams.dbo.spWebGetFSPJobDetailForBooking @UserID = @UserID, @JobID = @JobID


 exec CAMS.dbo.spGetJobsForBooking @JobID = @JobID, @Radius = null
/*

WebCAMS.dbo.spWebGetFSPJobsForBooking 199513, 2205655
*/
GO

Grant EXEC on spWebGetFSPJobsForBooking to eCAMS_Role
Go


Use CAMS
Go


Grant EXEC on spGetJobsForBooking  to eCAMS_Role
Go
