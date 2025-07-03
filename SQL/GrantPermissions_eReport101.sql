USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebAddStockFaultyLog]    Script Date: 07/12/20 17:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


Grant EXEC on spWebAddStockFaultyLog to eCAMS_Role
Go

Grant EXEC on spWebCloseFSPStockFaulty to eCAMS_Role
GO

Grant EXEC on spWebGetFSPStockFaulty to eCAMS_Role
GO

Grant EXEC on spWebGetFSPStockFaultyLog to eCAMS_Role
Go


Grant EXEC on spWebPutFSPStockFaulty to eCAMS_Role
Go


GRANT EXEC ON [dbo].[spWebUpdateEquipmentInventoryNote] to eCAMS_Role
GO