Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockTakeTarget]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockTakeTarget]
GO


Create Procedure dbo.spWebGetFSPStockTakeTarget 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/02/12 16:51 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockTakeTarget.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get FSP stocktake list

 SET NOCOUNT ON
 DECLARE @FSP int


 select @FSP = InstallerID
   from webCAMS.dbo.tblUser
   where UserID = @UserID
 
 select * 
	from tblFSPStockTakeTarget 
		where (FSP = @FSP OR FSP = -1)
			and StockTakeDate>=CONVERT(varchar, getdate(), 107);
 
GO

Grant EXEC on spWebGetFSPStockTakeTarget to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockTakeTarget]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockTakeTarget]
GO


Create Procedure dbo.spWebGetFSPStockTakeTarget 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockTakeTarget.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockTakeTarget @UserID = @UserID


GO

Grant EXEC on spWebGetFSPStockTakeTarget to eCAMS_Role
Go
