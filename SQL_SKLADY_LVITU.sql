Use bc_produkcni
Go
--seznam -> odebrané pøedmìty

IF OBJECT_ID ('tempdb.dbo.##OP', 'U') IS NOT NULL  	          DROP TABLE ##OP
IF OBJECT_ID ('tempdb.dbo.##UD', 'U') IS NOT NULL  	          DROP TABLE ##UD
IF OBJECT_ID ('tempdb.dbo.##Prijemky', 'U') IS NOT NULL  	  DROP TABLE ##Prijemky
IF OBJECT_ID ('tempdb.dbo.##HK', 'U') IS NOT NULL  			  DROP TABLE ##HK
IF OBJECT_ID ('tempdb.dbo.##Vydejky', 'U') IS NOT NULL  	  DROP TABLE ##Vydejky
IF OBJECT_ID ('tempdb.dbo.##ALLVydejky', 'U') IS NOT NULL  	  DROP TABLE ##ALLVydejky

SELECT *INTO ##HK 
				FROM  ( SELECT [G_L Account No_],[Global Dimension 2 Code],'CZK' AS [MENA],SUM([SUM$Amount]) AS [CzkAmount]	
						 FROM [CZ UCL CZ$G_L Entry$VSIFT$17]
						 WHERE[Posting Date] between '2014-12-31' and  '2021-11-30'
						 AND [G_L Account No_] IN('042600','325510','641600')
						 GROUP BY [G_L Account No_], [Global Dimension 2 Code]
						 HAVING  SUM([SUM$Amount]) <>0 

			   ) AS Header

               PIVOT

			   (Sum([CzkAmount]) For [G_L Account No_] IN([042600],[325510],[641600])) AS [CzkAmount]

--- rozpis úètu po smlouvì----konec---			
--------- Vytvoøení listu OP ---------
select 
       A.[No_],A.[Global Dimension 2 Code] AS [Smlouva],
		(case
			when B.[Financing Type]=0 then 'FL'
			when B.[Financing Type]=1 then 'OL'
			when B.[Financing Type]=2 then 'UV'
			when B.[Financing Type]=3 then 'SP'
		 else ''
		 end) AS  [Financing Type], C.[Actual Record],A.[Description], 
		(case
			when [Object Type]= 1 then 'Vlastní'
			when [Object Type]= 2 then 'Leasingový'
			when [Object Type]= 3 then 'Odebraný'
		else ''
		end ) AS [Typ_Majetku],
		(case 
			when [Object Status]=0 then 'Nový'
			when [Object Status]=1 then 'Blokovaný'
			when [Object Status]=2 then 'Problém'
			when [Object Status]=3 then 'Evidovaný'
			when [Object Status]=4 then 'U znalce'
			when [Object Status]=5 then 'Vystavený'
			when [Object Status]=6 then 'Ukonèený'
		 else ''
		 end) AS [Stav_Predmetu], 
		 A.[Financed Object No_] AS [Cislo_predmetu_],
		 (case
			when A.[Takeover]=1 then 'Èásteèné'
			when A.[Takeover]=2 then 'Úplné'
          else ''
		  end ) AS [Prevzeti],A.[Machine Registration No_] AS [Registracni_Cislo], [VIN] AS [Cislo_karoserie],
		  round(C.[Expert Evid_ Cost Excl_ VAT],2) AS [LAM_Cena],
		  round([Residual Value Excl_ VAT],2) AS [Ucet_ZustHodnota],[Warehouse Receipt Date] AS [Prevzeti_sklad],
		  D.[No_] AS [FA No_], D.[FA Class Code],D.[Disposed], D.[Disposal Date] AS [Dat_vyrazeni],D.[To Disposal] AS [Kod_vyrazeni], [Positive Adjmt_ Posted] AS [Prijem_zauct],
		  UD.[Dat_Uct_Prijemky],Sk.Cisl_Prijemka ,PR.[Castka_Ucto_Prijemka],[Negative Adjmt_ Posted] AS [Vydej_zauct],UD.[Dat_Uct_Vydejky],Sk.Cisl_Vydejka,VY.Castka_Ucto_Vydejka,
		  [Customer Name] AS [Nazev_Zakaznika],  HK.[042600],HK.[325510],HK.[641600]


		  INTO ##OP
  from [CZ UCL CZ$Removed Object] A
  left join [CZ UCL CZ$LEA Contract Header] B
  On B.[No_]=A.[Global Dimension 2 Code]
  left join [CZ UCL CZ$Removed Object Appraisal] C
  On A.[No_]=C.[Removed Object No_]
  left join [CZ UCL CZ$Fixed Asset] D
  On D.[No_]=A.[Financed Object No_]
  Left join (SELECT * FROM

			(select [Removed Object No_], (case
											when [Document Type]=0 then 'Dat_Uct_Prijemky'
											when [Document Type]=1 then 'Dat_Uct_Vydejky'
											else ''
											end ) AS [Document Type],Min([Posting Date]) AS [Zuct_Datum]
			 from [CZ UCL CZ$Posted Removed Object Document]
			 where  [Financing Type]=2 	and [Canceled]=0 and [Revoked]=0
			        --and [Removed Object No_] in('3135')
			 Group by [Removed Object No_],[Document Type]

			 ) AS header

			 PIVOT

            (Min([Zuct_Datum]) For [Document Type] IN([Dat_Uct_Prijemky],[Dat_Uct_Vydejky])) AS [Zuct_Datum]) UD


