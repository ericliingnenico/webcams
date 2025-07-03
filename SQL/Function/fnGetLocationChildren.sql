Use CAMS
Go

Alter FUNCTION fnGetLocationChildren(
--'<!--$$Revision: 2 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 6/05/04 10:58a $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnGetLocationChildren.sql $-->
--'<!--$$NoKeywords: $-->
	@Location int
) RETURNS @LocChildren TABLE (
			Location int
	)
/*
 Purpose: Get all children of the location passed-in
*/
AS
BEGIN
 DECLARE @ChildLocation int

 --check if there are children under this parent location
 IF EXISTS(SELECT 1 FROM Locations_Master WHERE ParentLocation = @Location AND IsActive = 1)
  BEGIN
	--loop through each child location
	DECLARE curChildLocation CURSOR LOCAL FAST_FORWARD
		FOR SELECT Location FROM Locations_Master WHERE ParentLocation = @Location AND IsActive = 1
	
	OPEN curChildLocation

	WHILE 1 = 1
	 BEGIN
		FETCH NEXT FROM curChildLocation INTO @ChildLocation
		
		IF @@FETCH_STATUS <> 0
			BREAK

		--store this child location
		INSERT @LocChildren VALUES (@ChildLocation)

		--drill down into next level
		INSERT @LocChildren SELECT * FROM dbo.fnGetLocationChildren(@ChildLocation)
		
	 END

	CLOSE curChildLocation
	DEALLOCATE curChildLocation

  END


 --return back point
 RETURN
END

/*
 select * from dbo.fnGetLocationChildren (461)

select * from locations_master where location in  (461,4001)

select * from locations_master where location = parentlocation



*/