use BC_PRODUKCNI
go


IF OBJECT_ID ('tempdb.dbo.##Ucty', 'U') IS NOT NULL     DROP TABLE ##Ucty
IF OBJECT_ID ('tempdb.dbo.##GL', 'U') IS NOT NULL  	    DROP TABLE ##GL
IF OBJECT_ID ('tempdb.dbo.##Final', 'U') IS NOT NULL  	DROP TABLE ##Final

/*
Sestava zobrazuje došlé faktury, které byly zaplacené za vybrané období

[Imported Date] = datum kdy byla faktura naskenována a pøijatá do systému
[Close at Date] = datum vyrovnání faktury
[Dtm_spl] = datum splatnosti
[Datum_plt] = datum vytvoøení pøíkazu k úhradì

*/
create table ##Ucty([G_L Account No_] NVARCHAR(10) COLLATE SQL_Slovak_CP1250_CI_AS)

INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501100V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501110')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501120')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501121')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501121V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501125')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501130')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501131')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501140')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501150')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501170')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('501180')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('502100H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('502110')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('502120')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('502200')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511201')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511202')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511203')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511204')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511205')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511206')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511210')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511300')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511301')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511301V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('511302')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('512100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('512100H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('512200')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('512400')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('513100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('513200')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518110')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518112')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518113')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518115')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518116')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518124')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518130')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518130V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518131')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518150')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518150V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518160')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518161')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518162')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518170')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518170V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518171')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518172')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518173')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518173V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518174')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518177')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518178')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518179')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518180')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518180V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518184')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518184V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518185')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518186')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518190')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518190V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518193')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518200')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518200H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518260')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518261V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518290')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518291')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518300')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518301')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518301V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518302')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518303')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518305')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518306')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518311')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518312')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518313')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518314')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518320')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518321')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518322')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518329')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518329V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518330')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518332')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518335')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518337')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518339')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518350')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518350H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518350V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518360')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518360H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518370')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518370V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518371')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518372')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518373')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518374')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518375')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518377')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518377V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518378')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518379')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518380')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518385')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518390')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518400')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518400H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518401')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518538')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518615')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518616')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518630')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518700H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518900')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518900H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('518900V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('531100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('532100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('532910H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('532930H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('538100H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('538110')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('538110V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('538400')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('543200')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('544100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('545100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('545100H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('545110')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548011')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548100')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548100I')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548150')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548180')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548200H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548300H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548341')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548343')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548344')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548346')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548500')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548501')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548600')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548601')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548605')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548607')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548610')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548611')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548707')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548900H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('548901H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('551140')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('551410')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('551990')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('559400')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('568120')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('568120V')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('568129')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('568161')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('568910H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('568930H')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('648004IH')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('648350')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('648351')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('900000')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('900003')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('900022')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('900033')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('900035')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('900038')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995016DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995017DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995019DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995021DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995022DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995025DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995027DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995030DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995032DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995033DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995034DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995035DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995037DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995040DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995041DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('995042DIF')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('041200')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('042140')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('042200')
INSERT INTO ##Ucty([G_L Account No_]) VALUES ('042800')

	






		SELECT [MANDANT],[G_L Account No_],[Document Kind Code],[Posting Date],[Document No_],[Global Dimension 2 Code],REPLACE(sum([Castka_ucetnictvi]),'.',',') AS [Celkem],
			   [Source No_],[Variable Symbol],[External Document No_],[User ID] ,[Cislo_Faktury],[Cisl_Dodav],[Nazev_Dodav],[Mena],[Cst_bez_DPH_sum_za_fakt],
			   [Cst_incl_DPH_sum_za_fakt],[dtm_dokl],[dtam_DPH],[Puv_dtm_DPH],[Dtm_spl],[Datum_plt],[Ocek_dtm_plt],[Imported Date],[Closed at Date],[IC]

		INTO ##Final
		

		FROM    (

											(SELECT 'CZ UCL CZ' AS [MANDANT],A.[G_L Account No_],CONVERT(VARCHAR(10),A.[Posting Date], 104) AS [Posting Date],--CONVERT(VARCHAR(12),A.[VAT Date], 104) AS [VAT Date], 
																  A.[Document Kind Code],A.[Document No_],A.[Description], A.[Global Dimension 1 Code],A.[Global Dimension 2 Code],
																  --REPLACE(A.[Amount],'.',',')  AS 
																  A.[Amount] AS [Castka_ucetnictvi] , 
																  --REPLACE(A.[Debit Amount],'.',',') AS 
																  A.[Debit Amount] AS [Debit Amount], 
																  --REPLACE(A.[Credit Amount],'.',',') AS 
																  A.[Credit Amount] AS [Credit Amount],A.[Bal_ Account No_], A.[Description 2],A.[Source No_],VendLedgEntry.[Variable Symbol],
																  A.[External Document No_],A.[User ID], VendLedgEntry.[Closed at Date],CDC.[Imported Date],
																  DF.* 

														   FROM [CZ UCL CZ$G_L Entry] A

				   												 left join
				   
																	   (select DISTINCT [No_] AS [Cislo_Faktury],[Pay-to Vendor No_] AS [Cisl_Dodav],[Pay-to Name] AS [Nazev_Dodav],
																	   (CASE	
																		WHEN [Currency Code] ='' THEN 'CZK'
																		ELSE [Currency Code]
																		END ) AS [Mena],replace(([Document Amount Excl_ VAT]-[VAT Amount]),'.',',') AS [Cst_bez_DPH_sum_za_fakt],replace(([Document Amount Excl_ VAT]),'.',',') AS [Cst_incl_DPH_sum_za_fakt], 
																		CONVERT(VARCHAR(10),[Document Date], 104) AS [dtm_dokl],
																		CONVERT(VARCHAR(12),[VAT Date], 104) AS [dtam_DPH],  CONVERT(VARCHAR(12),[Original Document VAT Date], 104) AS [Puv_dtm_DPH],
																		CONVERT(VARCHAR(12),[Due Date], 104) AS [Dtm_spl],CONVERT(VARCHAR(12),[Payment Sending Date], 104) AS [Datum_plt] ,CONVERT(VARCHAR(12),[Expected Receipt Date], 104) AS [Ocek_dtm_plt],
																				(CASE 
																					WHEN [Dimension Code]='INTERCOMPANY' THEN  [Dimension Value Code]
											
																				END) AS [IC],[Payment Sending Date]

																				from [CZ UCL CZ$Purch_ Inv_ Header] Inv
																					left join  (SELECT [Dimension Set ID],[Dimension Code],[Dimension Value Code] from [CZ UCL CZ$Dimension Set Entry] 
																								 where  [Dimension Code]='INTERCOMPANY'
																								 group by  [Dimension Set ID],[Dimension Code],[Dimension Value Code])IC
																					On Inv.[Dimension Set ID]=IC.[Dimension Set ID]) DF

																left join (select [Vendor No_],[Variable Symbol], [Posting Date],CONVERT(VARCHAR(12),[Closed at Date], 104) AS [Closed at Date], [Document No_]
																		   from [CZ UCL CZ$Vendor Ledger Entry]) VendLedgEntry

																		On VendLedgEntry.[Vendor No_] = DF.[Cisl_Dodav]	and VendLedgEntry.[Document No_]= DF.[Cislo_Faktury]


																left join (select [Source Record No_], [Created Doc_ No_],CONVERT(VARCHAR(12),[Imported Date-Time], 104) AS [Imported Date]
																		   from [CZ UCL CZ$CDC Document]) CDC

																		On DF.[Cisl_Dodav] = CDC.[Source Record No_] AND DF.Cislo_Faktury = CDC.[Created Doc_ No_]




															ON 	DF.[Cislo_Faktury]=A.[Document No_]  AND A.[Source No_]=DF.[Cisl_Dodav]

											WHERE  
											[G_L Account No_] in (SELECT [G_L Account No_] COLLATE DATABASE_DEFAULT  FROM  ##Ucty )  
											and  A.[Posting Date] >='2023-11-01' AND A.[Posting Date] <='2024-12-31'
											--and  [Payment Sending Date] between '2024-01-01' AND '2024-12-31'
											--and [Cisl_Dodav]=2441773 
											--and  [Cislo_Faktury] in('FR24B00639')
											and  [Cislo_Faktury] is not null

											---------vymazat podmínku níže

											--and A.[Closed at Date] is null
						)) vyber

	
		GROUP BY
				[MANDANT],[G_L Account No_],[Document Kind Code],[Posting Date],[Document No_],[Global Dimension 2 Code],
				[Source No_],[Variable Symbol],[External Document No_],[User ID] ,[Cislo_Faktury],[Cisl_Dodav],[Nazev_Dodav],[Mena],[Cst_bez_DPH_sum_za_fakt],
				[Cst_incl_DPH_sum_za_fakt],	[dtm_dokl],[dtam_DPH],[Puv_dtm_DPH],[Dtm_spl],[Datum_plt],[Ocek_dtm_plt],[Imported Date],[Closed at Date],[IC]


UPDATE ##Final
SET [Datum_plt] = CASE
    
    WHEN [Datum_plt] = '01.01.1753' AND [Closed at Date] = '01.01.1753' THEN [Ocek_dtm_plt]
	WHEN [Datum_plt] IS NULL OR [Datum_plt] = '01.01.1753' THEN [Closed at Date]
    ELSE [Datum_plt]
END,
	[Imported Date] = CASE
    WHEN [Imported Date] IS NULL OR [Imported Date] = '01.01.1753' THEN [dtam_DPH]
    ELSE [Imported Date]
END

select * from ##Final 




