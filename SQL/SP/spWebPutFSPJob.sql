Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPJob]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutFSPJob]
GO


Create Procedure dbo.spWebPutFSPJob 
	(
		@UserID int,
		@JobID int,
		@OnSiteDateTime datetime,
		@OffSiteDateTime datetime,
		@Original_OnSiteDateTime datetime,
		@Original_OffSiteDateTime datetime
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/04/03 9:27 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPJob.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT OFF

 EXEC CAMS.dbo.spWebPutFSPJob @UserID = @UserID, @JobID = @JobID, @OnSiteDateTime = @OnSiteDateTime,
				@OffSiteDateTime = @OffSiteDateTime, 
				@Original_OnSiteDateTime = @Original_OnSiteDateTime, 
				@Original_OffSiteDateTime = @Original_OffSiteDateTime
			

/*
spWebPutFSPJob 3, 187196

*/
Go


Grant EXEC on spWebPutFSPJob to eCAMS_Role
Go


Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPJob]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutFSPJob]
GO


Create Procedure dbo.spWebPutFSPJob 
	(
		@UserID int,
		@JobID int,
		@OnSiteDateTime datetime,
		@OffSiteDateTime datetime,
		@Original_OnSiteDateTime datetime,
		@Original_OffSiteDateTime datetime
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/04/03 13:04 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebPutFSPJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT OFF
 DECLARE @OnSiteDateTimeOffset   int,
	@OffSiteDateTimeOffset   int,
	@State 			varchar(3)

 --Get Job Info
 SELECT
	@State = State
   FROM vwIMSJob
  WHERE JobID = @JobID

 --Get Time Zone for OnSiteDate/OffSiteDate
 SELECT @OnSiteDateTimeOffset = DateTimeOffset
	FROM tblTimeZone
	WHERE State = @State
		AND  @OnSiteDateTime >= FromDate
		AND @OnSiteDateTime <= ToDate

 SELECT @OffSiteDateTimeOffset = DateTimeOffset
	FROM tblTimeZone
	WHERE State = @State
		AND  @OffSiteDateTime >= FromDate
		AND @OffSiteDateTime <= ToDate

 IF @Original_OnSiteDateTime IS NULL OR @Original_OffSiteDateTime IS NULL
  --If original value is null, go ahead to update it
  BEGIN
	 UPDATE c
	    SET OnSiteDateTime = @OnSiteDateTime,
		OffSiteDateTime = @OffSiteDateTime,
		OnSiteDateTimeOffset = @OnSiteDateTimeOffset,
		OffSiteDateTimeOffset = @OffSiteDateTimeOffset
	   FROM vwIMSJob c JOIN WebCams.dbo.tblUser u ON c.BookedInstaller = u.InstallerID
	  WHERE u.UserID = @UserID
		AND JobID = @JobID
  END
  --If original values are not null, update only for the matched
  BEGIN
	 UPDATE c
	    SET OnSiteDateTime = @OnSiteDateTime,
		OffSiteDateTime = @OffSiteDateTime,
		OnSiteDateTimeOffset = @OnSiteDateTimeOffset,
		OffSiteDateTimeOffset = @OffSiteDateTimeOffset
	   FROM vwIMSJob c JOIN WebCams.dbo.tblUser u ON c.BookedInstaller = u.InstallerID
	  WHERE u.UserID = @UserID
		AND JobID = @JobID
		AND c.OnSiteDateTime = @Original_OnSiteDateTime
		AND c.OffSiteDateTime = @Original_OffSiteDateTime

  END



GO

Grant EXEC on spWebPutFSPJob to eCAMS_Role
Go
