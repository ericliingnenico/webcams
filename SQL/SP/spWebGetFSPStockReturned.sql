
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockReturned]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockReturned]
GO


Create Procedure dbo.spWebGetFSPStockReturned 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int,
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/11/05 4:06p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockReturned.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get FSP stock returned batch details

 SET NOCOUNT ON

 --verify if the depot is in user's FSP group
 IF EXISTS(SELECT 1 FROM tblFSPStockReturned 
			WHERE  UserID = @UserID 
				AND SourceID = ISNULL(@SourceID, SourceID) 
				AND BatchID = @BatchID
				AND Status = ISNULL(@Status, Status))
  BEGIN
	SELECT * FROM tblFSPStockReturned 
		WHERE  UserID = @UserID
			AND SourceID = ISNULL(@SourceID, SourceID) 
			AND BatchID = @BatchID
			AND Status = ISNULL(@Status, Status)
  END 
 ELSE
  BEGIN
	SELECT * FROM tblFSPStockReturned 
		WHERE  UserID = @UserID
			AND SourceID = ISNULL(@SourceID, SourceID) 
			AND Status = ISNULL(@Status, Status)
  END 

GO

Grant EXEC on spWebGetFSPStockReturned to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockReturned]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockReturned]
GO


Create Procedure dbo.spWebGetFSPStockReturned 
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
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockReturned.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockReturned @UserID = @UserID, 
				@SourceID = @SourceID,
				@BatchID = @BatchID,
				@Status = @Status

/*

declare @BatchID int

exec dbo.spWebGetFSPStockReturned @UserID = 199663, 
				@SourceID = 'P',
				@BatchID = 11,
				@Status = 'O'
select @BatchID

select * from tblFSPStockReturned


*/
GO

Grant EXEC on spWebGetFSPStockReturned to eCAMS_Role
Go
