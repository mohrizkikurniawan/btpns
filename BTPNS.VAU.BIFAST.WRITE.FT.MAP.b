    SUBROUTINE BTPNS.VAU.BIFAST.WRITE.FT.MAP
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220711
* Description        : write and update record transaction to IDIH.WS.DATA.FT.MAP and IDIH.QUEUE.CHARGES
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.IDIH.WS.DATA.FT.MAP
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    $INSERT I_F.DATES
    $INSERT I_F.IDIH.IN.FT.JOURNAL.PAR
    $INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
	$INSERT I_F.IDIH.QUEUE.CHARGES
	$INSERT I_F.FT.COMMISSION.TYPE

    GOSUB INIT
    GOSUB PROCESS
	
    RETURN
*----------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------
    FN.IDIH.WS.DATA.FT.MAP 		= 'F.IDIH.WS.DATA.FT.MAP'
    F.IDIH.WS.DATA.FT.MAP 		= ''
    CALL OPF(FN.IDIH.WS.DATA.FT.MAP, F.IDIH.WS.DATA.FT.MAP)

    FN.ACCOUNT 					= 'F.ACCOUNT'
    F.ACCOUNT 					= ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    FN.IDIH.IN.FT.JOURNAL.PAR 	= 'F.IDIH.IN.FT.JOURNAL.PAR'
    F.IDIH.IN.FT.JOURNAL.PAR 	= ''
    CALL OPF(FN.IDIH.IN.FT.JOURNAL.PAR,CF.IDIH.IN.FT.JOURNAL.PAR)

    FN.BTPNS.TH.BIFAST.OUTGOING = "F.BTPNS.TH.BIFAST.OUTGOING"
    F.BTPNS.TH.BIFAST.OUTGOING  = ""
    CALL OPF(FN.BTPNS.TH.BIFAST.OUTGOING, F.BTPNS.TH.BIFAST.OUTGOING)

    FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
    F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
    CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)
	
	FN.IDIH.QUEUE.CHARGES = "F.IDIH.QUEUE.CHARGES"
	F.IDIH.QUEUE.CHARGES  = ""
	CALL OPF(FN.IDIH.QUEUE.CHARGES,F.IDIH.QUEUE.CHARGES)
	
	FN.FT.COMMISSION.TYPE = "F.FT.COMMISSION.TYPE"
	F.FT.COMMISSION.TYPE  = ""
	CALL OPF(FN.FT.COMMISSION.TYPE, F.FT.COMMISSION.TYPE)
	
    X 				= OCONV(DATE(),"D-")
    Y.TIME.STAMP 	= FIELD(TIMEDATE(), " ", 1)
    DT 				= X[9,2]:X[1,2]:X[4,2]:Y.TIME.STAMP[1,2]:Y.TIME.STAMP[4,2]

    Y.APP     = "FUNDS.TRANSFER":FM:"IDIH.WS.DATA.FT.MAP":FM:"IDIH.IN.FT.JOURNAL.PAR"
    Y.FIELDS  = "IN.BENEF.ACCT":VM:"IN.BENEF.BANK":VM:"IN.CHANNEL.ID":VM
    Y.FIELDS := "IN.INST.ID":VM:"IN.LOCATION":VM:"IN.NETWORK.ID":VM
    Y.FIELDS := "IN.PAYEE":VM:"IN.PRM.ACC.NO":VM:"IN.REVERSAL.ID":VM
    Y.FIELDS := "IN.STAN":VM:"IN.TRNS.DT.TM":VM:"IN.UNIQUE.ID":VM
    Y.FIELDS := "IN.TERMINAL.ID"
    Y.FIELDS := FM
    Y.FIELDS := "CHG.DB.AMOUNT":VM:"CHG.CR.ACCT":VM:"ATI.WAIVE.AMT"
    Y.FIELDS := FM
    Y.FIELDS := "ACC.CR.SPLIT"
    Y.POS     = ""
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FIELDS,Y.POS)

    Y.IN.BENEF.ACCT.POS     = Y.POS<1,1>
    Y.IN.BENEF.BANK.POS     = Y.POS<1,2>
    Y.IN.CHANNEL.ID.POS     = Y.POS<1,3>
    Y.IN.INST.ID.POS        = Y.POS<1,4>
    Y.IN.LOCATION.POS       = Y.POS<1,5>
    Y.IN.NETWORK.ID.POS     = Y.POS<1,6>
    Y.IN.PAYEE.POS          = Y.POS<1,7>
    Y.IN.PRM.ACC.NO.POS     = Y.POS<1,8>
    Y.IN.REVERSAL.ID.POS    = Y.POS<1,9>
    Y.IN.STAN.POS           = Y.POS<1,10>
    Y.IN.TRNS.DT.TM.POS     = Y.POS<1,11>
    Y.IN.UNIQUE.ID.POS      = Y.POS<1,12>
    Y.IN.TERMINAL.ID.POS    = Y.POS<1,13>

    Y.CHG.DB.AMOUNT.POS     = Y.POS<2,1>
    Y.CHG.CR.ACCT.POS       = Y.POS<2,2>
	Y.WS.WAIVE.AMT.POS		= Y.POS<2,3>

    Y.ACC.CR.SPLIT.POS      = Y.POS<3,1>

    Y.IN.BENEF.ACCT    		= R.NEW(FT.LOCAL.REF)<1,Y.IN.BENEF.ACCT.POS>
    Y.IN.BENEF.BANK    		= R.NEW(FT.LOCAL.REF)<1,Y.IN.BENEF.BANK.POS>
    Y.IN.CHANNEL.ID    		= R.NEW(FT.LOCAL.REF)<1,Y.IN.CHANNEL.ID.POS>
    Y.IN.INST.ID       		= R.NEW(FT.LOCAL.REF)<1,Y.IN.INST.ID.POS>
    Y.IN.LOCATION      		= R.NEW(FT.LOCAL.REF)<1,Y.IN.LOCATION.POS>
    Y.IN.NETWORK.ID    		= R.NEW(FT.LOCAL.REF)<1,Y.IN.NETWORK.ID.POS>
    Y.IN.PAYEE         		= R.NEW(FT.LOCAL.REF)<1,Y.IN.PAYEE.POS>
    Y.IN.PRM.ACC.NO    		= R.NEW(FT.LOCAL.REF)<1,Y.IN.PRM.ACC.NO.POS>
    Y.IN.REVERSAL.ID   		= R.NEW(FT.LOCAL.REF)<1,Y.IN.REVERSAL.ID.POS>
    Y.IN.STAN          		= R.NEW(FT.LOCAL.REF)<1,Y.IN.STAN.POS>
    Y.IN.TRNS.DT.TM    		= R.NEW(FT.LOCAL.REF)<1,Y.IN.TRNS.DT.TM.POS>
    Y.IN.UNIQUE.ID     		= R.NEW(FT.LOCAL.REF)<1,Y.IN.UNIQUE.ID.POS>
    Y.IN.TERMINAL.ID   		= R.NEW(FT.LOCAL.REF)<1,Y.IN.TERMINAL.ID.POS>

    Y.TRANSACTION.TYPE  	= R.NEW(FT.TRANSACTION.TYPE)
    Y.DEBIT.ACCT.NO     	= R.NEW(FT.DEBIT.ACCT.NO)
    Y.DEBIT.AMOUNT      	= R.NEW(FT.DEBIT.AMOUNT)
    Y.DEBIT.CURRENCY    	= R.NEW(FT.DEBIT.CURRENCY)
    Y.CREDIT.ACCT.NO    	= R.NEW(FT.CREDIT.ACCT.NO)
    Y.CREDIT.AMOUNT     	= R.NEW(FT.CREDIT.AMOUNT)
    Y.CREDIT.CURRENCY   	= R.NEW(FT.CREDIT.CURRENCY)
    Y.PAYMENT.DETAILS   	= R.NEW(FT.PAYMENT.DETAILS)
    Y.COMMISSION.TYPE   	= R.NEW(FT.COMMISSION.TYPE)
    Y.CREDIT.VALUE.DATE 	= R.NEW(FT.CREDIT.VALUE.DATE)
    Y.DEBIT.VALUE.DATE  	= R.NEW(FT.DEBIT.VALUE.DATE)
    Y.DATE.TIME.FT      	= R.NEW(FT.DATE.TIME)

    CALL F.READ(FN.IDIH.IN.FT.JOURNAL.PAR,Y.IN.UNIQUE.ID,R.IDIH.IN.FT.JOURNAL.PAR,F.IDIH.IN.FT.JOURNAL.PAR,ERR.PAR)
    Y.ACC.CR.SPLIT = R.IDIH.IN.FT.JOURNAL.PAR<JOURNAL.PAR.LOCAL.REF,Y.ACC.CR.SPLIT.POS>

    GOSUB GET.GATEG.ACCT

    RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    CALL F.READ(FN.IDIH.WS.DATA.FT.MAP, Y.IN.REVERSAL.ID, R.IDIH.WS.DATA.FT.MAP, F.IDIH.WS.DATA.FT.MAP, IDIH.WS.DATA.FT.MAP.ERR)

    IF NOT(R.IDIH.WS.DATA.FT.MAP) THEN
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DEBIT.ACCT.NO>     = Y.DEBIT.ACCT.NO
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DEBIT.CURRENCY>    = Y.DEBIT.CURRENCY
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DEBIT.AMOUNT>      = Y.DEBIT.AMOUNT
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CREDIT.ACCT.NO>    = Y.CREDIT.ACCT.NO
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CREDIT.CURRENCY>   = Y.CREDIT.CURRENCY
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CREDIT.AMOUNT>     = Y.CREDIT.AMOUNT
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.PAYMENT.DETAILS>   = Y.PAYMENT.DETAILS
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.PRM.ACC.NO>     = Y.IN.PRM.ACC.NO
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.STAN>           = Y.IN.STAN
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.CHANNEL.ID>     = Y.IN.CHANNEL.ID
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.NETWORK.ID>     = Y.IN.NETWORK.ID
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.TRNS.DT.TM>     = Y.IN.TRNS.DT.TM
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.TERMINAL.ID>    = Y.IN.TERMINAL.ID
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.LOCATION>       = Y.IN.LOCATION
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.UNIQUE.ID>      = Y.IN.UNIQUE.ID
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.NO.FT>             = ID.NEW
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.REVERSAL.ID>    = Y.IN.REVERSAL.ID
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.BENEF.BANK>     = Y.IN.BENEF.BANK
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.BENEF.ACCT>     = Y.IN.BENEF.ACCT
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.PAYEE>          = Y.IN.PAYEE
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.STATUS.REC>     = "Success"

        IF OFS$OPERATION EQ "REVERSE" OR V$FUNCTION EQ "R" THEN
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.STATUS.REC> = "REVERSING"
        END

        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.INSTITUTION.ID> = Y.IN.INST.ID
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CATEG.DB>          = Y.CATEG.DB
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CATEG.CR>          = Y.CATEG.CR
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.COMMISSION.TYPE>   = Y.COMMISSION.TYPE
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.TRANSACTION.TYPE>  = Y.TRANSACTION.TYPE
        Y.CURR.NO = 1
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CURR.NO>          += Y.CURR.NO
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.INPUTTER>          = TNO:'_':OPERATOR
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DATE.TIME>         = DT
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.AUTHORISER>        = TNO:'_':OPERATOR
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CO.CODE>           = ID.COMPANY
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DEPT.CODE>         = R.USER<EB.USE.DEPARTMENT.CODE>
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.PROC.DATE>      = TODAY

        IF Y.IN.CHANNEL.ID EQ "6020" THEN
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.PAYEE>          = Y.TRANSACTION.TYPE
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.INSTITUTION.ID> = Y.COMMISSION.TYPE
        END

		GOSUB UPDATE.CHARGES

        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF, Y.WS.WAIVE.AMT.POS>	= Y.FT.WAIVE.AMT

        CALL F.WRITE(F.IDIH.WS.DATA.FT.MAP, Y.IN.REVERSAL.ID, R.IDIH.WS.DATA.FT.MAP)
    END ELSE
        Y.CURR.NO = 1
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CURR.NO>              += Y.CURR.NO
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DATE.TIME>             = DT
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DEPT.CODE>             = R.USER<EB.USE.DEPARTMENT.CODE>

        IF OFS$OPERATION EQ "REVERSE" OR V$FUNCTION EQ "R" THEN
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.IN.STATUS.REC>     = "REVERSING"
        END

        IF R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF,Y.CHG.DB.AMOUNT.POS> THEN
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DEBIT.CURRENCY>    = "IDR"
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.DEBIT.AMOUNT>      = R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF,Y.CHG.DB.AMOUNT.POS>
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CREDIT.ACCT.NO>    = R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF,Y.CHG.CR.ACCT.POS>
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CREDIT.CURRENCY>   = "IDR"
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CREDIT.AMOUNT>     = R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF,Y.CHG.DB.AMOUNT.POS>
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.TRANSACTION.TYPE>  = "ACAO"
		    R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.NO.FT>             = ""
        END
        
        IF Y.CREDIT.VALUE.DATE NE "" THEN
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CREDIT.DATE> = Y.CREDIT.VALUE.DATE
        END ELSE
            R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.CREDIT.DATE> = Y.DEBIT.VALUE.DATE
        END

        CALL F.READ(FN.IDIH.IN.FT.JOURNAL.PAR, Y.IN.UNIQUE.ID, R.IDIH.IN.FT.JOURNAL.PAR, F.IDIH.IN.FT.JOURNAL.PAR, IDIH.IN.FT.JOURNAL.PAR.ERR)
        Y.CR.COMMTYP = R.IDIH.IN.FT.JOURNAL.PAR<JOURNAL.PAR.CHRG.CODE.CR>
        Y.DB.COMMTYP = R.IDIH.IN.FT.JOURNAL.PAR<JOURNAL.PAR.CHRG.CODE.DB>

        BEGIN CASE
        CASE Y.CR.COMMTYP NE ""
            Y.COMM.TYPE = Y.CR.COMMTYP
        CASE Y.DB.COMMTYP NE ""
            Y.COMM.TYPE = Y.DB.COMMTYP
        CASE Y.CR.COMMTYP EQ "" AND Y.DB.COMMTYP EQ ""
            Y.COMM.TYPE = 0
        END CASE

        GOSUB UPDATE.CHARGES

        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.COMMISSION.TYPE>   			= Y.COMM.TYPE
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.PROCCESSING.DATE>  			= Y.DATE.TIME.FT
        R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF, Y.WS.WAIVE.AMT.POS>	= Y.FT.WAIVE.AMT

        CALL F.WRITE(F.IDIH.WS.DATA.FT.MAP, Y.IN.REVERSAL.ID, R.IDIH.WS.DATA.FT.MAP)
    END
	
    RETURN
