USE BC_PRODUKCNI
----DenÌk
-- !!!!  upravit sql tak aby se od˙Ëtov·val kurz.rozdÌl doklad 'KR' na ˙Ëty 563/663 pozn. ze dne 4.9.2018
---!!!! provÈst kontrolu Group Ucet, Code, Castka pro ˙Ëty 76* musÌ jÌt do nuly


IF OBJECT_ID ('tempdb.dbo.##DENIK', 'U') IS NOT NULL  	      DROP TABLE ##DENIK
IF OBJECT_ID ('tempdb.dbo.##81', 'U') IS NOT NULL  	          DROP TABLE ##81

-- !!!!!! doklad 'ID21US0001 nebrat jde o p¯e˙Ëtov·nÌ, je t¯eba omezit datem od 02.9.21

SELECT (SUBSTRING([G_L Account No_],1,3)) AS [UCET], [GLobal Dimension 2 Code], SUM( [CZ UCL CZ$G_L Entry].[Amount]) AS CASTKA  
								    FROM  [CZ UCL CZ$G_L Entry]
								    WHERE [Posting Date] <='2024-12-31' AND [G_L Account No_] like '760%' 
									--AND [Document No_] NOT LIKE 'KR%'  --> doklady kurz.rozdÌl˘ vzl·öù
								    GROUP BY (SUBSTRING([G_L Account No_],1,3)),[GLobal Dimension 2 Code]
								    HAVING SUM([Amount])<>0



CREATE TABLE ##DENIK
          ([G_L Account No_] NVARCHAR(7) NULL, [Posting Date] NVARCHAR(12), [Document No_] NVARCHAR(20) NULL,
		   [Description] NVARCHAR(150) NULL,[Global Dimension 2 Code] NVARCHAR(20) NULL,[DruhSml] NVARCHAR(10) NULL, [Amount] NUMERIC(15,2) NULL,
		   [Debit Amount] NUMERIC(15,2) NULL, [Credit Amount] NUMERIC(15,2) NULL, [Description 2] NVARCHAR(150) NULL,
		   [Variable Symbol] NVARCHAR(20) NULL)


INSERT INTO ##DENIK ([G_L Account No_], [Posting Date], [Document No_], [Description], [Global Dimension 2 Code], [DruhSml], [Amount],
		           [Debit Amount], [Credit Amount], [Description 2], [Variable Symbol])
	
				   

--> Ë·st mimo kurz.rozdÌly


				   SELECT A.[G_L Account No_],CONVERT(VARCHAR(10),A.[Posting Date], 104),A.[Document No_],A.[Description], A.[Global Dimension 2 Code],
					SUBSTRING(C.[Gen_ Prod_ Posting Group],1,2),A.[Amount], A.[Debit Amount], A.[Credit Amount], A.[Description 2],A.[Variable Symbol]

				   FROM [CZ UCL CZ$G_L Entry] A
				   		INNER JOIN (SELECT (SUBSTRING([G_L Account No_],1,3)) AS [UCET], [GLobal Dimension 2 Code], SUM( [CZ UCL CZ$G_L Entry].[Amount]) AS CASTKA  
								    FROM  [CZ UCL CZ$G_L Entry]
								    WHERE [Posting Date] <='2024-12-31' AND [G_L Account No_] like '760%' 
									AND [Document No_] NOT LIKE 'KR%'  --> doklady kurz.rozdÌl˘ vzl·öù
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
--> Ë·st kurz.rozdÌly
				   SELECT A.[G_L Account No_],CONVERT(VARCHAR(10),A.[Posting Date], 104),A.[Document No_],A.[Description], A.[Global Dimension 2 Code],
					SUBSTRING(C.[Gen_ Prod_ Posting Group],1,2),A.[Amount], A.[Debit Amount], A.[Credit Amount], A.[Description 2],A.[Variable Symbol]

				   FROM [CZ UCL CZ$G_L Entry] A
				   		INNER JOIN (SELECT (SUBSTRING([G_L Account No_],1,3)) AS [UCET], [GLobal Dimension 2 Code], SUM( [CZ UCL CZ$G_L Entry].[Amount]) AS CASTKA  
								    FROM  [CZ UCL CZ$G_L Entry]
								    WHERE [Posting Date] <='2024-12-31' AND [G_L Account No_] like '760%'
									AND [Document No_] LIKE 'KR%'  --> doklady kurz.rozdÌl˘  
								    GROUP BY SUBSTRING([G_L Account No_],1,3),[GLobal Dimension 2 Code]
								    HAVING SUM([Amount])<>0
								) B
					    ON A.[GLobal Dimension 2 Code]=B.[GLobal Dimension 2 Code] AND B.[UCET]=SUBSTRING([G_L Account No_],1,3)
						LEFT JOIN [CZ UCL CZ$LEA Contract Header] C
	                   ON A.[Global Dimension 2 Code]=C.[No_] --collate database_default

					  
					WHERE A.[Posting Date] >='2024-12-01' AND A.[Posting Date]<='2024-12-31'   
					      AND [Document No_] LIKE 'KR%' --> doklady kurz.rozdÌl˘    

					ORDER BY A.[G_L Account No_] ASC

--> ! <--



CREATE TABLE ##81
            ([N·zev öablony denÌku] NVARCHAR(50),[N·zev listu denÌku] NVARCHAR(30),[»Ìslo ¯·dku] INTEGER NULL,[Z˙ËtovacÌ datum] NVARCHAR(10),
			 [Typ dokladu] NVARCHAR(10),[»Ìslo dokladu] NVARCHAR(30),[KÛd druhu dokladu] NVARCHAR(5),[Typ ˙Ëtu] NVARCHAR(20),
			 [»Ìslo ˙Ëtu] NVARCHAR(7),[Popis] NVARCHAR(200),[Popis 2] NVARCHAR(200), [KÛd mÏny] NVARCHAR(3) NULL, [MD Ë·stka] NUMERIC(15,2) NULL,
			 [Dal Ë·stka] NUMERIC(15,2) NULL, [»·stka] NUMERIC(15,2) NULL,[»·stka (LM)] NUMERIC(15,2) NULL,[Typ proti˙Ëtu] NVARCHAR(20),[»Ìslo proti˙Ëtu] NVARCHAR(7),
			 [»Ìslo externÌho dokladu] NVARCHAR(10) NULL,[VariabilnÌ symbol] NVARCHAR(10) NULL,[KÛd zkratky dimenze 2] NVARCHAR(10),[KÛd zkratky dimenze 1] NVARCHAR(10))


INSERT INTO ##81  ([N·zev öablony denÌku],[N·zev listu denÌku],[»Ìslo ¯·dku] ,[Z˙ËtovacÌ datum],[Typ dokladu],[»Ìslo dokladu],
			       [KÛd druhu dokladu],[Typ ˙Ëtu],[»Ìslo ˙Ëtu],[Popis] ,[Popis 2],[KÛd mÏny], [MD Ë·stka], [Dal Ë·stka],
			       [»·stka] ,[»·stka (LM)], [Typ proti˙Ëtu],[»Ìslo proti˙Ëtu],[»Ìslo externÌho dokladu] ,[VariabilnÌ symbol],[KÛd zkratky dimenze 2],[KÛd zkratky dimenze 1])

