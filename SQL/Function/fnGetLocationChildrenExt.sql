if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetLocationChildrenExt]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetLocationChildrenExt]
GO

CREATE FUNCTION fnGetLocationChildrenExt(
--'<!--$$Revision: 1 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 20/02/04 15:06 $-->
--'<!--$$Logfile: /pCAMSSource/SQL/Function/fnGetLocationChildrenExt.sql $-->
--'<!--$$NoKeywords: $-->
	@Location int
) RETURNS @LocChildren TABLE (
			Location int
	)
/*
 Purpose: Get all children of the location passed-in and include itself
*/
AS
BEGIN
 INSERT @LocChildren VALUES (@Location)

 INSERT @LocChildren SELECT * FROM dbo.fnGetLocationChildren(@Location)

 RETURN
END

/*
 select * from dbo.fnGetLocationChildrenExt (461)

select * from locations_master where location in  (461,4001)

select * from locations_master where location = parentlocation



*/