Use CAMS
Go

Alter Procedure dbo.spWebSendFSPStockReceivedReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 16 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/03/16 11:31 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebSendFSPStockReceivedReport.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Send FSP Stock Received Report for the batch specified
---#3877 (UPDATING SERIALS NOT IN TRANSIT TO FSP'S) CaseID = 3 is exception

DECLARE @ret int,
	@Serial varchar(32),
	@MMD_ID varchar(5),
	@DateIn datetime,
	@CaseDescription varchar(255),
	@FSPLocation int,
	@FSPStockAddress varchar(500),
	@Count int,
	@FSPOperatorNumber int,
	@Msg varchar(max),
	@CRLF varchar(10),
	@TAB varchar(50),
	@Subject varchar(200),
	@LogDate datetime

 --init
 SELECT @CRLF = '<br/>',  --CHAR(13) + CHAR(10),
	@TAB = '&nbsp;&nbsp;&nbsp;&nbsp;' --CHAR(9)

 --verify user
 IF NOT EXISTS(SELECT 1 FROM tblTMPFSPStockReceived WHERE UserID = @UserID AND BatchID = @BatchID)
  BEGIN
	--the batch is not belong to this user, return
	RETURN 
  END

 --Get Location for the user
 SELECT @FSPLocation = r.Depot,
	@FSPStockAddress = 'FSPStockReceivedScan@keycorp.net;' + 
				CASE WHEN Master.dbo.fnIsValidEmail(ISNULL(l.StockAddress, '')) = 1 THEN l.StockAddress ELSE '' END,
	@Subject = 'FSP Stock Received Report (' + CASE WHEN r.SourceID = 'P' THEN 'PDA' ELSE 'Web' END + ' Scanned by ' + CAST(@FSPLocation as varchar) + '-' + u.UserName + ')',
	@LogDate = r.LogDate
   FROM tblTMPFSPStockReceived r WITH (NOLOCK) JOIN Locations_Master l WITH (NOLOCK) ON r.Depot = l.Location
				JOIN WebCAMS.dbo.tblUser u ON u.UserID = r.UserID
  WHERE r.BatchID = @BatchID


 SELECT @FSPOperatorNumber = -@FSPLocation


 IF EXISTS(SELECT 1 FROM tblControl WHERE Attribute = 'IsLiveDB' AND AttrValue = 'YES')
  BEGIN
	SELECT @FSPStockAddress = @FSPStockAddress ----+ ';bl100@eftpos.com.au'
  END
 ELSE
  BEGIN
	SELECT @FSPStockAddress = 'bli@keycorp.net'
  END


 SELECT @Msg = 'Stock Received Report' + @CRLF

 --cache StockReceivedLog
 SELECT Serial,
	MMD_ID,
	CaseID
   INTO #myLog
  FROM tblTMPFSPStockReceivedLog WITH (NOLOCK)
 WHERE BatchID = @BatchID

 --cache inventory
 SELECT Serial,
	MMD_ID,
	DateIn
   INTO #myDevice
  FROM Equipment_Inventory
 WHERE Condition = 2  
	AND Location = @FSPLocation

 --device scanned
 SELECT @Count = COUNT(*)
	FROM #myLog

 SELECT @Msg = @Msg + 'Devices scanned: ' + CAST(@Count as Varchar) + @CRLF

 --device updated
 SELECT @Count = COUNT(*)
	FROM #myLog
	WHERE CaseID IN (1)

 SELECT @Msg = @Msg + 'Devices updated: ' + CAST(@Count as Varchar) + @CRLF


 --device NOT updated
 SELECT @Count = COUNT(*)
	FROM #myLog
	WHERE CaseID NOT IN (1)

 SELECT @Msg = @Msg + 'Devices not updated: ' + CAST(@Count as Varchar) + @CRLF

 IF @Count > 0 
  BEGIN
	 DECLARE curDevice CURSOR LOCAL FORWARD_ONLY FOR
		SELECT l.Serial, ISNULL(l.MMD_ID, ''), c.CaseDescription
		FROM #myLog l JOIN tblFSPStockReceivedCase c ON l.CaseID = c.CaseID
		WHERE l.CaseID NOT IN (1)

	 OPEN curDevice
	 WHILE 1 = 1 
	  BEGIN
		FETCH NEXT FROM curDevice INTO @Serial, @MMD_ID, @CaseDescription
		IF @@FETCH_STATUS <> 0
			BREAK
	
		SELECT @Msg = @Msg + @TAB + LTRIM(@Serial) + ' / ' + @MMD_ID + ' - ' + @CaseDescription + @CRLF

	  END
	
	 CLOSE curDevice
	 DEALLOCATE curDevice
  END


 --other outstanding device
 --shipped this day
 SELECT @Count = Count(*)
  FROM #myDevice
 WHERE CONVERT(Varchar, DateIn, 112) = CONVERT(Varchar, @LogDate, 112)

 SELECT @Msg = @Msg + @CRLF + 'Other devices outstanding:' + @CRLF +
			'Shipped on the same date as device scanned: ' + CAST(@Count as Varchar) + @CRLF


 IF @Count > 0
  BEGIN
	DECLARE curDevice CURSOR LOCAL FORWARD_ONLY FOR
		SELECT Serial, MMD_ID, DateIn
		 FROM #myDevice
		 WHERE CONVERT(Varchar, DateIn, 112) = CONVERT(Varchar, @LogDate, 112)

	OPEN curDevice

	WHILE 1 = 1
	 BEGIN
		FETCH NEXT FROM curDevice INTO @Serial, @MMD_ID, @DateIn

		IF @@FETCH_STATUS <> 0
			BREAK

		SELECT @Msg = @Msg + @TAB + LTRIM(@Serial) + ' / ' + @MMD_ID + ' - Despatched ' + CONVERT(varchar, @DateIn, 103) + @CRLF


	 END

	CLOSE curDevice
	DEALLOCATE curDevice
  END

 --other outstanding shipped on other dates
 SELECT @Count = COUNT(*)
   FROM #myDevice
  WHERE CONVERT(Varchar, DateIn, 112) <> CONVERT(Varchar, @LogDate, 112)



 SELECT @Msg = @Msg + @CRLF + 'Shipped on other dates: ' + CAST(@Count as Varchar) + @CRLF

 IF @Count > 0
  BEGIN
	DECLARE curDevice CURSOR LOCAL FORWARD_ONLY FOR
		SELECT Serial, MMD_ID, DateIn
		  FROM #myDevice
		  WHERE CONVERT(Varchar, DateIn, 112) <> CONVERT(Varchar, @LogDate, 112)

	OPEN curDevice
	
	WHILE 1 = 1
	 BEGIN
		FETCH NEXT FROM curDevice INTO @Serial, @MMD_ID, @DateIn

		IF @@FETCH_STATUS <> 0
			BREAK

		SELECT @Msg = @Msg + @TAB + LTRIM(@Serial) + ' / ' + @MMD_ID + ' - Despatched ' + CONVERT(varchar, @DateIn, 103) + @CRLF


	 END

	CLOSE curDevice
	DEALLOCATE curDevice
  END


 --send email

