Use WebCAMS
Go

Alter Procedure dbo.spWebSwapBundledSIM
(
	@UserID int,
	@JobID bigint,
	@SerialOut varchar(32),
	@SerialIn varchar(32)
)
AS
-- =============================================
-- Author: Andrew Falzon
-- Create date: 05/09/2018
-- Description:	Facilitate swapping of a bundled SIM card.
-- =============================================
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebSwapBundledSIM @UserID = @UserID, @JobID = @JobID, @SerialOut = @SerialOut, @SerialIn = @SerialIn
/*
exec spWebSwapBundledSIM 200031, 2932709, '8500128903367N', '019678960N'
*/
Go

--Grant EXEC on spWebSwapBundledSIM to CallSysUsers, CAMSApp, eCAMS_Role
Go

Use CAMS
Go

Alter Procedure dbo.spWebSwapBundledSIM 
(
	@UserID int,
	@JobID bigint,
	@SerialOut varchar(32),
	@SerialIn varchar(32)
)
AS
-- =============================================
-- Author: Andrew Falzon
-- Create date: 05/09/2018
-- Description:	Facilitate swapping of a bundled SIM card.
-- =============================================
declare @ret int = 0,
		@ClientID varchar(4), 
		@AssignTo int,
		@MMD_IN varchar(5),
		@MMD_OUT varchar(5),
		@Serials varchar(8000),
		@OperatorID int

select @OperatorID = OperatorNumber from [Security]
where OperatorNumber = @UserID

select @SerialOut as SerialOut, @SerialIn as SerialIn
into #SERIALS

select @MMD_OUT = COALESCE(SE_OUT.MMD_ID, E_OUT.MMD_ID), 
	   @MMD_IN = COALESCE(SE_IN.MMD_ID, E_IN.MMD_ID)
from #SERIALS S
left join Site_Equipment SE_OUT on SE_OUT.Serial = S.SerialOut
left join Site_Equipment SE_IN on SE_IN.Serial = S.SerialIn
left join Equipment_Inventory E_OUT on E_OUT.Serial = S.SerialOut
left join Equipment_Inventory E_IN on E_IN.Serial = S.SerialIn

if @MMD_IN is null OR @MMD_OUT is null
	begin
		raiserror('MMD IDs could not be determined! Aborted.', 16, 1)
		select @ret = -1
		GOTO Exit_Handle
	end

select @Serials = @MMD_OUT + ',' + @SerialOut + ',' + @MMD_IN + ',' + @SerialIn

if dbo.fnIsSwapCall(cast(@JobID as varchar(20))) = 0
	begin
		select @ClientID = ClientID, @AssignTo = BookedInstaller
		from IMS_Jobs where JobID = @JobID
	end
else
	begin
		select @ClientID = ClientID, @AssignTo = AssignedTo
		from Calls where CallNumber = cast(@JobID as varchar(20))
	end

if @ClientID is null OR @AssignTo is null
	begin
		raiserror('Call/Job could not be found! Aborted.', 16, 1)
		select @ret = -1
		GOTO Exit_Handle
	end

select @UserID = COALESCE(@OperatorID, -@AssignTo)

exec @ret = spSwapBundledSIM @ClientID, @AssignTo, @Serials, 0, @UserID, @JobID

RETURN @ret

Exit_Handle:
	
RETURN @ret

GO
--Grant EXEC on spWebSwapBundledSIM to CallSysUsers, CAMSApp, eCAMS_Role
Go


