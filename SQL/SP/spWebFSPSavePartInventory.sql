use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebFSPSavePartInventory' and type = 'p')
	drop proc spWebFSPSavePartInventory
go

create proc spWebFSPSavePartInventory (
	@UserID int,
	@PartNoList varchar(8000),
	@QtyList varchar(8000),
	@Mode int)
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 12/08/13 11:03 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebFSPSavePartInventory.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Update PartInventory
-- Mode: 1- for stock take
--		 2 - for parts ordering

as
 declare @FSPID int,
	@ret int,
	@MovementIDExternQtyOnHand INT,
	@StartedTransaction BIT,
	@PartID int,
	@Qty int,
	@Seq int,
	@FSPLocation int,
	@CurrentDateTime datetime,
	@PartIDList varchar(5000),
	@Subject varchar(500),
	@Msg varchar(max),
	@Email varchar(500)


 --init
 SET NOCOUNT ON
 SET @ret = 0
 SET @MovementIDExternQtyOnHand = 34 --EXTERNAL ADJUST QtyOnHand
 set @StartedTransaction = 0
 set @CurrentDateTime = GETDATE()
 
 SELECT @FSPID = InstallerID * (-1),
		@FSPLocation = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID


 --create temp table
 CREATE TABLE #myPartNo (Seq int identity, PartNo varchar(20) collate database_default)
 CREATE TABLE #myQty (Seq int identity, QtyOnHand int)


 --cache PartNos
 BEGIN TRY
 
	INSERT INTO #myPartNo (PartNo)
	  SELECT *
	   FROM dbo.fnConvertListToTable(@PartNoList)

	 
	--cache QtyOnHands
	INSERT INTO #myQty (QtyOnHand)
	  SELECT *
	   FROM dbo.fnConvertListToTable(@QtyList)


	if @Mode = 2  --Parts ordering, need to remove zero qty
	 begin
		delete l
		 from #myPartNo l JOIN #myQty q ON l.Seq = q.Seq
		 where q.QtyOnHand = 0
		
		delete #myQty
			where QtyOnHand = 0
	 end


 	IF @@TRANCOUNT = 0 
	BEGIN
		BEGIN TRANSACTION
		SET @StartedTransaction = 1
	END

	if @Mode = 2  --Parts ordering, need to remove zero qty
	 begin
		
	   --check abnormal order
		select @PartIDList = ''
		select @PartIDList = @PartIDList + PartID + 
				' [QtyOnHand:' + CAST(pv.QtyOnHand as varchar) + 
				', MinLevel:' + CAST(pv.MinReOrderLevel as varchar) + 
				', OrderQty:' + CAST(q.QtyOnHand as varchar) + '] ' + dbo.fnCRLF()
		 from vwIMSPartInventory pv join #myPartNo l on l.PartNo = pv.PartID collate database_default
								JOIN #myQty q ON l.Seq = q.Seq
		 where Location = @FSPLocation
			  and ((pv.MinReOrderLevel > 0 and pv.QtyOnHand > MinReOrderLevel * 1.5)
						or pv.QtyOnHand < 0)
			  

		if Len(@PartIDList) > 0
		 begin
			 IF EXISTS(SELECT 1 FROM tblControl WHERE Attribute = 'IsLiveDB' AND AttrValue = 'YES')
			  BEGIN
				SELECT @Email = 'StockTeam@Keycorp.net'
			  END
			 ELSE
			  BEGIN
				SELECT @Email = 'bli@keycorp.net'
			  END

			select @Subject = 'FSP Abnormal Parts Web Order Alert - ' + CAST(@FSPLocation as varchar) + ' @ ' + CONVERT(varchar, getdate(), 120)
			select @Msg = 'This alert is generated from WebCAMS when FSP makes an abnormal order on Parts. ' + dbo.fnCRLF() + @PartIDList
			exec msdb.dbo.sp_send_dbmail
				@profile_name = 'SQLMail',
				@recipients = @Email,
				@importance = 'High',
				@subject = @Subject,
				@body = @Msg,
				@exclude_query_output = 1		 
		 end
  	   
	 
		while exists(select 1 from #myPartNo)
		 begin
			select @PartID = p.PartID,
					@Qty =  q.QtyOnHand,
					@Seq = l.Seq 
			 from #myPartNo l JOIN #myQty q ON l.Seq = q.Seq
						join tblPart p on l.PartNo = p.PartNo collate database_default

			exec dbo.spPIMRaiseStockRequestFSP
						@PartID = @PartID
						,@Quantity = @Qty
						,@LoggedBy = @FSPID
						,@Location = 300
						,@ToLocation = @FSPLocation

			delete #myPartNo where Seq = @Seq
			delete #myQty where Seq = @Seq
		 end
	 end  --if @Mode = 2  --Parts ordering
	else
	 begin
		--create part movement log
		INSERT INTO tblPartMovementLog(Location, 
					PartID, 
					Quantity, 
					RefNo, 
					MovementID, 
					XMLData, 
					LoggedDateTime, 
					LoggedBy)
			SELECT i.Location, 
				p.PartID, 
				ISNULL(q.QtyOnHand, 0) - ISNULL(i.QtyOnHand, 0), 
				NULL, 
				@MovementIDExternQtyOnHand, 
				dbo.fnBuildXmlData(dbo.fnBuildXmlData('','OldQtyOnHand',CAST(i.QtyOnHand AS VARCHAR)),'NewQtyOnHand',CAST(q.QtyOnHand AS VARCHAR)), 
				@CurrentDateTime, 
				@FSPID
			FROM vwIMSPartInventory i JOIN #myPartNo l ON i.PartID = l.PartNo collate database_default
					JOIN #myQty q ON l.Seq = q.Seq
					join tblPart p on p.PartNo = l.PartNo collate database_default
			WHERE i.Location = @FSPLocation
					and i.QtyOnHand <> q.QtyOnHand

			--update part usage for those parts/locations that already have a record 
			UPDATE pu
			SET pu.TotalAdjusted = ISNULL(pu.TotalAdjusted,0) + (ISNULL(q.QtyOnHand, 0) - ISNULL(i.QtyOnHand, 0))
				,pu.LastUpdated = @CurrentDateTime
			FROM vwIMSPartInventory i 
			INNER JOIN #myPartNo l ON i.PartID = l.PartNo collate database_default
			INNER JOIN #myQty q ON l.Seq = q.Seq
			INNER JOIN tblPart p on p.PartNo = l.PartNo collate database_default
			INNER JOIN tblPartUsage pu On pu.Location = i.Location AND pu.PartID = p.PartID
			WHERE i.Location = @FSPLocation AND i.QtyOnHand <> q.QtyOnHand

			--insert new part usage records for those parts/locations that do not have a record 			
			INSERT INTO tblPartUsage(Location, PartID, TotalAdjusted, TotalOrdered, TotalReceived, TotalUsage, TotalToTest, TotalTestedOK, TotalTestedNotOK, LastUpdated)
			SELECT	i.Location 
					,p.PartID
					,(ISNULL(q.QtyOnHand, 0) - ISNULL(i.QtyOnHand, 0))
					,0
					,0
					,0
					,0
					,0
					,0
					,@CurrentDateTime
			FROM vwIMSPartInventory i 
			INNER JOIN #myPartNo l ON i.PartID = l.PartNo collate database_default
			INNER JOIN #myQty q ON l.Seq = q.Seq
			INNER JOIN tblPart p on p.PartNo = l.PartNo collate database_default
			LEFT OUTER JOIN tblPartUsage pu On pu.Location = i.Location AND pu.PartID = p.PartID
			WHERE i.Location = @FSPLocation AND i.QtyOnHand <> q.QtyOnHand		 
			AND pu.Location IS NULL

		 --Increase tblIMSPartInventory stock level
		 UPDATE i
			SET i.QtyOnHand = q.QtyOnHand
		  FROM vwIMSPartInventory i JOIN #myPartNo l ON i.PartID = l.PartNo collate database_default
					JOIN #myQty q ON l.Seq = q.Seq
		  WHERE i.Location = @FSPLocation
	 end --if @Mode = 1 parts stocktake

 
	IF @StartedTransaction = 1 	
		COMMIT TRANSACTION	
END TRY
BEGIN CATCH
	IF @StartedTransaction = 1 
		ROLLBACK TRANSACTION
	
	EXEC master.dbo.upGetErrorInfo

END CATCH


/*
exec spWebFSPSavePartInventory @UserID=199649,@PartNoList='CC797,GBSSK,NABIM,NHLTH,NXTRS',@QtyList='226,19,10,12,8'


*/

Go

GRANT EXEC ON spWebFSPSavePartInventory TO CALLSYSUSERS, eCAMS_Role
go

use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebFSPSavePartInventory' and type = 'p')
	drop proc spWebFSPSavePartInventory
go

create proc spWebFSPSavePartInventory (
	@UserID int,
	@PartNoList varchar(8000),
	@QtyList varchar(8000),
	@Mode int)
as
DECLARE @ret int
 SET NOCOUNT ON
 EXEC @ret = CAMS.dbo.spWebFSPSavePartInventory @UserID = @UserID,
				@PartNoList = @PartNoList,
				@QtyList = @QtyList,
				@Mode = @Mode


 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
Go

GRANT EXEC ON spWebFSPSavePartInventory TO eCAMS_Role
go



