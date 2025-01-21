USE BC_PRODUKCNI
----Den�k
-- !!!!  upravit sql tak aby se od��tov�val kurz.rozd�l doklad 'KR' na ��ty 563/663 pozn. ze dne 4.9.2018
---!!!! prov�st kontrolu Group Ucet, Code, Castka pro ��ty 76* mus� j�t do nuly


IF OBJECT_ID ('tempdb.dbo.##DENIK', 'U') IS NOT NULL  	      DROP TABLE ##DENIK
IF OBJECT_ID ('tempdb.dbo.##81', 'U') IS NOT NULL  	          DROP TABLE ##81

-- !!!!!! doklad 'ID21US0001 nebrat jde o p�e��tov�n�, je t�eba omezit datem od 02.9.21

SELECT (SUBSTRING([G_L Account No_],1,3)) AS [UCET], [GLobal Dimension 2 Code], SUM( [CZ UCL CZ$G_L Entry].[Amount]) AS CASTKA  
								    FROM  [CZ UCL CZ$G_L Entry]
								    WHERE [Posting Date] <='2024-12-31' AND [G_L Account No_] like '760%' 
									--AND [Document No_] NOT LIKE 'KR%'  --> doklady kurz.rozd�l� vzl᚝
								    GROUP BY (SUBSTRING([G_L Account No_],1,3)),[GLobal Dimension 2 Code]
								    HAVING SUM([Amount])<>0



CREATE TABLE ##DENIK
          ([G_L Account No_] NVARCHAR(7) NULL, [Posting Date] NVARCHAR(12), [Document No_] NVARCHAR(20) NULL,
		   [Description] NVARCHAR(150) NULL,[Global Dimension 2 Code] NVARCHAR(20) NULL,[DruhSml] NVARCHAR(10) NULL, [Amount] NUMERIC(15,2) NULL,
		   [Debit Amount] NUMERIC(15,2) NULL, [Credit Amount] NUMERIC(15,2) NULL, [Description 2] NVARCHAR(150) NULL,
		   [Variable Symbol] NVARCHAR(20) NULL)


INSERT INTO ##DENIK ([G_L Account No_], [Posting Date], [Document No_], [Description], [Global Dimension 2 Code], [DruhSml], [Amount],
		           [Debit Amount], [Credit Amount], [Description 2], [Variable Symbol])
	
				   

--> ��st mimo kurz.rozd�ly


				   SELECT A.[G_L Account No_],CONVERT(VARCHAR(10),A.[Posting Date], 104),A.[Document No_],A.[Description], A.[Global Dimension 2 Code],
					SUBSTRING(C.[Gen_ Prod_ Posting Group],1,2),A.[Amount], A.[Debit Amount], A.[Credit Amount], A.[Description 2],A.[Variable Symbol]

				   FROM [CZ UCL CZ$G_L Entry] A
				   		INNER JOIN (SELECT (SUBSTRING([G_L Account No_],1,3)) AS [UCET], [GLobal Dimension 2 Code], SUM( [CZ UCL CZ$G_L Entry].[Amount]) AS CASTKA  
								    FROM  [CZ UCL CZ$G_L Entry]
								    WHERE [Posting Date] <='2024-12-31' AND [G_L Account No_] like '760%' 
									AND [Document No_] NOT LIKE 'KR%'  --> doklady kurz.rozd�l� vzl᚝
								    GROUP BY SUBSTRING([G_L Account No_],1,3),[GLobal Dimension 2 Code]
								    HAVING SUM([Amount])<>0
								) B
					    ON A.[GLobal Dimension 2 Code]=B.[GLobal Dimension 2 Code] AND B.[UCET]=SUBSTRING([G_L Account No_],1,3)
						LEFT JOIN [CZ UCL CZ$LEA Contract Header] C
	                   ON A.[Global Dimension 2 Code]=C.[No_] --collate database_default

					  
					WHERE A.[Posting Date] >='2024-12-01' AND A.[Posting Date]<='2024-12-31'   
					AND [Document No_] NOT LIKE 'KR%'             

					ORDER BY A.[G_L Account No_] ASC

--> ! <--



INSERT INTO ##DENIK ([G_L Account No_], [Posting Date], [Document No_], [Description], [Global Dimension 2 Code], [DruhSml], [Amount],
		           [Debit Amount], [Credit Amount], [Description 2], [Variable Symbol])
--> ��st kurz.rozd�ly
				   SELECT A.[G_L Account No_],CONVERT(VARCHAR(10),A.[Posting Date], 104),A.[Document No_],A.[Description], A.[Global Dimension 2 Code],
					SUBSTRING(C.[Gen_ Prod_ Posting Group],1,2),A.[Amount], A.[Debit Amount], A.[Credit Amount], A.[Description 2],A.[Variable Symbol]

				   FROM [CZ UCL CZ$G_L Entry] A
				   		INNER JOIN (SELECT (SUBSTRING([G_L Account No_],1,3)) AS [UCET], [GLobal Dimension 2 Code], SUM( [CZ UCL CZ$G_L Entry].[Amount]) AS CASTKA  
								    FROM  [CZ UCL CZ$G_L Entry]
								    WHERE [Posting Date] <='2024-12-31' AND [G_L Account No_] like '760%'
									AND [Document No_] LIKE 'KR%'  --> doklady kurz.rozd�l�  
								    GROUP BY SUBSTRING([G_L Account No_],1,3),[GLobal Dimension 2 Code]
								    HAVING SUM([Amount])<>0
								) B
					    ON A.[GLobal Dimension 2 Code]=B.[GLobal Dimension 2 Code] AND B.[UCET]=SUBSTRING([G_L Account No_],1,3)
						LEFT JOIN [CZ UCL CZ$LEA Contract Header] C
	                   ON A.[Global Dimension 2 Code]=C.[No_] --collate database_default

					  
					WHERE A.[Posting Date] >='2024-12-01' AND A.[Posting Date]<='2024-12-31'   
					      AND [Document No_] LIKE 'KR%' --> doklady kurz.rozd�l�    

					ORDER BY A.[G_L Account No_] ASC

