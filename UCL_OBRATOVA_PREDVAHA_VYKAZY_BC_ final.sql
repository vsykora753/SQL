USE BC_PRODUKCNI
GO
DECLARE @MinPostingDate    DATE
DECLARE @MaxPostingDate    DATE  
DECLARE @Company           NVARCHAR(20)
SELECT  @MinPostingDate = '2019-01-01'
SELECT  @MaxPostingDate = '2024-12-31'

SELECT  @Company = 'CZ UCL CZ'


IF OBJECT_ID ('tempdb..##tempA') is not null
DROP TABLE ##tempA
IF OBJECT_ID ('tempdb..##MappingRozvaha') is not null
DROP TABLE ##MappingRozvaha
IF OBJECT_ID ('tempdb..##MappingVysledovka') is not null
DROP TABLE ##MappingVysledovka


/* **********************OBRATOVA PREDVAHA************************ */

EXEC (N'CREATE TABLE ##tempA 
     ([OPUCET] VARCHAR(8) PRIMARY KEY, [OPNAZEV] VARCHAR(120), [Radek_Vykazu] VARCHAR (8), [Popis_Radku] VARCHAR(200), [OPPOCST] NUMERIC(15,2), [OPMDROK] NUMERIC(15,2),
      [OPDALROK] NUMERIC(15,2), [OPMDMES] NUMERIC(15,2),[OPDALMES] NUMERIC(15,2), [OPKONZUS] NUMERIC(15,2),
      [OPPODN] VARCHAR(20), [OPROK] INT, [OPODBDO] INT, [OPKNIHA] VARCHAR(20), [OPTRIDA] VARCHAR(1), [OPSKUP] VARCHAR (2), [OPSYNT] VARCHAR (3))')
      

      

EXEC (N'INSERT INTO ##tempA ([OPUCET], [OPNAZEV], [OPKNIHA], [OPPODN], [OPODBDO], [OPROK], [OPTRIDA], [OPSKUP], [OPSYNT])
      SELECT [No_], [Name], ''OBA'' AS [OPKNIHA], ''' + @Company + ''' AS [OPPODN],
      Month(''' + @MaxPostingDate + ''') AS [OPODBDO], Year(''' + @MaxPostingDate + ''') AS [OPROK],
      SUBSTRING([No_],1,1) AS [OPTRIDA], SUBSTRING([No_],1,2) AS [OPSKUP],SUBSTRING([No_],1,3) AS [OPSYNT]
      FROM [' + @Company + '$G_L Account]
      WHERE [Account Type]=0 AND [Accounting system]=0
      GROUP BY [No_],[Name]')
      
    

EXEC (N'UPDATE ##tempA 
      SET [OPPOCST]=T2.[PS]
      FROM ##tempA INNER JOIN
      (SELECT [' + @Company + '$G_L Entry$VSIFT$1].[G_L Account No_],Sum([Sum$Amount]) AS [PS]
         FROM [' + @Company + '$G_L Entry$VSIFT$1]
         WHERE Year([Posting Date])<= Year(''' + @MaxPostingDate + ''')-1
         GROUP BY [' + @Company + '$G_L Entry$VSIFT$1].[G_L Account No_]
		 HAVING SUBSTRING([G_L Account No_],1,1) IN(''0'',''1'',''2'',''3'',''4'',''7'') 
		                     ) T2 
      ON T2.[G_L Account No_]=##tempA.[OPUCET]COLLATE DATABASE_DEFAULT')



EXEC (N'UPDATE ##tempA
      SET [OPMDROK]=T2.[OPMDROK],
          [OPDALROK]=T2.[OPDALROK]
      FROM ##tempA INNER JOIN 
                  (SELECT [G_L Account No_],Sum([Sum$Debit Amount]) AS [OPMDROK], Sum([Sum$Credit Amount]) AS [OPDALROK]
                   FROM [' + @Company + '$G_L Entry$VSIFT$1]
                   WHERE [Posting Date]>=CONVERT(VARCHAR(8),DATEADD(YEAR, DATEDIFF(YEAR,0,''' + @MaxPostingDate + '''),0),112)
				   AND [Posting Date]<=''' + @MaxPostingDate + '''
                   GROUP BY [G_L Account No_]
				   
                    ) T2 
            ON T2.[G_L Account No_]=##tempA.[OPUCET]COLLATE DATABASE_DEFAULT')
             
--HAVING SUBSTRING([G_L Account No_],1,1) IN(''5'',''6'')		   
		    
EXEC (N'UPDATE ##tempA
      SET [OPMDMES]=T2.[OPMDMES],
          [OPDALMES]=T2.[OPDALMES]
      FROM ##tempA INNER JOIN 
           (SELECT [G_L Account No_],Sum([Sum$Debit Amount]) AS [OPMDMES], Sum([Sum$Credit Amount]) AS [OPDALMES]
              FROM [' + @Company + '$G_L Entry$VSIFT$1]
              WHERE [Posting Date]>=CONVERT(VARCHAR(8),DATEADD(MONTH, DATEDIFF(MONTH,0,''' + @MaxPostingDate + '''),0),112) AND [Posting Date]<=''' + @MaxPostingDate + '''
              GROUP BY [G_L Account No_]
			  
                    ) T2 
              ON T2.[G_L Account No_]=##tempA.[OPUCET]COLLATE DATABASE_DEFAULT')
              
-- HAVING SUBSTRING([G_L Account No_],1,1) IN(''5'',''6'')
           
EXEC (N'UPDATE ##tempA 
        SET [OPKONZUS]=T2.[OPKONZUS]
        FROM ##tempA INNER JOIN
                    (SELECT [' + @Company + '$G_L Entry$VSIFT$1].[G_L Account No_],Sum([Sum$Amount]) AS [OPKONZUS]
                     FROM [' + @Company + '$G_L Entry$VSIFT$1]
                     WHERE [Posting Date]<=''' + @MaxPostingDate + '''
                     GROUP BY [' + @Company + '$G_L Entry$VSIFT$1].[G_L Account No_]
                      ) T2
               ON T2.[G_L Account No_]=##tempA.[OPUCET]COLLATE DATABASE_DEFAULT')   


/* **************** OBRATOVA PREDVAHA - KONEC **************** */



EXEC (N'SELECT [Schedule Name],[Line No_],[Row No_], [Description], [Totaling ],
      (CASE
	  
	  WHEN [Line No_] IN(''10000'')
		THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''30000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''40000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''50000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''60000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''70000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''80000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''90000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''100000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''110000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''120000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''130000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''150000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''160000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''

	  WHEN [Line No_] IN(''170000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +
			'' OR '' +''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],16,3) + ''%'''''' + '''' + 
			'' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],23,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],32,3) + ''%I%'''''' 


	  WHEN [Line No_] IN(''190000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +
			'' OR '' +''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],16,3) + ''%'''''' + '''' + 
			'' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],23,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],32,3) + ''%I%'''''' 


	  WHEN [Line No_] IN(''200000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +   
			     '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],18,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],27,3) + ''%I%''''''  + '''' + 
	             '' OR '' + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],34,6) + '''''''' + '''' + '')'' 

	  
	  WHEN [Line No_] IN(''210000'')
             THEN  ''[OPUCET] LIKE ''''022___'''' OR [OPUCET] LIKE ''''022___L''''''

	  WHEN [Line No_] IN(''220000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +       
                '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],18,3) + ''%E%''''''  + '''' + 
				'' OR ''  + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],24,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],31,6) + ''''''''  + '''' + '')''



	  WHEN [Line No_] IN(''230000'')
	        THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' 
	  WHEN [Line No_] IN(''240000'')
                  THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''250000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''260000'')
                  THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''270000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''280000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''290000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' + 
			      '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],16,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],24,6) + '''''''' 
	  WHEN [Line No_] IN(''300000'')
	        THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' 
	  
	  WHEN [Line No_] IN(''310000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      
	  
	  WHEN [Line No_] IN(''330000'')
            THEN  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' + 
			      '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +  
				  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' 

	  WHEN [Line No_] IN(''340000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' 

	  WHEN [Line No_] IN(''350000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      
	  WHEN [Line No_] IN(''360000'')
			THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '')''
	  
	  
	  WHEN [Line No_] IN(''370000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''390000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''410000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''430000'')
			THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''450000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''470000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''490000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''510000'')
	        THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +       
                  '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],16,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],24,6) + ''''''''
	  WHEN [Line No_] IN(''520000'')
                  THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''530000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''540000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''550000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''560000'') 
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''570000'') 
	        THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +       
                  '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],16,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],24,6) + ''''''''
	  WHEN [Line No_] IN(''580000'') 
                  THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''590000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''600000'')
                  THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  
	  WHEN [Line No_] IN(''610000'')
	        THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +       
                  '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],16,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],24,6) + '''''''' + '''' +    
	              '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],31,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],39,6) + ''''''''


	  WHEN [Line No_] IN(''620000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''

	  WHEN [Line No_] IN(''690000'')
              THEN  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' + 
			      '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' 
	  
	  WHEN [Line No_] IN(''750000'')
	        THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' +
                                 '','' + '''''''' + SUBSTRING([Totaling],15,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],22,6) + '''''''' +
                                 '','' + ''''''''  + SUBSTRING([Totaling],29,6) + ''''''''  + '','' + ''''''''  + SUBSTRING([Totaling],36,6) + ''''''''  + 
								 '','' + ''''''''  + SUBSTRING([Totaling],43,6) + ''''''''  +  '','' + ''''''''  + SUBSTRING([Totaling],50,6) + ''''''''  + 
								 '','' + ''''''''  + SUBSTRING([Totaling],57,6) + ''''''''  +  '','' + ''''''''  + SUBSTRING([Totaling],64,6) + ''''''''  + 
								 '','' + ''''''''  + SUBSTRING([Totaling],71,6) + ''''''''  +  '','' + ''''''''  + SUBSTRING([Totaling],78,6) + ''''''''  + 
								 '','' + ''''''''  + SUBSTRING([Totaling],85,6) + ''''''''  +  '','' + ''''''''  + SUBSTRING([Totaling],92,6) + ''''''''  + 
								 '','' + ''''''''  + SUBSTRING([Totaling],99,6) + ''''''''  + '','' + ''''''''  + SUBSTRING([Totaling],121,6) + ''''''''  + '''' +'')'' +
								 '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],106,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],114,6) + ''''''''


   
	  WHEN [Line No_] IN(''760000'')
			THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' + '''' + '')'' 
	  WHEN [Line No_] IN(''770000'')
	        THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' +
                                 '','' + '''''''' + SUBSTRING([Totaling],15,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],22,6) + '''''''' +
                                 '','' + '''''''' + SUBSTRING([Totaling],29,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],36,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],43,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],50,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],57,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],64,6) + '''''''' +
								 '','' + ''''''''  + SUBSTRING([Totaling],71,6) + ''''''''+ '','' + ''''''''  + SUBSTRING([Totaling],78,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],85,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],92,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],99,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],106,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],113,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],120,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],127,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],134,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],141,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],148,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],155,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],162,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],169,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],176,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],183,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],190,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],197,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],204,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],211,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],218,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],225,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],232,6) + '''''''' + 
								 '','' + ''''''''  + SUBSTRING([Totaling],239,7) + '''''''' +  '''' + '')''



 WHEN [Line No_] IN(''775000'')
	        THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,7) + '''''''' + '''' + '')''


 WHEN [Line No_] IN(''780000'')
			THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' + 
				               '','' + ''''''''  + SUBSTRING([Totaling],15,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],22,6) + '''''''' +
							   '','' + ''''''''  + SUBSTRING([Totaling],29,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],36,6) + '''''''' +	
							   '','' + ''''''''  + SUBSTRING([Totaling],43,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],50,6) + '''''''' +
							   '','' + ''''''''  + SUBSTRING([Totaling],57,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],64,6) + '''''''' +
							   '','' + ''''''''  + SUBSTRING([Totaling],71,6) + '''''''' +  '''' + '')'' 




	
	  WHEN [Line No_] IN(''790000'')
			THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +    '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' + '''' +  
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +    '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%''''''


	
	WHEN [Line No_] IN(''850000'')
            THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + ''''

	  WHEN [Line No_] IN(''870000'')
	        THEN ''[OPUCET] LIKE '' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + 
			    '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
				'' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' + '''' +  
				'' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +    '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
			    '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
				'' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +    '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
			    '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''



	  WHEN [Line No_] IN(''890000'')
	        THEN ''[OPUCET] LIKE '' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +
			     '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' + '''' +  
			     '' AND '' + ''[OPUCET] NOT IN('' + '''''''' + SUBSTRING([Totaling],26,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],35,6) + '''''''' +
				                               '','' + '''''''' + SUBSTRING([Totaling],44,6) + ''''''''  +  '')'' 
								 


	  WHEN [Line No_] IN(''910000'')
	        THEN ''[OPUCET] LIKE '' + '''''''' + SUBSTRING([Totaling],1,3) + ''%''''''


	  WHEN [Line No_] IN(''920000'')
	        THEN ''[OPUCET] LIKE '' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + 
			     '' OR '' + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],6,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],13,6) + '''''''' +
                                 '','' + '''''''' + SUBSTRING([Totaling],20,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],27,6) + '''''''' +
                                 '','' + '''''''' + SUBSTRING([Totaling],34,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],41,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],48,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],55,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],62,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],69,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],76,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],83,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],90,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],97,6) + '''''''' +
                                 '','' + '''''''' + SUBSTRING([Totaling],104,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],111,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],118,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],125,6) + '''''''' +
								 '','' + ''''''''  + SUBSTRING([Totaling],132,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],139,6) + '''''''' +
								 '','' + ''''''''  + SUBSTRING([Totaling],146,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],153,6) + '''''''' +
								 '','' + ''''''''  + SUBSTRING([Totaling],160,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],167,6) + '''''''' +
								 '','' + ''''''''  + SUBSTRING([Totaling],174,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],181,6) + '''''''' +
								 '','' + ''''''''  + SUBSTRING([Totaling],188,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],195,6) + '''''''' +
								 '','' + ''''''''  + SUBSTRING([Totaling],202,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],209,6) + '''''''' +
								 '','' + ''''''''  + SUBSTRING([Totaling],216,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],223,6) + '''''''' +	
								 '','' + ''''''''  + SUBSTRING([Totaling],230,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],237,6) + '''''''' +	
								 +  '')''

 WHEN [Line No_] IN(''920500'')
	        THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' +
                                 '','' + '''''''' + SUBSTRING([Totaling],15,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],22,6) + '''''''' +
                                 '','' + '''''''' + SUBSTRING([Totaling],29,6) + '''''''' + '','' + '''''''' + SUBSTRING([Totaling],36,6) + '''''''' + 
								 '','' + '''''''' + SUBSTRING([Totaling],43,6) + '''''''' + '','' + '''''''' + SUBSTRING([Totaling],50,6) + '''''''' + 
								 '','' + '''''''' + SUBSTRING([Totaling],57,6) + '''''''' + '','' + '''''''' + SUBSTRING([Totaling],64,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],71,6) + '''''''' +'','' + '''''''' + SUBSTRING([Totaling],78,6) + '''''''' +
								 '','' + '''''''' + SUBSTRING([Totaling],85,6) + '''''''' +
								 + '')''
								 



  
	  WHEN [Line No_] IN(''930000'')
			THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' + 
			                   '','' + ''''''''  + SUBSTRING([Totaling],15,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],22,6) + '''''''' + '''' + '')'' 
	  
	  WHEN [Line No_] IN(''940000'')
		   	THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' + 
			                   '','' + ''''''''  + SUBSTRING([Totaling],15,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],22,6) + '''''''' + 
							   '','' + ''''''''  + SUBSTRING([Totaling],29,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],36,6) + '''''''' + 
							   '','' + ''''''''  + SUBSTRING([Totaling],43,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],50,6) + '''''''' + 
							   '','' + ''''''''  + SUBSTRING([Totaling],57,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],64,6) + '''''''' + 
							   '','' + ''''''''  + SUBSTRING([Totaling],71,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],78,6) + '''''''' + 
							   '','' + ''''''''  + SUBSTRING([Totaling],85,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],92,6) + '''''''' + 
							   '','' + ''''''''  + SUBSTRING([Totaling],99,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],106,6) + '''''''' +
							   '','' + ''''''''  + SUBSTRING([Totaling],113,6) + '''''''' + '''' + '')'' 


      
	  WHEN [Line No_] IN(''950000'')
		    THEN  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      
	  WHEN [Line No_] IN(''960000'')
            THEN  ''[OPUCET] LIKE '' + '''''''' + SUBSTRING([Totaling],1,3) + ''%''''''

	  WHEN [Line No_] IN(''980000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +       
                 '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],16,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],24,6) + ''''''''         
	  WHEN [Line No_] IN(''990000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +       
                 '' OR '' + ''[OPUCET]  BETWEEN  '' + '''' + '''''''' + SUBSTRING([Totaling],16,6) + '''''''' + '''' + '' AND '' + '''' + '''''''' + SUBSTRING([Totaling],24,6) + ''''''''        
	  
	  
	  WHEN [Line No_] IN(''1000000'')
			     THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +       
				      '' AND '' + ''[OPUCET] NOT IN('' + '''''''' + SUBSTRING([Totaling],18,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],27,6) + '''''''' + 
			          '','' + ''''''''  + SUBSTRING([Totaling],36,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],45,6) + '''''''' + '''' + '')''  + 
					  '' OR '' +  ''[OPUCET] LIKE '' + '''''''' + SUBSTRING([Totaling],52,3) + ''%'''''' + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],59,3) + ''%E%''''''  + '''' +
				      '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],68,3) + ''%I%'''''' + '''' +
					  '' OR '' + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],75,7) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],83,7) + '''''''' +  '''' + '')''


	
	  WHEN [Line No_] IN(''1010000'')
				THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' + '')''

   
	  WHEN [Line No_] IN(''1020000'')
			    THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +   
			         '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],18,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],27,3) + ''%I%''''''

    
	  WHEN [Line No_] IN(''1030000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''1040000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''1050000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	  WHEN [Line No_] IN(''1060000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''1070000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''1080000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''1090000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''1100000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''1110000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''1120000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      WHEN [Line No_] IN(''1130000'')
            THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
      
	  WHEN [Line No_] IN(''1140000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' 

      WHEN [Line No_] IN(''1150000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +       
                 '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],16,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],24,6) + '''''''' 

      WHEN [Line No_] IN(''1160000'')
			THEN ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%I''''''  + '''' +
				 '' OR '' +  ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],14,6) + '''''''' + '''' + '')'' + 
				 '' OR '' +  ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],21,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],29,6) + ''''''''

	WHEN [Line No_] IN(''1170000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''  
    
	WHEN [Line No_] IN(''1180000'')
	        THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''  

	WHEN [Line No_] IN(''1190000'')
			THEN ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,1) + ''%'''''' + '''' +  
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],6,1) + ''%I%''''''  + '''' +	    
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],12,1) + ''%E%''''''  + '''' +	   
				 '' OR ''  + ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],16,1) + ''%'''''' + '''' +  
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],21,1) + ''%I%''''''  + '''' +	    
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],27,1) + ''%E%''''''  + '''' 




	WHEN [Line No_] IN(''1220000'')
		   THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '')'' 


	WHEN [Line No_] IN(''1230000'')
		  THEN  ''[OPUCET] BETWEEN '' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '' AND '' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''
	
	
	WHEN [Line No_] IN(''1240000'')
			THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' + 
			                   '','' + ''''''''  + SUBSTRING([Totaling],15,6) + '''''''' +  '','' + ''''''''  + SUBSTRING([Totaling],22,6) + '''''''' + 
							   '','' + ''''''''  + SUBSTRING([Totaling],29,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],36,6) + '''''''' + '''' + 
							   '','' + ''''''''  + SUBSTRING([Totaling],43,6) + '''''''' +  '')''


							    

	WHEN [Line No_] IN(''1250000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],6,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],14,6) + ''''''''  

	WHEN [Line No_] IN(''1270000'')
			  THEN  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' + 
			        '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' 
  
  WHEN [Line No_] IN(''1280000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +
			     '' OR '' + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],16,8) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],25,6) + '''''''' + 
			                '','' + ''''''''  + SUBSTRING([Totaling],32,8) + '''''''' + '''' + '')''


  WHEN [Line No_] IN(''1310000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''  


  WHEN [Line No_] IN(''1330000'')
	          THEN  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' + 
			        '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' 



 WHEN [Line No_] IN(''1340000'')
	        THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],21,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],28,6) + '''''''' +  '''' + '')'' +
			     '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],35,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],43,6) + '''''''' +
				 '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],64,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],72,6) + '''''''' +
				 '' OR '' + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],50,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],57,6) + '''''''' +  
				 '','' + ''''''''  + SUBSTRING([Totaling],79,6) + '''''''' + '''' + '')''


WHEN [Line No_] IN(''1360000'')
	        THEN ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%''''''


 WHEN [Line No_] IN(''1370000'')
			THEN ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%I%''''''  + '''' +	    
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%E%'''''' + '''' +
				 '' OR  '' + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],24,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],54,6) + '''''''' +
				                           '','' + ''''''''  + SUBSTRING([Totaling],61,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],68,6) + ''''''''+  '''' + '')'' + '''' +
				 '' OR  '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],75,3) + ''%'''''' + '''' +  
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],82,3) + ''%I%''''''  + '''' +	    
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],91,3) + ''%E%''''''



WHEN [Line No_] IN(''1380000'')
	        THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +   
			     '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],18,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],27,3) + ''%I%'''''' + '''' +
				 '' OR '' + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],34,8) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],43,6) + '''''''' + 
			                '','' + ''''''''  + SUBSTRING([Totaling],50,8) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],59,8) + '''''''' + '''' + '')''





WHEN [Line No_] IN(''1390000'')
			THEN ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%I%''''''  + '''' +	    
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%E%'''''' + '''' +
				 '' OR '' + ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%I%''''''  + '''' +	    
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%E%''''''


