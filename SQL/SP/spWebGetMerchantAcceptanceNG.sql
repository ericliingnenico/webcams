USE CAMS
Go

if object_id('spWebGetMerchantAcceptanceNG') is null
	exec ('create procedure dbo.spWebGetMerchantAcceptanceNG as return 1')
go

Alter PROCEDURE dbo.spWebGetMerchantAcceptanceNG 
(
	@UserID int,
	@JobID	bigint

)
AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 25/08/15 8:54 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetMerchantAcceptanceNG.sql $-->
--<!--$$NoKeywords: $-->
Declare @IsOK bit

 SET NOCOUNT ON

 --init
 select @IsOk = 0

 --verification
 if dbo.fnIsSwapCall(@JobID) = 1
  begin
	IF EXISTS(SELECT 1 FROM Calls c  WITH (NOLOCK) JOIN vwUserClientEquipmentCode u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
			WHERE u.UserID = @UserID
			 	AND CallNumber = @JobID)
	  begin
		select @IsOk = 1
	  end
	else
	 begin
		IF EXISTS(SELECT 1 FROM Call_History c  WITH (NOLOCK) JOIN vwUserClientEquipmentCode u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
				WHERE u.UserID = @UserID
			 		AND cast(CallNumber as varchar) = @JobID)
		  begin
			select @IsOk = 1
		  end
	 end
  end
 else
  begin
	 IF EXISTS(SELECT 1 FROM IMS_Jobs c WITH (NOLOCK) JOIN UserClientDeviceType u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.DeviceType = ISNULL(u.DeviceType, c.DeviceType)
				WHERE u.UserID = @UserID
			 		AND JobID = @JobID)
	  begin
		select @IsOk = 1
	  end
	else
	 begin
		 IF EXISTS(SELECT 1 FROM IMS_Jobs_History c WITH (NOLOCK) JOIN UserClientDeviceType u WITH (NOLOCK) ON c.ClientID = u.ClientID AND c.DeviceType = ISNULL(u.DeviceType, c.DeviceType)
					WHERE u.UserID = @UserID
			 			AND JobID = @JobID)
		  begin
			select @IsOk = 1
		  end
	 end
 end

 if @IsOk = 0
  begin
	raiserror ('You do not have persmission to access this job survey.',16,1)
  end
 else
  begin
	SELECT m.* 
		FROM tblMerchantAcceptance m
			WHERE  m.JobID = @JobID
  end

/*
EXECUTE spWebGetMerchantAcceptanceNG 210000, 20150501234
*/
GO

Grant EXEC on dbo.spWebGetMerchantAcceptanceNG  to eCAMS_Role
Go
