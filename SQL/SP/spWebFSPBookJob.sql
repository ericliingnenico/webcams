Use WebCAMS
Go

if exists(select 1 from sys.procedures where name = 'spWebFSPBookJob')
 drop proc spWebFSPBookJob
Go

create proc dbo.spWebFSPBookJob
	(
		@UserID int,
		@JobIDs varchar(4000),
		@BookInstaller int,
		@BookForDateTime datetime,
		@Notes varchar(4000)

	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 20/01/16 8:47 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebFSPBookJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 declare @FSPID int,
	@FSPOperatorNumber int,
	 @BookForDate datetime,
	 @BookForTime datetime,
	@ret int
 --get installerid
 SELECT @FSPID = InstallerID FROM WebCams.dbo.tblUser Where UserID = @UserID

 SELECT @FSPOperatorNumber = -@FSPID

 --select * into #MyFSPFamily
	--from CAMS.dbo.fnGetLocationFamily(@FSPID)

 ----not a FSP, return (Warning? Save WebService respond time, just return)
 --IF @FSPID IS NULL
 -- BEGIN
	--RAISERROR('The user is not a FSP. Abort.', 16, 1)
	--SELECT @ret = -1
	--GOTO Exit_Handle
 -- END

 select @BookForDate = convert(varchar, @BookForDateTime, 107),
		@BookForTime = convert(varchar, @BookForDateTime, 108)

 exec @ret = CAMS.dbo.spBookInstallerForMultipleJobs 
	 @JobIDs = @JobIDs,
	 @BookInstaller = @BookInstaller,
	 @BookForDate = @BookForDate,
	 @BookForTime = @BookForTime,
	 @BookBy = @FSPOperatorNumber,
	 @HasMultipleInstallers = 0

 if @ret <> 0 
	goto Exit_Handle

 if isnull(@Notes, '') <> ''
  begin
	 exec @ret = CAMS.dbo.spWebAddFSPJobNoteExt
		 @UserID = @UserID,
		 @JobIDs = @JobIDs,
		 @Notes = @Notes
  end

 exec CAMS.dbo.spSetJobAllowFSPWebAccessExt
		@JobIDs = @JobIDs

--log the booking
 exec CAMS.dbo.spWebPutFSPBookingLog 
		@FSPID = @FSPOperatorNumber,
		@JobIDs = @JobIDs,
		@BookInstaller = @BookInstaller,
		@BookForDateTime = @BookForDateTime,
		@Notes = @Notes

Exit_Handle:
  SELECT @ret  --buble up to SqlHelper.ExecuteScalar
  RETURN @ret
GO
/*

WebCAMS.dbo.spWebFSPBookJob 199513, 2205655
*/
GO

Grant EXEC on spWebFSPBookJob to eCAMS_Role
Go


Use CAMS
Go


Grant EXEC on spBookInstallerForMultipleJobs  to eCAMS_Role
Go

