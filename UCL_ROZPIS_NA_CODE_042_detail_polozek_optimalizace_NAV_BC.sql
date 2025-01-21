Use BC_PRODUKCNI
GO
/* Rozpis úètù */
DECLARE @MinPostingDate    DATE
DECLARE @MaxPostingDate    DATE
DECLARE @SQLString         NVARCHAR(2000)
DECLARE @Company           NVARCHAR(20)
SELECT  @MinPostingDate = '2014-12-31'
SELECT  @MaxPostingDate = '2024-08-31'
SELECT  @Company = 'CZ UCL CZ'

select * FROM [CZ UCL CZ$Default Dimension]
WHERE [Table ID]=15 AND [Dimension Code]='SMLOUVA'
AND SUBSTRING ([No_],1,3) IN('042')
	
IF OBJECT_ID ('tempdb..##A')				is not null					DROP TABLE ##A
IF OBJECT_ID ('tempdb..##B')				is not null					DROP TABLE ##B
IF OBJECT_ID ('tempdb..##C')				is not null					DROP TABLE ##C
IF OBJECT_ID ('tempdb..##D')				is not null					DROP TABLE ##D
IF OBJECT_ID ('tempdb..##E')				is not null					DROP TABLE ##E
IF OBJECT_ID ('tempdb..##F')				is not null					DROP TABLE ##F
IF OBJECT_ID ('tempdb..##G')				is not null					DROP TABLE ##G
IF OBJECT_ID ('tempdb..##PocStavDetail')	is not null					DROP TABLE ##PocStavDetail

