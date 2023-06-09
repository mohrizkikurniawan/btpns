*-----------------------------------------------------------------------------
*Created by Laily Alfia
*Date: 20200210
*Routine for SKN Out STO dan DEPOSITS ONLINE
*-----------------------------------------------------------------------------
* Date               : 20221028
* Modified by        : Moh Rizki Kurniawan
* Description        : Flag untuk tranfer melalui BIFAST (CBA-64)
* No Log             : 
*-----------------------------------------------------------------------------
    SUBROUTINE IDIB.SKN.OUT.STODEPO.ONLINE(SEL.LIST)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.IDCH.SKN.INTERFACE.PARAM
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.STANDING.ORDER
    $INSERT I_IDIB.SKN.OUT.STODEPO.ONLINE.COMMON
    $INSERT I_F.IDIU.STODEPO.CLEARING
    $INSERT I_F.IDIU.DEPO.RTGS
    $INSERT I_F.IDIH.PMS.CALC.PARAMETER
    $INSERT I_F.IDIL.PMS.DEPO.CONCAT
    $INSERT I_F.DATES
    $INSERT I_F.IDIL.AZ.SCH.MARGIN
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.SETTLEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    GOSUB INITIAL
    GOSUB PROCESS
	
    RETURN
*-----------------------------------------------------------------------------
INITIAL:
*-----------------------------------------------------------------------------

    Y.ACCT       = SEL.LIST
    R.STODEPO    = ''
    R.DEPO.RTGS  = ''
    Y.FLAG.BREAK = ''

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    CALL F.READ(FN.ACCT.ENT,Y.ACCT,R.ACCT.ENT,F.ACCT.ENT,ACCT.ENT.ERR)
    IF R.ACCT.ENT THEN
        Y.STMT = R.ACCT.ENT
        Y.CNT.STMT = DCOUNT(Y.STMT,@FM)
        FOR I=1 TO Y.CNT.STMT
            Y.STMT.NO    = Y.STMT<I>
            CALL F.READ(FN.STMT.ENTRY,Y.STMT.NO,R.STMT.ENT,F.STMT.ENTRY,STMT.ERR)
            Y.TRANS.REF     = R.STMT.ENT<AC.STE.TRANS.REFERENCE>
            Y.OUR.REF       = R.STMT.ENT<AC.STE.OUR.REFERENCE>
            Y.AMT.LCY       = R.STMT.ENT<AC.STE.AMOUNT.LCY>
            Y.SYSTEM.ID     = R.STMT.ENT<AC.STE.SYSTEM.ID>
            Y.VALUE.DATE    = R.STMT.ENT<AC.STE.VALUE.DATE>
			Y.CHEQUE.NUMBER = R.STMT.ENT<AC.STE.CHEQUE.NUMBER>

            IF (Y.AMT.LCY GT 0) THEN
                GOSUB PROCESS.DEPO
            END
        NEXT I
    END ELSE
	    CALL F.READ(FN.LWORK.DAY,Y.ACCT,R.LWORK.DAY,F.LWORK.DAY,LWORK.DAY.ERR)
        IF R.LWORK.DAY THEN
            Y.STMT.LWORK     = R.LWORK.DAY
            Y.CNT.STMT.LWORK = DCOUNT(Y.STMT.LWORK,@FM)
            FOR J=1 TO Y.CNT.STMT.LWORK
                Y.STMT.NO    = Y.STMT.LWORK<J>
                CALL F.READ(FN.STMT.ENTRY,Y.STMT.NO,R.STMT.ENT,F.STMT.ENTRY,STMT.ERR)
                Y.TRANS.REF     = R.STMT.ENT<AC.STE.TRANS.REFERENCE>
                Y.OUR.REF       = R.STMT.ENT<AC.STE.OUR.REFERENCE>
                Y.AMT.LCY       = R.STMT.ENT<AC.STE.AMOUNT.LCY>
                Y.SYSTEM.ID     = R.STMT.ENT<AC.STE.SYSTEM.ID>
                Y.VALUE.DATE    = R.STMT.ENT<AC.STE.VALUE.DATE>
				Y.CHEQUE.NUMBER = R.STMT.ENT<AC.STE.CHEQUE.NUMBER>
				
                IF (Y.AMT.LCY GT 0) THEN
                    GOSUB PROCESS.DEPO
                END
            NEXT J
        END
	END

    RETURN