WHEN [Line No_] IN(''1400000'')
	          THEN  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' + 
			        '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' 

WHEN [Line No_] IN(''1410000'')
	        THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''


WHEN [Line No_] IN(''1420000'')
	        THEN ''SUBSTRING([OPUCET],1,3) IN('' + '''''''' + SUBSTRING([Totaling],1,3) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],6,3) + '''''''' + 
			                                 '','' + ''''''''  + SUBSTRING([Totaling],11,3) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],16,3) + '''''''' + 
				                             '','' + ''''''''  + SUBSTRING([Totaling],21,3) + ''''''''	 + '''' + '')''

	  
WHEN [Line No_] IN(''1430000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''


WHEN [Line No_] IN(''1440000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +
			     '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],18,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],27,3) + ''%I%'''''' + ''''+
			     '' OR '' + ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],34,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],42,6) + '''''''' + '''' +
				 '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],51,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],60,3) + ''%I%''''''



WHEN [Line No_] IN(''1450000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +
			     '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],18,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],27,3) + ''%I%''''''

WHEN [Line No_] IN(''1460000'')

			THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' +
				                           '','' + ''''''''  + SUBSTRING([Totaling],15,7) + '''''''' + '''' + '')''

WHEN [Line No_] IN(''1470000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +   
			     '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],18,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],27,3) + ''%I%''''''


WHEN [Line No_] IN(''1480000'')
	        THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],8,6) + '''''''' +
			                   '','' + ''''''''  + SUBSTRING([Totaling],15,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],22,6) + '''''''' +
			                   '','' + ''''''''  + SUBSTRING([Totaling],29,6) + '''''''' +'','' + ''''''''  + SUBSTRING([Totaling],36,6) + '''''''' +
			                   '','' + ''''''''  + SUBSTRING([Totaling],43,6) + '''''''' +'','' + ''''''''  + SUBSTRING([Totaling],50,6) + '''''''' +
			                   '','' + ''''''''  + SUBSTRING([Totaling],57,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],64,7) + '''''''' + '''' + '')''




WHEN [Line No_] IN(''1490000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + ''''''''

WHEN [Line No_] IN(''1500000'')
			THEN ''[OPUCET] BETWEEN '' + '''' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' + '''' + '' AND '' + '''' + ''''''''  + SUBSTRING([Totaling],9,6) + '''''''' + '''' +   
			     '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],18,3) + ''%E%''''''  + '''' +  '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],27,3) + ''%I%''''''


	  Else '''' 
      End) AS  [SQL]
      
      INTO ##MappingRozvaha 
      FROM [' + @Company + '$Acc_ Schedule Line] 
      WHERE [Schedule Name]=''ROZV2023'' ')


  /* **************** MAPPING ROZVAHA KONEC **************** SOUBOR OK FUNGUJE *********************** */


   EXEC (N'SELECT [Schedule Name],[Line No_],[Row No_], [Description], [Totaling ],
 
         (CASE
          WHEN [Line No_] IN(''10000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' 
		  
		  WHEN [Line No_] IN(''20000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''

					   
		 WHEN [Line No_] IN(''30000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''

	
		 WHEN [Line No_] IN(''40000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''


		WHEN [Line No_] IN(''50000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I% ''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],70,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],77,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],86,3) + ''%I%''''''






		WHEN [Line No_] IN(''60000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I% ''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],70,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],77,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],86,3) + ''%I%''''''


		WHEN [Line No_] IN(''70000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I% ''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],70,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],77,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],86,3) + ''%I%''''''

        
	  WHEN [Line No_] IN(''80000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''



					   
     WHEN [Line No_] IN(''90000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''
       

	 WHEN [Line No_] IN(''100000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' 





	 WHEN [Line No_] IN(''110000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' 

      
	WHEN [Line No_] IN(''120000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''

      
	  
     WHEN [Line No_] IN(''140000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''
					   




      WHEN [Line No_] IN(''150000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''
					   
	  WHEN [Line No_] IN(''160000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''

	 WHEN [Line No_] IN(''170000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],70,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],77,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],86,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],93,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],100,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],109,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],116,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],123,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],132,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],139,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],146,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],155,3) + ''%I%''''''





	WHEN [Line No_] IN(''180000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''

	WHEN [Line No_] IN(''190000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''

	WHEN [Line No_] IN(''200000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''

	WHEN [Line No_] IN(''210000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],49,6) + '''''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],56,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],72,3) + ''%I%''''''




	WHEN [Line No_] IN(''220000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],70,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],77,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],86,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],93,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],100,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],109,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],116,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],123,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],132,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],139,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],146,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],155,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],162,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],169,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],178,3) + ''%I%''''''  + '''' +
					   '' OR '' + ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],185,6) + '''''''' + 
					   '','' + ''''''''  + SUBSTRING([Totaling],192,6) + '''''''' + '','' + ''''''''  + SUBSTRING([Totaling],199,6) + '''''''' + '''' + '')''




	WHEN [Line No_] IN(''250000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''

    WHEN [Line No_] IN(''270000'')
	  				THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' 

	WHEN [Line No_] IN(''280000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''


	WHEN [Line No_] IN(''300000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''			   
					   
	
	WHEN [Line No_] IN(''310000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' 
	
	WHEN [Line No_] IN(''320000'')
					THEN ''[OPUCET] IN('' + '''''''' + SUBSTRING([Totaling],1,6) + '''''''' +   '','' + ''''''''  + SUBSTRING([Totaling],8,6) + ''''''''  + '''' + '')''


	WHEN [Line No_] IN(''330000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%'''''' + '''' +				   
					   '' AND '' + ''[OPUCET] <> '' + '''' + '''''''' + SUBSTRING([Totaling],26,6) + '''''''' + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''' + '''''''' + SUBSTRING([Totaling],35,6) + ''''''''




	WHEN [Line No_] IN(''340000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],70,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],77,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],86,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],93,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],100,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],109,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],116,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],123,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],132,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],139,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],146,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],155,3) + ''%I%''''''




	WHEN [Line No_] IN(''350000'')
				THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],70,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],77,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],86,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],93,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],100,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],109,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],116,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],123,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],132,3) + ''%I%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],141,6) + ''''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],150,6) + ''''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],159,6) + ''''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],166,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],173,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],182,3) + ''%I%''''''  + '''' +	
					   
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],189,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],196,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],205,3) + ''%I%''''''
					   



	WHEN [Line No_] IN(''360000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],24,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],31,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],40,3) + ''%I%'''''' + '''' +
					   '' OR '' +  ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],47,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],54,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],63,3) + ''%I%''''''  + '''' +
					   '' OR '' +  ''[OPUCET] = '' + '''' + '''''''' + SUBSTRING([Totaling],70,6) + '''''''' 




	
	WHEN [Line No_] IN(''370000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''

	WHEN [Line No_] IN(''380000'')
					THEN   ''[OPUCET] LIKE '' + '''' + '''''''' + SUBSTRING([Totaling],1,3) + ''%'''''' + '''' +  
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],8,3) + ''%E%''''''  + '''' +
					   '' AND '' + ''[OPUCET] <> '' + '''''''' + SUBSTRING([Totaling],17,3) + ''%I%''''''
					  
		  ELSE ''''
		  END) AS  [SQL]
          INTO ##MappingVysledovka
          FROM [' + @Company + '$Acc_ Schedule Line]
          WHERE [Schedule Name]=''VYSL2023'' AND [Totaling Type]=0')

