USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebGetFSPStockFaultyLog]    Script Date: 11/12/20 09:52:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER Procedure [dbo].[spWebGetFSPStockFaultyLog] 
	(
		@UserID int,
		@BatchID int,
		@From int
	)
	AS
--<!--$Author: Minh <minh.chau@ingenico.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-06-19 14:43:17$-->
--<!--$ModifiedBy: Minh <minh.chau@ingenico.com>$-->
--<!--$Comment: icm-71$-->
--Purpose: Get FSP stock faulty log details
-- 10/08/2007 Minh added for Update Stock as Faulty

 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockFaultyLog @UserID = @UserID, 
				@BatchID = @BatchID,
				@From = @From


GO


/*

exec dbo.spWebGetFSPStockFaultyLog @UserID = 199663, 
				@BatchID = 708,
				@From = 1

select * from tblFSPStockFaulty


select * from webcams.dbo.tblUser



*/