ON UD.[Removed Object No_]=A.[No_]
Left join (SELECT * 
				  FROM  ( SELECT [G_L Account No_],[Global Dimension 2 Code],'CZK' AS [MENA],SUM([SUM$Amount]) AS [CzkAmount]	
						 FROM [CZ UCL CZ$G_L Entry$VSIFT$17]
						 WHERE[Posting Date] between '2014-12-31' and  '2021-11-30'
						 AND [G_L Account No_] IN('042600','325510','641600')
						 GROUP BY [G_L Account No_], [Global Dimension 2 Code]
						 HAVING  SUM([SUM$Amount]) <>0 

			      ) AS Header

                  PIVOT

			     (Sum([CzkAmount]) For [G_L Account No_] IN([042600],[325510],[641600])) AS [CzkAmount] ) HK

ON HK.[Global Dimension 2 Code]=A.[Global Dimension 2 Code]
Left join(SELECT * FROM

			(select [Removed Object No_], (case
											when [Document Type]=0 then 'Cisl_Prijemka'
											when [Document Type]=1 then 'Cisl_Vydejka'
											else ''
											end ) AS [Document Type],Max([No_]) AS [Cisl_dokladu]
			 from [CZ UCL CZ$Posted Removed Object Document]
			 where  [Financing Type]=2 	and [Canceled]=0 and [Revoked]=0
			        --and [Removed Object No_] in('3135')
			 Group by [Removed Object No_],[Document Type]

			 ) AS header

			 PIVOT

            (Max([Cisl_dokladu]) For [Document Type] IN([Cisl_Prijemka],[Cisl_Vydejka])) AS [Cisl_dokladu] ) SK	 

On SK.[Removed Object No_]=A.[No_]


left join (SELECT [No_],[Removed Object No_],[Amount] AS [Castka_Ucto_Prijemka]  from [CZ UCL CZ$Posted Removed Object Document]
           where    [Document Type]=0) PR
ON PR.[Removed Object No_]= SK.[Removed Object No_] AND PR.[No_]=SK.[Cisl_Prijemka]

left join (SELECT [No_],[Removed Object No_],[Amount] AS [Castka_Ucto_Vydejka]  from [CZ UCL CZ$Posted Removed Object Document]
           where    [Document Type]=1) VY
ON VY.[Removed Object No_]= SK.[Removed Object No_] AND VY.[No_]=SK.[Cisl_Vydejka]


where  Isnull(C.[Actual Record],1) in(1)  AND B.[Financing Type]=2 
         --AND A.[No_] in('1010','1011','1016','1018','1134')
order by A.[No_] asc
-------- vytvoøení listu OP ------ konec



--vytvoøení listu UD----------zaèátek
--zaúètované odebrané pøedmìty na sklad
select [Removed Object No_],[No_] AS [Cislo],
       (case
	    when [Document Type]=0 then 'Pøíjem'
		when [Document Type]=1 then 'Výdej'
		else ''
		end ) AS [Document Type]
       ,[Posting Date] AS [Zuct_Datum],
	   (case
			when [Financing Type]=0 then 'FL'
			when [Financing Type]=1 then 'OL'
			when [Financing Type]=2 then 'UV'
			when [Financing Type]=3 then 'SP'
		 else ''
		 end) AS  [Financing Type]
       ,[Global Dimension 2 Code] AS [Smlouva]
       ,[Amount] AS [Castka]
       ,[Description]
       ,[Fin_ Journal Template Name]
       ,[Std_ Financial Journal Code]
  into ##UD     
  from [CZ UCL CZ$Posted Removed Object Document]
  where [Posting Date] between '2021-11-01' and '2021-11-30' and 
        [Financing Type]=2
		and [Canceled]=0 and [Revoked]=0
