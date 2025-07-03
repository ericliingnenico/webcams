Use CAMS
Go

Alter FUNCTION fnGetLocationChildrenList(
--'<!--$$Revision: 2 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 6/05/04 10:58a $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnGetLocationChildrenList.sql $-->
--'<!--$$NoKeywords: $-->
	@Location int
) RETURNS varchar(1000)
/*
 Purpose: Get list of child locations
*/
AS
BEGIN
 DECLARE @ChildLocation int,
	@LocChildren varchar(1000)

 --init, otherwise the return will be null
 SELECT @LocChildren = ''

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
		SELECT @LocChildren = @LocChildren + CAST(@ChildLocation as varchar) + ','

		--drill down into next level
		SELECT @LocChildren = @LocChildren + dbo.fnGetLocationChildrenList(@ChildLocation)
		
	 END

	CLOSE curChildLocation
	DEALLOCATE curChildLocation

  END


 --return back point
 RETURN @LocChildren
END

/*
select dbo.fnGetLocationChildrenList (461)

select * from locations_master where location in  (461,4001)

select * from locations_master where location = parentlocation
*/