--EXEC msdb.dbo.sp_send_dbmail
--    @profile_name = 'SQLMail',
--    @recipients = @FSPStockAddress,
--	@importance = 'High',
--    @subject = @Subject,
--	@body = @Msg

 exec @ret = spAddMailTask 
		@To = @FSPStockAddress,
		@Cc = null,
		@Bcc = null,
		@From = 'sqlmail@keycorp.net',
		@ReplyTo = null,
		@Subject = @Subject,
		@Body = @Msg,
		@Type = 'Standard',
		@Parameters = null,
		@Priority = 3,  --1,2,3
		@State = 0,
		@Expiry = null,
		@AttachmentFilename = null,
		@AttachmentMimeType = null,
		@AttachmentUTFContent = null,
		@UserID = @UserID

--print @Msg
 RETURN @@ERROR

GO

Grant EXEC on spWebSendFSPStockReceivedReport to eCAMS_Role
Go


Use WebCAMS
Go

Alter Procedure dbo.spWebSendFSPStockReceivedReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDACloseJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON

 EXEC Cams.dbo.spWebSendFSPStockReceivedReport 
		@UserID = @UserID,
		@BatchID = @BatchID

/*


spWebSendFSPStockReceivedReport @UserID = 199638,
		@BatchID = 30
*/
Go

Grant EXEC on spWebSendFSPStockReceivedReport to eCAMS_Role
Go
