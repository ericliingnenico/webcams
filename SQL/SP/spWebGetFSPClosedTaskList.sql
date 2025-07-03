
Use CAMS
Go

Alter Procedure dbo.spWebGetFSPClosedTaskList 
	(
		@UserID int,
		@FSPID int,
		@FromDate datetime,
		@ToDate datetime
	)
	AS
--<!--$$Revision: 11 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/02/07 4:46p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPClosedTaskList.sql $-->
--<!--$$NoKeywords: $-->
---Get closed tasks for given FSP and date range
DECLARE @dt datetime,
	@InstallerID int

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 --get InstallerID
 SELECT @InstallerID = InstallerID 
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID


 --swap the date if from > to
 IF @FromDate > @ToDate
  BEGIN
	SELECT @dt = @ToDate
	SELECT @ToDate = @FromDate
	SELECT @FromDate = @dt
  END


 --format date range
 SELECT @FromDate = CONVERT(varchar, @FromDate, 106),
	@ToDate = CONVERT(varchar, @ToDate, 106) + ' 23:59:59:999'


 SELECT 
	'<A HREF="../Member/FSPTask.aspx?JID=' + CAST(TaskID as varchar) + '">' + CAST(t.JobID as varchar) + '-' + CAST(TaskID as varchar) + '</A>' as JobID,
--	CAST(t.JobID as varchar) + '-' + CAST(TaskID as varchar) as JobID,
	t.ToLocation, 
	t.ConNoteNo,
	t.ClosedDateTime,
	t.CloseComment
	FROM tblTask_History t
	WHERE t.AssignedTo = @FSPID
		AND t.ClosedDateTime BETWEEN @FromDate AND @ToDate
    Order by t.ClosedDateTime


GO

Grant EXEC on spWebGetFSPClosedTaskList to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPClosedTaskList 
	(
		@UserID int,
		@FSPID int,
		@FromDate datetime,
		@ToDate datetime
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 2:47p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPClosedTaskList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPClosedTaskList @UserID = @UserID, 
					@FSPID = @FSPID,
					@FromDate = @FromDate,
					@ToDate = @ToDate

/*


spWebGetFSPClosedTaskList 199611, 2000, '2004-01-01', '2004-09-30'

*/
Go

Grant EXEC on spWebGetFSPClosedTaskList to eCAMS_Role
Go
