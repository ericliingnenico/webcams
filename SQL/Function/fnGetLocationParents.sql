if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetLocationParents]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetLocationParents]
GO

CREATE FUNCTION fnGetLocationParents(
--'<!--$$Revision: 1 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 20/02/04 15:06 $-->
--'<!--$$Logfile: /pCAMSSource/SQL/Function/fnGetLocationParents.sql $-->
--'<!--$$NoKeywords: $-->
	@Location int
) RETURNS @LocParents TABLE (
			Location int
	)
/*
 Purpose: Get all parents of the location passed-in
*/
AS
BEGIN
 DECLARE @ParentLocation int

 --get parent lcoation
 SELECT @ParentLocation = ParentLocation
    FROM Locations_Master
    WHERE Location = @Location
		AND IsActive = 1

 IF @ParentLocation IS NOT NULL
  BEGIN
	--not null, store the parent location in temp table
	INSERT @LocParents Values(@ParentLocation)
	--drill down to next level
	INSERT @LocParents SELECT * FROM dbo.fnGetLocationParents(@ParentLocation)	
  END

 --parent lcoation is null, return back point
 RETURN
END

/*
 select * from dbo.fnGetLocationParents (4001)

select * from locations_master where location in  (461,4001)

select * from locations_master where location = parentlocation



*/