*-----------------------------------------------------------------------------
PROCESS.DEPO:
*-----------------------------------------------------------------------------

    Y.DB.ACCT   = '' ; Y.FLAG.BREAK    = '' ; Y.FLAG.PMA    = '' ; Y.MARGIN       = ''
    R.MM        = '' ; Y.FLAG.CLEARING = '' ; Y.SKN.RTGS    = '' ; Y.CHG.AMT      = ''
    R.PMS.PARAM = '' ; Y.LAST.PMS.ACT  = '' ; Y.PMS.DEPO.ID = '' ; Y.SISA.MARGIN  = ''
    R.PMS.DEPO  = '' ; Y.GROSS.AMT     = '' ; Y.ZAKAT.AMT   = '' ; Y.TAX.AMT      = ''
     
    Y.DB.ACCT    = FIELD(Y.CHEQUE.NUMBER, "*", 1)
	
	IF NOT(Y.DB.ACCT) THEN
		CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY, Y.TRANS.REF , R.AA.ARRANGEMENT.ACTIVITY, F.AA.ARRANGEMENT.ACTIVITY, ERR.AA.ARRANGEMENT.ACTIVITY)
		Y.AA.ARRANGEMENT.ID = R.AA.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.ARRANGEMENT>
		Y.DB.ACCT = Y.AA.ARRANGEMENT.ID
	END
	
    Y.FLAG.BREAK = ""                            
    Y.FLAG.PMA   = FIELD(Y.CHEQUE.NUMBER, "*", 2)

    CALL F.READ(FN.AA.ARRANGEMENT, Y.DB.ACCT, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, AA.ARRANGEMENT.ERR)
    Y.CO.CODE        = R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
    Y.CUST.ID        = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
	Y.LINKED.APPL.ID = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
	
	CALL F.READ(FN.ACCT, Y.LINKED.APPL.ID, R.ACCOUNT, F.ACCOUNT, ACCOUNT.ERR)
	Y.ACCOUNT.TITLE.1 = R.ACCOUNT<AC.ACCOUNT.TITLE.1>
	Y.ATI.JOINT.NAME  = R.ACCOUNT<AC.LOCAL.REF, Y.ATI.JOINT.NAME.POS>
    Y.TAX.FLAG        = R.ACCOUNT<AC.LOCAL.REF, Y.POS.SYS.TAXABLE>
    Y.ZAKAT.FLAG      = R.ACCOUNT<AC.LOCAL.REF, Y.POS.ZAKAT>

	CALL F.READ(FN.AA.ACCOUNT.DETAILS, Y.DB.ACCT, R.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS, AA.ACCOUNT.DETAILS.ERR)
	
    Y.PROPERTY.ID.SET    = "SETTLEMENT"
    Y.PROPERTY.CLASS.SET = ""
    Y.EFFECTIVE.DATE.SET = TODAY
    CALL AA.GET.PROPERTY.RECORD("",Y.DB.ACCT,Y.PROPERTY.ID.SET,Y.EFFECTIVE.DATE.SET,Y.PROPERTY.CLASS.SET,"",R.AA.SETTLEMENT,RET.ERROR.SET)

    Y.FLAG.CLEARING    = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.AZ.MUD.CLEARED>
    Y.SKN.RTGS         = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.SKN.RTGS>
    Y.INPUTTER         = R.AA.SETTLEMENT<AA.SET.INPUTTER>
    Y.DATE.TIME        = R.AA.SETTLEMENT<AA.SET.DATE.TIME>
    Y.AUTHORISER       = R.AA.SETTLEMENT<AA.SET.AUTHORISER>
    Y.DEPT.CODE        = R.AA.SETTLEMENT<AA.SET.DEPT.CODE>
    Y.BREAK.AMT        = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.BREAK.AMT>
*20201124
    Y.L.CHARGE         = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.L.CHARGE.POS>
    Y.L.CHG.ACCT       = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.L.CHG.ACCT.POS>
    Y.PAYOUT.ACCOUNT   = R.AA.SETTLEMENT<AA.SET.PAYOUT.ACCOUNT>
*20201124

*20221003_RPU
    Y.CHARGE.TYPE       = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.STLM.CHARGE.TYPE>
    Y.CHARGE.AMT        = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.STLM.CHARGE.AMT>
