USE WebCAMS
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[fnCanUseNewPCAMS]') AND xtype IN (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fnCanUseNewPCAMS]
GO

CREATE FUNCTION dbo.fnCanUseNewPCAMS
	(
		@UserID int
	) RETURNS bit
--'<!--$$Revision: 5 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 22/10/12 14:10 $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnCanUseNewPCAMS.sql $-->
--'<!--$$NoKeywords: $-->
AS
BEGIN
 --Purpose: Check if fsp can use new pocketcams
 --Return CASE WHEN exists(select 1 from tblUser where UserID = @UserID and isnumeric(InstallerID) = 1 and EmailAddress in (select emailaddress from iCAMSUser)) THEN 1 ELSE 0 END
	Return 1
END
/*
	SELECT dbo.fnCanUseNewPCAMS(199649)
	
	SELECT dbo.fnCanUseNewPCAMS(201222)
	
	SELECT dbo.fnCanUseNewPCAMS(199806)
	
*/
GO


Grant EXEC on dbo.fnCanUseNewPCAMS to eCAMS_Role
GO

