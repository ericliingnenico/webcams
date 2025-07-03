USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebAddStockFaultyLog]    Script Date: 07/12/20 17:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER Procedure [dbo].[spWebAddStockFaultyLog] 
	(
		@UserID int,
		@BatchID int,
		@Serial varchar(32),
		@CaseID int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Minh $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebAddStockFaultyLog.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebAddStockFaultyLog 
		@UserID = @UserID,
		@BatchID = @BatchID,
		@Serial = @Serial,
		@CaseID = @CaseID

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
 
GO
 