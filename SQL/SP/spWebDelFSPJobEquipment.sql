
Use CAMS
Go

Alter  Procedure dbo.spWebDelFSPJobEquipment 
	(
		@UserID int,
		@JobID bigint,
		@Serial varchar(32),
		@MMD_ID varchar(5),
		@Action smallint
	)
	AS
--<!--$$Revision: 18 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/09/07 2:11p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebDelFSPJobEquipment.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Delete existing device from ims job/calls
---Amend revoke location/condition
---21/12/2005 Changed the revoked location to Job FSP location (ref Task: 539)
DECLARE @Note varchar(65),
	@ret int,
	@Location int,

	@LastLocation int,
	@LastCondition int,

	@NewSerial varchar(32),
	@NewMMD_ID varchar(5),
	
	@ClientID varchar(3),

	@FSPOperatorNumber int,
	
	@JobFSP int,
	@JobExist bit,

	@JobIDString varchar(11)



 --init
 SELECT @ret = 0,
	@JobIDString = CAST(@JobID as varchar(11))


 --Get Location for the user
 SELECT @Location = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@Location

 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)

 --***Get job details
 IF LEN(@JobID) = 11 
  --Swap Calls
  BEGIN
	--get call details
	SELECT @ClientID = ClientID,
		@JobFSP = AssignedTo
	  FROM Calls
	 WHERE CallNumber = @JobID
	
	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

  END
 ELSE
  --IMS Jobs
  BEGIN
	--get job details
	SELECT @ClientID = ClientID,
		@JobFSP = BookedInstaller
	 FROM  IMS_Jobs
	 WHERE JobID = @JobID

	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END


  END

 --***validation
 --verify if the job is belong to this user
 IF NOT EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
  BEGIN
	IF @JobExist = 1
	 BEGIN
		RAISERROR('Job [%s] is not assigned to FSP [%d] group. Abort', 16, 1, @JobIDString, @Location)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END
	ELSE
	 BEGIN
		RAISERROR('Job [%s] does not exist. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END

  END -- job does not exist

 --Start Transaction
 DECLARE @bInCallerTransaction bit
 SET @bInCallerTransaction = @@TRANCOUNT
 IF @bInCallerTransaction = 0
	BEGIN TRAN


 IF LEN(@JobID) = 11 
  --Swap Calls
  BEGIN
	--The device to be deleted is an installation
	IF @Action = 1 
	 BEGIN
		--then, we need to free it up, only do this when it is in inventory	
		IF EXISTS(SELECT 1 FROM Equipment_Inventory WHERE Serial = @Serial AND MMD_ID = @MMD_ID)
		 BEGIN
			SELECT @LastLocation = @JobFSP,
				@LastCondition = CASE WHEN LastCondition IN  (18, 19, 20) THEN LastCondition
							ELSE dbo.fnGetRevokedDeviceDefaultCondition(MMD_ID) END
			  FROM Equipment_Inventory 
			 WHERE Serial = @Serial
				AND MMD_ID = @MMD_ID

			SELECT @Note = 'NO LONGER RESERVED FOR ' + CAST(@JobID as varchar)

			--free up the device only when it exists
			EXEC @ret = dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = @LastCondition,
					@NewLocation = @LastLocation,
					@Note = @Note,
					@AddedBy = @FSPOperatorNumber

			 IF @ret <> 0 
				GOTO RollBack_Handle

		 END				

		IF EXISTS(SELECT 1 FROM Call_Equipment WHERE CallNumber = @JobID
								AND NewSerial = @Serial
								AND NewMMD_ID = @MMD_ID
								AND dbo.fnIsSerialisedDevice(Serial) = 0)
		 BEGIN
			DELETE Call_Equipment
			  WHERE CallNumber = @JobID
				AND NewSerial = @Serial
				AND NewMMD_ID = @MMD_ID


			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle
		 END
		ELSE
		 BEGIN
			--update call equipment, set the new device to 'CONFIRM'
			UPDATE Call_Equipment
			   SET NewSerial = 'CONFIRM',
				Swapped = 0,
				NewIs3DES = 0,
				NewIsEMV = 0
			  WHERE CallNumber = @JobID
				AND NewSerial = @Serial
				AND NewMMD_ID = @MMD_ID
	
	
			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle

		 END

	 END --IF @Action = 1 '' install a new device

	--Remove existing device
	IF @Action = 2
	 BEGIN
		--verify if the new device has been removed yet. 
		--If not, we will remove this new device before delete the call equipment record
		SELECT @NewSerial = NewSerial,
			@NewMMD_ID = NewMMD_ID
		  FROM Call_Equipment
		  WHERE CallNumber = @JobID
			AND Serial = @Serial
			AND MMD_ID = @MMD_ID
		
		SELECT @ret = @@ERROR
		IF @ret <> 0 
			GOTO RollBack_Handle

		--free it up if it is in inventory
		IF EXISTS(SELECT 1 FROM Equipment_Inventory WHERE Serial = @NewSerial
								AND MMD_ID = @NewMMD_ID)
		 BEGIN
			SELECT @LastLocation = @JobFSP,
				@LastCondition = CASE WHEN LastCondition IN  (18, 19, 20) THEN LastCondition
							ELSE dbo.fnGetRevokedDeviceDefaultCondition(MMD_ID) END
			   FROM Equipment_Inventory 
			  WHERE Serial = @NewSerial
				AND MMD_ID = @NewMMD_ID

			SELECT @Note = 'NO LONGER RESERVED FOR ' + CAST(@JobID as varchar)

			--free up the device only when it exists
			EXEC @ret = dbo.spChangeInventoryConditionLocation 
					@Serial = @NewSerial,
					@MMD_ID = @NewMMD_ID,
					@NewCondition = @LastCondition,
					@NewLocation = @LastLocation,
					@Note = @Note,
					@AddedBy = @FSPOperatorNumber

			 IF @ret <> 0 
				GOTO RollBack_Handle

		 END				

		--remove the record
		DELETE Call_Equipment
		 WHERE CallNumber = @JobID
			AND Serial = @Serial
			AND MMD_ID = @MMD_ID

		SELECT @ret = @@ERROR
		IF @ret <> 0 
			GOTO RollBack_Handle
		

	 END --IF @Action = 2 ''remove the existing device
	
  END -- swap job

 ELSE

  --IMS Jobs
  BEGIN
	--Install new device
	IF @Action = 1 
	 BEGIN

		--verify if the device is in inventory and free it up
		IF EXISTS(SELECT 1 FROM Equipment_Inventory WHERE Serial = @Serial 
								AND MMD_ID = @MMD_ID)

		 BEGIN

			--Is it part of Kit? If so, no need to release the device, just leave as it is
			--otherwise, release it
			IF EXISTS(SELECT 1 FROM Equipment_Kits WHERE (PinpadSerial = @Serial AND PinpadMMD_ID = @MMD_ID) 
									OR (PrinterSerial = @Serial AND PrinterMMD_ID = @MMD_ID) 
									OR (TerminalSerial = @Serial AND TerminalMMD_ID = @MMD_ID) )
			 BEGIN
				--in a kit, unpack it from PDA
				EXEC @ret = dbo.spPDAProcessKit 
					@UserID = @UserID,
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@IsFaultyOutOfBox = 0

				IF @ret <> 0
					GOTO RollBack_Handle

			 END

			SELECT @LastLocation = @JobFSP,
				@LastCondition = CASE WHEN LastCondition IN  (18, 19, 20) THEN LastCondition
							ELSE dbo.fnGetRevokedDeviceDefaultCondition(MMD_ID) END

			 FROM Equipment_Inventory
			WHERE Serial = @Serial
				AND MMD_ID = @MMD_ID


			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle


			SELECT @Note = 'NO LONGER RESERVED FOR ' + CAST(@JobID as varchar)

			--free up the device only when it exists
			EXEC @ret = dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = @LastCondition,
					@NewLocation = @LastLocation,
					@Note = @Note,
					@AddedBy = @FSPOperatorNumber

			 IF @ret <> 0 
				GOTO RollBack_Handle



		 END			

		--remove this record
		DELETE IMS_Job_Equipment
		 WHERE JobID = @JobID
			AND Serial = @Serial
			AND MMD_ID = @MMD_ID
			AND ActionID  = 1 --IN ('INSTALL', 'CONFIRM')
		
		SELECT @ret = @@ERROR
		IF @ret <> 0
			GOTO RollBack_Handle

	 END --@Action = 1  ''install new device

	--Remove existing device
	IF @Action = 2
	 BEGIN
		--remove this record
		DELETE IMS_Job_Equipment
		 WHERE JobID = @JobID
			AND Serial = @Serial
			AND MMD_ID = @MMD_ID
			AND ActionID = 2 -- IN ('REMOVE')
		
		SELECT @ret = @@ERROR
		IF @ret <> 0
			GOTO RollBack_Handle


	 END --@Action = 2  ''remove existing device

  END --ims job

 --Commit
 IF @bInCallerTransaction = 0
	COMMIT TRAN


Exit_Handle:

 RETURN @ret

RollBack_Handle:
 IF @bInCallerTransaction = 0
	ROLLBACK TRAN

 GOTO Exit_Handle

GO

Grant EXEC on spWebDelFSPJobEquipment to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebDelFSPJobEquipment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebDelFSPJobEquipment]
GO


Create Procedure dbo.spWebDelFSPJobEquipment 
	(
		@UserID int,
		@JobID bigint,
		@Serial varchar(32),
		@MMD_ID varchar(5),
		@Action smallint
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/10/03 11:25 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebDelFSPJobEquipment.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebDelFSPJobEquipment @UserID = @UserID, 
					@JobID = @JobID,
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@Action = @Action
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*
spWebDelFSPJobEquipment 199663, 20050303172
spWebDelFSPJobEquipment 199663, 310352
312691

select * from webcams.dbo.tblUSer

select * from calls
 where assignedto = 3011

select * from ims_jobs
 where bookedinstaller = 3011



*/
Go

Grant EXEC on spWebDelFSPJobEquipment to eCAMS_Role
Go
