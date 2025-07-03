USE CAMS
go

if object_id('spWebGetOpenJobListNG') is null
	exec ('create procedure dbo.spWebGetOpenJobListNG as return 1')
go

Alter Procedure dbo.spWebGetOpenJobListNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@JobType varchar(20),
		@FilterStatusID tinyint,
		@State varchar(3) = null
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/09/15 16:01 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetOpenJobListNG.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Get Open Job List


*/

 DECLARE @STATUS_ALL int
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 --init
 SELECT @STATUS_ALL = 22

 IF ISNULL(@ClientID, 'ALL') = 'ALL'
  BEGIN
	 IF ISNULL(@State, 'ALL') = 'ALL'
	  begin
	 	SELECT 
			j.JobID,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			j.Status, 
			j.State,
			ws.FilterStatusID,
			j.StatusID

			FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN j.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 0
			WHERE u.UserID = @UserID
				AND JobType = @JobType
			 Order by JobID
	  end
	 ELSE
	  begin
	 	SELECT 
			j.JobID,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			j.Status, 
			j.State,
			ws.FilterStatusID,
			j.StatusID
			FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN j.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 0
			WHERE u.UserID = @UserID
				AND State = @State
				AND JobType = @JobType
			 Order by JobID
	  end
  END
 ELSE
  BEGIN
	 IF ISNULL(@State, 'ALL') = 'ALL'
	  begin
	 	SELECT 
			j.JobID,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			j.Status, 
			j.State,
			ws.FilterStatusID,
			j.StatusID
			FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN j.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 0
			WHERE u.UserID = @UserID
				AND j.ClientID = @ClientID
				AND JobType = @JobType
			 Order by JobID
	  end
	 ELSE
	  begin
	 	SELECT 
			j.JobID,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			j.Status, 
			j.State,
			ws.FilterStatusID,
			j.StatusID
			FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN j.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 0
			WHERE u.UserID = @UserID
				AND j.ClientID = @ClientID
				AND State = @State
				AND JobType = @JobType
			 Order by JobID
	  end

  END




GO

Grant EXEC on spWebGetOpenJobListNG to eCAMS_Role
Go
/*
dbo.spWebGetOpenJobListNG 
		@UserID = 21000,
		@ClientID  = 'cba',
		@JobType = 'install',
		@FilterStatusID = 22,
		@State = 'all'




*/