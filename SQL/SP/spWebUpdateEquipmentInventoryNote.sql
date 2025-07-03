USE [WebCAMS]
GO

/****** Object:  StoredProcedure [dbo].[spWebUpdateEquipmentInventoryNote]    Script Date: 28/01/21 14:46:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].spWebUpdateEquipmentInventoryNote') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
--	drop procedure [dbo].spWebUpdateEquipmentInventoryNote
--Go

CREATE PROC [dbo].[spWebUpdateEquipmentInventoryNote]
(
	@BatchID int,
	@Notes varchar(65)
)
--<!--$$Revision: 7 $-->
--<!--$$Author: Minh $-->
--<!--$$Date: 28/01/21 16:55 $-->
--<!--$$Logfile: /SQL/SP/CAMS/spWebUpdateEquipmentInventoryNote.sql $-->
--<!--$$NoKeywords: $-->
AS
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebUpdateEquipmentInventoryNote 
				@BatchID = @BatchID, 
				@Notes = @Notes

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

GO
