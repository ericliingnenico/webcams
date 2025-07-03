Use CAMS
Go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockCount]
GO


Create Procedure dbo.spWebGetFSPStockCount 
	(
		@UserID int,
		@FSPID int,
		@Conditions varchar(100)
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 3/03/05 3:46p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockCount.sql $-->
--<!--$$NoKeywords: $-->
---Get stock count for a FSP
DECLARE @InstallerID int


 --get user details
 SELECT @InstallerID = InstallerID 
   FROM WebCams.dbo.tblUser
  WHERE UserID = @UserID

 --if FSPID is one of  user's FSP children, use FSPID as InstallerID, otherwise, use NULL
 IF @FSPID IS NOT NULL
	SELECT @InstallerID = CASE WHEN EXISTS(SELECT 1 FROM dbo.fnGetLocationChildrenExt(@InstallerID) WHERE Location = @FSPID) THEN @FSPID
				ELSE NULL END

				

 IF @Conditions IS NULL
	SELECT COUNT(*)
	  FROM Equipment_Inventory
	 WHERE Location = @InstallerID
 ELSE
	SELECT COUNT(*)
	  FROM Equipment_Inventory
	 WHERE Location = @InstallerID
		AND Condition IN (@Conditions)	

GO

Grant EXEC on spWebGetFSPStockCount to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPStockCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPStockCount]
GO


Create Procedure dbo.spWebGetFSPStockCount 
	(
		@UserID int,
		@FSPID int,
		@Conditions varchar(100)
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPStockCount.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPStockCount @UserID = @UserID, 
					@FSPID = @FSPID, 
					@Conditions = @Conditions

/*
select * from webcams.dbo.tblUser

spWebGetFSPStockCount 199512, null, '2'

spWebGetFSPStockCount 199512, 3011, '2'

spWebGetFSPStockCount 199512, null, null

spWebGetFSPStockCount 199512, 2000, '2'

select count(*) from equipment_inventory
 where location = 3001
	and condition = 2

*/
Go

Grant EXEC on spWebGetFSPStockCount to eCAMS_Role
Go