*20221003_RPU

    Y.PROPERTY.ID.AMT    = "COMMITMENT"
    Y.PROPERTY.CLASS.AMT = ""
    Y.EFFECTIVE.DATE.AMT = TODAY
    CALL AA.GET.PROPERTY.RECORD("",Y.DB.ACCT,Y.PROPERTY.ID.AMT,Y.EFFECTIVE.DATE.AMT,Y.PROPERTY.CLASS.AMT,"",R.AA.TERM.AMOUNT,RET.ERROR.AMT)
	
    Y.ARO          = R.AA.TERM.AMOUNT<AA.AMT.LOCAL.REF, Y.ARO.OPTION>
    Y.L.MAT.MODE   = R.AA.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.L.MAT.MODE.POS>
    Y.TENOR	   = R.AA.TERM.AMOUNT<AA.AMT.TERM>
    Y.L.TENOR	   = R.AA.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.L.TENOR.POS>

	IF Y.L.TENOR NE '' THEN
		Y.TENOR	= Y.L.TENOR
	END
	
	Y.END.TENOR	= RIGHT(Y.TENOR,1)
	Y.NUM.TENOR	= FIELD(Y.TENOR,Y.END.TENOR,1)
	
	IF Y.END.TENOR EQ 'Y' THEN
		CHANGE "Y" TO "M" IN Y.END.TENOR
		Y.TENOR = Y.NUM.TENOR * 12
		Y.TENOR = Y.TENOR :Y.END.TENOR
	END

*20201124
*    Y.CHG.AMT      = R.AA.TERM.AMOUNT<AA.AMT.AMOUNT> * Y.CHRG.BRK.RATE/100
    IF Y.L.CHG.ACCT NE Y.PAYOUT.ACCOUNT THEN
        Y.CHG.AMT   = 0
    END ELSE
        Y.CHG.AMT   = Y.L.CHARGE
    END
*20201124
    Y.CHG.AMT     = DROUND(Y.CHG.AMT,0)
    *Y.CHG.AMT      = "" 
	IF Y.ARO NE "" THEN
		Y.INT.PERIOD.START = R.AA.ACCOUNT.DETAILS<AA.AD.LAST.RENEW.DATE>      ;*R.MM<MM.INT.PERIOD.START>
	END ELSE
		Y.INT.PERIOD.START = R.AA.ACCOUNT.DETAILS<AA.AD.START.DATE>           ;*R.MM<MM.INT.PERIOD.START>
	END

    CALL F.READ(FN.AZ.MARGIN, Y.DB.ACCT, R.AZ.MARGIN, F.AZ.MARGIN, AZ.MARGIN.ERR)
    Y.PERIOD.MARGIN.AMT    = R.AZ.MARGIN<AZ.SCH.MARG.PERIOD.MARGIN.AMT>
    Y.PERIOD.MARGIN.AMT.EF = R.AZ.MARGIN<AZ.SCH.MARG.BREAK.AFT.MAT>
    IF Y.BREAK.AMT NE '' THEN
        IF Y.FLAG.PMA NE '' THEN
            CALL F.READ(FN.PMS.PARAM,"SYSTEM",R.PMS.PARAM,F.PMS.PARAM,PMS.PARAM.ERR)
            Y.LAST.PMS.ACT = R.PMS.PARAM<PMS.CALC.LAST.PMS.ACTION.ID>

            Y.PMS.DEPO.ID = Y.LAST.PMS.ACT : "*" : Y.DB.ACCT

            CALL F.READ(FN.PMS.DEPO,Y.PMS.DEPO.ID,R.PMS.DEPO,F.PMS.DEPO,PMS.DEPO.ERR)

            Y.GROSS.AMT = R.PMS.DEPO<IDIL.DEPO.CON.GROSS.AMOUNT>
            Y.ZAKAT.AMT = R.PMS.DEPO<IDIL.DEPO.CON.ZAKAT.AMOUNT>
            Y.TAX.AMT   = R.PMS.DEPO<IDIL.DEPO.CON.TAX.AMOUNT>

            IF Y.L.MAT.MODE NE "PRINCIPAL + PROFIT ROLLOVER" THEN
                Y.GROSS.AMT += Y.PERIOD.MARGIN.AMT
            END

            IF Y.BREAK.AMT THEN
                Y.GROSS.AMT = Y.BREAK.AMT
                GOSUB CALC.TAX.ZAKAT.AMT
            END

            Y.MARGIN = Y.GROSS.AMT - Y.ZAKAT.AMT - Y.TAX.AMT

            IF Y.PERIOD.MARGIN.AMT.EF GT '0' THEN
