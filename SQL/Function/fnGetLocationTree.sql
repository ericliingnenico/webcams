if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetLocationTree]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetLocationTree]
GO

Create FUNCTION fnGetLocationTree(
--'<!--$$Revision: 2 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 31/05/04 10:38a $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnGetLocationTree.sql $-->
--'<!--$$NoKeywords: $-->
	@Location int,
	@Level tinyint
) RETURNS @LocChildren TABLE (
			Location int,
			[Level] tinyint
	)
/*
 Purpose: Get location tree
*/
AS
BEGIN
 DECLARE @ChildLocation int,
	@NextLevel tinyint

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
		INSERT @LocChildren VALUES (@ChildLocation, @Level)

		--drill down into next level
		SELECT @NextLevel = @Level + 1
		INSERT @LocChildren SELECT * FROM dbo.fnGetLocationTree(@ChildLocation, @NextLevel)
		
	 END

	CLOSE curChildLocation
	DEALLOCATE curChildLocation

  END


 --return back point
 RETURN
END

/*
 select * from dbo.fnGetLocationTree (461, 1)

select * from locations_master where location in  (461,4001)

select * from locations_master where location = parentlocation



*/