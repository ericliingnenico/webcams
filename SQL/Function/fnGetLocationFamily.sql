Alter FUNCTION fnGetLocationFamily(
--'<!--$$Revision: 3 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 2/06/04 2:43p $-->
--'<!--$$Logfile: /pCAMSSource/SQL/Function/fnGetLocationFamily.sql $-->
--'<!--$$NoKeywords: $-->
	@Location int
) RETURNS @LocFamily TABLE (
			Location int
	)
/*
 Purpose: Get all locations in a family tree
	Logic: Get all parents and then drill down from each parent to get the whole family members
*/
AS
BEGIN
 DECLARE @ParentLocation int,
	@HasParent bit
 

 --init
 SELECT @HasParent = 0

 --Get parent location children first, loop through each parent to retrieve its children
 DECLARE curParents CURSOR LOCAL FAST_FORWARD
	FOR SELECT * FROM dbo.fnGetLocationParents(@Location)

 OPEN curParents

 WHILE 1 = 1
  BEGIN
	FETCH NEXT FROM curParents INTO @ParentLocation

	IF @@FETCH_STATUS <> 0
		BREAK

	--mark has parent
	SELECT @HasParent = 1

	--Get children of this parent
	INSERT @LocFamily 
		SELECT c.* 
		  FROM dbo.fnGetLocationChildrenExt(@ParentLocation) c LEFT OUTER JOIN @LocFamily f 
									ON c.Location = f.Location
		 WHERE f.Location IS NULL
  END 

 CLOSE curParents
 DEALLOCATE curParents

 --Case of no parent, make it as parent to dill down
 IF @HasParent = 0
  BEGIN
	INSERT @LocFamily 
		SELECT c.* 
		  FROM dbo.fnGetLocationChildrenExt(@Location) c	
  END

 RETURN
END

/*
 --has parnet
 select * from dbo.fnGetLocationFamily (4001)

 --no parent
 select * from dbo.fnGetLocationFamily (461)

 select * from dbo.fnGetLocationParents (4001)

 select * from dbo.fnGetLocationChildren (461)

*/