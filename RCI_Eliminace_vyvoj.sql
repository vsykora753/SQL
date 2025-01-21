USE BC_PRODUKCNI
Go
DECLARE @MaxPostingDate		DATE 
DECLARE @Obdobi				NVARCHAR(6)
DECLARE @Company			NVARCHAR(20)
SELECT  @MaxPostingDate = '2024-11-30'  -- datum závìrky mínus 1 mìsíc
SET @Obdobi='202412'

IF OBJECT_ID ('tempdb.dbo.##DENIK', 'U') IS NOT NULL  	      DROP TABLE ##DENIK
IF OBJECT_ID ('tempdb.dbo.##81', 'U') IS NOT NULL  			  DROP TABLE ##81
--SET ansi_warnings OFF


CREATE TABLE ##DENIK
          ([G_L Account No_] NVARCHAR(7) NULL, [Posting Date] NVARCHAR(12), [VAT Date] NVARCHAR(12),[Document Kind Code] NVARCHAR(20) NULL,[Document No_] NVARCHAR(100) NULL,
		   [Description] NVARCHAR(150) NULL,[Global Dimension 2 Code] NVARCHAR(20) NULL, [Amount] NUMERIC(15,2) NULL,
		   [Debit Amount] NUMERIC(15,2) NULL, [Credit Amount] NUMERIC(15,2) NULL, [Bal_ Account No_] VARCHAR(50) NULL, [Description 2] NVARCHAR(150) NULL, [Currency Code] NVARCHAR(5)  NULL,
		   [Variable Symbol] NVARCHAR(150) NULL, [External Document No_] NVARCHAR(50) NULL,[User ID] NVARCHAR(150) NULL,[Source No_] NVARCHAR(20) NULL)

INSERT INTO ##DENIK ([G_L Account No_], [Posting Date], [VAT Date], [Document Kind Code],[Document No_], [Description], [Global Dimension 2 Code], [Amount],
		           [Debit Amount], [Credit Amount], [Bal_ Account No_],[Description 2],[Currency Code],[Variable Symbol],[External Document No_],[User ID],[Source No_])
				   
				   SELECT A.[G_L Account No_],CONVERT(VARCHAR(10),A.[Posting Date], 104),CONVERT(VARCHAR(12),A.[VAT Date], 104), A.[Document Kind Code],A.[Document No_],A.[Description], 
				          A.[Global Dimension 2 Code], A.[Amount] , A.[Debit Amount], A.[Credit Amount],A.[Bal_ Account No_], A.[Description 2],A.[Currency Code],A.[Variable Symbol],
						  A.[External Document No_],A.[User ID],A.[Source No_]

				   FROM [CZ RCI$G_L Entry] A

					WHERE A.[Posting Date] > '2024-11-30' --- @MaxPostingDate 
					AND [Journal Batch Name] like 'MAJ%'
					AND [G_L Account No_] like '%L'

																	 
					ORDER BY A.[Document No_],A.[Global Dimension 2 Code] 


INSERT INTO ##DENIK ([G_L Account No_], [Posting Date], [VAT Date], [Document Kind Code],[Document No_], [Description], [Global Dimension 2 Code], [Amount],
		           [Debit Amount], [Credit Amount], [Bal_ Account No_],[Description 2],[Currency Code],[Variable Symbol],[External Document No_],[User ID],[Source No_])
				   
				   SELECT A.[G_L Account No_],CONVERT(VARCHAR(10),A.[Posting Date], 104),CONVERT(VARCHAR(12),A.[VAT Date], 104), A.[Document Kind Code],A.[Document No_],A.[Description], 
				          A.[Global Dimension 2 Code], A.[Amount] , A.[Debit Amount], A.[Credit Amount],A.[Bal_ Account No_], A.[Description 2],A.[Currency Code],A.[Variable Symbol],
						  A.[External Document No_],A.[User ID],A.[Source No_]

				   FROM [CZ RCI$G_L Entry] A

				

					WHERE A.[Posting Date] > @MaxPostingDate 
					
					AND [G_L Account No_] like '38980%L'
																	 
					ORDER BY A.[Document No_],A.[Global Dimension 2 Code]


