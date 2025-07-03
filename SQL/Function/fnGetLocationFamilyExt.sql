if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetLocationFamilyExt]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetLocationFamilyExt]
GO

CREATE FUNCTION dbo.fnGetLocationFamilyExt(
--'<!--$$Revision: 5 $-->
--'<!--$$Author: Chester $-->
--'<!--$$Date: 19/10/06 5:09p $-->
--'<!--$$Logfile: /pCAMSSource/SQL/Function/fnGetLocationFamilyExt.sql $-->
--'<!--$$NoKeywords: $-->
	@Location int
) RETURNS @LocFamily TABLE (
			Location int
	)
/*
 Purpose: Get all locations in a family tree, include location 300, 998 (Spare stock kept at site)
*/
AS
BEGIN
 INSERT @LocFamily SELECT * FROM dbo.fnGetLocationFamily(@Location)

 declare @BaseLocation int
 SELECT @BaseLocation = dbo.fnGetMyBaseLocation()

 --add 300/Base Location
 IF NOT EXISTS(SELECT 1 FROM @LocFamily WHERE Location = @BaseLocation)
	INSERT @LocFamily VALUES(@BaseLocation)


 --add 998
 IF NOT EXISTS(SELECT 1 FROM @LocFamily WHERE Location = 998)
	INSERT @LocFamily VALUES(998)

 RETURN
END

/*
 select * from dbo.fnGetLocationFamilyExt (4001)

 select * from dbo.fnGetLocationParents (4001)

 select * from dbo.fnGetLocationChildren (461)

*/
GO


