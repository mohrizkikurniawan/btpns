	SUBROUTINE BTPNS.VVR.BIFAST.AMOUNT.DB
*-----------------------------------------------------------------------------
* Developer Name     : Budi Saptono
* Development Date   : 20220701
* Description        : Routine to Validate Amount BIFAST
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
	$INSERT I_F.CURRENCY
	$INSERT I_F.COMPANY
	$INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
	$INSERT I_F.FT.COMMISSION.TYPE
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    CALL OPF(FN.COMPANY,F.COMPANY)
	
	FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
    F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
    CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)
	
	FN.FT.COMMISSION.TYPE = "F.FT.COMMISSION.TYPE"
    F.FT.COMMISSION.TYPE  = ""
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)
	
	FN.ACC = "F.ACCOUNT"
    CALL OPF(FN.ACC, F.ACC)
	
    RETURN

*------------
PROCESS:
*------------
	Y.DB.ACCT      = R.NEW(FT.DEBIT.ACCT.NO)
	Y.DATE.TIME    = R.NEW(FT.DATE.TIME)
	Y.COMM.CODE    = R.NEW(FT.COMMISSION.CODE)
	Y.COMM.ID      = R.NEW(FT.COMMISSION.TYPE)
	Y.CO.CODE      = ID.COMPANY
	
	Y.DEBIT.AMOUNT = COMI
	
	IF Y.DEBIT.AMOUNT LE 0 THEN
	   ETEXT = "Amount Tidak Boleh kurang atau sama dengan 0"
       CALL STORE.END.ERROR	   
	END
	CALL F.READ(FN.ACC,Y.DB.ACCT,R.ACC,F.ACC,ERR.ACC)
	Y.CATEGORY =  R.ACC<AC.CATEGORY>
	
	CALL F.READ(FN.FT.COMMISSION.TYPE,Y.COMM.ID,R.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE,ERR.FT.COMMISSION.TYPE)
	Y.FLAT.AMT		 = R.FT.COMMISSION.TYPE<FT4.FLAT.AMT>
	IF Y.COMM.CODE = 'WAIVE' THEN
	   Y.FLAT.AMT = 0
	END
	CALL F.READ(FN.BTPNS.TL.BFAST.INTERFACE.PARAM,"SYSTEM",R.BIFAST.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,READ.PAR.ERR)
    Y.AVAIL.AMT = 0
    IF Y.DEBIT.AMOUNT THEN
        Y.PAR.MINIMUM = R.BIFAST.PARAM<BF.INT.PAR.MIN.TXN.AMT>
        Y.PAR.MAXIMUM = R.BIFAST.PARAM<BF.INT.PAR.MAX.TXN.AMT>

        IF Y.DEBIT.AMOUNT LT Y.PAR.MINIMUM THEN
			AF = FT.DEBIT.AMOUNT
	    	ETEXT = "FT-BIFAST.MIN.AMOUNT"
	    	CALL STORE.END.ERROR
	    END

        IF Y.DEBIT.AMOUNT GT Y.PAR.MAXIMUM THEN
			AF = FT.DEBIT.AMOUNT
	    	ETEXT = "FT-BIFAST.MAX.AMOUNT"
	    	CALL STORE.END.ERROR
	    END

* Using core overdraft validation 
*        Y.FMT.AMOUNT     = LEN(R.NEW(FT.AMOUNT.DEBITED))
*		Y.AMOUNT.DEBITED = R.NEW(FT.AMOUNT.DEBITED)[4,Y.FMT.AMOUNT]
        IF Y.DB.ACCT[1,3] NE 'IDR' OR ( Y.CATEGORY LE '5001' AND Y.CATEGORY GT '5010' ) THEN
           CALL ID.AC.CHK.AVAIL.AMT(Y.DB.ACCT, Y.DEBIT.AMOUNT, Y.AVAIL.AMT, Y.MIN.BAL, Y.CATEGORY, Y.AMOUNT.TOT.LOCK)
           Y.AVAIL.AMT = Y.AVAIL.AMT - Y.FLAT.AMT
	       IF (Y.AVAIL.AMT LT 0) THEN
	    	   ETEXT = "AC-IDI.AMT.OVERDRAFT" : FM : Y.DB.ACCT
	    	   CALL STORE.END.ERROR
		   END
	    END
    END
    RETURN
END