*<Hamka Ardyansah - 20191031 - INC0311376
                IF Y.TAX.FLAG NE 'Y' THEN
                    Y.TAX.AMT = 0
                END ELSE
                    IF Y.TENOR NE '01M' THEN
                        Y.TAX.AMT = Y.PERIOD.MARGIN.AMT.EF * Y.TAX.RATE/100
                        Y.TAX.AMT = DROUND(Y.TAX.AMT,0)
                    END ELSE
                        Y.TAX.AMT = 0
                    END
                END
                IF Y.ZAKAT.FLAG NE 'Y' THEN
                    Y.ZAKAT.AMT = 0
                END ELSE
                    IF Y.TENOR NE '01M' THEN
                        Y.ZAKAT.AMT = (Y.PERIOD.MARGIN.AMT.EF - Y.TAX.AMT) * Y.ZAKAT.RATE/100
                        Y.ZAKAT.AMT = DROUND(Y.ZAKAT.AMT,0)
                    END ELSE
                        Y.ZAKAT.AMT = 0
                    END
                END
                Y.MARGIN=Y.PERIOD.MARGIN.AMT.EF - Y.TAX.AMT - Y.ZAKAT.AMT
*>INC0311376
                R.AZ.MARGIN<AZ.SCH.MARG.BREAK.AFT.MAT> = "0"
                CALL F.WRITE(FN.AZ.MARGIN,Y.DB.ACCT,R.AZ.MARGIN)
            END
*>
        END ELSE

            Y.MARGIN = Y.AMT.LCY - Y.CHG.AMT

        END
    END ELSE
        IF Y.FLAG.PMA NE '' THEN
            CALL F.READ(FN.PMS.PARAM,"SYSTEM",R.PMS.PARAM,F.PMS.PARAM,PMS.PARAM.ERR)
            Y.LAST.PMS.ACT = R.PMS.PARAM<PMS.CALC.LAST.PMS.ACTION.ID>

            Y.PMS.DEPO.ID = Y.LAST.PMS.ACT : "*" : Y.DB.ACCT

            CALL F.READ(FN.PMS.DEPO,Y.PMS.DEPO.ID,R.PMS.DEPO,F.PMS.DEPO,PMS.DEPO.ERR)

            Y.GROSS.AMT = R.PMS.DEPO<IDIL.DEPO.CON.GROSS.AMOUNT>
            Y.ZAKAT.AMT = R.PMS.DEPO<IDIL.DEPO.CON.ZAKAT.AMOUNT>
            Y.TAX.AMT = R.PMS.DEPO<IDIL.DEPO.CON.TAX.AMOUNT>

            IF Y.L.MAT.MODE NE "PRINCIPAL + PROFIT ROLLOVER" THEN
                Y.GROSS.AMT += Y.PERIOD.MARGIN.AMT
            END

            IF Y.BREAK.AMT THEN
                Y.GROSS.AMT = Y.BREAK.AMT
                GOSUB CALC.TAX.ZAKAT.AMT
            END

            Y.MARGIN = Y.GROSS.AMT - Y.ZAKAT.AMT - Y.TAX.AMT

            IF Y.PERIOD.MARGIN.AMT.EF GT '0' THEN
*<Hamka Ardyansah - 20191031 - INC0311376
                IF Y.TAX.FLAG NE 'Y' THEN
                    Y.TAX.AMT = 0
                END ELSE
                    IF Y.TENOR NE '01M' THEN
                        Y.TAX.AMT = Y.PERIOD.MARGIN.AMT.EF * Y.TAX.RATE/100
                        Y.TAX.AMT = DROUND(Y.TAX.AMT,0)
                    END ELSE
                        Y.TAX.AMT = 0
                    END
                END
                IF Y.ZAKAT.FLAG NE 'Y' THEN
                    Y.ZAKAT.AMT = 0
                END ELSE
                    IF Y.TENOR NE '01M' THEN
                        Y.ZAKAT.AMT = (Y.PERIOD.MARGIN.AMT.EF - Y.TAX.AMT) * Y.ZAKAT.RATE/100
                        Y.ZAKAT.AMT = DROUND(Y.ZAKAT.AMT,0)
                    END ELSE
                        Y.ZAKAT.AMT = 0
                    END
                END
                Y.MARGIN=Y.PERIOD.MARGIN.AMT.EF - Y.TAX.AMT - Y.ZAKAT.AMT
*>INC0311376
                R.AZ.MARGIN<AZ.SCH.MARG.BREAK.AFT.MAT> = "0"
                CALL F.WRITE(FN.AZ.MARGIN,Y.DB.ACCT,R.AZ.MARGIN)
            END
*>
        END ELSE
*20201124
*            Y.MARGIN = Y.AMT.LCY
            Y.MARGIN = Y.AMT.LCY - Y.CHG.AMT
*20201124
        END
    END

    IF Y.FLAG.CLEARING EQ "Y" THEN
