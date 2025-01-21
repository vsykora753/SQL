Use BC_PRODUKCNI
go
DECLARE @MaxPostingDate    DATE 
DECLARE @SQLString         NVARCHAR(2000)
DECLARE @Company           NVARCHAR(20)
SELECT  @MaxPostingDate = '2022-07-31'
SELECT  @Company = 'CZ UCL CZ'


IF OBJECT_ID ('tempdb.dbo.##tmpA', 'U') IS NOT NULL  	      DROP TABLE ##tmpA
IF OBJECT_ID ('tempdb.dbo.##tmpB', 'U') IS NOT NULL           DROP TABLE ##tmpB
IF OBJECT_ID ('tempdb.dbo.##tmpC', 'U') IS NOT NULL           DROP TABLE ##tmpC
IF OBJECT_ID ('tempdb.dbo.##tmpD', 'U') IS NOT NULL           DROP TABLE ##tmpD
IF OBJECT_ID ('tempdb.dbo.##tmpE', 'U') IS NOT NULL           DROP TABLE ##tmpE
IF OBJECT_ID ('tempdb.dbo.##tmpH', 'U') IS NOT NULL           DROP TABLE ##tmpH
IF OBJECT_ID ('tempdb.dbo.##tmpI', 'U') IS NOT NULL           DROP TABLE ##tmpI
IF OBJECT_ID ('tempdb.dbo.##tmpJ', 'U') IS NOT NULL           DROP TABLE ##tmpJ
               

        

EXEC (N'SELECT [Cust_ Ledger Entry No_] AS POLOZKA, Sum([Amount (LCY)]) AS SALDOCZK, SUM([Amount]) AS SALDOMENA 
        INTO ##tmpA 
        FROM [' + @Company + '$Detailed Cust_ Ledg_ Entry] 
        WHERE[Posting Date]<=CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112)
        GROUP BY [Cust_ Ledger Entry No_]
        HAVING   Sum([Amount]) <>0 AND Sum([Amount (LCY)])<>0')



EXEC (N'SELECT [Entry No_], [Cust_ Ledger Entry No_], [Entry Type], [Posting Date], [Document Type], [Document No_], 
        [Amount], [Amount (LCY)], [Customer No_], [Currency Code], [User ID], [Source Code], [Transaction No_], 
        [Journal Batch Name], [Reason Code], [Debit Amount], [Credit Amount], [Debit Amount (LCY)], [Credit Amount (LCY)],
        [Initial Entry Due Date], [Initial Entry Global Dim_ 1], [Initial Entry Global Dim_ 2], [Gen_ Bus_ Posting Group],
        [Gen_ Prod_ Posting Group], [Use Tax], [VAT Bus_ Posting Group], [VAT Prod_ Posting Group], [Initial Document Type],
        [Applied Cust_ Ledger Entry No_], [Unapplied], [Unapplied by Entry No_], [Remaining Pmt_ Disc_ Possible],
        [Max_ Payment Tolerance], [Tax Jurisdiction Code], [Advance], [Customer Posting Group], [Fin_ Charge Reversed],
        [Original Posting Date]
        INTO ##tmpB
        FROM [' + @Company + '$Detailed Cust_ Ledg_ Entry] 
        INNER JOIN ##tmpA
        ON ##tmpA.[POLOZKA]=[' + @Company + '$Detailed Cust_ Ledg_ Entry].[Cust_ Ledger Entry No_] 
        WHERE [Posting Date]<=CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112) ')  /* vytvoøí detail s otevøenými záznamy pohledávek   'pøes [Cust_ Ledger Entry No_] lze spojit záznam v tabulce [G_L Entry]  */

		--AND [Unapplied]=0  odstranìno z pøedchozího øádku, aby souhlasilo Saldo na HK i po spuštìní párování  ze dne 03.5.2018


 


