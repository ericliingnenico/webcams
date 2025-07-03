USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebGetFSPStockFaulty]    Script Date: 11/12/20 10:42:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER Procedure [dbo].[spWebGetFSPStockFaulty] 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int,
		@Status varchar(1)
	)
	AS
--<!--$Author: Minh <minh.chau@ingenico.com>$-->
--<!--$Created: 2020-12-11 10:00:32$-->
--<!--$Modified: 2020-12-11 14:43:17$-->
--<!--$ModifiedBy: Minh <minh.chau@ingenico.com>$-->
--<!--$Comment: icm-71$-->
--Purpose: Get FSP stock faulty log details
-- 10/08/2007 Minh added for Update Stock as Faulty
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockFaulty @UserID = @UserID, 
				@SourceID = @SourceID,
				@BatchID = @BatchID,
				@Status = @Status
				
GO
 

/*

declare @BatchID int

exec dbo.spWebGetFSPStockFaulty @UserID = 199663, 
				@SourceID = 'P',
				@BatchID = 11,
				@Status = 'O'
select @BatchID

select * from tblFSPStockFaulty


*/
