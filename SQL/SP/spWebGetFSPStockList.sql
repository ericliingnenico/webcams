
Use CAMS
Go

Alter Procedure dbo.spWebGetFSPStockList 
	(
		@UserID int,
		@FSPID int,
		@Conditions varchar(100),
		@From tinyint,
		@TransitToEE bit
	)
	AS
--<!--$$Revision: 16 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 26/05/10 9:10 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockList.sql $-->
--<!--$$NoKeywords: $-->
---Get stock list for a FSP (If no FSP passed in, use FSP ID from WebCAMS.dbo.tblUser table.)
 DECLARE @InstallerID int,
	@BaseLocation int

 --get base location
 SELECT @BaseLocation = dbo.fnGetMyBaseLocation()

 --get user details
 SELECT @InstallerID = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 IF @FSPID IS NOT NULL
	SELECT @InstallerID = CASE WHEN EXISTS(SELECT 1 FROM dbo.fnGetLocationChildrenExt(@InstallerID) WHERE Location = @FSPID) THEN @FSPID
				ELSE NULL END


  SELECT * 
   INTO #myLocChildren
   FROM dbo.fnGetLocationChildrenExt(@InstallerID)

 IF @From = 1  --from desk top web
  BEGIN
	IF @TransitToEE = 1
	 BEGIN
		SELECT ei.Serial,
			ei.MMD_ID,
			ei.ClientID,
			ei.Location,
			Status = dbo.fnParseFSPStockCondition(ei.Condition),
			SoftwareVer = ei.SoftwareVersion,
			HardwareVer = ei.HardwareRevision,
			Firmware = ei.Firmware,
			ei.DateIn,
			ei.Note
		  FROM Equipment_Inventory ei JOIN #myLocChildren l on ei.LastLocation = l.Location
		 WHERE ei.Location = @BaseLocation 
			AND ei.Condition = 2
		ORDER BY ei.DateIn
	 END
	ELSE
	 BEGIN
		--transit to FSP
		IF @Conditions = '2' 
		 BEGIN
			SELECT ei.Serial,
					ei.MMD_ID,
					ei.ClientID,
					ei.Location,
					Status = dbo.fnParseFSPStockCondition(ei.Condition),
					SoftwareVer = ei.SoftwareVersion,
					HardwareVer = ei.HardwareRevision,
					Firmware = ei.Firmware,
					ei.DateIn,
					cast('' as varchar(30)) as ConNote,
					ei.Note
			  INTO #MyList
			  FROM Equipment_Inventory ei JOIN #myLocChildren l on ei.Location = l.Location
			 WHERE ei.Condition IN (2)
			ORDER BY ei.DateIn

			--Get ConNote from tblFSPStockReceived
			UPDATE t
				SET t.ConNote = r.ReferenceNo
			 FROM #MyList t JOIN tblFSPStockReceivedLog l ON t.Serial = l.Serial and t.MMD_ID = l.MMD_ID AND l.ScanAtArrival IS NULL
							JOIN tblFSPStockReceived r ON l.BatchID = r.BatchID
			--return 
			SELECT * FROM #MyList
			
		 END
		ELSE
		 BEGIN
			SELECT ei.Serial,
				ei.MMD_ID,
				ei.ClientID,
				ei.Location,
				Status = dbo.fnParseFSPStockCondition(ei.Condition),
				SoftwareVer = ei.SoftwareVersion,
				HardwareVer = ei.HardwareRevision,
				Firmware = ei.Firmware,
				ei.DateIn,
				ei.Note
			  FROM Equipment_Inventory ei JOIN #myLocChildren l on ei.Location = l.Location
			 WHERE ei.Condition IN (SELECT * from dbo.fnConvertListToTable(@Conditions))
			ORDER BY ei.DateIn
		 END
	 END
	

  END --from desktop web
 ELSE
  --from PDA web
  BEGIN
	IF @TransitToEE = 1
	 BEGIN
		SELECT ei.Serial,
			ei.MMD_ID,
			ei.ClientID,
			ei.Location,
			ei.Condition,
			SoftwareVer = ei.SoftwareVersion,
			HardwareVer = ei.HardwareRevision,
			Firmware = ei.Firmware,
			ei.DateIn
		  FROM Equipment_Inventory ei JOIN #myLocChildren l on ei.LastLocation = l.Location
		 WHERE ei.Location = @BaseLocation 
			AND ei.Condition = 2
		ORDER BY ei.DateIn
	 END
	ELSE
	 BEGIN
		SELECT ei.Serial,
			ei.MMD_ID,
			ei.ClientID,
			ei.Location,
			ei.Condition,
			SoftwareVer = ei.SoftwareVersion,
			HardwareVer = ei.HardwareRevision,
			Firmware = ei.Firmware,
			ei.DateIn
		  FROM Equipment_Inventory ei JOIN #myLocChildren l on ei.Location = l.Location
		 WHERE ei.Condition IN (SELECT * from dbo.fnConvertListToTable(@Conditions))
		ORDER BY ei.DateIn
	 END
	
  END

GO

Grant EXEC on spWebGetFSPStockList to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPStockList 
	(
		@UserID int,
		@FSPID int,
		@Conditions varchar(100),
		@From tinyint,
		@TransitToEE bit
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockList @UserID = @UserID, 
					@FSPID = @FSPID, 
					@Conditions = @Conditions, 
					@From = @From,
					@TransitToEE = @TransitToEE

/*
select * from webcams.dbo.tblUser

spWebGetFSPStockList 199512, null, '2,19,20',1, 1
spWebGetFSPStockList 199512, 3001, null,1


*/
Go

Grant EXEC on spWebGetFSPStockList to eCAMS_Role
Go