INSERT INTO ##DENIK ([G_L Account No_], [Posting Date], [VAT Date], [Document Kind Code],[Document No_], [Description], [Global Dimension 2 Code], [Amount],
		           [Debit Amount], [Credit Amount], [Bal_ Account No_],[Description 2],[Currency Code],[Variable Symbol],[External Document No_],[User ID],[Source No_])
				   
				   SELECT A.[Bal_ Account No_] AS [G_L Account No_],CONVERT(VARCHAR(10),A.[Posting Date], 104),CONVERT(VARCHAR(12),A.[VAT Date], 104), A.[Document Kind Code],A.[Document No_],A.[Description], 
				          A.[Global Dimension 2 Code], A.[Amount]*-1 AS [Amount] , (A.[Debit Amount]*-1) AS [Debit Amount], (A.[Credit Amount]*-1) AS [Credit Amount],A.[Bal_ Account No_], A.[Description 2],A.[Currency Code],A.[Variable Symbol],
						  A.[External Document No_],A.[User ID],A.[Source No_]

				   FROM [CZ RCI$G_L Entry] A

					

					WHERE A.[Posting Date] > @MaxPostingDate 
					
					AND [Bal_ Account No_] like '5417%L' 

					OR

					A.[Posting Date] > @MaxPostingDate 
					
					AND [Bal_ Account No_] like '5412%L' 

					OR

					A.[Posting Date] > @MaxPostingDate 
					
					AND [Bal_ Account No_] like '5488%L' 

					--OR

					--A.[Posting Date] > @MaxPostingDate 
					
					--AND [Bal_ Account No_] like '042%L' 
																	 
					ORDER BY A.[Document No_],A.[Global Dimension 2 Code]




-- výbìr dokladù k eliminaci
select [G_L Account No_], [Posting Date], [VAT Date], [Document Kind Code],[Document No_], [Description], [Global Dimension 2 Code],[Currency Code], REPLACE([Amount],'.',',') AS [Amount],
		           REPLACE([Debit Amount], '.',',') AS [Debit Amount], REPLACE([Credit Amount],'.',',') AS [Credit Amount], [Bal_ Account No_],[Description 2], [Variable Symbol],
	   [External Document No_], [User ID],[Source No_]
				   
FROM  ##DENIK 

ORDER BY  [Document No_],[Global Dimension 2 Code] ASC


-- dále udìlat script, který stejný doklad udìlá s opaènými znaménky na úèty ***E (script pro konfiguraèní balíèek)
-- odpovídá strukuøe konfig.balíèku

CREATE TABLE ##81
            ([Název šablony deníku] NVARCHAR(50),[Název listu deníku] NVARCHAR(30),[Èíslo øádku] INTEGER NULL,[Zúètovací datum] NVARCHAR(10),
			 [Typ dokladu] NVARCHAR(10),[Èíslo dokladu] NVARCHAR(30),[Kód druhu dokladu] NVARCHAR(5),[Typ úètu] NVARCHAR(20),
			 [Èíslo úètu] NVARCHAR(7),[Popis] NVARCHAR(200),[Popis 2] NVARCHAR(200), [Kód mìny] NVARCHAR(3) NULL, [MD èástka] NUMERIC(15,2) NULL,
			 [Dal èástka] NUMERIC(15,2) NULL, [Èástka] NUMERIC(15,2) NULL,[Èástka (LM)] NUMERIC(15,2) NULL,[Uèto skupina] NVARCHAR(100),[Èíslo externího dokladu] NVARCHAR(10) NULL,[Variabilní symbol] NVARCHAR(10) NULL,
			 [Typ protiúètu] NVARCHAR(20),[Èíslo protiúètu] NVARCHAR(7), [Kód pøíèiny] NVARCHAR(20),[Typ pùvodu] NVARCHAR(20),[Èíslo pùvodu] NVARCHAR(30), [Kód zkratky dimenze 2] NVARCHAR(10),[Kód zkratky dimenze 1] NVARCHAR(10))


INSERT INTO ##81  ([Název šablony deníku],[Název listu deníku],[Èíslo øádku] ,[Zúètovací datum],[Typ dokladu],[Èíslo dokladu],
			       [Kód druhu dokladu],[Typ úètu],[Èíslo úètu],[Popis] ,[Popis 2],[Kód mìny], [MD èástka], [Dal èástka],
			       [Èástka] ,[Èástka (LM)], [Uèto skupina],[Èíslo externího dokladu] ,[Variabilní symbol],[Typ protiúètu],[Èíslo protiúètu],
				   [Kód pøíèiny] ,[Typ pùvodu],[Èíslo pùvodu], [Kód zkratky dimenze 2],[Kód zkratky dimenze 1])


  SELECT 'ZAVERKA_IF' AS [Název šablony deníku], 'ZAVERKA_IF' AS [Název listu deníku],0 AS [Èíslo øádku], [Posting Date] AS [Zúètovací datum], '' AS [Typ Dokladu], 'cislo dokladu' AS  [èíslo dokladu],
  [Document Kind Code] AS [Kód druhu dokladu],'Úèet' AS [Typ úètu],substring([G_L Account No_],1,6)+'E' AS [Èíslo úètu],[Document No_] AS [Popis], 'eliminace'AS [Popis 2],[Currency Code] AS [Kód mìny],
  [Debit Amount]*-1 AS [MD],[Credit Amount]*-1 AS [DAL], [Amount]*-1 AS [Èástka], [Amount]*-1 AS [Èástka(LM)],'' AS [Uèto skupina], @Obdobi AS [Èíslo externího dokladu],'' AS [Variabilní symbol],
  'Úèet' AS [Typ protiúètu],'' AS [Èíslo protiúètu],'' AS [Kód pøíèiny], '' AS [Typ pùvodu],'' AS [Èíslo pùvodu],[Global Dimension 2 Code] AS [Kód zkratky dimenze 2],'' AS [Kód zkratky dimenze 1]

  FROM  ##DENIK 

 -- WHERE [Document No_] not in('ID24UO0029','ID24UO0030')




  ORDER BY  [Document No_],[Global Dimension 2 Code] ASC


