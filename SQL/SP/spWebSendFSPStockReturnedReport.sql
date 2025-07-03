Use CAMS
Go

Alter Procedure dbo.spWebSendFSPStockReturnedReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 10 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/03/16 11:31 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebSendFSPStockReturnedReport.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Send FSP Stock Returned Report for the batch specified
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
 SELECT @CRLF =  '<br/>',  --CHAR(13) + CHAR(10),
	@TAB = '&nbsp;&nbsp;&nbsp;&nbsp;' --CHAR(9)

 --verify user
 IF NOT EXISTS(SELECT 1 FROM tblFSPStockReturned WHERE UserID = @UserID AND BatchID = @BatchID)
  BEGIN
	--the batch is not belong to this user, return
	RETURN 
  END
 --Get Location for the user
 SELECT @FSPLocation = r.FromLocation,
	@FSPStockAddress = 'FSPStockReturnedScan@keycorp.net;' + 
				CASE WHEN Master.dbo.fnIsValidEmail(ISNULL(l.StockAddress, '')) = 1 THEN l.StockAddress ELSE '' END,
	@Subject = 'FSP Stock Returned Report (' + CASE WHEN r.SourceID = 'P' THEN 'PDA' ELSE 'Web' END + ' Scanned by ' + CAST(@FSPLocation as varchar) + '-' + u.UserName + ') ConNote: ' + ISNULL(r.ReferenceNo, '') + ', NoOfBox: ' + CAST(ISNULL(r.NoOfBox, '') as varchar),
	@LogDate = r.LogDate
   FROM tblFSPStockReturned r JOIN Locations_Master l ON r.FromLocation = l.Location
				JOIN WebCAMS.dbo.tblUser u ON u.UserID = r.UserID
  WHERE r.BatchID = @BatchID


 SELECT @FSPOperatorNumber = -@FSPLocation


 IF EXISTS(SELECT 1 FROM tblControl WHERE Attribute = 'IsLiveDB' AND AttrValue = 'YES')
  BEGIN
	SELECT @FSPStockAddress = @FSPStockAddress 
  END
 ELSE
  BEGIN
	SELECT @FSPStockAddress = 'bli@keycorp.net'
  END


 SELECT @Msg = 'Stock Returned Report' + @CRLF

 --cache StockReturnedLog
 SELECT Serial,
	MMD_ID,
	CaseID
   INTO #myLog
  FROM tblFSPStockReturnedLog
 WHERE BatchID = @BatchID

 --device scanned
 SELECT @Count = COUNT(*)
	FROM #myLog

 SELECT @Msg = @Msg + 'Devices scanned: ' + CAST(@Count as Varchar) + @CRLF

 --device updated
 SELECT @Count = COUNT(*)
	FROM #myLog
	WHERE CaseID IN (1, 3)

 SELECT @Msg = @Msg + 'Devices updated: ' + CAST(@Count as Varchar) + @CRLF


 --device NOT updated
 SELECT @Count = COUNT(*)
	FROM #myLog
	WHERE CaseID NOT IN (1, 3)

 SELECT @Msg = @Msg + 'Devices not updated: ' + CAST(@Count as Varchar) + @CRLF

 IF @Count > 0 
  BEGIN
	 DECLARE curDevice CURSOR LOCAL FORWARD_ONLY FOR
		SELECT l.Serial, ISNULL(l.MMD_ID, ''), c.CaseDescription
		FROM #myLog l JOIN tblFSPStockReturnedCase c ON l.CaseID = c.CaseID
		WHERE l.CaseID NOT IN (1, 3)

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

Grant EXEC on spWebSendFSPStockReturnedReport to eCAMS_Role
Go


Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebSendFSPStockReturnedReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebSendFSPStockReturnedReport]
GO


Create Procedure dbo.spWebSendFSPStockReturnedReport 
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

 EXEC Cams.dbo.spWebSendFSPStockReturnedReport 
		@UserID = @UserID,
		@BatchID = @BatchID

/*


spWebSendFSPStockReturnedReport @UserID = 199638,
		@BatchID = 30
*/
Go

Grant EXEC on spWebSendFSPStockReturnedReport to eCAMS_Role
Go
