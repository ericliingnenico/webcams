Use CAMS
Go

if exists(select 1 from sys.procedures where name = 'spWebGetJobKittedDevice')
	drop proc spWebGetJobKittedDevice
go

Create Procedure dbo.spWebGetJobKittedDevice 
	(
		@UserID int,
		@JobID bigint,
		@CheckFSPConfirmLog bit
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 5/04/13 14:02 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobKittedDevice.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Return kitted device from vwPIMCurrentDeviceKit if there is a match

DECLARE @ret int,
	@Location int

 --init
 SELECT @ret = 0
 
 --Get Location for the user
 SELECT @Location = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 if @@ROWCOUNT = 0
  begin
	raiserror('Invalid user, abort', 16, 1)
	return -1
  end
  
 IF dbo.fnIsSwapCall(@JobID) = 1
  --Swap Calls
  BEGIN
	if @CheckFSPConfirmLog = 1
	 begin
		if exists(select 1 from tblFSPKitPartUsageConfirmLog where JobID = @JobID)
		 begin
			select dk.Serial, dk.MMD_ID
			 from vwPIMCurrentDeviceKit dk
				where 1 = 2 
		 end
		else
		 begin
			select dk.Serial, dk.MMD_ID
			 from Call_Equipment ce with (nolock) join vwPIMCurrentDeviceKit dk with (nolock) on ce.NewMMD_ID = dk.MMD_ID and ce.NewSerial = dk.Serial
				where ce.CallNumber = @JobID and dbo.fnIsSerialisedDevice(ce.NewSerial) = 1 and dk.ItemType='E'
		 end
	 end
	else
	 begin
		select dk.Serial, dk.MMD_ID
		 from Call_Equipment ce with (nolock) join vwPIMCurrentDeviceKit dk with (nolock) on ce.NewMMD_ID = dk.MMD_ID and ce.NewSerial = dk.Serial
			where ce.CallNumber = @JobID and dbo.fnIsSerialisedDevice(ce.NewSerial) = 1 and dk.ItemType='E'
	 end
	
  END
 ELSE
  --IMS Jobs
  BEGIN
	select dk.Serial, dk.MMD_ID
	 from vwPIMCurrentDeviceKit dk
		where 1 = 2 

  END

 RETURN @ret
/*
declare @ret  int
exec @ret = dbo.spWebGetJobKittedDevice @UserID = 199663, 
					@JobID = 310352
select @ret



*/
Go

Grant EXEC on spWebGetJobKittedDevice to eCAMS_Role
Go


Use WebCAMS
Go
if exists(select 1 from sys.procedures where name = 'spWebGetJobKittedDevice')
	drop proc spWebGetJobKittedDevice
go

Create Procedure dbo.spWebGetJobKittedDevice 
	(
		@UserID int,
		@JobID bigint,
		@CheckFSPConfirmLog bit
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebCloseFSPJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebGetJobKittedDevice @UserID = @UserID,
		@JobID = @JobID,
		@CheckFSPConfirmLog = @CheckFSPConfirmLog


 RETURN @ret
/*

spWebGetJobKittedDevice @UserID = 199516,
		@JobID = 221895,
		@CheckFSPConfirmLog = 1

*/
Go

Grant EXEC on spWebGetJobKittedDevice to eCAMS_Role
Go