*CBA-64_20220928<
        CALL OCOMO("process tranfer to ":Y.SKN.RTGS:" data : ":Y.DB.ACCT)
        IF Y.SKN.RTGS EQ "1" THEN
            GOSUB DO.PROCESS.DEPO.SKN
        END
         IF Y.SKN.RTGS EQ "2" THEN
            GOSUB DO.PROCESS.DEPO.RTGS
        END       
*>CBA-64_20220928
    END

    RETURN

*-----------------------------------------------------------------------------
DO.PROCESS.DEPO.SKN:
*-----------------------------------------------------------------------------

    R.TEMP.STODEPO = ''
    CALL F.READ(FN.TEMP.STODEPO,Y.STMT.NO,R.TEMP.STODEPO,F.TEMP.STODEPO,R.STODEPO.ERR)

    Y.STMT.ID = Y.STMT.NO
    CALL F.READ.HISTORY(FN.TEMP.STODEPO.HIS,Y.STMT.ID,R.TEMP.STODEPO.HIS,F.TEMP.STODEPO.HIS,R.STODEPO.HIS.ERR)
	IF R.TEMP.STODEPO OR R.TEMP.STODEPO.HIS THEN
        RETURN
    END ELSE
        IF Y.MARGIN GT 0 THEN
            GOSUB PROCESS.DEPO.SKN
        END
    END

    RETURN

*-----------------------------------------------------------------------------
DO.PROCESS.DEPO.RTGS:
*-----------------------------------------------------------------------------

    R.DEPO.RTGS = ''
    CALL F.READ(FN.DEPO.RTGS,Y.STMT.NO,R.DEPO.RTGS,F.DEPO.RTGS,R.DEPO.RTGS.ERR)

    Y.STMT.ID = Y.STMT.NO
    CALL F.READ.HISTORY(FN.DEPO.RTGS.HIS,Y.STMT.ID,R.DEPO.RTGS.HIS,F.DEPO.RTGS.HIS,R.DEPO.RTGS.HIS.ERR)
	IF R.DEPO.RTGS OR R.DEPO.RTGS.HIS THEN
        RETURN
    END ELSE
        IF Y.MARGIN GT 0 THEN
            GOSUB PROCESS.DEPO.RTGS
        END
    END

    RETURN

*-----------------------------------------------------------------------------
PROCESS.DEPO.SKN:
*-----------------------------------------------------------------------------

    IF Y.ATI.JOINT.NAME NE "" THEN
        CONVERT SM TO " " IN Y.ATI.JOINT.NAME

        Y.DB.NAME = Y.ATI.JOINT.NAME[1,40]
    END ELSE
        Y.DB.NAME = Y.ACCOUNT.TITLE.1     ;*R.MM<MM.LOCAL.REF><1,Y.POS.MUD.PRINTED>
    END

    Y.DB.AMT     = Y.MARGIN
    Y.STODEPO    = Y.DB.ACCT : "-" : Y.VALUE.DATE
    Y.BEN.ACCT   = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.AZ.BEN.ACC>
    Y.BEN.NAME   = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.AZ.BEN.NAME>
    Y.BANK.CODE  = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.AZ.RECEIVE.BANK>
    Y.DESC       = "DEPO.SKN-":Y.STODEPO
    Y.RCV.STREET = R.AA.SETTLEMENT<AA.SET.LOCAL.REF,PRF.RCV.STREET>
    Y.RCV.TYPE   = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, PRF.RCV.TYPE>
    Y.RCV.ID     = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, PRF.RCV.ID>
    Y.RCV.TXN    = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, PRF.RCV.TXN>
    Y.PAY.DET    = "";*R.AA.SETTLEMENT<AA.SET.LOCAL.REF, PRF.PAY.DET>
    Y.RCV.RSD    = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, PRF.RCV.RESIDE>

    CALL F.READ(FN.CUS,Y.CUST.ID,R.CUS,F.CUS,CUS.ERR)
    Y.STREET        = R.CUS<EB.CUS.STREET>

    CONVERT VM TO SM IN Y.STREET

    Y.CUSTOMER.TYPE = R.CUS<EB.CUS.LOCAL.REF><1, PRF.CUS.CUST.TYPE>
    Y.RESIDE.Y.N    = R.CUS<EB.CUS.LOCAL.REF><1, PRF.CUS.RESIDE.Y.N>
    Y.LEGAL.ID.NO   = R.CUS<EB.CUS.LOCAL.REF><1, PRF.CUS.LEGAL.ID.NO>
    Y.TAX.ID        = R.CUS<EB.CUS.TAX.ID>

    GOSUB CHECK.RCV.FIELD
    GOSUB PROCESS.WRITE

    RETURN