*----------------------------------------------------------------------
GET.GATEG.ACCT:
*----------------------------------------------------------------------
    IF (LEFT(Y.DEBIT.ACCT.NO,3)) EQ "IDR" OR (LEFT(Y.DEBIT.ACCT.NO,2)) EQ "PL"  THEN
        Y.CATEG.DB = "00"
    END ELSE
        CALL F.READ(FN.ACCOUNT, Y.DEBIT.ACCT.NO, R.ACCOUNT.DB, F.ACCOUNT, ACCOUNT.DB.ERR)
        Y.CATEG.DB = R.ACCOUNT.DB<AC.CATEGORY>
    END

    IF (LEFT(Y.CREDIT.ACCT.NO,3)) EQ "IDR" OR (LEFT(Y.CREDIT.ACCT.NO,2)) EQ "PL"  THEN
        Y.CATEG.CR = "00"
    END ELSE
        CALL F.READ(FN.ACCOUNT, Y.CREDIT.ACCT.NO, R.ACCOUNT.CR, F.ACCOUNT, ACCOUNT.CR.ERR)
        Y.CATEG.CR = R.ACCOUNT.CR<AC.CATEGORY>
    END

    RETURN
	
*------------------------------------------------------------------------------------
UPDATE.CHARGES:
*------------------------------------------------------------------------------------
	IF Y.ACC.CR.SPLIT NE '' THEN
        Y.ID.REQ = Y.IN.REVERSAL.ID:"01"
        CALL F.READ(F.IDIH.QUEUE.CHARGES,Y.ID.REQ,R.IDIH.QUEUE.CHARGES,F.IDIH.QUEUE.CHARGES,ERR.QUEUE)
		
		Y.TOTAL.CHARGE.AMT = R.NEW(FT.TOTAL.CHARGE.AMT)
		Y.TOTAL.CHARGE.AMT = Y.TOTAL.CHARGE.AMT[4,LEN(Y.TOTAL.CHARGE.AMT)]
        R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.AT.CHG.CODE> = Y.IN.UNIQUE.ID
        R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.VALUE.DATE>  = TODAY
		R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.AMOUNT>      = R.NEW(FT.LOCAL.CHARGE.AMT)
        R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.DATE.TIME>   = DT
        R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.CO.CODE>     = R.NEW(FT.CO.CODE)
		
		GOSUB GET.WAIVE.FEE
        
        CALL F.WRITE(FN.IDIH.QUEUE.CHARGES,Y.ID.REQ,R.IDIH.QUEUE.CHARGES)    
    END