EXEC (N'SELECT [' + @Company + '$Default Dimension].[No_] INTO ##A 
      FROM [' + @Company + '$Default Dimension]
      INNER JOIN [' + @Company + '$G_L Account]
      ON [' + @Company + '$Default Dimension].[No_]= [' + @Company + '$G_L Account].[No_]
      WHERE [Table ID]=15 AND [Dimension Code]=''SMLOUVA''
      AND [' + @Company + '$G_L Account].[Account Type]=0 AND [' + @Company + '$G_L Account].[Accounting system] IN(0,2)
	  AND SUBSTRING ([' + @Company + '$G_L Account].[No_],1,3) IN(''042'')') 

IF @Company = 'CZ UCFM' -- èást pouze pro UCFM
	BEGIN
		EXEC (N'INSERT INTO ##A ([No_])
				SELECT [' + @Company + '$Default Dimension].[No_] 
				FROM [' + @Company + '$Default Dimension]
				INNER JOIN [' + @Company + '$G_L Account]
				ON [' + @Company + '$Default Dimension].[No_]= [' + @Company + '$G_L Account].[No_]
				WHERE [Table ID]=15 AND [' + @Company + '$Default Dimension].[No_] IN(''082100'')
				AND [' + @Company + '$G_L Account].[Account Type]=0 AND [' + @Company + '$G_L Account].[Accounting system] IN(0,2)' ) -- zde doplnit úèty, které mají smlouvu, ale nejsou
	END																																  -- v default dimension jako položky smlouva
     
EXEC (N'SELECT [G_L Account No_],[Global Dimension 2 Code],''CZK'' AS [MENA],SUM([SUM$Amount]) AS [CzkAmount]
		INTO ##B
		FROM [' + @Company + '$G_L Entry$VSIFT$17]
		INNER JOIN ##A
		ON [' + @Company + '$G_L Entry$VSIFT$17].[G_L Account No_]=##A.[No_]
		WHERE[Posting Date] >=''' + @MinPostingDate + ''' AND [Posting Date] <=''' + @MaxPostingDate + '''
		AND SUBSTRING ([G_L Account No_],1,3) IN(''042'')
		GROUP BY [G_L Account No_], [Global Dimension 2 Code]
		HAVING  SUM([SUM$Amount]) <>0 
		ORDER BY [G_L Account No_] ASC')      /*vybere pouze CZK*/


--EXEC (N'INSERT INTO ##B ([G_L Account No_],[Global Dimension 2 Code], [MENA], [CzkAmount])
--		SELECT [G_L Account No_],[Global Dimension 2 Code],''CZK'' AS [MENA],SUM([SUM$Amount]) AS [CzkAmount]
--		FROM [' + @Company + '$G_L Entry$VSIFT$11]
--		INNER JOIN ##A
--		ON [' + @Company + '$G_L Entry$VSIFT$11].[G_L Account No_]=##A.[No_]
--		WHERE [Posting Date] >=''2016-01-01'' AND [Posting Date] <=''' + @MaxPostingDate + '''
--		GROUP BY [G_L Account No_], [Global Dimension 2 Code]
--		HAVING  SUM([SUM$Amount]) <>0 AND SUBSTRING ([G_L Account No_],1,3) IN(''042'')
--		ORDER BY [G_L Account No_] ASC')      /*vybere pouze CZK*/


EXEC (N'SELECT [G_L Account No_],[Global Dimension 2 Code], [Currency Code], SUM([SUM$Currency Amount]) AS [OrgAmount]
      INTO ##C
      FROM [' + @Company + '$G_L Entry$VSIFT$23]
      INNER JOIN ##A
      ON [' + @Company + '$G_L Entry$VSIFT$23].[G_L Account No_]=##A.[No_]
      WHERE[Posting Date] >=''' + @MinPostingDate + ''' AND [Posting Date] <=''' + @MaxPostingDate + '''
      GROUP BY [G_L Account No_], [Global Dimension 2 Code], [Currency Code]
      HAVING  SUM([SUM$Currency Amount]) <>0
      ORDER BY [G_L Account No_] ASC')        /*vybere Cizi mìny*/
      

EXEC (N'CREATE TABLE ##D
     ([OPPODN] VARCHAR(20),[OPROK] INT, [OPODBDO] INT, [OPUCET] VARCHAR(7), [OPNAZEV] VARCHAR(60), [CODE] VARCHAR(20), [MENA] VARCHAR(3), [OrgAmount] NUMERIC(15,2), [CzkAmount] NUMERIC(15,2))')

-- zaèátek -> script pro vložení rozklíèovaného zùstatku z migrace---


CREATE TABLE ##PocStavDetail ([G_L Account No_] VARCHAR (6), [Source No_] VARCHAR (15),KZ NUMERIC (15,2) ) 

IF @Company = 'CZ UCFM'  -- Poè.stav 042 pouze pro UCFM

	BEGIN

		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001206621', -1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001509680', 703000) 
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101603376', 787622) -- pùv. '11001509681'
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001510488', 1518.87)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001510914', 546490.91)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511248', 241455.29)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511501', 2160)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511527', 523028.87)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511550', 333626.36)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511572', 552176.86)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511669', 321433.89)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511701', 414617.35)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511702', 414617.35)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511743', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511764', 566609.11)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511829', 910972.64)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511869', 2258635.3)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511915', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511951', 415907.35)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511952', 414617.35)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511953', 414617.35)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511954', 414617.35)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511955', 414617.35)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '11001511962', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500004', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500017', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500018', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500019', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500020', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500040', 249435.99)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500059', 420306.49)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500083', 428024.79)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500092', 369188.43)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500096', 1112604.85)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500105', 558099.92)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500128', 554430)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500172', 300946.29)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500174', 465374.38)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500496', 639018)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500596', 424392.57)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500606', 574297.51)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500617', 309828.1)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500618', 309828.1)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500619', 309828.1)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500620', 309828.1)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500621', 309828.1)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500622', 309828.1)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500623', 309828.1)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500661', 879223.9)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500663', 243101.65)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500674', 1290)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500678', 538010.75)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500680', 570365.19)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500723', 2089490.08)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500745', 249436.36)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500748', 249435.99)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500751', 249436)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500756', 432606.61)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500757', 249436.36)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500770', 564723.97)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500780', 249435.99)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500783', 1970878.51)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500784', 917810.74)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500785', 907268.59)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500814', 644390.1)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500825', 564723.97)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500854', 945907)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500860', 249436.15)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500868', 882013.22)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500898', 1632231.4)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500899', 1658310.74)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500907', 249434.71)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500908', 249434.71)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500909', 249435.99)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500912', 249435.99)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500918', 4689.54)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500925', 210959)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500926', 210959)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500927', 210959)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500928', 210959)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500929', 210959)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '1101500961', 243611.57)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '2201500001', 1017590.91)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '2201500030', 1187002)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '2201500031', 1187002)
		INSERT INTO ##PocStavDetail ([G_L Account No_], [Source No_], [KZ]) VALUES ('042110', '3301555025', 295320.59)

	END