EXEC (N'SELECT [Cust_ Ledger Entry No_], [Entry Type], [Document No_], SUM([Amount]) AS [OrigAmount], 
        CAST(0.00 AS NUMERIC(15,2))  AS [OrigZaplaceno], CAST(0.00 AS NUMERIC(15,2))  AS [OrigZbyva], SUM([Amount (LCY)]) AS [CzkAmount],
        CAST(0.00 AS NUMERIC(15,2))  AS [ZAPLACENO],  CAST(0.00 AS NUMERIC(15,2))  AS [KurzRozdily], CAST(0.00 AS NUMERIC(15,2)) AS [ZBYVA] 
        INTO ##tmpC 
        FROM  ##tmpB 
        WHERE [Entry Type]=1 
        GROUP BY [Cust_ Ledger Entry No_], [Entry Type], [Document No_]')  /* FAKTURY   */  --[Entry Type]=1 - Pùvodní položka


EXEC (N'SELECT [Cust_ Ledger Entry No_], SUM([Amount]) AS [OrigAmount],
        SUM([Amount (LCY)]) AS [CzkAmount] 
        INTO ##tmpD 
        FROM  ##tmpB
        WHERE [Entry Type]=2
        GROUP BY [Cust_ Ledger Entry No_]')  /*PLATBY */   --[Entry Type]=2 - Vyrovnání
                      
        
EXEC (N'SELECT [Cust_ Ledger Entry No_], SUM([Amount]) AS [OrigAmount], 
        SUM([Amount (LCY)]) AS [CzkAmount] 
        INTO ##tmpE
        FROM  ##tmpB 
        WHERE [Entry Type] IN (3,4,5,6,11,12) 
        GROUP BY [Cust_ Ledger Entry No_]')   /* OSTATNÍ*/
		                                       --OSTATNÍ  tbl.#tmpE  -> [Entry Type]=3 - NEREALIZOVANÁ ZTRÁTA
                                               --OSTATNÍ  tbl.#tmpE  -> [Entry Type]=4 - NEREALIZOVANÝ ZISK
                                               --OSTATNÍ  tbl.#tmpE  -> [Entry Type]=5 - REALIZOVANÁ   ZTRÁTA
                                               --OSTATNÍ  tbl.#tmpE  -> [Entry Type]=6 - REALIZOVANÝ   ZISK
											   --OSTATNÍ

         
EXEC (N'UPDATE ##tmpC SET [OrigZaplaceno]=##tmpD.[OrigAmount], [ZAPLACENO]= ##tmpD.[CzkAmount]
        FROM ##tmpC 
        INNER JOIN ##tmpD 
        ON ##tmpD.[Cust_ Ledger Entry No_]=##tmpC.[Cust_ Ledger Entry No_]'   )

                                          
        
EXEC (N'UPDATE ##tmpC SET [KurzRozdily]=##tmpE.[CzkAmount]
        FROM ##tmpC 
        INNER JOIN ##tmpE 
        ON ##tmpE.[Cust_ Ledger Entry No_]=##tmpC.[Cust_ Ledger Entry No_]')

                                         
        
EXEC (N'UPDATE ##tmpC SET [OrigZbyva]=##tmpC.[OrigAmount]+##tmpC.[OrigZaplaceno], [ZBYVA]=##tmpC.[CzkAmount]+##tmpC.[ZAPLACENO]+##tmpC.[KurzRozdily] 
        FROM ##tmpC')
		                             
        
EXEC (N'SELECT ##tmpB.[Cust_ Ledger Entry No_],[Posting Date],[Initial Entry Due Date],DATEDIFF(DD,[Initial Entry Due Date],CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112)) AS [DNY PO SPLATNOSTI], ##tmpB.[Document No_],
        ##tmpC.[OrigAmount], ##tmpC.[OrigZaplaceno], ##tmpC.[OrigZbyva], ##tmpC.[CzkAmount], ##tmpC.[ZAPLACENO], ##tmpC.[KurzRozdily], ##tmpC.[ZBYVA], [Customer No_], [Currency Code], [Initial Entry Global Dim_ 2] 
        INTO ##tmpH FROM ##tmpB 
        INNER JOIN ##tmpC 
        ON ##tmpc.[Cust_ Ledger Entry No_]=##tmpB.[Cust_ Ledger Entry No_]
        AND ##tmpc.[Entry Type]=##tmpB.[Entry Type] 
        ORDER BY [Customer No_],[Posting Date]') 



EXEC (N'CREATE TABLE ##tmpI

            ([G_L Account No_] VARCHAR(7) NULL, [NazevUctu] VARCHAR(100) NULL, [Customer No_] INT NULL, [ZakSml] INT NULL, [ZAKAZNIK] VARCHAR(150) NULL,
			 [ICO] VARCHAR(50) NULL, [Customer Address] VARCHAR (50) NULL,[Customer Address 2] VARCHAR (50) NULL, [Customer City] VARCHAR (30) NULL,
			 [Post Code] VARCHAR (20) NULL, [Email] VARCHAR (150) NULL, [MANDANT] VARCHAR(20) NULL, [Document Kind Code] VARCHAR(20) NULL,[Document No_] VARCHAR(20) NULL,
			 [Document_Kind Name] VARCHAR(100) NULL,[Posting Date] DATE NULL, [Initial Entry Due Date] DATE NULL, [DNY PO SPLATNOSTI] INT NULL,
			 [Currency Code] VARCHAR(3) NULL, [OrigAmount] NUMERIC(15,2) NULL, [OrigZaplaceno] NUMERIC(15,2) NULL,[OrigZbyva] NUMERIC(15,2) NULL,
			 [CzkAmount] NUMERIC(15,2) NULL, [ZAPLACENO] NUMERIC(15,2) NULL, [KurzRozdily] NUMERIC(15,2) NULL, [ZBYVA] NUMERIC(15,2) NULL,
			 [Initial Entry Global Dim_ 2] VARCHAR(20) NULL, [PREDANI_PREDMETU] DATE NULL, [ZacSml] DATE NULL, [PredpUkonc] DATE NULL, 
			 [UkonSml] DATE NULL, [StavSml] VARCHAR(3) NULL, [Stav_popis] VARCHAR(100) NULL, [MIGR_SML] VARCHAR(5) NULL, [TypFin] VARCHAR(20) NULL,
			 [PREP_PREDP] VARCHAR(6) NULL, [IC_kod] VARCHAR(5) NULL, [Cust_ Ledger Entry No_] INT NULL, [KeDni] DATE NULL, [PocetPrevodu] INT NULL,
			 [Mena_Sml] VARCHAR(4) NULL )')


EXEC (N' INSERT INTO ##tmpI([G_L Account No_],[Customer No_],[Document No_],[Posting Date], [Initial Entry Due Date], [DNY PO SPLATNOSTI],
         [Currency Code], [OrigAmount], [OrigZaplaceno], [OrigZbyva], [CzkAmount],[ZAPLACENO],
		 [KurzRozdily], [ZBYVA], [Initial Entry Global Dim_ 2], [Cust_ Ledger Entry No_])
		 SELECT [' + @Company + '$G_L Entry].[G_L Account No_], ##tmpH.[Customer No_], ##tmpH.[Document No_],
		 ##tmpH.[Posting Date], ##tmpH.[Initial Entry Due Date], ##tmpH.[DNY PO SPLATNOSTI], ##tmpH.[Currency Code],
		 ##tmpH.[OrigAmount],##tmpH.[OrigZaplaceno], ##tmpH.[OrigZbyva], ##tmpH.[CzkAmount], ##tmpH.[ZAPLACENO], ##tmpH.[KurzRozdily],
		 ##tmpH.[ZBYVA], ##tmpH.[Initial Entry Global Dim_ 2], ##tmpH.[Cust_ Ledger Entry No_]
         FROM ##tmpH 
         INNER JOIN [' + @Company + '$G_L Entry] 
         ON [' + @Company + '$G_L Entry].[Entry No_]=##tmpH.[Cust_ Ledger Entry No_]')  -- vloží hodnoty ze saldokontních úètù

 

EXEC (N'INSERT INTO ##tmpI ([G_L Account No_], [Customer No_],[ZBYVA],[Initial Entry Global Dim_ 2])
         SELECT [G_L Account No_],B.[Customer No_], SUM([SUM$Amount]) AS [ZBYVA],[Global Dimension 2 Code]
		 FROM [' + @Company + '$G_L Entry$VSIFT$17] A
	     LEFT JOIN [' + @Company + '$LEA Contract Header]  B
	     ON B.[No_]= A.[Global Dimension 2 Code]
	     WHERE [G_L Account No_] in (''378900'', ''378920'')
	     AND [Posting Date]  <=CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112)
	     GROUP BY [G_L Account No_],[Global Dimension 2 Code],B.[Customer No_] ')  -- vloží hodnoty 3789x0 z hlavní knihy (vìcné položky) CZK


EXEC (N'UPDATE ##tmpI  SET [OrigZbyva]=B.[OrigZbyva],
                           [Currency Code]=B.[Currency Code]
        FROM ##tmpI A
		INNER JOIN (SELECT [G_L Account No_], [Currency Code],[Global Dimension 2 Code], SUM([SUM$Currency Amount]) AS [OrigZbyva] FROM [' + @Company + '$G_L Entry$VSIFT$23]
                    WHERE [G_L Account No_] IN (''378920'',''378900'') 
					AND [Currency Code]=''EUR'' AND [Posting Date]<=CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112)
                    GROUP BY [G_L Account No_],[Currency Code],[Global Dimension 2 Code]) B
		ON A.[Initial Entry Global Dim_ 2]=B.[Global Dimension 2 Code]COLLATE DATABASE_DEFAULT
		AND A.[G_L Account No_]=B.[G_L Account No_] COLLATE DATABASE_DEFAULT')  -- aktualizuje u úètù 378900,920 èástku v EUR, a mìnu


EXEC (N'UPDATE ##tmpI  SET [CzkAmount]=B.[CzkAmount]
      FROM ##tmpI A
	  INNER JOIN (SELECT  [G_L Account No_], [Global Dimension 2 Code], SUM([Amount]) AS [CzkAmount] from [dbo].[' + @Company + '$G_L Entry] 
                  WHERE [Source Code]<>''ADJSMKURZU''
                  AND [G_L Account No_] IN (''378920'',''378900'') AND [Posting Date]<=CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112)
                  GROUP BY [G_L Account No_],[Global Dimension 2 Code]) B
	    ON A.[Initial Entry Global Dim_ 2]=B.[Global Dimension 2 Code]COLLATE DATABASE_DEFAULT
		AND A.[G_L Account No_]=B.[G_L Account No_] COLLATE DATABASE_DEFAULT')  -- aktualizuje pole CZKAmount



EXEC (N'UPDATE ##tmpI  SET [KurzRozdily]=B.[KurzRozdily]
      FROM ##tmpI A
	  INNER JOIN (SELECT  [G_L Account No_], [Global Dimension 2 Code], SUM([Amount]) AS [KurzRozdily] from [dbo].[' + @Company + '$G_L Entry] 
                  WHERE [Source Code]=''ADJSMKURZU''
                  AND [G_L Account No_] IN (''378920'',''378900'') AND [Posting Date]<=CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112)
                  GROUP BY [G_L Account No_],[Global Dimension 2 Code]) B
	    ON A.[Initial Entry Global Dim_ 2]=B.[Global Dimension 2 Code]COLLATE DATABASE_DEFAULT
		AND A.[G_L Account No_]=B.[G_L Account No_] COLLATE DATABASE_DEFAULT')  -- aktualizuje pole CZKAmount



 

EXEC(N'UPDATE  ##tmpI SET [Currency Code]=''CZK'' WHERE [Currency Code] ='''' OR [Currency Code] is null ')

EXEC (N'UPDATE ##tmpI SET [ZAKAZNIK]=B.[NAME], 
                          [ICO]=B.[Registration No_],
						  [Customer Address]=B.[Address],
						  [Customer Address 2]=B.[Address 2],
						  [Customer City]=B.[City],
						  [Post Code]=B.[Post Code],
						  [Email]=B.[E-Mail]


        FROM ##tmpI 
        INNER JOIN [' + @Company + '$Customer] B
        ON B.[No_]=##tmpI.[Customer No_] ') 

EXEC (N' UPDATE ##tmpI SET [IC_kod]  = B.[Dimension Value Code]
         FROM  ##tmpI 
		 INNER JOIN 
		 [' + @Company + '$Default Dimension] B
		 ON ##tmpI.[Customer No_]=B.[No_] COLLATE DATABASE_DEFAULT
		  WHERE [Dimension Code]=''Intercompany'' AND [Table ID]=18  ')     

EXEC (N'UPDATE ##tmpI SET [ZacSml]=B.[ZacSml], 
						  [ZakSml]=B.[Customer No_],
						  [PredpUkonc]=B.[PredpUkonc],
                          [UkonSml]=(CASE WHEN B.[UkonSml]=''1753-01-01'' THEN B.[Early Termination Date]
						             ELSE
									 B.[UkonSml] 
									 END),
						  [StavSml]=B.[Detail Contract Status],
						  [Stav_popis]=B.[Description],
						  [TypFin]=B.[TypFin],
						  [PREDANI_PREDMETU]=B.[Object Handover Date],      
						  [MIGR_SML]= B.[MIGR_SML],				 
						  [Mena_Sml]=B.[Currency Code]
       FROM  ##tmpI 
	   INNER JOIN (SELECT [No_],[Customer No_],[Status],[Detail Contract Status],[Detail Contract Status].[Description],
				  (CASE
					WHEN [Financing Type]=0 then ''FL''
					WHEN [Financing Type]=1 then ''OL''
					WHEN [Financing Type]=2 then ''UV''
					WHEN [Financing Type]=3 then ''SP''
					ELSE ''''
					END) AS TypFin,[Calculation Starting Date] AS [ZacSml], [Assumed Termination Date] AS [PredpUkonc],
					[Real Termination Date] AS [UkonSml],[Early Termination Date],[Object Handover Date],
					(CASE
					  WHEN [ILEAS Contract]=0 then ''NE''
					  WHEN [ILEAS Contract]=1 then ''ANO''
					  ELSE ''''
                     END) AS MIGR_SML, [Currency Code]
				 FROM [' + @Company + '$LEA Contract Header]
				 INNER JOIN
				 [Detail Contract Status]
				 ON[Detail Contract Status].[Code]=[' + @Company + '$LEA Contract Header].[Detail Contract Status] COLLATE DATABASE_DEFAULT) B
		ON  B.[No_]=##tmpI.[Initial Entry Global Dim_ 2] COLLATE DATABASE_DEFAULT')

                          
EXEC (N'UPDATE ##tmpI SET [NazevUctu]=[' + @Company + '$G_L Account].[NAME] 
        FROM ##tmpI 
        INNER JOIN [' + @Company + '$G_L Account] 
        ON [' + @Company + '$G_L Account].[No_]=##tmpI.[G_L Account No_] COLLATE DATABASE_DEFAULT 
        WHERE [Account Type]=  0 ')

EXEC (N'UPDATE ##tmpI SET [PREP_PREDP]=''PREDPL''
        FROM ##tmpI
		WHERE [G_L Account No_] LIKE ''324%'' AND [StavSml] IN(''PPS'',''PPO'',''ZRR'')')

EXEC (N'UPDATE ##tmpI SET [PREP_PREDP]=''PREPL''
        FROM ##tmpI
		WHERE [G_L Account No_] LIKE ''324%'' AND [StavSml] NOT IN(''PPS'',''PPO'',''ZRR'')')

EXEC (N'UPDATE ##tmpI SET [Initial Entry Due Date]=[PredpUkonc]
        FROM ##tmpI WHERE [G_L Account No_]=''378900'' AND [UkonSml]=''1753-01-01''')

EXEC (N'UPDATE ##tmpI SET [Initial Entry Due Date]=[UkonSml]
        FROM ##tmpI WHERE [G_L Account No_]=''378900'' AND [UkonSml]<>''1753-01-01''')

EXEC (N'UPDATE ##tmpI SET [DNY PO SPLATNOSTI]=DATEDIFF(DD,[Initial Entry Due Date],CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112))
        FROM ##tmpI WHERE [G_L Account No_]=''378900''')

EXEC (N'UPDATE ##tmpI SET [Document Kind Code]= CUSFA.[Document Kind Code],
                          [Document_Kind Name]=[Document Kind].[Name]
        FROM ##tmpI
		RIGHT JOIN [' + @Company + '$Cust_ Ledger Entry] CUSFA
		ON CUSFA.[Entry No_] = ##tmpI.[Cust_ Ledger Entry No_]
		INNER JOIN [Document Kind]
		ON CUSFA.[Document Kind Code]=[Document Kind].[Code]')



EXEC (N'UPDATE ##tmpI SET 
                     [KeDni]= CONVERT(VARCHAR(12),''' +@MaxPostingDate + ''', 112),
					 [MANDANT]= ''' + @Company + '''
        FROM ##tmpI ')


EXEC (N'UPDATE ##tmpI SET [PocetPrevodu]=  B.[PocetZaznamu]
        FROM ##tmpI A
		INNER JOIN (select [Contract No_], Count([Contract No_]) AS [PocetZaznamu]
                    FROM [' + @Company + '$Contract Transfer History]
                    WHERE [Transfer Status]=5
                    GROUP BY [Contract No_]) B
		ON A.[Initial Entry Global Dim_ 2]=B.[Contract No_] COLLATE DATABASE_DEFAULT')

   


                   
GO

--select * from ##tmpI  WHERE [ZBYVA]<>0 
--AND [Initial Entry Global Dim_ 2]='1531329759'

--SELECT * FROM ##tmpB   WHERE  [Initial Entry Global Dim_ 2]='1531329759'

--SELECT * FROM ##tmpE

SELECT [MANDANT],[G_L Account No_], [NazevUctu], [Customer No_],[ZAKAZNIK], [ZakSml], [PocetPrevodu],[ICO] , [Document Kind Code],[Document_Kind Name],[Document No_],
	   [Posting Date], [Initial Entry Due Date], [DNY PO SPLATNOSTI], [Currency Code],
	   [OrigAmount], [OrigZaplaceno],[OrigZbyva], [CzkAmount], [ZAPLACENO], [KurzRozdily], [ZBYVA],
	   [Initial Entry Global Dim_ 2], [PREDANI_PREDMETU], [ZacSml], [PredpUkonc], [UkonSml],
	   [StavSml], [Stav_popis], [MIGR_SML], [TypFin], [PREP_PREDP],
	   [IC_kod], [KeDni],[Mena_Sml]
	   FROM ##tmpI  WHERE [ZBYVA]<>0
	   ORDER BY [G_L Account No_],[Customer No_], [Posting Date] ASC  --- saldo pohledávek 

	   

--  následující script vytvoøí pohledávky mimo code --- upraveno  dne: 9.02.2018
--  tvoøeno výbìrem z pøedchozí tabulky

SELECT [MANDANT],[G_L Account No_], [NazevUctu], [Customer No_], [ZakSml],[ZAKAZNIK], [ICO] ,
       [Customer Address], [Customer Address 2], [Customer City], [Post Code], [Email],[Document Kind Code],
	   [Document_Kind Name],[Document No_], [Posting Date], [Initial Entry Due Date], [DNY PO SPLATNOSTI], [Currency Code],
	   [OrigAmount], [OrigZaplaceno],[OrigZbyva], [CzkAmount], [ZAPLACENO], [KurzRozdily], [ZBYVA],
	   [Initial Entry Global Dim_ 2], [PREDANI_PREDMETU], [ZacSml], [PredpUkonc], [UkonSml],
	   [StavSml], [Stav_popis], [MIGR_SML], [TypFin], [PREP_PREDP],
	   [IC_kod], [KeDni],[Mena_Sml]
	   FROM ##tmpI  
	   WHERE 
	   
	   SUBSTRING([G_L Account No_],1,4) IN('3111','3112','3113','3115','3116') AND [ZacSml] is null 
	   AND  [Document Kind Code]<>'UP'
	   
	   OR
	   SUBSTRING([G_L Account No_],1,4) IN('3111','3112','3113','3115','3116') 
	   AND [ZacSml] is not null   AND [Customer No_]<>[ZakSml]  AND  [Document Kind Code]<>'UP'
	   
	   ORDER BY [G_L Account No_],[Customer No_], [Posting Date] ASC



 