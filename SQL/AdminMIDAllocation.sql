use webCAMS
Go

--select * from tblModule
if not exists(select 1 from tblModule where ModuleName = 'AdminMIDAllocation')
	insert  tblModule values('AdminMIDAllocation', 'APAC MID Manual Allocation Web Tool',1)
Go

if  not exists(select 1 from tblUserModule where UserID = 199649)
	insert tblUserModule values(199649, 6)
Go


if  not exists(select 1 from tblUserModule where UserID in (select userid from tblUser where EmailAddress = 'dev102'))
	insert tblUserModule 
		select UserID, 6
			from tblUSer
			where EmailAddress = 'dev102'
Go


if not exists(select 1 from tblMenuSet where MenuSet = 'Menu_Client_BNZ_MID_Admin')
  insert tblMenuSet values(8, 'Menu_Client_BNZ_MID_Admin')
Go