-- konec -> script pro vložení rozklíèovaného zùstatku z migrace  


EXEC (N'INSERT INTO ##D ([OPPODN], [OPROK], [OPODBDO], [OPUCET], [CODE], [MENA], [OrgAmount], [CzkAmount])
      SELECT ''' + @Company + ''' AS [OPPODN], Year(''' + @MaxPostingDate + ''') AS [OPROK], Month(''' + @MaxPostingDate + ''') AS [OPODBDO],
      ##B.[G_L Account No_] AS [OPUCET], ##B.[Global Dimension 2 Code] AS [CODE],
	  (CASE WHEN ##C.[Currency Code]IS NULL THEN ''CZK''
	        ELSE ##C.[Currency Code]
			END) AS [MENA], ##C.[OrgAmount],##B.[CzkAmount]
      FROM ##B
            LEFT JOIN ##C
            ON ##B.[G_L Account No_]=##C.[G_L Account No_]
            AND ##B.[Global Dimension 2 Code]=##C.[Global Dimension 2 Code]')


EXEC (N'INSERT INTO ##D ([OPPODN], [OPROK], [OPODBDO], [OPUCET], [CODE], [MENA], [CzkAmount])
      SELECT ''' + @Company + ''' AS [OPPODN], Year(''' + @MaxPostingDate + ''') AS [OPROK], Month(''' + @MaxPostingDate + ''') AS [OPODBDO],
      ##PocStavDetail.[G_L Account No_] AS [OPUCET], ##PocStavDetail.[Source No_] AS [CODE],
	  ''CZK'' AS [MENA], ##PocStavDetail.[KZ]
      FROM ##PocStavDetail')


EXEC (N'UPDATE ##D 
      SET [OPNAZEV]=T2.[OPNAZEV]
      FROM ##D 
      INNER JOIN
           (SELECT [No_], [Name] AS [OPNAZEV]
            FROM [' + @Company + '$G_L Account]) T2
      ON T2.[No_]=##D.[OPUCET]COLLATE DATABASE_DEFAULT')


EXEC (N'DELETE FROM ##D WHERE [OPUCET]=''042110'' AND [CODE]=''0'' ')  -- odstraní souhrn detailních èástek



EXEC (N'CREATE TABLE ##E
     ([OPPODN] VARCHAR(20),[OPROK] INT, [OPODBDO] INT, [OPUCET] VARCHAR(7), [OPNAZEV] VARCHAR(60), [CODE] VARCHAR(20), [MENA] VARCHAR(3), [OrgAmount] NUMERIC(15,2), [CzkAmount] NUMERIC(15,2))')


EXEC (N'INSERT INTO ##E ([OPPODN], [OPROK], [OPODBDO], [OPUCET], [OPNAZEV], [CODE], [MENA], [OrgAmount], [CzkAmount])
        SELECT[OPPODN], [OPROK], [OPODBDO], [OPUCET], [OPNAZEV], [CODE], [MENA], SUM([ORGAMOUNT]) AS  [OrgAmount] , SUM([CZKAmount]) AS  [CzkAmount]
		FROM ##D 
        GROUP BY [OPPODN], [OPROK], [OPODBDO], [OPUCET], [OPNAZEV], [CODE], [MENA]
        HAVING SUM([CZKAmount])<>0 ')


EXEC (N'SELECT [G_L Account No_],[Posting Date],[Document No_],[Description],
       [Amount],[Global Dimension 2 Code],[User ID],[Reason Code],
	   [Debit Amount],[Credit Amount] ,[Document Date],[External Document No_],[Source Type],[Source No_]
      INTO ##F
			FROM [' + @Company + '$G_L Entry]

	  RIGHT JOIN ##E
        ON [' + @Company + '$G_L Entry].[G_L Account No_]=##E.[OPUCET]COLLATE DATABASE_DEFAULT
		AND [' + @Company + '$G_L Entry].[Global Dimension 2 Code]=##E.[CODE]COLLATE DATABASE_DEFAULT

		WHERE
		SUBSTRING([G_L Account No_],1,3)IN(''042'')
		AND [Posting Date]>=''2016-01-01'' AND [Posting Date]<=''' + @MaxPostingDate + '''
  UNION ALL
		SELECT
		[G_L Account No_]COLLATE DATABASE_DEFAULT,''2015-12-31'' AS [Posting Date],''PS'' AS [Document No_],
	   ''PocatecniStav'' AS [Description], [KZ] AS [Amount],[Source No_]COLLATE DATABASE_DEFAULT AS [Global Dimension 2 Code],''MIGRACE'' AS [User ID],
	   ''IMP'' AS [Reason Code], 0 AS [Debit Amount], 0 AS [Credit Amount] ,''2015-12-31'' AS[Document Date], ''PS'' AS[External Document No_],
	   0 AS [Source Type],'''' AS [Source No_]
	
	FROM   ##PocStavDetail

	WHERE [Source No_] IN(''11001509680'',''1101603376'',''1101500004'',''1101500018'',''1101500019'')
	--
ORDER BY [Posting Date] ASC ')

--WHERE [Source No_] IN(''11001509680'',''11001509681'',''11001511743'',''11001511869'',''11001511962'',''1101500004'',''1101500018'',''1101500019'',''1101500606'')



EXEC (N'SELECT [G_L Account No_],[Global Dimension 2 Code] AS SMLOUVA,
     ( CASE
	     WHEN [Status]=2 THEN ''NABÍDKA'' 
	     WHEN [Status]=4 THEN ''ÈEKÁ NA SCHVÁLENÍ''
		 WHEN [Status]=6 THEN ''SCHVÁLENÁ''
		 WHEN [Status]=7 THEN ''ODMÍTNUTÁ''
		 WHEN [Status]=8 THEN ''PODEPSANÁ''
		 WHEN [Status]=9 THEN ''PØEDANÁ''
		 WHEN [Status]=10 THEN ''AKTIVNÍ''
		 WHEN [Status]=12 THEN ''POZASTAVENÁ''
		 WHEN [Status]=14 THEN ''UKONÈOVANÁ''
		 WHEN [Status]=16 THEN ''VYPOØÁDÁVÁNA''
		 WHEN [Status]=18 THEN ''ARCHIVOVANÁ''
		 WHEN [Status]=19 THEN ''UKONÈOVANÁ''
		 WHEN [Status]=21 THEN ''VZOR''
		 WHEN [Status]=22 THEN ''ZMÌNOVÁ KOPIE''
		 
  ELSE ''''
  END) AS [STATSML], Convert(varchar(10),[Posting Date],120) AS DATUM, SUM([Amount]) AS CASTKA INTO ##G
FROM ##F
LEFT JOIN [' + @Company + '$LEA Contract Header]
    ON ##F.[Global Dimension 2 Code]=[' + @Company + '$LEA Contract Header].[No_]
GROUP BY [G_L Account No_],[Global Dimension 2 Code],[Posting Date],[Status]
HAVING SUM([Amount])<>0
ORDER BY [G_L Account No_],[Posting Date] ASC,[Global Dimension 2 Code] ')

GO

SELECT * FROM ##G 

--SELECT * FROM ##E WHERE [OPUCET] LIKE '042%'
--SELECT * FROM ##F
--SELECT * FROM ##D WHERE [OPUCET] LIKE '042%'




