--Run on CS PIT database
drop table #pdata

--select data into temp table, change to appropriate PIT database and table and date range
use [CSPit_Mobile_Archive];
select * 
into #pdata
from pit03 (nolock)
where ArrivalDtUtc between '2016-3-31 00:00' and '2016-4-1 00:00'

--select vendor ID from PIT, whitelist table, and production vendor name
select p.VendorID as VendorIdPIT, ISNULL(vp.VendorID, -1) as VendorIdWhiteList, ISNULL(vp.[Description], -1) as VendorNmWhiteList, v1.VendorID as VendorIdDEN, v1.VendorName as VendorDEN
, COUNT(*) as Volume
from #pdata p 
--use the following two rows if selecing data from CS PIT Main
--left outer join DNWSQL03.ConnectedServicesPIT.dbo.vendorprovider vp on p.VendorID = vp.VendorID
--left outer join DNWSQL05.[InrixTrafficService].dbo.vendor v1 on p.VendorID = v1.VendorId 
--use the following two rows if selecing data from CS PIT Mobile
left outer join DNWMSQL02.ConnectedServicesPIT.dbo.vendorprovider vp on p.VendorID = vp.VendorID
left outer join DNWMSQL03.inrixtrafficservice.dbo.vendor v1 on p.VendorID = v1.VendorId
where (p.VendorID not in (12587, 12627, 12669, 12670)) --internal testing VendorIds  12502, 12512,  12605, 12627, 12632
group by p.VendorID, vp.VendorID, vp.[Description], v1.VendorID, v1.VendorName
order by VendorIdWhiteList, Volume desc
