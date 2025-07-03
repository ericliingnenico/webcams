USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebCloseFSPStockFaulty]    Script Date: 11/12/20 13:20:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER Procedure [dbo].[spWebCloseFSPStockFaulty] 
	(
		@UserID int,
		@BatchID int,
		@NoOfBox int,
		@ReferenceNo varchar(30),
		@Notes varchar(65)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Minh $-->
--<!--$$Date: 07/12/20 10:03a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPStockFaulty.sql $-->
--<!--$$NoKeywords: $-->

 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebCloseFSPStockFaulty @UserID = @UserID, 
				@BatchID = @BatchID,
				@NoOfBox = @NoOfBox,
				@ReferenceNo = @ReferenceNo,
				@Notes = @Notes
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret


GO
 