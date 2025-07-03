USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebPutFSPStockFaulty]    Script Date: 08/12/20 18:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER Procedure [dbo].[spWebPutFSPStockFaulty] 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int OUTPUT,
		@FromLocation int,
		@ToLocation int,
		@DateReturned datetime,
		@ReferenceNo varchar(30),
		@Note varchar(65),
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPStockFaulty.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebPutFSPStockFaulty @UserID = @UserID, 
				@SourceID = @SourceID,
				@BatchID = @BatchID OUTPUT,
				@FromLocation = @FromLocation,
				@ToLocation = @ToLocation,
				@DateReturned = @DateReturned,
				@ReferenceNo = @ReferenceNo,
				@Note = @Note,
				@Status = @Status

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

declare @BatchID int

exec dbo.spWebPutFSPStockFaulty @UserID = 199663, 
				@SourceID = 'P',
				@BatchID = @BatchID OUTPUT,
				@FromLocation = 3003,
				@ToLocation = 300,
				@DateReturned = '2005-11-15',
				@ReferenceNo = '123456789',
				@Note = 'this is a test.',
				@Status = 'O'

select @BatchID

select * from tblFSPStockFaulty

*/
GO