--vytvoøení listu UD----------konec

--- pouze pøíjemky --zaèátek
select distinct ##UD.[Removed Object No_], ##UD.Cislo,##UD.[Zuct_Datum],##UD.[Document Type], ##UD.[Financing Type],##UD.[Smlouva],##UD.[Castka],[LAM_Cena],[Ucet_ZustHodnota], [FA No_],[Stav_Predmetu],
       Isnull([LAM_Cena],[Ucet_ZustHodnota]) AS [042600->325510],Vydejky.[Smlouva] AS [Vydejka]
into ##Prijemky     
from ##UD
Left join ##OP
ON ##UD.[Removed Object No_]=##OP.No_
Left join (select [No_] AS [Cislo],[Removed Object No_],
           (case
			when [Document Type]=0 then 'Pøíjem'
			when [Document Type]=1 then 'Výdej'
			else ''
			end ) AS [Document Type],[Posting Date] AS [Zuct_Datum],
			(case
				when [Financing Type]=0 then 'FL'
				when [Financing Type]=1 then 'OL'
				when [Financing Type]=2 then 'UV'
				when [Financing Type]=3 then 'SP'
			else ''
			end) AS  [Financing Type] ,[Global Dimension 2 Code] AS [Smlouva],[Amount] AS [Castka],[Description] ,[Fin_ Journal Template Name] ,[Std_ Financial Journal Code]
     
			from [CZ UCL CZ$Posted Removed Object Document]
			where  [Financing Type]=2 and [Canceled]=0 and [Revoked]=0 and [Document Type]=1
			
			)  Vydejky
 On Vydejky.[Smlouva]=##UD.Smlouva
   
 where  ##UD.[Zuct_Datum] between '2021-11-01' and '2021-11-30'	and 
		##UD.[Financing Type]='UV'and ##UD.[Document Type]='Pøíjem'
--- pouze pøíjemky --konec

--- pouze vydejky --zaèátek
select distinct ##UD.[Removed Object No_],##UD.Cislo,##UD.[Zuct_Datum],##UD.[Document Type], ##UD.[Financing Type],##UD.[Smlouva],##UD.[Castka],[LAM_Cena],[Ucet_ZustHodnota], [FA No_],
				[Disposed],[Stav_Predmetu],##OP.[042600],##OP.[325510],##OP.[641600],'dodìlat vzorec' AS [Rozdíl mezi 325510 a 641600],##OP.[Kod_vyrazeni]

       
	   --Isnull([LAM_Cena],[Ucet_ZustHodnota]) AS [042600->325510],Vydejky.[Smlouva] AS [Vydejka]
into ##Vydejky     
from ##UD
Left join ##OP
ON ##UD.[Removed Object No_]=##OP.No_
Left join (select [No_] AS [Cislo],[Removed Object No_],
           (case
			when [Document Type]=0 then 'Pøíjem'
			when [Document Type]=1 then 'Výdej'
			else ''
			end ) AS [Document Type],[Posting Date] AS [Zuct_Datum],
			(case
				when [Financing Type]=0 then 'FL'
				when [Financing Type]=1 then 'OL'
				when [Financing Type]=2 then 'UV'
				when [Financing Type]=3 then 'SP'
			else ''
			end) AS  [Financing Type] ,[Global Dimension 2 Code] AS [Smlouva],[Amount] AS [Castka],[Description] ,[Fin_ Journal Template Name] ,[Std_ Financial Journal Code]
     
			from [CZ UCL CZ$Posted Removed Object Document]
			where  [Financing Type]=2 and [Canceled]=0 and [Revoked]=0
			and [Document Type]=1)  Vydejky
 On Vydejky.[Smlouva]=##UD.Smlouva
 Left join (SELECT *
                  FROM  ( SELECT [G_L Account No_],[Global Dimension 2 Code],'CZK' AS [MENA],SUM([SUM$Amount]) AS [CzkAmount]
                         FROM [CZ UCL CZ$G_L Entry$VSIFT$17]
                         WHERE[Posting Date] between '2014-12-31' and  '2021-11-30'
                         AND [G_L Account No_] IN('042600','325510','641600')
                         GROUP BY [G_L Account No_], [Global Dimension 2 Code]
                         HAVING Sum([SUM$Amount]) <> 0

                  ) AS Header

                  PIVOT

                 (Sum([CzkAmount]) For [G_L Account No_] IN([042600],[325510],[641600])) AS [CzkAmount] ) HK


 On HK.[Global Dimension 2 Code]=##UD.[Smlouva]

 where   ##UD.[Zuct_Datum] between '2021-11-01' and '2021-11-30' 	and 
         ##UD.[Financing Type]='UV'
		 and ##UD.[Document Type]='Výdej'

