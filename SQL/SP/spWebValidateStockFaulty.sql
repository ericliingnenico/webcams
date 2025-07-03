USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebValidateStockFaulty]    Script Date: 08/12/20 18:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER Procedure [dbo].[spWebValidateStockFaulty] 
	(
		@UserID int,
		@BatchID int,
		@Serial varchar(32),
		@RetCaseID int OUTPUT
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebValidateStockFaulty.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebValidateStockFaulty 
                @UserID = @UserID, 
				@BatchID = @BatchID,
				@Serial = @Serial,
				@RetCaseID = @RetCaseID OUTPUT
		

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

GO

