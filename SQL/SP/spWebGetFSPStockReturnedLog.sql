
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockReturnedLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockReturnedLog]
GO


Create Procedure dbo.spWebGetFSPStockReturnedLog 
	(
		@UserID int,
		@BatchID int,
		@From int
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:30 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockReturnedLog.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get FSP stock returned log details
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
	FROM tblFSPStockReturnedLog l JOIN tblFSPStockReturned r ON l.BatchID = r.BatchID
					JOIN tblFSPStockReturnedCase c ON l.CaseID = c.CaseID
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

Grant EXEC on spWebGetFSPStockReturnedLog to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockReturnedLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockReturnedLog]
GO


Create Procedure dbo.spWebGetFSPStockReturnedLog 
	(
		@UserID int,
		@BatchID int,
		@From int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockReturnedLog.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockReturnedLog @UserID = @UserID, 
				@BatchID = @BatchID,
				@From = @From

/*

exec dbo.spWebGetFSPStockReturnedLog @UserID = 199663, 
				@BatchID = 708,
				@From = 1

select * from tblFSPStockReturned


select * from webcams.dbo.tblUser



*/
GO

Grant EXEC on spWebGetFSPStockReturnedLog to eCAMS_Role
Go
