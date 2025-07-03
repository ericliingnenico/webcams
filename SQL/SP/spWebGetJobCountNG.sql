Use CAMS
Go
if object_id('spWebGetJobCountNG') is null
	exec ('create procedure dbo.spWebGetJobCountNG as return 1')
go



alter Procedure dbo.spWebGetJobCountNG 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/12/15 16:27 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobCountNG.sql $-->
--<!--$$NoKeywords: $-->
 set nocount on
 DECLARE 	@SwapJobCount int,
		@InstallJobCount int,
		@DeinstallJobCount int,
		@UpgradeJobCount int,
		@ServiceDeskJobCount int

 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	 SELECT @SwapJobCount = ISNULL(Count(*), 0)
		FROM Calls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
						join vwFSP f on c.AssignedTo = f.Location
		WHERE u.UserID = @UserID

	 SELECT @ServiceDeskJobCount = ISNULL(Count(*), 0)
		FROM Calls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
						left outer join vwFSP f on isnull(c.AssignedTo, 0) = f.Location
		WHERE u.UserID = @UserID and f.Location is null
	
	 SELECT @InstallJobCount = ISNULL(Count(*), 0)
		FROM IMS_Jobs j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE u.UserID = @UserID
			AND JobTypeID = 1
	
	 SELECT @DeinstallJobCount = ISNULL(Count(*), 0)
		FROM IMS_Jobs j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE u.UserID = @UserID
			AND JobTypeID = 2

	 SELECT @UpgradeJobCount = ISNULL(Count(*), 0)
		FROM IMS_Jobs j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
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
		UpgradeJobAvg = cast(@UpgradeJobCount * 0.2 as int)


GO

Grant EXEC on spWebGetJobCountNG to eCAMS_Role
Go
/*
 dbo.spWebGetJobCountNG 202419
 dbo.spWebGetJobCountNG 202469
*/

