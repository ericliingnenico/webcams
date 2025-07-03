
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebCloseFSPTask]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebCloseFSPTask]
GO


Create Procedure dbo.spWebCloseFSPTask 
	(
		@UserID int,
		@TaskID int
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/03/05 1:41p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPTask.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @InstallerID int,
	@FSPOperator int,
	@ret int


 SELECT @ret = 0

 --Get FSPID
 SELECT @InstallerID = InstallerID,
	@FSPOperator = -InstallerID
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID



 IF EXISTS(SELECT 1 FROM tblTask t JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON t.AssignedTo = l.Location
		WHERE  TaskID = @TaskID)
  BEGIN

	EXEC @ret = dbo.spCloseTask 
		@TaskID = @TaskID,
		@TaskStatusID = 4,
		@ClosedBy = @FSPOperator


  END

 RETURN @ret
GO

Grant EXEC on spWebCloseFSPTask to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebCloseFSPTask]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebCloseFSPTask]
GO


Create Procedure dbo.spWebCloseFSPTask 
	(
		@UserID int,
		@TaskID int	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPTask.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebCloseFSPTask @UserID = @UserID, 
				@TaskID = @TaskID
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

spWebCloseFSPTask 199512, 1672


*/
GO

Grant EXEC on spWebCloseFSPTask to eCAMS_Role
Go