SELECT 'ZAVERKA','ZAVERKA',0,convert(varchar(10),'31.12.2024',104),'','DOPLNIT','ID','⁄Ëet',
       (CASE  WHEN [DruhSml]='FL' THEN '760641' WHEN [DruhSml]='OL' THEN '760642' ELSE '' END) AS [»Ìslo ˙Ëtu], 'P¯e˙Ët.zapl. KFV do v˝nos˘' AS [Popis],
	   [Description 2],'',[Credit Amount],[Debit Amount], [Amount]*-1, [Amount]*-1,'⁄Ëet',
       (CASE  WHEN [DruhSml]='FL' AND [Document No_] NOT LIKE 'KR%' THEN '648313'
	          WHEN [DruhSml]='OL' AND [Document No_] NOT LIKE 'KR%'THEN '648323' 
			  WHEN [DruhSml]='FL' AND [Document No_] LIKE 'KR%' THEN '663200'
	          WHEN [DruhSml]='OL' AND [Document No_] LIKE 'KR%'THEN '663200' 

	


		ELSE '' END) AS [»Ìslo proti˙Ëtu],'' AS [»Ìslo externÌho dokladu],
	   [Variable symbol], [GLobal Dimension 2 Code],''
FROM ##DENIK
WHERE SUBSTRING([G_L Account No_],1,3) IN ('760')


UPDATE ##81  SET [»Ìslo dokladu]=B.[CislDokladu]
FROM ##81 A
INNER JOIN (SELECT [Series Code], ( CASE 
	                                        WHEN convert(varchar(15),[Last No_ Used])='' then [Starting No_]
		                                    ELSE substring(convert(varchar(20),[Last No_ Used]),1,3)+ convert(varchar(20),convert(INT,substring(convert(varchar(20),[Last No_ Used]),4,7))+[Increment-by No_]) END) AS [CislDokladu]
                    FROM [CZ UCL CZ$No_ Series Line] 
                    WHERE [Series Code]='ZAVERKA' AND Year([Starting Date])=Year(Getdate()))  B
					
		ON B.[Series Code]=A.[N·zev öablony denÌku] COLLATE DATABASE_DEFAULT  -- aktualizuje ËÌselnou ¯adu doklad˘ 



SELECT * FROM ##DENIK WHERE SUBSTRING([G_L Account No_],1,3) IN ('760')  -- poloûky p¯e˙Ëtovat z 760641 (FL) MD -> 648313 (FL) DAL
                                                                         -- poloûky p¯e˙Ëtovat z 760642 (OL) MD -> 648323 (OL) DAL
                                                                         --	ËÌseln· ¯ada k p¯e˙Ëtov·nÌ bude  Z¡VÃRKA CAS
                                                                         --	form·t datum pouûÌvat convert(varchar(10),GETDATE(),104)



DECLARE  @Row AS INT
DECLARE  @LnNo  AS  INT
SELECT  @LnNo = 10

DECLARE  tbl81 CURSOR FOR 
         SELECT [»Ìslo ¯·dku] FROM ##81
         OPEN tbl81
         FETCH NEXT FROM tbl81 INTO @Row
		
         WHILE @@FETCH_STATUS = 0
		     
              BEGIN
			  IF @Row=0
			  update Top(1) ##81 SET [»Ìslo ¯·dku] = @LnNo  WHERE [»Ìslo ¯·dku]=0
			  SELECT @LnNo=  @LnNo + 10 
			                
              FETCH NEXT FROM tbl81 INTO @Row
         END
         CLOSE tbl81
         DEALLOCATE tbl81

		
SELECT * FROM ##81


---!!!! provÈst kontrolu Group Ucet, Code, Castka pro ˙Ëty 76* musÌ jÌt do nuly