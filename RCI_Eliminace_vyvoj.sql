USE BC_PRODUKCNI
Go
DECLARE @MaxPostingDate		DATE 
DECLARE @Obdobi				NVARCHAR(6)
DECLARE @Company			NVARCHAR(20)
SELECT  @MaxPostingDate = '2024-11-30'  -- datum z�v�rky m�nus 1 m�s�c
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




-- v�b�r doklad� k eliminaci
select [G_L Account No_], [Posting Date], [VAT Date], [Document Kind Code],[Document No_], [Description], [Global Dimension 2 Code],[Currency Code], REPLACE([Amount],'.',',') AS [Amount],
		           REPLACE([Debit Amount], '.',',') AS [Debit Amount], REPLACE([Credit Amount],'.',',') AS [Credit Amount], [Bal_ Account No_],[Description 2], [Variable Symbol],
	   [External Document No_], [User ID],[Source No_]
				   
FROM  ##DENIK 

ORDER BY  [Document No_],[Global Dimension 2 Code] ASC


-- d�le ud�lat script, kter� stejn� doklad ud�l� s opa�n�mi znam�nky na ��ty ***E (script pro konfigura�n� bal��ek)
-- odpov�d� struku�e konfig.bal��ku

CREATE TABLE ##81
            ([N�zev �ablony den�ku] NVARCHAR(50),[N�zev listu den�ku] NVARCHAR(30),[��slo ��dku] INTEGER NULL,[Z��tovac� datum] NVARCHAR(10),
			 [Typ dokladu] NVARCHAR(10),[��slo dokladu] NVARCHAR(30),[K�d druhu dokladu] NVARCHAR(5),[Typ ��tu] NVARCHAR(20),
			 [��slo ��tu] NVARCHAR(7),[Popis] NVARCHAR(200),[Popis 2] NVARCHAR(200), [K�d m�ny] NVARCHAR(3) NULL, [MD ��stka] NUMERIC(15,2) NULL,
			 [Dal ��stka] NUMERIC(15,2) NULL, [��stka] NUMERIC(15,2) NULL,[��stka (LM)] NUMERIC(15,2) NULL,[U�to skupina] NVARCHAR(100),[��slo extern�ho dokladu] NVARCHAR(10) NULL,[Variabiln� symbol] NVARCHAR(10) NULL,
			 [Typ proti��tu] NVARCHAR(20),[��slo proti��tu] NVARCHAR(7), [K�d p���iny] NVARCHAR(20),[Typ p�vodu] NVARCHAR(20),[��slo p�vodu] NVARCHAR(30), [K�d zkratky dimenze 2] NVARCHAR(10),[K�d zkratky dimenze 1] NVARCHAR(10))


INSERT INTO ##81  ([N�zev �ablony den�ku],[N�zev listu den�ku],[��slo ��dku] ,[Z��tovac� datum],[Typ dokladu],[��slo dokladu],
			       [K�d druhu dokladu],[Typ ��tu],[��slo ��tu],[Popis] ,[Popis 2],[K�d m�ny], [MD ��stka], [Dal ��stka],
			       [��stka] ,[��stka (LM)], [U�to skupina],[��slo extern�ho dokladu] ,[Variabiln� symbol],[Typ proti��tu],[��slo proti��tu],
				   [K�d p���iny] ,[Typ p�vodu],[��slo p�vodu], [K�d zkratky dimenze 2],[K�d zkratky dimenze 1])


  SELECT 'ZAVERKA_IF' AS [N�zev �ablony den�ku], 'ZAVERKA_IF' AS [N�zev listu den�ku],0 AS [��slo ��dku], [Posting Date] AS [Z��tovac� datum], '' AS [Typ Dokladu], 'cislo dokladu' AS  [��slo dokladu],
  [Document Kind Code] AS [K�d druhu dokladu],'��et' AS [Typ ��tu],substring([G_L Account No_],1,6)+'E' AS [��slo ��tu],[Document No_] AS [Popis], 'eliminace'AS [Popis 2],[Currency Code] AS [K�d m�ny],
  [Debit Amount]*-1 AS [MD],[Credit Amount]*-1 AS [DAL], [Amount]*-1 AS [��stka], [Amount]*-1 AS [��stka(LM)],'' AS [U�to skupina], @Obdobi AS [��slo extern�ho dokladu],'' AS [Variabiln� symbol],
  '��et' AS [Typ proti��tu],'' AS [��slo proti��tu],'' AS [K�d p���iny], '' AS [Typ p�vodu],'' AS [��slo p�vodu],[Global Dimension 2 Code] AS [K�d zkratky dimenze 2],'' AS [K�d zkratky dimenze 1]

  FROM  ##DENIK 

 -- WHERE [Document No_] not in('ID24UO0029','ID24UO0030')




  ORDER BY  [Document No_],[Global Dimension 2 Code] ASC


