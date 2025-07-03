Use CAMS
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebGetFSPFamilyExt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spWebGetFSPFamilyExt]
GO

Create Procedure dbo.spWebGetFSPFamilyExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 13/02/14 13:45 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPFamilyExt.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: return FSP children list

Declare @InstallerID int

 SET NOCOUNT ON

 
 SELECT @InstallerID = InstallerID
   FROM WebCams.dbo.tblUser 
  WHERE UserID = @UserID

 --check if FSP has parentlocation
 if exists(select 1 from Locations_Master where Location = @InstallerID and isnull(ParentLocation, 0)<>0)
  begin
	select @InstallerID = ParentLocation from Locations_Master where Location = @InstallerID and isnull(ParentLocation, 0)<>0
  end

 SELECT l.Location as FSPID, 
	' ' + Cast(l.Location as varchar) + '-' + l.[Description] as FSPDisplayName
  FROM Locations_Master l WHERE @InstallerID = l.Location
 UNION
 SELECT l.Location as FSPID, 
	REPLICATE('---', f.[Level]) + Cast(l.Location as varchar) + '-' + ISNULL(l.Contact, 'TBA') as FSPDisplayName
  FROM Locations_Master l JOIN dbo.fnGetLocationTree(@InstallerID, 1) f ON l.Location = f.Location
	ORDER BY FSPDisplayName


GO

Grant EXEC on spWebGetFSPFamilyExt to eCAMS_Role
Go


Use WebCAMS
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebGetFSPFamilyExt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spWebGetFSPFamilyExt]
GO

Create Procedure dbo.spWebGetFSPFamilyExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 2:41p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPFamilyExt.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/

 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPFamilyExt @UserID = @UserID
/*

spWebGetFSPFamilyExt 200029


*/
GO

Grant EXEC on spWebGetFSPFamilyExt to eCAMS_Role
Go
