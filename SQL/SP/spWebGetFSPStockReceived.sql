
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockReceived]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockReceived]
GO


Create Procedure dbo.spWebGetFSPStockReceived 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int,
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 1/07/08 4:36p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockReceived.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get FSP stock received batch details

 SET NOCOUNT ON

 --verify if the depot is in user's FSP group
 IF EXISTS(SELECT 1 FROM tblTMPFSPStockReceived 
			WHERE  UserID = @UserID 
				AND SourceID = ISNULL(@SourceID, SourceID) 
				AND BatchID = @BatchID
				AND Status = ISNULL(@Status, Status))
  BEGIN
	SELECT * FROM tblTMPFSPStockReceived 
		WHERE  UserID = @UserID
			AND SourceID = ISNULL(@SourceID, SourceID) 
			AND BatchID = @BatchID
			AND Status = ISNULL(@Status, Status)
  END 
 ELSE
  BEGIN
	SELECT * FROM tblTMPFSPStockReceived 
		WHERE  UserID = @UserID
			AND SourceID = ISNULL(@SourceID, SourceID) 
			AND Status = ISNULL(@Status, Status)
  END 

GO

Grant EXEC on spWebGetFSPStockReceived to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockReceived]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockReceived]
GO


Create Procedure dbo.spWebGetFSPStockReceived 
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
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockReceived.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockReceived @UserID = @UserID, 
				@SourceID = @SourceID,
				@BatchID = @BatchID,
				@Status = @Status

/*

declare @BatchID int

exec dbo.spWebGetFSPStockReceived @UserID = 199663, 
				@SourceID = 'P',
				@BatchID = 11,
				@Status = 'O'
select @BatchID

select * from tblTMPFSPStockReceived


*/
GO

Grant EXEC on spWebGetFSPStockReceived to eCAMS_Role
Go