*-----------------------------------------------------------------------------
PROCESS.DEPO.RTGS:
*-----------------------------------------------------------------------------
    IF Y.ATI.JOINT.NAME NE "" THEN
        CONVERT SM TO " " IN Y.ATI.JOINT.NAME

        Y.DB.NAME = Y.ATI.JOINT.NAME[1,40]
    END ELSE
        Y.DB.NAME = Y.ACCOUNT.TITLE.1     ;*R.MM<MM.LOCAL.REF><1,Y.POS.MUD.PRINTED>
    END

    Y.DB.AMT          = Y.MARGIN
    Y.DEPO.RTGS       = Y.DB.ACCT : "-" : Y.VALUE.DATE
    Y.BEN.ACCT        = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.AZ.BEN.ACC>
    Y.BEN.NAME        = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.AZ.BEN.NAME>
    Y.RTGS.CODE       = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.RTGS.CODE>
    Y.RTGS.TXN        = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.RTGS.TXN>
    Y.RTGS.BRANCH     = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.ACC.BRANCH>
    Y.RTGS.BEN.ADDR   = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.RTGS.BEN.ADDR.POS>
    Y.RTGS.BEN.NATION = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.RTGS.BEN.NATION.POS>
    Y.DESC            = "DEPO.RTGS-":Y.DEPO.RTGS	
    CALL F.READ(FN.CUS,Y.CUST.ID,R.CUS,F.CUS,CUS.ERR)
    Y.RESIDE.Y.N      = R.CUS<EB.CUS.LOCAL.REF><1,PRF.CUS.RESIDE.Y.N>
    Y.NATIONALITY     = R.CUS<EB.CUS.NATIONALITY>
    Y.STREET          = R.CUS<EB.CUS.STREET>
	
    CONVERT VM TO SM IN Y.STREET

    GOSUB CHECK.RCV.FIELD.RTGS
    GOSUB GET.MEMBER.INFO
    GOSUB PROCESS.WRITE.RTGS

    RETURN

*-----------------------------------------------------------------------------
PROCESS.WRITE:
*-----------------------------------------------------------------------------

    R.STODEPO<STODEPO.SEND.ACCT>    = Y.DB.ACCT
    R.STODEPO<STODEPO.SEND.NAME>    = Y.DB.NAME
    R.STODEPO<STODEPO.BEN.ACCT>     = Y.BEN.ACCT
    Y.SKN.BEN.NAME = Y.BEN.NAME
    CONVERT SM TO VM IN Y.SKN.BEN.NAME
    R.STODEPO<STODEPO.BEN.NAME>     = Y.SKN.BEN.NAME
    R.STODEPO<STODEPO.NOMINAL>      = Y.DB.AMT
    R.STODEPO<STODEPO.RECEIVE.BANK> = Y.BANK.CODE
    R.STODEPO<STODEPO.REMARKS>      = Y.DESC
    R.STODEPO<STODEPO.PROCESS.FLAG> = "YES"
    R.STODEPO<STODEPO.INPUTTER>     = Y.INPUTTER
    R.STODEPO<STODEPO.DATE.TIME>    = Y.DATE.TIME
    R.STODEPO<STODEPO.AUTHORISER>   = Y.AUTHORISER
    R.STODEPO<STODEPO.CO.CODE>      = Y.CO.CODE
    R.STODEPO<STODEPO.DEPT.CODE>    = Y.DEPT.CODE
    R.STODEPO<STODEPO.RESERVED.4>   = TODAY

    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.SND.STREET> = Y.STREET

    IF Y.CUSTOMER.TYPE EQ 'R' THEN
        R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.SND.TYPE> = 'Kode 1 - Perorangan'
    END ELSE
        IF Y.CUSTOMER.TYPE EQ 'C' THEN
            R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.SND.TYPE> = 'Kode 2 - Perusahaan'
        END ELSE
            IF Y.CUSTOMER.TYPE EQ 'P' THEN
                R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.SND.TYPE> = 'Kode 3 - Pemerintah'
            END
        END
    END

    IF Y.RESIDE.Y.N EQ 'Y' THEN
        R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.SND.RESIDE> = 'Kode 1 - Penduduk'
    END ELSE
        R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.SND.RESIDE> = 'Kode 2 - Bukan Penduduk'
    END

    IF Y.CUSTOMER.TYPE EQ 'R' THEN
        R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.SND.ID> = Y.LEGAL.ID.NO
    END ELSE
        IF Y.CUSTOMER.TYPE EQ 'C' THEN
            R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.SND.ID> = Y.TAX.ID
        END
    END

    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.RCV.ID>     = Y.RCV.ID
    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.RCV.TYPE>   = Y.RCV.TYPE
    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.RCV.STREET> = Y.RCV.STREET
    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.RCV.TXN>    = Y.RCV.TXN
    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.PAY.DET>    = Y.PAY.DET
    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.RCV.RESIDE> = Y.RCV.RSD