*------------------------------------------------------------------------------------
GET.WAIVE.FEE:
*------------------------------------------------------------------------------------

	IF R.NEW(FT.COMMISSION.CODE) EQ "WAIVE" THEN
		CALL F.READ(FN.BTPNS.TL.BFAST.INTERFACE.PARAM,"SYSTEM",R.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM,READ.PAR.ERR)
		Y.BIFAST.PL.WAIVE.FEE = R.BFAST.INTERFACE.PARAM<BF.INT.PAR.PL.WAIVE.FEE>
		Y.COMM.CODE           = R.BFAST.INTERFACE.PARAM<BF.INT.PAR.COMM.DESC>
	
		FIND "FEE AJ" IN Y.COMM.CODE SETTING POSF,POSV THEN
			Y.COMM.TYPE.FEEAJ = R.BFAST.INTERFACE.PARAM<BF.INT.PAR.COMM.TYPE><1,POSV>
			CALL F.READ(FN.FT.COMMISSION.TYPE,Y.COMM.TYPE.FEEAJ,R.FTCOMM.FEEAJ,F.FT.COMMISSION.TYPE,ERR2)
			IF R.FTCOMM.FEEAJ THEN
				Y.FEEAJ.AC  = R.FTCOMM.FEEAJ<FT4.CATEGORY.ACCOUNT>
				Y.FEEAJ.AMT = R.FTCOMM.FEEAJ<FT4.FLAT.AMT>
			END
		END
		FIND "FEE BI" IN Y.COMM.CODE SETTING POSF,POSV THEN
			Y.COMM.TYPE.FEEBI = R.BFAST.INTERFACE.PARAM<BF.INT.PAR.COMM.TYPE><1,POSV>
			CALL F.READ(FN.FT.COMMISSION.TYPE,Y.COMM.TYPE.FEEBI,R.FTCOMM.FEEBI,F.FT.COMMISSION.TYPE,ERR2)
			IF R.FTCOMM.FEEBI THEN
				Y.FEEBI.AC  = R.FTCOMM.FEEBI<FT4.CATEGORY.ACCOUNT>
				Y.FEEBI.AMT = R.FTCOMM.FEEBI<FT4.FLAT.AMT>
			END
		END
		Y.FT.WAIVE.AMT = Y.FEEAJ.AMT + Y.FEEBI.AMT
		R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.AMOUNT>  = Y.FT.WAIVE.AMT
	END

	RETURN
*------------------------------------------------------------------------------------
END


