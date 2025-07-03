if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetLocationFamily]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetLocationFamily]
GO

CREATE FUNCTION fnGetLocationFamily(
--'<!--$$Revision: 1 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 20/02/04 15:06 $-->
--'<!--$$Logfile: /pCAMSSource/SQL/Function/fnGetLocationParentsExt.sql $-->
--'<!--$$NoKeywords: $-->
	@Location int
) RETURNS @LocFamily TABLE (
			Location int
	)
/*
 Purpose: Get all locations in a family tree
*/
AS
BEGIN
 --Get location children first
 INSERT @LocFamily SELECT * FROM dbo.fnGetLocationChildren(@Location)

 --Get location parents 
 INSERT @LocFamily SELECT * FROM dbo.fnGetLocationParents(@Location)

 --Include itself
 INSERT @LocFamily VALUES(@Location)

 --return back point
 RETURN
END

/*
 select * from dbo.fnGetLocationFamily (4001)

select * from locations_master where location in  (461,4001)

select * from locations_master where location = parentlocation



*/