--SELECT * FROM [CZ RCI$Acc_ Schedule Line]
--WHERE [Schedule Name]='VYSL2020'



/* ***************** AKTUALIZACE OBRATOV� P�EDVAHY -> MAPPINGEM  ***ZA�ATEK************* */



DECLARE  @RowR                VARCHAR(8)
DECLARE  @PopisR			 VARCHAR(1000)
DECLARE  @SQLR				 VARCHAR(1000)

DECLARE  Rozvaha CURSOR FOR SELECT [Row No_], [Description], [SQL]
FROM ##MappingRozvaha WHERE [Row No_]  NOT IN('R1020P','R9998P')

OPEN Rozvaha
FETCH NEXT FROM Rozvaha INTO  @RowR, @PopisR, @SQLR
WHILE @@FETCH_STATUS = 0
BEGIN
 
                      IF   @SQLR <> ''
                           BEGIN
                           
                                EXEC (N'UPDATE  ##tempA
                                      SET [Radek_Vykazu] =''' + @RowR + ''',
									      [Popis_Radku]= ''' + @PopisR + '''
                                      WHERE ' + @SQLR + ' ')
                           END
                
                 
FETCH NEXT FROM Rozvaha INTO  @RowR, @PopisR, @SQLR

END
CLOSE Rozvaha

DEALLOCATE Rozvaha

/* ***************** AKTUALIZACE OBRATOV� P�EDVAHY -> MAPPINGEM  ***KONEC************* */

/* ***************** AKTUALIZACE V�SLEDOVKY -> MAPPINGEM VYSLEDOVKY        *** ZA�ATEK************* */

DECLARE  @RowV                VARCHAR(8)
DECLARE  @PopisV			 VARCHAR(1500)
DECLARE  @SQLV				 VARCHAR(1000)
DECLARE  Vysledovka CURSOR FOR 
         SELECT [Row No_], [Description], [SQL]
         FROM ##MappingVysledovka 
         OPEN Vysledovka
         FETCH NEXT FROM Vysledovka INTO  @RowV , @PopisV, @SQLV
         WHILE @@FETCH_STATUS = 0
              BEGIN
                      IF   @SQLV <> '' 
                           BEGIN
                           
                                EXEC (N'UPDATE ##tempA
                                      SET [Radek_Vykazu] =''' + @RowV + ''',
									      [Popis_Radku]= ''' + @PopisV + '''
                                      WHERE ' + @SQLV + ' AND [Radek_Vykazu]  IS NULL')
                           END
                
                 
              FETCH NEXT FROM Vysledovka INTO  @RowV , @PopisV, @SQLV
          END
          CLOSE Vysledovka
          DEALLOCATE Vysledovka

-- úprava mappingu podle konečného zůstatku (+/-)


EXEC (N'UPDATE ##tempA
      SET [Radek_Vykazu]=''R1410P'',
	      [Popis_Radku]  =''C.II.8.5. Stát - daňové závazky a dotace''
      FROM ##tempA 
	  inner join (SELECT [OPSYNT],Sum([OPKONZUS]) AS SUM_SYN 
				  FROM ##tempA  
				  WHERE [OPSYNT] IN(''343'',''342'') 
				  Group by [OPSYNT]
				  having Sum([OPKONZUS])<0 ) B
	  ON ##tempA.[OPSYNT]=B.[OPSYNT]

	 ') --- změna 343*,342* podle zůstatku (+/-)



EXEC (N'UPDATE ##tempA
      SET [Radek_Vykazu]=''R0640A'',
	      [Popis_Radku]  =''C.II.2.4.3.Stát - daňové pohledávky''
      FROM ##tempA 
	  inner join (SELECT [OPSYNT],Sum([OPKONZUS]) AS SUM_SYN 
				  FROM ##tempA  
				  WHERE [OPSYNT] IN(''343'',''342'') 
				  Group by [OPSYNT]
				  having Sum([OPKONZUS])>0 ) B
	  ON ##tempA.[OPSYNT]=B.[OPSYNT]

	 ') --- změna 343*, 342* podle zůstatku (+/-)




/* ***************** AKTUALIZACE V�SLEDOVKY -> MAPPINGEM VYSLEDOVKY        *** KONEC************* */


SELECT * FROM ##MappingRozvaha 
SELECT * FROM ##MappingVysledovka
SELECT * FROM ##tempA  --Where [OPTRIDA] in(5,6) --[Radek_Vykazu] is null AND [OPKONZUS]<>0 AND [OPTRIDA]=3


