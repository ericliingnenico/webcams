
Use CAMS
Go

Alter Procedure dbo.spWebGetFSPStockReceivedLog 
	(
		@UserID int,
		@BatchID int,
		@From int
	)
	AS
--<!--$$Revision: 11 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:30 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockReceivedLog.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get FSP stock received log details
-- 10/08/2007 Bo added order by LogID due to SQL2005/ADO did not return dataset in the order

 SET NOCOUNT ON

 CREATE TABLE #srl (
	Seq int identity, 
	Serial varchar(32) collate database_default, 
	DeviceName varchar(80) collate database_default, 
	[Status] varchar(20) collate database_default,
	CaseDescription varchar(255) collate database_default)


 INSERT INTO #srl (
	Serial,
	DeviceName,
	[Status],
	CaseDescription)
  SELECT 
	l.Serial,
	LTRIM(ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '')),
	c.[Status],
	c.CaseDescription
	FROM tblTMPFSPStockReceivedLog l JOIN tblTMPFSPStockReceived r ON l.BatchID = r.BatchID
					JOIN tblFSPStockReceivedCase c ON l.CaseID = c.CaseID
					LEFT OUTER JOIN M_M_D m ON l.MMD_ID = m.MMD_ID
	WHERE  r.UserID = @UserID
		AND r.BatchID = @BatchID
    ORDER BY l.LogID 

 IF @From = 1 --desktop
  BEGIN
	SELECT * FROM #srl ORDER By Seq DESC
  END
 ELSE
  BEGIN
	SELECT * FROM #srl ORDER By Seq DESC
  END
GO

Grant EXEC on spWebGetFSPStockReceivedLog to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPStockReceivedLog 
	(
		@UserID int,
		@BatchID int,
		@From int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockReceivedLog.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockReceivedLog @UserID = @UserID, 
				@BatchID = @BatchID,
				@From = @From

/*

exec dbo.spWebGetFSPStockReceivedLog @UserID = 199663, 
				@BatchID = 708,
				@From = 1

select * from tblTMPFSPStockReceived


select * from webcams.dbo.tblUser



*/
GO

Grant EXEC on spWebGetFSPStockReceivedLog to eCAMS_Role
Go
