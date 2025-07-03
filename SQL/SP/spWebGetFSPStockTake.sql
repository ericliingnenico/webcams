Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockTake]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockTake]
GO


Create Procedure dbo.spWebGetFSPStockTake 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int,
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/06/10 10:35 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockTake.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get FSP stocktake batch details

 SET NOCOUNT ON


 --verify if the depot is in user's FSP group
 IF EXISTS(SELECT 1 FROM tblFSPStockTake 
			WHERE  UserID = @UserID 
				AND SourceID = ISNULL(@SourceID, SourceID) 
				AND BatchID = @BatchID
				AND Status = ISNULL(@Status, Status))
  BEGIN
	SELECT * FROM tblFSPStockTake 
		WHERE  UserID = @UserID
			AND SourceID = ISNULL(@SourceID, SourceID) 
			AND BatchID = @BatchID
			AND Status = ISNULL(@Status, Status)
  END 
 ELSE
  BEGIN
	SELECT * FROM tblFSPStockTake 
		WHERE  UserID = @UserID
			AND SourceID = ISNULL(@SourceID, SourceID) 
			AND Status = ISNULL(@Status, Status)
  END 

GO

Grant EXEC on spWebGetFSPStockTake to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockTake]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockTake]
GO


Create Procedure dbo.spWebGetFSPStockTake 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int,
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockTake.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockTake @UserID = @UserID, 
				@SourceID = @SourceID,
				@BatchID = @BatchID,
				@Status = @Status

/*

declare @BatchID int

exec dbo.spWebGetFSPStockTake @UserID = 199663, 
				@SourceID = 'P',
				@BatchID = 11,
				@Status = 'O'
select @BatchID

select * from tblFSPStockTake


*/
GO

Grant EXEC on spWebGetFSPStockTake to eCAMS_Role
Go
