
Use CAMS
Go

Alter Procedure dbo.spWebAddFSPTaskDevice 
	(
		@UserID int,
		@TaskID int,
		@Serial varchar(32),
		@MMD_ID varchar(5)
	)
	AS
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/09/07 2:11p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFSPTaskDevice.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @InstallerID int,
	@Count int,
	@ClientID varchar(3),
	@FSPOperator int,
	@ToLocation int,

	@JobID bigint,
	
	@Require3DES bit,
	@RequireEMV bit,
	@COMPLIANCE_3DES tinyint,
	@COMPLIANCE_EMV tinyint



	
 --init
 SELECT @Require3DES = 0,
	@RequireEMV = 0,
	@COMPLIANCE_3DES = 1,
	@COMPLIANCE_EMV = 2




 --Get FSPID
 SELECT @InstallerID = InstallerID,
	@FSPOperator = -InstallerID
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID

 SELECT @Serial = UPPER(dbo.fnLeftPadSerial(@Serial))

 IF EXISTS(SELECT 1 FROM tblTask t JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON t.AssignedTo = l.Location
		WHERE  TaskID = @TaskID)
  BEGIN
	--get task info
	SELECT @ClientID = ISNULL(j.ClientID, c.ClientID),
		@ToLocation = t.ToLocation,
		@JobID = t.JobID
		FROM tblTask t LEFT OUTER JOIN IMS_Jobs j ON j.JobID = t.JobID AND t.SourceID = 1
			LEFT OUTER JOIN Calls c ON CAST(c.CallNumber as BigInt) = t.JobID AND t.SourceID = 2
		WHERE t.TaskID = @TaskID


	 --get device compliance requirements, since we don't know MMD_ID in some cases, so get compliance requirment at job level
	 SELECT @Require3DES = dbo.fnJobRequireCompliantDevice(@JobID, @COMPLIANCE_3DES),
		@RequireEMV = dbo.fnJobRequireCompliantDevice(@JobID, @COMPLIANCE_EMV)


	SELECT @Count = COUNT(*) 
		FROM Equipment_Inventory ei JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
								AND ISNULL(ei.Is3DES, 0) = CASE WHEN @Require3DES = 1 AND m.Is3DES = 1 THEN 1 ELSE ISNULL(ei.Is3DES, 0) END
								AND ISNULL(ei.IsEMV, 0) = CASE WHEN @RequireEMV = 1 AND m.IsEMV = 1 THEN 1 ELSE ISNULL(ei.IsEMV, 0) END

			WHERE ei.Serial = @Serial 
				AND ei.ClientID = @ClientID
				AND ei.MMD_ID = ISNULL(@MMD_ID, ei.MMD_ID)
				AND ei.Condition IN (18, 19, 20, 2)



	--if the device exists with unique device
	IF @Count = 1
	 BEGIN
		--get MMD_ID if not provided
		IF @MMD_ID IS NULL
			SELECT @MMD_ID = MMD_ID 
				FROM Equipment_Inventory 
				WHERE Serial = @Serial 
					AND ClientID = @ClientID
					AND Condition IN (18, 19, 20, 2)
		

		

		--still unique, reserve the stock
		EXEC dbo.spAddTaskEquipmentAndReserveStock
				@TaskID	= @TaskID,
				@Serial	= @Serial,
				@MMD_ID	= @MMD_ID,
				@Location = @ToLocation,
				@NewCondition = 9,
				@Operator = @FSPOperator

		--regardless how many device, the proc will return device in inventory
		--use ^ as separator, since it is not printable on barcode128
		SELECT ei.Serial, 
			ei.MMD_ID, 
			LTRIM(ei.Serial) + '^' + ei.MMD_ID as SerialMMD_ID,
			m.Maker + ' ' + m.Model + ' ' + m.Device + '-' + LTRIM(ei.Serial) as DeviceDescription 
		  FROM Equipment_Inventory ei JOIN M_M_D m ON ei.MMD_ID = m.MMD_ID
		 WHERE ei.Serial = @Serial AND ei.ClientID = @ClientID
					AND ei.MMD_ID = ISNULL(@MMD_ID, ei.MMD_ID)
	
	 END
	ELSE
	 BEGIN
		--regardless how many device, the proc will return device in inventory
		--use ^ as separator, since it is not printable on barcode128
		SELECT ei.Serial, 
			ei.MMD_ID, 
			LTRIM(ei.Serial) + '^' + ei.MMD_ID as SerialMMD_ID,
			m.Maker + ' ' + m.Model + ' ' + m.Device + '-' + LTRIM(ei.Serial) as DeviceDescription 
		FROM Equipment_Inventory ei JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
								AND ISNULL(ei.Is3DES, 0) = CASE WHEN @Require3DES = 1 AND m.Is3DES = 1 THEN 1 ELSE ISNULL(ei.Is3DES, 0) END
								AND ISNULL(ei.IsEMV, 0) = CASE WHEN @RequireEMV = 1 AND m.IsEMV = 1 THEN 1 ELSE ISNULL(ei.IsEMV, 0) END

			WHERE ei.Serial = @Serial 
				AND ei.ClientID = @ClientID
				AND ei.MMD_ID = ISNULL(@MMD_ID, ei.MMD_ID)
				AND ei.Condition IN (18, 19, 20, 2)
	
	 END
  END

GO

Grant EXEC on spWebAddFSPTaskDevice to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebAddFSPTaskDevice 
	(
		@UserID int,
		@TaskID int,
		@Serial varchar(32),
		@MMD_ID varchar(5)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFSPTaskDevicei.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebAddFSPTaskDevice @UserID = @UserID, 
				@TaskID = @TaskID,
				@Serial = @Serial,
				@MMD_ID = @MMD_ID

/*

spWebAddFSPTaskDevice 199512, 1670, 'bl101', null, 1, 'abc', 'test'

SELECT * FROM tblTask t JOIN dbo.fnGetLocationChildrenExt(3001) l ON t.ToLocation = l.Location
		WHERE  TaskID = 1672

*/
GO

Grant EXEC on spWebAddFSPTaskDevice to eCAMS_Role
Go