-- select * from ##81
  
UPDATE ##81  SET [��slo dokladu]=B.[CislDokladu]
FROM ##81 A
INNER JOIN (SELECT [Series Code], ( CASE 
	                                        WHEN convert(varchar(15),[Last No_ Used])='' then [Starting No_]
		                                    ELSE substring(convert(varchar(20),[Last No_ Used]),1,3)+ convert(varchar(20),convert(INT,substring(convert(varchar(20),[Last No_ Used]),4,7))+[Increment-by No_]) END) AS [CislDokladu]
                    FROM [CZ RCI$No_ Series Line] 
                    WHERE [Series Code]='ZAVERKA_IF' AND Year([Starting Date])=Year(Getdate()))  B
					
		ON B.[Series Code]=A.[N�zev �ablony den�ku] COLLATE DATABASE_DEFAULT  -- aktualizuje ��selnou �adu doklad� 

 ---pro vytvo�en� tabulky s ��slov�n�m ��dk� pro import p�es konfigura�n� bal�cek.

   
DECLARE  @Row AS INT
DECLARE  @LnNo  AS  INT
SELECT  @LnNo = 10

DECLARE  tbl81 CURSOR FOR 
         SELECT [��slo ��dku] FROM ##81
         OPEN tbl81
         FETCH NEXT FROM tbl81 INTO @Row
		
         WHILE @@FETCH_STATUS = 0
		     
              BEGIN
			  IF @Row=0
			  update Top(1) ##81 SET [��slo ��dku] = @LnNo  WHERE [��slo ��dku]= 0
			  SELECT @LnNo=  @LnNo + 10 
			                
              FETCH NEXT FROM tbl81 INTO @Row
         END
         CLOSE tbl81
         DEALLOCATE tbl81

		
SELECT * FROM ##81


  ----script pro doklad, kter� se vkl�d� do finan�n�ch den�k�


  -- SELECT [Posting Date] AS [Z��tovac� datum], '' AS [Typ Dokladu], 'ZI23000094' AS  [��slo dokladu], 'ID' AS [K�d druhu dokladu],'��et' AS [Typ ��tu],substring([G_L Account No_],1,6)+'E' AS [��slo ��tu],[Document No_] AS [Popis], 'eliminace'AS [Popis 2],[Currency Code] AS [K�d m�ny],
  --[Debit Amount]*-1 AS [MD],[Credit Amount]*-1 AS [DAL], [Amount] * -1 AS [��stka], [Amount]*-1 AS [��stka(LM)],'��et' AS [Typ proti��tu],''	AS [��slo proti��tu], @Obdobi AS [��slo extern�ho dokladu],'' AS [Variabiln� symbol],
  --[Global Dimension 2 Code] AS [K�d zkratky dimenze 2],'' AS [K�d zkratky dimenze 1],'' AS [Intercompany], 'Ne' AS OPRAVA, 'Ne' AS [BLokovatUctovani]

  --FROM  ##DENIK 

  --ORDER BY  [Document No_],[Global Dimension 2 Code] ASC
  


--kontrola zda po za��tov�n� zda je eliminace spr�vn� ?,  tedy ��ty E a L jdou do nuly

SELECT SUBSTRING([G_L Account No_],1,6) AS [G_L Account No_],Sum([Sum$Amount]) AS [Saldo]
FROM [CZ RCI$G_L Entry$VSIFT$1]
WHERE [Posting Date]<='2024-12-31'
AND SUBSTRING([G_L Account No_],7,1) IN('E','L') 

GROUP BY SUBSTRING([G_L Account No_],1,6)
HAVING Sum([Sum$Amount])<>0


		 