USE CAMS
Go


if exists(select 1 from sysobjects where name = 'spWebGetFSPCalendar')
	drop proc spWebGetFSPCalendar
go	

create proc spWebGetFSPCalendar 
	(
		@FSP int,
		@FromDate datetime = null
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/02/14 14:10 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPCalendar.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get FSP Boobing Capacity and IMS Job Booking Stats
--8/5/2007: List All FSP and its children regardless IMS Jobs booking stats
--		And sum all its children booking stats and display at parent row
--		Use ParentLocation instead of ParentLocation
 SET NOCOUNT ON

--SET FMTONLY OFF 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @D1 as date,
	@D2 as date,
	@D3 as date,
	@D4 as date,
	@D5 as date,
	@D6 as date,
	@D7 as date,
	@D8 as date,
	@D9 as date,
	@D10 as date,
	@D11 as date,
	@D12 as date,
	@D13 as date,
	@D14 as date,
	@D15 as date,
	@D15Time as datetime,
	@i int,
	@date datetime

 select @FromDate = ISNULL(@FromDate, GETDATE())
 --select @FromDate = '2013-12-18'
 
 create table #FSPFmaily(FSP int)
 insert #FSPFmaily
	select * from dbo.fnGetLocationChildrenExt(@FSP)
	 
 SELECT @D1 = cast(@FromDate as date),
	@D2 = cast(DateAdd(d, 1, @FromDate) as date),
	@D3 = cast(DateAdd(d, 2, @FromDate) as date),
	@D4 = cast(DateAdd(d, 3, @FromDate) as date),
	@D5 = cast(DateAdd(d, 4, @FromDate) as date),
	@D6 = cast(DateAdd(d, 5, @FromDate) as date),
	@D7 = cast(DateAdd(d, 6, @FromDate) as date),
	@D8 = cast(DateAdd(d, 7, @FromDate) as date),
	@D9 = cast(DateAdd(d, 8, @FromDate) as date),
	@D10 = cast(DateAdd(d, 9, @FromDate) as date),
	@D11 = cast(DateAdd(d, 10, @FromDate) as date),
	@D12 = cast(DateAdd(d, 11, @FromDate) as date),
	@D13 = cast(DateAdd(d, 12, @FromDate) as date),
	@D14 = cast(DateAdd(d, 13, @FromDate) as date),
	@D15 = DateAdd(d, 14, @FromDate)

 --convert @D15 to end of D15 in datetime
 select @D15Time = CONVERT(varchar, @D15, 107) + ' 23:59:59'

--get weekend date
 select @i = 0
 create table #holiday(TheDate datetime)
 while (@i < 15)
  begin
	select @date = cast(DateAdd(d, @i, @FromDate) as date)
	if datename(dw, @date) in ('Saturday', 'Sunday')
	 begin
		insert #holiday values(@date)
	 end
	select @i = @i + 1
  end 
 --getdate public holiday
 insert #holiday
	select ph.[Date] from tblPublicHoliday ph join Locations_Master lm on ph.State = lm.state
	where lm.Location = @FSP and ph.[Date] between @D1 and @D15Time
	

select Depot=l.Location,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D1 THEN 1 ELSE 0 END) as D1,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D2 THEN 1 ELSE 0  END) as D2,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D3 THEN 1 ELSE 0  END) as D3,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D4 THEN 1 ELSE 0  END) as D4,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D5 THEN 1 ELSE 0  END) as D5,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D6 THEN 1 ELSE 0  END) as D6,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D7 THEN 1 ELSE 0  END) as D7,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D8 THEN 1 ELSE 0  END) as D8,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D9 THEN 1 ELSE 0  END) as D9,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D10 THEN 1 ELSE 0  END) as D10,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D11 THEN 1 ELSE 0  END) as D11,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D12 THEN 1 ELSE 0  END) as D12,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D13 THEN 1 ELSE 0  END) as D13,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D14 THEN 1 ELSE 0  END) as D14,
	SUM(CASE WHEN j.AgentSLADateTime >= @D15 THEN 1 ELSE 0  END) as D15,
	C1 = CAST((case when exists(select 1 from #holiday where TheDate = @D1) then 'Y' else '' end)  as varchar(50)),
	C2 = CAST((case when exists(select 1 from #holiday where TheDate = @D2) then 'Y' else '' end)  as varchar(50)),
	C3 = CAST((case when exists(select 1 from #holiday where TheDate = @D3) then 'Y' else '' end)  as varchar(50)),
	C4 = CAST((case when exists(select 1 from #holiday where TheDate = @D4) then 'Y' else '' end)  as varchar(50)),
	C5 = CAST((case when exists(select 1 from #holiday where TheDate = @D5) then 'Y' else '' end)  as varchar(50)),
	C6 = CAST((case when exists(select 1 from #holiday where TheDate = @D6) then 'Y' else '' end)  as varchar(50)),
	C7 = CAST((case when exists(select 1 from #holiday where TheDate = @D7) then 'Y' else '' end)  as varchar(50)),
	C8 = CAST((case when exists(select 1 from #holiday where TheDate = @D8) then 'Y' else '' end)  as varchar(50)),
	C9 = CAST((case when exists(select 1 from #holiday where TheDate = @D9) then 'Y' else '' end)  as varchar(50)),
	C10 = CAST((case when exists(select 1 from #holiday where TheDate = @D10) then 'Y' else '' end)  as varchar(50)),
	C11 = CAST((case when exists(select 1 from #holiday where TheDate = @D11) then 'Y' else '' end)  as varchar(50)),
	C12 = CAST((case when exists(select 1 from #holiday where TheDate = @D12) then 'Y' else '' end)  as varchar(50)),
	C13 = CAST((case when exists(select 1 from #holiday where TheDate = @D13) then 'Y' else '' end)  as varchar(50)),
	C14 = CAST((case when exists(select 1 from #holiday where TheDate = @D14) then 'Y' else '' end)  as varchar(50)),
	C15 = CAST((case when exists(select 1 from #holiday where TheDate = @D15) then 'Y' else '' end)  as varchar(50)),
	max(l.ParentLocation) as ParentLocation
 into #myJob
 from  Locations_Master l LEFT OUTER JOIN IMS_Jobs j ON j.BookedInstaller = l.Location 
								--and j.JobTypeID in (1,3)
								and j.AgentSLADateTime >= @FromDate
 WHERE l.Location  IN (SELECT * FROM #FSPFmaily) 
 GROUP BY l.Location, 
	l.DailyInstallCapacity


select 
	Depot=l.Location,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D1 THEN 1 ELSE 0 END) as D1,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D2 THEN 1 ELSE 0  END) as D2,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D3 THEN 1 ELSE 0  END) as D3,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D4 THEN 1 ELSE 0  END) as D4,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D5 THEN 1 ELSE 0  END) as D5,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D6 THEN 1 ELSE 0  END) as D6,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D7 THEN 1 ELSE 0  END) as D7,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D8 THEN 1 ELSE 0  END) as D8,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D9 THEN 1 ELSE 0  END) as D9,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D10 THEN 1 ELSE 0  END) as D10,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D11 THEN 1 ELSE 0  END) as D11,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D12 THEN 1 ELSE 0  END) as D12,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D13 THEN 1 ELSE 0  END) as D13,
	SUM(CASE WHEN cast(j.AgentSLADateTime as date) = @D14 THEN 1 ELSE 0  END) as D14,
	SUM(CASE WHEN j.AgentSLADateTime >= @D15 THEN 1 ELSE 0  END) as D15,
	C1 = CAST((case when exists(select 1 from #holiday where TheDate = @D1) then 'Y' else '' end)  as varchar(50)),
	C2 = CAST((case when exists(select 1 from #holiday where TheDate = @D2) then 'Y' else '' end)  as varchar(50)),
	C3 = CAST((case when exists(select 1 from #holiday where TheDate = @D3) then 'Y' else '' end)  as varchar(50)),
	C4 = CAST((case when exists(select 1 from #holiday where TheDate = @D4) then 'Y' else '' end)  as varchar(50)),
	C5 = CAST((case when exists(select 1 from #holiday where TheDate = @D5) then 'Y' else '' end)  as varchar(50)),
	C6 = CAST((case when exists(select 1 from #holiday where TheDate = @D6) then 'Y' else '' end)  as varchar(50)),
	C7 = CAST((case when exists(select 1 from #holiday where TheDate = @D7) then 'Y' else '' end)  as varchar(50)),
	C8 = CAST((case when exists(select 1 from #holiday where TheDate = @D8) then 'Y' else '' end)  as varchar(50)),
	C9 = CAST((case when exists(select 1 from #holiday where TheDate = @D9) then 'Y' else '' end)  as varchar(50)),
	C10 = CAST((case when exists(select 1 from #holiday where TheDate = @D10) then 'Y' else '' end)  as varchar(50)),
	C11 = CAST((case when exists(select 1 from #holiday where TheDate = @D11) then 'Y' else '' end)  as varchar(50)),
	C12 = CAST((case when exists(select 1 from #holiday where TheDate = @D12) then 'Y' else '' end)  as varchar(50)),
	C13 = CAST((case when exists(select 1 from #holiday where TheDate = @D13) then 'Y' else '' end)  as varchar(50)),
	C14 = CAST((case when exists(select 1 from #holiday where TheDate = @D14) then 'Y' else '' end)  as varchar(50)),
	C15 = CAST((case when exists(select 1 from #holiday where TheDate = @D15) then 'Y' else '' end)  as varchar(50)),
	max(l.ParentLocation) as ParentLocation
 into  #Swap
 from  Locations_Master l LEFT OUTER JOIN Calls j ON j.AssignedTo  IN (SELECT * FROM #FSPFmaily) 
								and j.AgentSLADateTime >= @FromDate
 WHERE l.Location = @FSP
 GROUP BY l.Location

--select * from #MyJob

--select * from #Swap


 update jb
	set D1 = jb.D1 + sp.D1,
		D2 = jb.D2 + sp.D2,
		D3 = jb.D3 + sp.D3,
		D4 = jb.D4 + sp.D4,
		D5 = jb.D5 + sp.D5,
		D6 = jb.D6 + sp.D6,
		D7 = jb.D7 + sp.D7,
		D8 = jb.D8 + sp.D8,
		D9 = jb.D9 + sp.D9,
		D10 = jb.D10 + sp.D10,
		D11 = jb.D11 + sp.D11,
		D12 = jb.D12 + sp.D12,
		D13 = jb.D13 + sp.D13,			
		D14 = jb.D14 + sp.D14,	
		D15 = jb.D15 + sp.D15
  from #myJob jb join #Swap sp on jb.Depot = sp.Depot


 
 UPDATE #myJob
   SET D1 = D1 + (select sum(D1) from #myJob where ParentLocation IS NOT NULL),
	D2 = D2 + (select sum(D2) from #myJob where ParentLocation IS NOT NULL),
	D3 = D3 + (select sum(D3) from #myJob where ParentLocation IS NOT NULL),
	D4 = D4 + (select sum(D4) from #myJob where ParentLocation IS NOT NULL),
	D5 = D5 + (select sum(D5) from #myJob where ParentLocation IS NOT NULL),
	D6 = D6 + (select sum(D6) from #myJob where ParentLocation IS NOT NULL),
	D7 = D7 + (select sum(D7) from #myJob where ParentLocation IS NOT NULL),
	D8 = D8 + (select sum(D8) from #myJob where ParentLocation IS NOT NULL),
	D9 = D9 + (select sum(D9) from #myJob where ParentLocation IS NOT NULL),
	D10 = D10 + (select sum(D10) from #myJob where ParentLocation IS NOT NULL),
	D11 = D11 + (select sum(D11) from #myJob where ParentLocation IS NOT NULL),
	D12 = D12 + (select sum(D12) from #myJob where ParentLocation IS NOT NULL),
	D13 = D13 + (select sum(D13) from #myJob where ParentLocation IS NOT NULL),
	D14 = D14 + (select sum(D14) from #myJob where ParentLocation IS NOT NULL)
  WHERE ParentLocation IS NULL

  
 ----set over booked color
 --UPDATE #myJob
 --  SET C1 = case when D1>DailyInstallCapacity then 'B' else C1 end,
	--C2 = case when D2>DailyInstallCapacity then 'B' else C2 end,
	--C3 = case when D3>DailyInstallCapacity then 'B' else C3 end,
	--C4 = case when D4>DailyInstallCapacity then 'B' else C4 end,
	--C5 = case when D5>DailyInstallCapacity then 'B' else C5 end,
	--C6 = case when D6>DailyInstallCapacity then 'B' else C6 end,
	--C7 = case when D7>DailyInstallCapacity then 'B' else C7 end,
	--C8 = case when D8>DailyInstallCapacity then 'B' else C8 end,
	--C9 = case when D9>DailyInstallCapacity then 'B' else C9 end,
	--C10 = case when D10>DailyInstallCapacity then 'B' else C10 end,
	--C11 = case when D11>DailyInstallCapacity then 'B' else C11 end,
	--C12 = case when D12>DailyInstallCapacity then 'B' else C12 end,
	--C13 = case when D13>DailyInstallCapacity then 'B' else C13 end,
	--C14 = case when D14>DailyInstallCapacity then 'B' else C14 end,
	--C15 = case when D15>DailyInstallCapacity then 'B' else C15 end
 -- WHERE DailyInstallCapacity > 0
		 		
 --set OnDutyFSP color
 select cp.Depot,
    C1 = max(case dbo.fnGetDayOverlap(@D1, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'  + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C2 = max(case dbo.fnGetDayOverlap(@D2, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C3 = max(case dbo.fnGetDayOverlap(@D3, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C4 = max(case dbo.fnGetDayOverlap(@D4, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C5 = max(case dbo.fnGetDayOverlap(@D5, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C6 = max(case dbo.fnGetDayOverlap(@D6, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C7 = max(case dbo.fnGetDayOverlap(@D7, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C8 = max(case dbo.fnGetDayOverlap(@D8, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C9 = max(case dbo.fnGetDayOverlap(@D9, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C10 = max(case dbo.fnGetDayOverlap(@D10, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C11 = max(case dbo.fnGetDayOverlap(@D11, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C12 = max(case dbo.fnGetDayOverlap(@D12, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C13 = max(case dbo.fnGetDayOverlap(@D13, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C14 = max(case dbo.fnGetDayOverlap(@D14, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C15 = max(case dbo.fnGetDayOverlap(@D15, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'G^' + CAST(fd.LogID as varchar) else 'C^' + CAST(fd.LogID as varchar) + '^'   + dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end)
 into #FSPOnDuty
 from #myJob cp join vwActiveFSPDelegation fd on fd.AssignToFSP = cp.Depot
 where (fd.FromDate between @D1 and @D15Time 
		or fd.ToDate  between @D1 and @D15Time )
 group by cp.Depot

		 
update cp
 set    cp.C1 = case when fd.C1<>'' then fd.C1 else cp.C1 end,
	C2 = case when fd.C2<>'' then fd.C2  else cp.C2 end,
 	C3 = case when fd.C3<>'' then fd.C3  else cp.C3 end,
	C4 = case when fd.C4<>'' then fd.C4  else cp.C4 end,
 	C5 = case when fd.C5<>'' then fd.C5  else cp.C5 end,
	C6 = case when fd.C6<>'' then fd.C6  else cp.C6 end,
 	C7 = case when fd.C7<>'' then fd.C7  else cp.C7 end,
	C8 = case when fd.C8<>'' then fd.C8  else cp.C8 end,
 	C9 = case when fd.C9<>'' then fd.C9  else cp.C9 end,
	C10 = case when fd.C10<>'' then fd.C10  else cp.C10 end,
 	C11 = case when fd.C11<>'' then fd.C11  else cp.C11 end,
	C12 = case when fd.C12<>'' then fd.C12  else cp.C12 end,
 	C13 = case when fd.C13<>'' then fd.C13  else cp.C13 end,
	C14 = case when fd.C14<>'' then fd.C14  else cp.C14 end,
 	C15 = case when fd.C15<>'' then fd.C15  else cp.C15 end
 from #myJob cp join #FSPOnDuty fd on fd.Depot = cp.Depot
 
 --set FSP not available (no AssignToFSP)
 select cp.Depot,
    C1 = max(case dbo.fnGetDayOverlap(@D1, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate) end),
    C2 = max(case dbo.fnGetDayOverlap(@D2, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C3 = max(case dbo.fnGetDayOverlap(@D3, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C4 = max(case dbo.fnGetDayOverlap(@D4, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C5 = max(case dbo.fnGetDayOverlap(@D5, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C6 = max(case dbo.fnGetDayOverlap(@D6, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C7 = max(case dbo.fnGetDayOverlap(@D7, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C8 = max(case dbo.fnGetDayOverlap(@D8, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C9 = max(case dbo.fnGetDayOverlap(@D9, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C10 = max(case dbo.fnGetDayOverlap(@D10, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C11 = max(case dbo.fnGetDayOverlap(@D11, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C12 = max(case dbo.fnGetDayOverlap(@D12, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C13 = max(case dbo.fnGetDayOverlap(@D13, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C14 = max(case dbo.fnGetDayOverlap(@D14, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end),
    C15 = max(case dbo.fnGetDayOverlap(@D15, fd.FromDate, fd.ToDate) when 0 then '' when 1 then 'R^' + CAST(fd.LogID as varchar) else 'O^' + CAST(fd.LogID as varchar) + '^'  +  dbo.fnFormatDateTime(fd.FromDate) + '-' + dbo.fnFormatDateTime(fd.ToDate)  end)
 into #FSPNotAvailable
 from #myJob cp join vwActiveFSPDelegation fd on fd.FSP = cp.Depot and fd.AssignToFSP is null
 where (fd.FromDate between @D1 and @D15Time 
		or fd.ToDate  between @D1 and @D15Time )
 group by cp.Depot

		 
update cp
 set    cp.C1 = case when fd.C1<>'' then fd.C1 else cp.C1 end,
	C2 = case when fd.C2<>'' then fd.C2  else cp.C2 end,
 	C3 = case when fd.C3<>'' then fd.C3  else cp.C3 end,
	C4 = case when fd.C4<>'' then fd.C4  else cp.C4 end,
 	C5 = case when fd.C5<>'' then fd.C5  else cp.C5 end,
	C6 = case when fd.C6<>'' then fd.C6  else cp.C6 end,
 	C7 = case when fd.C7<>'' then fd.C7  else cp.C7 end,
	C8 = case when fd.C8<>'' then fd.C8  else cp.C8 end,
 	C9 = case when fd.C9<>'' then fd.C9  else cp.C9 end,
	C10 = case when fd.C10<>'' then fd.C10  else cp.C10 end,
 	C11 = case when fd.C11<>'' then fd.C11  else cp.C11 end,
	C12 = case when fd.C12<>'' then fd.C12  else cp.C12 end,
 	C13 = case when fd.C13<>'' then fd.C13  else cp.C13 end,
	C14 = case when fd.C14<>'' then fd.C14  else cp.C14 end,
 	C15 = case when fd.C15<>'' then fd.C15  else cp.C15 end
 from #myJob cp join #FSPNotAvailable fd on fd.Depot = cp.Depot

select * from #myJob
 
/*
spGetFSPBookingCapacity 2600
spGetFSPBookingCapacity 3300
spGetFSPBookingCapacity 3300, '2013-12-23'

select * from tblFSPDelegation
 where FSP = 3300
*/


GO

Grant exec on spWebGetFSPCalendar to CAMSApp
go


grant EXEC on spWebGetFSPCalendar to eCAMS_Role
go

use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPCalendar')
	drop proc spWebGetFSPCalendar
go	

create proc spWebGetFSPCalendar (
	@UserID int,
	@FromDate datetime = null)
as
 declare @FSP int
 
 select @FSP = InstallerID
  from tblUser
  where UserID = @UserID
  
 --EXEC CAMS.dbo.spGetFSPCalendar @FSP = @FSP, @FromDate = @FromDate
 EXEC CAMS.dbo.spWebGetFSPCalendar @FSP = @FSP, @FromDate = @FromDate

/*
	spWebGetFSPCalendar @UserID = 199649, @FromDate = '2014-02-10'
	
*/	
GO

grant EXEC on spWebGetFSPCalendar to eCAMS_Role
go