*20221003_RPU
    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.CHARGE.TYPE> = Y.CHARGE.TYPE
    R.STODEPO<STODEPO.LOCAL.REF,PRF.IDIU.CHARGE.AMT>  = Y.CHARGE.AMT
*\20221003_RPU

    CALL F.WRITE(FN.TEMP.STODEPO,Y.STMT.NO,R.STODEPO)

    RETURN

*-----------------------------------------------------------------------------
PROCESS.WRITE.RTGS:
*-----------------------------------------------------------------------------

    R.DEPO.RTGS<DEPO.SEND.ACCT>                          = Y.DB.ACCT
    R.DEPO.RTGS<DEPO.SEND.NAME>                          = Y.DB.NAME
    R.DEPO.RTGS<DEPO.BEN.ACCT>                           = Y.BEN.ACCT
    R.DEPO.RTGS<DEPO.BEN.NAME>                           = Y.BEN.NAME
    R.DEPO.RTGS<DEPO.NOMINAL>                            = Y.DB.AMT
    R.DEPO.RTGS<DEPO.RTGS.CODE>                          = Y.RTGS.CODE
    R.DEPO.RTGS<DEPO.RTGS.TXN>                           = Y.RTGS.TXN
    R.DEPO.RTGS<DEPO.RTGS.BRANCH>                        = Y.RTGS.BRANCH
    R.DEPO.RTGS<DEPO.LOCAL.REF, Y.IDIU.DEPO.BEN.ADDR>    = Y.RTGS.BEN.ADDR
    R.DEPO.RTGS<DEPO.LOCAL.REF, Y.IDIU.DEPO.BEN.NATION>  = Y.RTGS.BEN.NATION
    R.DEPO.RTGS<DEPO.LOCAL.REF, Y.IDIU.DEPO.MEMBER.INFO> = Y.MEMBER.INFO
    R.DEPO.RTGS<DEPO.REMARKS>                            = Y.DESC
    R.DEPO.RTGS<DEPO.PROCESS.FLAG>                       = "YES"
    R.DEPO.RTGS<DEPO.INPUTTER>                           = Y.INPUTTER
    R.DEPO.RTGS<DEPO.DATE.TIME>                          = Y.DATE.TIME
    R.DEPO.RTGS<DEPO.AUTHORISER>                         = Y.AUTHORISER
    R.DEPO.RTGS<DEPO.CO.CODE>                            = Y.CO.CODE
    R.DEPO.RTGS<DEPO.DEPT.CODE>                          = Y.DEPT.CODE
    R.DEPO.RTGS<DEPO.RESERVED.4>                         = TODAY

    CALL F.WRITE(FN.DEPO.RTGS, Y.STMT.NO, R.DEPO.RTGS)

    RETURN
*-----------------------------------------------------------------------------
CALC.TAX.ZAKAT.AMT:
*-----------------------------------------------------------------------------

    Y.NET.SHR.CALC = Y.GROSS.AMT

    IF Y.DEDUCT.TYPE EQ 'NET' THEN
        IF (Y.TAX.PRIO LT Y.ZAKAT.PRIO) THEN
            IF Y.TAX.FLAG NE 'Y' THEN
                Y.TAX.AMT = 0
            END ELSE
                Y.TAX.AMT = Y.NET.SHR.CALC * Y.TAX.RATE/100
                Y.TAX.AMT = DROUND(Y.TAX.AMT,0)
            END
            IF Y.ZAKAT.FLAG NE 'Y' THEN
                Y.ZAKAT.AMT = 0
            END ELSE
                Y.ZAKAT.AMT = (Y.NET.SHR.CALC - Y.TAX.AMT) * Y.ZAKAT.RATE/100
                Y.ZAKAT.AMT = DROUND(Y.ZAKAT.AMT,0)
            END
        END ELSE
            IF Y.ZAKAT.FLAG NE 'Y' THEN
                Y.ZAKAT.AMT = 0
            END ELSE
                Y.ZAKAT.AMT = Y.NET.SHR.CALC * Y.ZAKAT.RATE/100
                Y.ZAKAT.AMT = DROUND(Y.ZAKAT.AMT,0)
            END
            IF Y.TAX.FLAG NE 'Y' THEN
                Y.TAX.AMT = 0
            END ELSE
                Y.TAX.AMT = (Y.NET.SHR.CALC - Y.ZAKAT.AMT) * Y.TAX.RATE/100
                Y.TAX.AMT = DROUND(Y.TAX.AMT,0)
            END
        END
    END ELSE
        IF Y.TAX.FLAG NE 'Y' THEN
            Y.TAX.AMT = 0
        END ELSE
            Y.TAX.AMT = Y.NET.SHR.CALC * Y.TAX.RATE/100
            Y.TAX.AMT = DROUND(Y.TAX.AMT,0)
        END
        IF Y.ZAKAT.FLAG NE 'Y' THEN
            Y.ZAKAT.AMT = 0
        END ELSE
            Y.ZAKAT.AMT = Y.NET.SHR.CALC * Y.ZAKAT.RATE/100
            Y.ZAKAT.AMT = DROUND(Y.ZAKAT.AMT,0)
        END
    END

    RETURN
