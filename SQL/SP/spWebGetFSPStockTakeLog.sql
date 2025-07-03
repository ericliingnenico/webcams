Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockTakeLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockTakeLog]
GO


Create Procedure dbo.spWebGetFSPStockTakeLog 
	(
		@UserID int,
		@BatchID int,
		@From int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/06/10 10:35 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockTakeLog.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get FSP stocktake log details
-- 10/08/2007 Bo added order by LogID due to SQL2005/ADO did not return dataset in the order

 SET NOCOUNT ON

 CREATE TABLE #srl (
	Seq int identity, 
	Serial varchar(32), 
	DeviceName varchar(80), 
	Status varchar(20),
	CaseDescription varchar(255))


 INSERT INTO #srl (
	Serial,
	DeviceName,
	Status,
	CaseDescription)
  SELECT 
	l.Serial,
	LTRIM(ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '')),
	c.Status,
	c.CaseDescription
	FROM tblFSPStockTakeLog l JOIN tblFSPStockTake r ON l.BatchID = r.BatchID
					JOIN tblFSPStockTakeCase c ON l.CaseID = c.CaseID
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

Grant EXEC on spWebGetFSPStockTakeLog to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockTakeLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockTakeLog]
GO


Create Procedure dbo.spWebGetFSPStockTakeLog 
	(
		@UserID int,
		@BatchID int,
		@From int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockTakeLog.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockTakeLog @UserID = @UserID, 
				@BatchID = @BatchID,
				@From = @From

/*

exec dbo.spWebGetFSPStockTakeLog @UserID = 199649, 
				@BatchID = 1,
				@From = 1

select * from tblFSPStockTake


select * from webcams.dbo.tblUser
 where emailaddress = 'dev101'
 


*/
GO

Grant EXEC on spWebGetFSPStockTakeLog to eCAMS_Role
Go
