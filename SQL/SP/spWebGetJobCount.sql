Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetJobCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetJobCount]
GO


Create Procedure dbo.spWebGetJobCount 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/07/15 17:18 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobCount.sql $-->
--<!--$$NoKeywords: $-->
 set nocount on
 DECLARE 	@SwapJobCount int,
		@InstallJobCount int,
		@DeinstallJobCount int,
		@UpgradeJobCount int,
		@ServiceDeskJobCount int,
		@FSPID int

 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SELECT @FSPID = InstallerID FROM WebCams.dbo.tblUser Where UserID = @UserID
 IF @FSPID IS NULL
  BEGIN

	 SELECT @SwapJobCount = ISNULL(Count(*), 0)
		FROM Calls c JOIN WebCams.dbo.vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
						join vwFSP f on c.AssignedTo = f.Location
		WHERE u.UserID = @UserID

	 SELECT @ServiceDeskJobCount = ISNULL(Count(*), 0)
		FROM Calls c JOIN WebCams.dbo.vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
						left outer join vwFSP f on isnull(c.AssignedTo, 0) = f.Location
		WHERE u.UserID = @UserID and f.Location is null
	
	 SELECT @InstallJobCount = ISNULL(Count(*), 0)
		FROM IMS_Jobs j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE u.UserID = @UserID
			AND JobTypeID = 1
	
	 SELECT @DeinstallJobCount = ISNULL(Count(*), 0)
		FROM IMS_Jobs j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE u.UserID = @UserID
			AND JobTypeID = 2

	 SELECT @UpgradeJobCount = ISNULL(Count(*), 0)
		FROM IMS_Jobs j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE u.UserID = @UserID
			AND JobTypeID = 3

	--Return the count as recordset
	 SELECT SwapJobCount = @SwapJobCount, 
		ServiceDeskJobCount = @ServiceDeskJobCount, 
		InstallJobCount = @InstallJobCount, 
		DeinstallJobCount = @DeinstallJobCount,
		UpgradeJobCount = @UpgradeJobCount,
		SwapJobAvg = cast(@SwapJobCount*0.8 as int), 
		ServiceDeskJobAvg = cast(@ServiceDeskJobCount * 0.9 as int), 
		InstallJobAvg = cast(@InstallJobCount * 0.7 as int), 
		DeinstallJobAvg = cast(@DeinstallJobCount * 1.1 as int),
		UpgradeJobAvg = cast(@UpgradeJobCount * 1.2 as int)

  END
 ELSE
  BEGIN
	EXEC dbo.spWebGetFSPJobCount @FSPID= @FSPID
  END


GO

Grant EXEC on spWebGetJobCount to eCAMS_Role
Go
/*
 dbo.spWebGetJobCount 202419
 dbo.spWebGetJobCount 202469
*/

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetJobCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetJobCount]
GO


Create Procedure dbo.spWebGetJobCount 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/08/08 10:58a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobCount.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/

 set nocount on
 EXEC Cams.dbo.spWebGetJobCount @UserID =@UserID
Go

Grant EXEC on spWebGetJobCount to eCAMS_Role
Go