---pouze vydejky ---konec

--- pouze vše vydejky --zaèátek
select distinct ##UD.Cislo,##UD.[Removed Object No_],##UD.[Zuct_Datum],##UD.[Document Type], ##UD.[Financing Type],##UD.[Smlouva],##UD.[Castka],[LAM_Cena],[Ucet_ZustHodnota], [FA No_],
				[Disposed],[Stav_Predmetu],##OP.[042600],##OP.[325510],##OP.[641600],'dodìlat vzorec' AS [Rozdíl mezi 325510 a 641600],##OP.[Kod_vyrazeni]

       
	   --Isnull([LAM_Cena],[Ucet_ZustHodnota]) AS [042600->325510],Vydejky.[Smlouva] AS [Vydejka]
into ##ALLVydejky     
from (select [No_] AS [Cislo],[Removed Object No_],
       (case
	    when [Document Type]=0 then 'Pøíjem'
		when [Document Type]=1 then 'Výdej'
		else ''
		end ) AS [Document Type]
       ,[Posting Date] AS [Zuct_Datum],
	   (case
			when [Financing Type]=0 then 'FL'
			when [Financing Type]=1 then 'OL'
			when [Financing Type]=2 then 'UV'
			when [Financing Type]=3 then 'SP'
		 else ''
		 end) AS  [Financing Type]
       ,[Global Dimension 2 Code] AS [Smlouva]
       ,[Amount] AS [Castka]
       ,[Description]
       ,[Fin_ Journal Template Name]
       ,[Std_ Financial Journal Code]
     
  from [CZ UCL CZ$Posted Removed Object Document]
  where --[Posting Date] between '2021-10-01' and '2021-10-31' and 
        [Financing Type]=2
		and [Canceled]=0 and [Revoked]=0 ) ##UD
Left join ##OP
ON ##UD.[Removed Object No_]=##OP.No_
Left join (select [No_] AS [Cislo],[Removed Object No_],
           (case
			when [Document Type]=0 then 'Pøíjem'
			when [Document Type]=1 then 'Výdej'
			else ''
			end ) AS [Document Type],[Posting Date] AS [Zuct_Datum],
			(case
				when [Financing Type]=0 then 'FL'
				when [Financing Type]=1 then 'OL'
				when [Financing Type]=2 then 'UV'
				when [Financing Type]=3 then 'SP'
			else ''
			end) AS  [Financing Type] ,[Global Dimension 2 Code] AS [Smlouva],[Amount] AS [Castka],[Description] ,[Fin_ Journal Template Name] ,[Std_ Financial Journal Code]
     
			from [CZ UCL CZ$Posted Removed Object Document]
			where  [Financing Type]=2 and [Canceled]=0 and [Revoked]=0	and [Document Type]=1 )  Vydejky
 On Vydejky.[Smlouva]=##UD.Smlouva
 Left join ##HK 
 On ##HK.[Global Dimension 2 Code]=##UD.[Smlouva]
 where   --##UD.[Zuct_Datum] between '2021-10-01' and '2021-10-31' 	and 
         ##UD.[Financing Type]='UV'
		 and ##UD.[Document Type]='Výdej'

---vše vydejky ---konec

--- rozpis úètu po smlouvì----


SELECT * FROM ##UD  order by [Removed Object No_] asc
SELECT * FROM ##Prijemky 
SELECT * FROM ##Vydejky 
SELECT * FROM ##OP order by [No_] asc
SELECT * FROM ##HK
SELECT * FROM ##ALLVydejky 

--SELECT * FROM ##OP
--left join ##Prijemky 
--ON ##OP.No_=##Prijemky.[Removed Object No_]
--left join  ##Vydejky
--ON ##OP.No_=##Vydejky.[Removed Object No_]
--left join ##HK
--On ##HK.[Global Dimension 2 Code]=##OP.[Smlouva]

--order by [No_]