-- select * from ##81
  
UPDATE ##81  SET [Èíslo dokladu]=B.[CislDokladu]
FROM ##81 A
INNER JOIN (SELECT [Series Code], ( CASE 
	                                        WHEN convert(varchar(15),[Last No_ Used])='' then [Starting No_]
		                                    ELSE substring(convert(varchar(20),[Last No_ Used]),1,3)+ convert(varchar(20),convert(INT,substring(convert(varchar(20),[Last No_ Used]),4,7))+[Increment-by No_]) END) AS [CislDokladu]
                    FROM [CZ RCI$No_ Series Line] 
                    WHERE [Series Code]='ZAVERKA_IF' AND Year([Starting Date])=Year(Getdate()))  B
					
		ON B.[Series Code]=A.[Název šablony deníku] COLLATE DATABASE_DEFAULT  -- aktualizuje èíselnou øadu dokladù 

 ---pro vytvoøení tabulky s èíslováním øádkù pro import pøes konfiguraèní balícek.

   
DECLARE  @Row AS INT
DECLARE  @LnNo  AS  INT
SELECT  @LnNo = 10

DECLARE  tbl81 CURSOR FOR 
         SELECT [Èíslo øádku] FROM ##81
         OPEN tbl81
         FETCH NEXT FROM tbl81 INTO @Row
		
         WHILE @@FETCH_STATUS = 0
		     
              BEGIN
			  IF @Row=0
			  update Top(1) ##81 SET [Èíslo øádku] = @LnNo  WHERE [Èíslo øádku]= 0
			  SELECT @LnNo=  @LnNo + 10 
			                
              FETCH NEXT FROM tbl81 INTO @Row
         END
         CLOSE tbl81
         DEALLOCATE tbl81

		
SELECT * FROM ##81


  ----script pro doklad, který se vkládá do finanèních deníkù


  -- SELECT [Posting Date] AS [Zúètovací datum], '' AS [Typ Dokladu], 'ZI23000094' AS  [èíslo dokladu], 'ID' AS [Kód druhu dokladu],'Úèet' AS [Typ úètu],substring([G_L Account No_],1,6)+'E' AS [Èíslo úètu],[Document No_] AS [Popis], 'eliminace'AS [Popis 2],[Currency Code] AS [Kód mìny],
  --[Debit Amount]*-1 AS [MD],[Credit Amount]*-1 AS [DAL], [Amount] * -1 AS [Èástka], [Amount]*-1 AS [Èástka(LM)],'Úèet' AS [Typ protiúètu],''	AS [Èíslo protiúètu], @Obdobi AS [Èíslo externího dokladu],'' AS [Variabilní symbol],
  --[Global Dimension 2 Code] AS [Kód zkratky dimenze 2],'' AS [Kód zkratky dimenze 1],'' AS [Intercompany], 'Ne' AS OPRAVA, 'Ne' AS [BLokovatUctovani]

  --FROM  ##DENIK 

  --ORDER BY  [Document No_],[Global Dimension 2 Code] ASC
  


--kontrola zda po zaúètování zda je eliminace správnì ?,  tedy úèty E a L jdou do nuly

SELECT SUBSTRING([G_L Account No_],1,6) AS [G_L Account No_],Sum([Sum$Amount]) AS [Saldo]
FROM [CZ RCI$G_L Entry$VSIFT$1]
WHERE [Posting Date]<='2024-12-31'
AND SUBSTRING([G_L Account No_],7,1) IN('E','L') 

GROUP BY SUBSTRING([G_L Account No_],1,6)
HAVING Sum([Sum$Amount])<>0


		 