Use BC_PRODUKCNI
-- seznam UCFM smluv s intercompany
-- požadavek Soňa Keprdová
-- pouze smlouvy
GO	 
DECLARE @MaxPostingDate    DATE 
DECLARE @MinPostingDate    DATE 
SELECT  @MinPostingDate = '2024-01-01'
SELECT  @MaxPostingDate = '2024-12-31'

IF OBJECT_ID ('tempdb.dbo.##Pivot', 'U')			IS NOT NULL   DROP TABLE ##Pivot



DECLARE @Skala AS TABLE (Obdobi varchar(7) not null primary key)
INSERT INTO @Skala 
			        SELECT DISTINCT (STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0')) AS [Obdobi] FROM [CZ UCFM$G_L Entry]
					WHERE YEAR([Posting Date])=Year('' + CAST(@MaxPostingDate as nvarchar) + '')
					GROUP BY (STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0'))
					ORDER BY (STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0')) asc

--seznam polí pro klauzuli IN
DECLARE @cols AS nvarchar(MAX), @years AS varchar(10)
SET @years = (SELECT Min(obdobi) FROM @Skala)
SET @cols = N''
	WHILE @years IS NOT NULL
		BEGIN
			SET @cols= @cols + N', ['+CAST(@years AS nvarchar(10))+N']'
			SET @years = (SELECT min(Obdobi) FROM @Skala WHERE obdobi > @years)
		END
SET @cols = substring(@cols, 2, LEN(@cols))
--Sestavit celý příkaz  T-SQL  a spustit dynamicky
DECLARE @sql AS nvarchar (MAX)
SET @sql = N'SELECT  * INTO ##Pivot 

				FROM (  SELECT B.[Dimension Value Code] AS [InterCompany], ''UniCredit Business Integrated Solutions S.C.p.A. -'' AS [Spolecnost], A.[G_L Account No_], A.[Global Dimension 2 Code], (STR(YEAR([Posting Date]),4) +''-''+ REPLACE(STR(MONTH([Posting Date]),2),'' '',''0'')) AS [Obdobi], A.[Amount] AS CASTKA,
				        Sum(A.[Amount]) over (partition by B.[Dimension Value Code],A.[Global Dimension 2 Code],A.[G_L Account No_]) AS Za_Spolecnost_Celkem
						FROM [CZ UCFM$G_L Entry] A
	   						INNER JOIN (SELECT [Global Dimension 2 Code],[Dimension Value Code]
										FROM [CZ UCFM$Default Dimension]      
										INNER JOIN [CZ UCFM$Fixed Asset]
										ON [CZ UCFM$Default Dimension].[No_]=[CZ UCFM$Fixed Asset].[No_]
							WHERE [Dimension Code]=''INTERCOMPANY'' AND [Table ID]=5600) B
							ON A.[Global Dimension 2 Code]=B.[Global Dimension 2 Code]
                      
				WHERE SUBSTRING([G_L Account No_],1,1) IN (''5'') AND
						[Posting Date]>=''' + CAST(@MinPostingDate as nvarchar) + '''  AND [Posting Date]<=''' + CAST(@MaxPostingDate as nvarchar) + '''
						) AS Header
				PIVOT
				(SUM(CASTKA) FOR [Obdobi] IN(' + @cols + N')) AS CASTKA'
            
PRINT @sql -- kvuli ladeni
EXEC (@sql)
-- přidat pole účet ze dne 27.1.2017, zatím je intercompany pouze pro tabulku 5600,
-- je třeba aplikovat i pro tabulku 15 ( účty intercompany )


EXEC('UPDATE ##Pivot SET [Spolecnost] =''UniCredit Business Integrated Solutions S.C.p.A. -''
      WHERE [InterCompany]=''081'' ')
EXEC('UPDATE ##Pivot SET [Spolecnost] =''UniCredit Bank Czech Republic and Slovakia, a.s.''
      WHERE [InterCompany]=''A1000'' ')
EXEC('UPDATE ##Pivot SET [Spolecnost] =''UniCredit Leasing CZ, a.s.''
      WHERE [InterCompany]=''A554'' ')
EXEC('UPDATE ##Pivot SET [Spolecnost] =''UniCredit pojišťovací makléřská spol. s r.o.''
      WHERE [InterCompany]=''A555'' ')
EXEC('UPDATE ##Pivot SET [Spolecnost] =''RCI Financial Services, s.r.o.''
      WHERE [InterCompany]=''A1583'' ')





GO

SELECT * FROM ##Pivot 



--SELECT B.[Dimension Value Code] AS [InterCompany], A.[G_L Account No_],  (STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0')) AS [Obdobi], SUM(A.[Amount]) AS CASTKA
--				           FROM [CZ UCFM$G_L Entry] A
--	   						INNER JOIN (SELECT [Global Dimension 2 Code],[Dimension Value Code]
--										FROM [NAV_Produkcni].[dbo].[CZ UCFM$Default Dimension]      
--										INNER JOIN [CZ UCFM$Fixed Asset]
--										ON [CZ UCFM$Default Dimension].[No_]=[CZ UCFM$Fixed Asset].[No_]
--							WHERE [Dimension Code]='INTERCOMPANY' AND [Table ID]=5600) B
--							ON A.[Global Dimension 2 Code]=B.[Global Dimension 2 Code]

--				WHERE SUBSTRING([G_L Account No_],1,1) IN ('5') AND
--						[Posting Date]>=CONVERT(VARCHAR(12),'2017-01-01', 112)  AND [Posting Date]<=CONVERT(VARCHAR(12),'2017-12-31', 112)

--GROUP BY B.[Dimension Value Code],A.[G_L Account No_],(STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0'))

						
-------(z majetku)


--UNION 


--SELECT D.[Dimension Value Code] AS [InterCompany], C.[G_L Account No_],  (STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0')) AS [Obdobi], SUM(C.[Amount]) AS CASTKA
--				           FROM [CZ UCFM$G_L Entry] C
--	   						INNER JOIN (SELECT [No_],[Dimension Value Code]
--										FROM  [CZ UCFM$Default Dimension]		
--										WHERE [Dimension Code]='INTERCOMPANY' AND [Table ID]=15
--										AND SUBSTRING([No_],1,1) IN('5') AND [Dimension Value Code]<>'') D
--							ON C.[G_L Account No_]=D.[No_]

--				WHERE SUBSTRING(C.[G_L Account No_],1,1) IN ('5') AND
--						C.[Posting Date]>=CONVERT(VARCHAR(12),'2016-01-01', 112)  AND C.[Posting Date]<=CONVERT(VARCHAR(12),'2016-12-31', 112)

--GROUP BY D.[Dimension Value Code],C.[G_L Account No_],(STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0'))

-- IC (celý účet)



--SELECT [Description 2] AS [InterCompany],[Description 2], E.[G_L Account No_],  (STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0')) AS [Obdobi], SUM(E.[Amount]) AS CASTKA
--FROM [CZ UCFM$G_L Entry] E
	   					   
--WHERE E.[G_L Account No_] IN (SELECT [No_] FROM  [CZ UCFM$Default Dimension]		
--							   WHERE [Table ID]=15
--							   AND SUBSTRING([No_],1,1) IN('5') AND [Dimension Value Code]='')
  
--	  AND		[Description 2] IN('UniCredit Leasing CZ, a.s.','UniCredit Bank Czech Republic and Slovakia, a.s.',
--                                   'UniCredit pojišťovací makléřská spol. s r.o.','RCI Financial Services, s.r.o.',
--				                   'UniCredit Business Integrated Solutions S.C.p.A. -', 'UniCredit Leasing Slovakia,a.s')
				
--      AND 
--				E.[Posting Date]>=CONVERT(VARCHAR(12),'2016-01-01', 112)  AND E.[Posting Date]<=CONVERT(VARCHAR(12),'2016-12-31', 112)



--GROUP BY [Description 2],E.[G_L Account No_],(STR(YEAR([Posting Date]),4) +'-'+ REPLACE(STR(MONTH([Posting Date]),2),' ','0'))
--dodělat pro výběr IC. 