--IF OBJECT_ID ('tempdb.dbo.##OP', 'U') IS NOT NULL  	          DROP TABLE ##OP
--------- Vytvoøení listu OP ---------
--select 
--       A.[No_],A.[Global Dimension 2 Code] AS [Smlouva],
--		(case
--			when B.[Financing Type]=0 then 'FL'
--			when B.[Financing Type]=1 then 'OL'
--			when B.[Financing Type]=2 then 'UV'
--			when B.[Financing Type]=3 then 'SP'
--		 else ''
--		 end) AS  [Financing Type], C.[Actual Record],A.[Description], 
--		(case
--			when [Object Type]= 1 then 'Vlastní'
--			when [Object Type]= 2 then 'Leasingový'
--			when [Object Type]= 3 then 'Odebraný'
--		else ''
--		end ) AS [Typ_Majetku],
--		(case 
--			when [Object Status]=0 then 'Nový'
--			when [Object Status]=1 then 'Blokovaný'
--			when [Object Status]=2 then 'Problém'
--			when [Object Status]=3 then 'Evidovaný'
--			when [Object Status]=4 then 'U znalce'
--			when [Object Status]=5 then 'Vystavený'
--			when [Object Status]=6 then 'Ukonèený'
--		 else ''
--		 end) AS [Stav_Predmetu], 
--		 A.[Financed Object No_] AS [Cislo_predmetu_],
--		 (case
--			when A.[Takeover]=1 then 'Èásteèné'
--			when A.[Takeover]=2 then 'Úplné'
--          else ''
--		  end ) AS [Prevzeti],A.[Machine Registration No_] AS [Registracni_Cislo], [VIN] AS [Cislo_karoserie],
--		  round(C.[Expert Evid_ Cost Excl_ VAT],2) AS [LAM_Cena],
--		  round([Residual Value Excl_ VAT],2) AS [Ucet_ZustHodnota],[Warehouse Receipt Date] AS [Prevzeti_sklad],
--		  D.[No_] AS [FA No_], D.[FA Class Code],D.[Disposed], D.[Disposal Date] AS [Dat_vyrazeni],D.[To Disposal] AS [Kod_vyrazeni], [Positive Adjmt_ Posted] AS [Prijem_zauct],
--		  UD.[Dat_Uct_Prijemky], [Negative Adjmt_ Posted] AS [Vydej_zauct],UD.[Dat_Uct_Vydejky],[Customer Name] AS [Nazev_Zakaznika],
--		  HK.[042600],HK.[325510],HK.[641600]


--		  INTO ##OP
--  from [CZ UCL CZ$Removed Object] A
--  left join [CZ UCL CZ$LEA Contract Header] B
--  On B.[No_]=A.[Global Dimension 2 Code]
--  left join [CZ UCL CZ$Removed Object Appraisal] C
--  On A.[No_]=C.[Removed Object No_]
--  left join [CZ UCL CZ$Fixed Asset] D
--  On D.[No_]=A.[Financed Object No_]
--  Left join (SELECT * FROM

--			(select [Removed Object No_], (case
--											when [Document Type]=0 then 'Dat_Uct_Prijemky'
--											when [Document Type]=1 then 'Dat_Uct_Vydejky'
--											else ''
--											end ) AS [Document Type],Min([Posting Date]) AS [Zuct_Datum]
--			 from [CZ UCL CZ$Posted Removed Object Document]
--			 where  [Financing Type]=2 	and [Canceled]=0 and [Revoked]=0
--			        --and [Removed Object No_] in('3135')
--			 Group by [Removed Object No_],[Document Type]

--			 ) AS header

--			 PIVOT

--            (Min([Zuct_Datum]) For [Document Type] IN([Dat_Uct_Prijemky],[Dat_Uct_Vydejky])) AS [Zuct_Datum]) UD


--ON UD.[Removed Object No_]=A.[No_]
--Left join (SELECT * 
--				  FROM  ( SELECT [G_L Account No_],[Global Dimension 2 Code],'CZK' AS [MENA],SUM([SUM$Amount]) AS [CzkAmount]	
--						 FROM [CZ UCL CZ$G_L Entry$VSIFT$17]
--						 WHERE[Posting Date] between '2014-12-31' and  '2021-10-31'
--						 AND [G_L Account No_] IN('042600','325510','641600')
--						 GROUP BY [G_L Account No_], [Global Dimension 2 Code]
--						 HAVING  SUM([SUM$Amount]) <>0 

--			      ) AS Header

--                  PIVOT

--			     (Sum([CzkAmount]) For [G_L Account No_] IN([042600],[325510],[641600])) AS [CzkAmount] ) HK

--ON HK.[Global Dimension 2 Code]=A.[Global Dimension 2 Code]




--where  Isnull(C.[Actual Record],1) in(1)  AND B.[Financing Type]=2 
--         --AND A.[No_] in('1010','1011','1016','1018','1134')
--order by A.[No_] asc
-------- vytvoøení listu OP ------ konec


--SELECT * FROM ##OP order by [No_] asc