*-----------------------------------------------------------------------------
CHECK.RCV.FIELD:
*-----------------------------------------------------------------------------
    IF (Y.RCV.TXN EQ "") AND (Y.RCV.TYPE EQ "") AND (Y.RCV.RSD EQ "") AND (Y.RCV.ID EQ "") AND (Y.RCV.STREET EQ "") THEN
        Y.RCV.TXN    = '1-Teller'
        Y.RCV.STREET = Y.STREET

        BEGIN CASE
        CASE Y.CUSTOMER.TYPE EQ 'R'
            Y.RCV.TYPE = 'Kode 1 - Perorangan'
        CASE Y.CUSTOMER.TYPE EQ 'C'
            Y.RCV.TYPE = 'Kode 2 - Perusahaan'
        CASE Y.CUSTOMER.TYPE EQ 'P'
            Y.RCV.TYPE = 'Kode 3 - Pemerintah'
        CASE 1
            Y.RCV.TYPE = ''
        END CASE

        BEGIN CASE
        CASE Y.RESIDE.Y.N EQ 'Y'
            Y.RCV.RSD = 'Kode 1 - Penduduk'
        CASE 1
            Y.RCV.RSD = 'Kode 2 - Bukan Penduduk'
        END CASE

        BEGIN CASE
        CASE Y.CUSTOMER.TYPE EQ 'R'
            Y.RCV.ID = Y.LEGAL.ID.NO
        CASE Y.CUSTOMER.TYPE EQ 'C'
            Y.RCV.ID = Y.TAX.ID
        CASE 1
            Y.RCV.ID = ''
        END CASE
    END

    RETURN
*-----------------------------------------------------------------------------
CHECK.RCV.FIELD.RTGS:
*-----------------------------------------------------------------------------
    IF (Y.RTGS.CODE EQ "") AND (Y.RTGS.TXN EQ "") AND (Y.RTGS.BEN.ADDR EQ "") AND (Y.RTGS.BEN.NATION EQ "") THEN
        Y.RTGS.CODE = R.AA.SETTLEMENT<AA.SET.LOCAL.REF, Y.POS.RTGS.CODE.G1>
        Y.RTGS.TXN  = '100'

        IF Y.NATIONALITY EQ 'ID' THEN
            Y.RTGS.BEN.NATION = 'LOCAL'
        END ELSE
            Y.RTGS.BEN.NATION = 'FOREIGN'
        END

        Y.RTGS.BEN.ADDR = Y.STREET
    END

    RETURN
*-----------------------------------------------------------------------------
GET.MEMBER.INFO:
*-----------------------------------------------------------------------------
    Y.MEMBER.INFO = '/FEAB/'

    IF Y.RESIDE.Y.N EQ 'Y' THEN
        Y.MEMBER.INFO := 'R'
    END ELSE
        Y.MEMBER.INFO := 'NR'
    END

    Y.MEMBER.INFO := '/PTR/'

    Y.RTGS.SEN.NATION = ''
    IF Y.NATIONALITY EQ 'ID' THEN
        Y.RTGS.SEN.NATION = 'LOCAL'
    END ELSE
        Y.RTGS.SEN.NATION = 'FOREIGN'
    END

    Y.MEMBER.INFO := Y.RTGS.SEN.NATION : '-' : Y.RTGS.BEN.NATION
    Y.MEMBER.INFO := '/BEN/'

    RETURN
*-----------------------------------------------------------------------------
END


