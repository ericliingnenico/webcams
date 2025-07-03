USE CAMS
go

if object_id('spWebGetOpenJobMatrixNG') is null
	exec ('create procedure dbo.spWebGetOpenJobMatrixNG as return 1')
go

Alter Procedure dbo.spWebGetOpenJobMatrixNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@JobType varchar(20)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 13/08/15 9:57 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetOpenJobMatrixNG.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Get Open Job Matrix - result set to speed up WebCAMS refreshGauget - refer ux js code - dashboard.viewmodel.js


*/

 DECLARE @STATUS_ALL int
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 --init
 SELECT @STATUS_ALL = 22

 IF ISNULL(@ClientID, 'ALL') = 'ALL'
  begin
	select 	ws.FilterStatusID,
			FilterStatus = fs.Status,
			Qty = count(distinct j.JobID)
		from vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = ws.StatusID AND ws.IsSwap = 0
					join tblStatus fs on fs.StatusID = ws.FilterStatusID
		 where u.UserID = @UserID
				AND JobType = @JobType
		 group by ws.FilterStatusID, fs.Status

  end
 ELSE
  begin
	select 	ws.FilterStatusID,
			FilterStatus = fs.Status,
			Qty = count(distinct j.JobID)
		from vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = ws.StatusID AND ws.IsSwap = 0
					join tblStatus fs on fs.StatusID = ws.FilterStatusID
		 where u.UserID = @UserID
				AND j.ClientID = @ClientID
				AND JobType = @JobType
		 group by ws.FilterStatusID, fs.Status

  end




GO

Grant EXEC on spWebGetOpenJobMatrixNG to eCAMS_Role
Go
/*

dbo.spWebGetOpenJobMatrixNG 
		@UserID = 210001,
		@ClientID  = 'cba',
		@JobType = 'install'




*/