--> ! <--



CREATE TABLE ##81
            ([N�zev �ablony den�ku] NVARCHAR(50),[N�zev listu den�ku] NVARCHAR(30),[��slo ��dku] INTEGER NULL,[Z��tovac� datum] NVARCHAR(10),
			 [Typ dokladu] NVARCHAR(10),[��slo dokladu] NVARCHAR(30),[K�d druhu dokladu] NVARCHAR(5),[Typ ��tu] NVARCHAR(20),
			 [��slo ��tu] NVARCHAR(7),[Popis] NVARCHAR(200),[Popis 2] NVARCHAR(200), [K�d m�ny] NVARCHAR(3) NULL, [MD ��stka] NUMERIC(15,2) NULL,
			 [Dal ��stka] NUMERIC(15,2) NULL, [��stka] NUMERIC(15,2) NULL,[��stka (LM)] NUMERIC(15,2) NULL,[Typ proti��tu] NVARCHAR(20),[��slo proti��tu] NVARCHAR(7),
			 [��slo extern�ho dokladu] NVARCHAR(10) NULL,[Variabiln� symbol] NVARCHAR(10) NULL,[K�d zkratky dimenze 2] NVARCHAR(10),[K�d zkratky dimenze 1] NVARCHAR(10))


INSERT INTO ##81  ([N�zev �ablony den�ku],[N�zev listu den�ku],[��slo ��dku] ,[Z��tovac� datum],[Typ dokladu],[��slo dokladu],
			       [K�d druhu dokladu],[Typ ��tu],[��slo ��tu],[Popis] ,[Popis 2],[K�d m�ny], [MD ��stka], [Dal ��stka],
			       [��stka] ,[��stka (LM)], [Typ proti��tu],[��slo proti��tu],[��slo extern�ho dokladu] ,[Variabiln� symbol],[K�d zkratky dimenze 2],[K�d zkratky dimenze 1])

SELECT 'ZAVERKA','ZAVERKA',0,convert(varchar(10),'31.12.2024',104),'','DOPLNIT','ID','��et',
       (CASE  WHEN [DruhSml]='FL' THEN '760641' WHEN [DruhSml]='OL' THEN '760642' ELSE '' END) AS [��slo ��tu], 'P�e��t.zapl. KFV do v�nos�' AS [Popis],
	   [Description 2],'',[Credit Amount],[Debit Amount], [Amount]*-1, [Amount]*-1,'��et',
       (CASE  WHEN [DruhSml]='FL' AND [Document No_] NOT LIKE 'KR%' THEN '648313'
	          WHEN [DruhSml]='OL' AND [Document No_] NOT LIKE 'KR%'THEN '648323' 
			  WHEN [DruhSml]='FL' AND [Document No_] LIKE 'KR%' THEN '663200'
	          WHEN [DruhSml]='OL' AND [Document No_] LIKE 'KR%'THEN '663200' 

	


		ELSE '' END) AS [��slo proti��tu],'' AS [��slo extern�ho dokladu],
	   [Variable symbol], [GLobal Dimension 2 Code],''
FROM ##DENIK
WHERE SUBSTRING([G_L Account No_],1,3) IN ('760')


UPDATE ##81  SET [��slo dokladu]=B.[CislDokladu]
FROM ##81 A
INNER JOIN (SELECT [Series Code], ( CASE 
	                                        WHEN convert(varchar(15),[Last No_ Used])='' then [Starting No_]
		                                    ELSE substring(convert(varchar(20),[Last No_ Used]),1,3)+ convert(varchar(20),convert(INT,substring(convert(varchar(20),[Last No_ Used]),4,7))+[Increment-by No_]) END) AS [CislDokladu]
                    FROM [CZ UCL CZ$No_ Series Line] 
                    WHERE [Series Code]='ZAVERKA' AND Year([Starting Date])=Year(Getdate()))  B
					
		ON B.[Series Code]=A.[N�zev �ablony den�ku] COLLATE DATABASE_DEFAULT  -- aktualizuje ��selnou �adu doklad� 



SELECT * FROM ##DENIK WHERE SUBSTRING([G_L Account No_],1,3) IN ('760')  -- polo�ky p�e��tovat z 760641 (FL) MD -> 648313 (FL) DAL
                                                                         -- polo�ky p�e��tovat z 760642 (OL) MD -> 648323 (OL) DAL
                                                                         --	��seln� �ada k p�e��tov�n� bude  Z�V�RKA CAS
                                                                         --	form�t datum pou��vat convert(varchar(10),GETDATE(),104)



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
			  update Top(1) ##81 SET [��slo ��dku] = @LnNo  WHERE [��slo ��dku]=0
			  SELECT @LnNo=  @LnNo + 10 
			                
              FETCH NEXT FROM tbl81 INTO @Row
         END
         CLOSE tbl81
         DEALLOCATE tbl81

		
SELECT * FROM ##81


---!!!! prov�st kontrolu Group Ucet, Code, Castka pro ��ty 76* mus� j�t do nuly