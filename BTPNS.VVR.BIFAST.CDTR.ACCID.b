	SUBROUTINE BTPNS.VVR.BIFAST.CDTR.ACCID
*-----------------------------------------------------------------------------
* Developer Name     : Budi Saptono
* Development Date   : 20220701
* Description        : Routine to Validate Cr acct no BIFAST
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date               : 20221111
* Modified by        : Saidah Manshuroh
* Description        : Delete "IDR" in fromAccount JSON Message
* No Log             :
*-----------------------------------------------------------------------------
* Date               : 20221220
* Modified by        : Ratih Purwaning Utami
* Description        : Upcase validation name
* No Log             :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
	$INSERT I_F.CURRENCY
	$INSERT I_F.COMPANY
	$INSERT I_F.IDCH.DISTRICT
	$INSERT I_F.IDCH.RTGS.BANK.CODE.G2
    $INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
    $INSERT I_F.FT.COMMISSION.TYPE
	$INSERT I_GTS.COMMON
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
	
	FN.BANK = 'F.IDCH.RTGS.BANK.CODE.G2'
    F.BANK = ''
    CALL OPF(FN.BANK,F.BANK)
	
	FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
    F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
    CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)
	
	FN.FT.COMMISSION.TYPE = "F.FT.COMMISSION.TYPE"
    F.FT.COMMISSION.TYPE  = ""
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)
	
	FN.ACC = "F.ACCOUNT"
    CALL OPF(FN.ACC, F.ACC)

    FN.DIS = "F.IDCH.DISTRICT"
    F.DIS = ""
    CALL OPF(FN.DIS,F.DIS)

    Y.AMT.WORDS = '' ; Y.ERR.MSG = '' ; Y.OUT = ''
    Y.LANGUAGE = 'ID' ; Y.CUR = "IDR" ; Y.TRANS.CODE = ""
    
    Y.DATE = TODAY

    Y.APP       = "FUNDS.TRANSFER" :FM: "IDCH.RTGS.BANK.CODE.G2"
    Y.FLD.NAME  = "B.CDTR.NM":VM: "B.DBTR.NM" :VM: "B.CDTR.PRXYID" :VM: "B.CDTR.AGTID" :VM: "B.CDTR.ACCID" :VM: "B.CDTR.ACCTYPE" :VM: "B.CHNTYPE"
    Y.FLD.NAME  := VM: "B.DBTR.ACCTYPE" :VM: "B.SEQ.NO" :VM: "IN.STAN" :VM: "TELLER.ID" :VM: "B.CDTR.PRXYTYPE" :VM: "B.CDTR.TYPE" :VM: "B.DBTR.RESSTS" :VM: "B.CDTR.RESSTS"
    Y.FLD.NAME  := VM: "B.DBTR.ID" :VM: "ATI.JNAME.1" :VM: "IN.REVERSAL.ID" :VM: "ATI.JNAME.2" :VM: "ATI.JNAME.3" :VM: "IN.BENEF.BANK"
	Y.FLD.NAME := FM: "SKN.CLR.CODE":VM:"B.BANK.TYPE"
	
    Y.POS       = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)

    Y.CDTR.NM.POS             = Y.POS<1,1>
    Y.DBTR.NM.POS             = Y.POS<1,2>
    Y.PRXY.ID.POS             = Y.POS<1,3>
    Y.CDTR.AGTID.POS          = Y.POS<1,4>
    Y.CDTR.ACCID.POS          = Y.POS<1,5>
	Y.CDTR.ACCTYPE.POS        = Y.POS<1,6>
	Y.CHNTYPE.POS             = Y.POS<1,7>
	Y.DBTR.ACCTYPE.POS        = Y.POS<1,8>
	Y.B.SEQNO.POS             = Y.POS<1,9>
	Y.INSTAN.POS              = Y.POS<1,10>
	Y.TELLER.ID.POS           = Y.POS<1,11>
	Y.CDTR.PRXYTYPE.POS       = Y.POS<1,12>
	Y.CDTR.TYPE.POS           = Y.POS<1,13>
	Y.DBTR.RESSTS.POS         = Y.POS<1,14>
	Y.CDTR.RESSTS.POS         = Y.POS<1,15>
	Y.DBTR.ID.POS             = Y.POS<1,16>
	Y.ATI.JNAME.1.POS         = Y.POS<1,17>
	Y.IN.REVERSAL.ID.POS      = Y.POS<1,18>
	Y.ATI.JNAME.2.POS         = Y.POS<1,19>
	Y.ATI.JNAME.3.POS         = Y.POS<1,20>
	Y.IN.BENEF.BANK.POS       = Y.POS<1,21>
	Y.SKN.CLR.CODE.POS        = Y.POS<2,1>
	Y.SKN.BNK.TYPE.POS        = Y.POS<2,2>
	
	
    RETURN	

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
	Y.CURRENT.TIME = TIMESTAMP()
	Y.YY = X[9,2]
	Y.MM = X[1,2]
	Y.DD = X[4,2]
	Y.TH = Y.TIME[1,2]
	Y.TM = Y.TIME[4,2]
	Y.TS = Y.TIME[7,2]
	
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]

	Y.FT.ID        = ID.NEW
    Y.CDTR.AGTID    = R.NEW(FT.LOCAL.REF)<1,Y.CDTR.AGTID.POS>
	Y.CDTR.PRXYTYPE = R.NEW(FT.LOCAL.REF)<1,Y.CDTR.PRXYTYPE.POS>
	IF Y.CDTR.AGTID = 'PUBAIDJ1' THEN
	   ETEXT = "EB-ACDB.SAME.INS"
	   CALL STORE.END.ERROR
	END
	
	IF Y.CDTR.PRXYTYPE NE '0' THEN
	   RETURN
	END
	
*	Y.CDTR.ACCID   = R.NEW(FT.LOCAL.REF)<1,Y.CDTR.ACCID.POS>
    Y.CDTR.ACCID   = COMI
	Y.ATI.JNAME.2  = R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.2.POS>
	
	Y.COMM.CODE    = R.NEW(FT.COMMISSION.CODE)
	Y.COMM.ID      = R.NEW(FT.COMMISSION.TYPE)

	
	CALL F.READ(FN.FT.COMMISSION.TYPE,Y.COMM.ID,R.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE,ERR.FT.COMMISSION.TYPE)
	Y.FLAT.AMT		 = R.FT.COMMISSION.TYPE<FT4.FLAT.AMT>
	IF Y.COMM.CODE = 'WAIVE' THEN
	   Y.FLAT.AMT = 0
	END
	
	CALL F.READ(FN.BANK,Y.CDTR.AGTID,R.RTGS.BANK.CODE,F.BANK,RTGSBCG2.ERR)
    Y.SKN.CLR.CODE = R.RTGS.BANK.CODE<RTGS.BANK.CODE.LOCAL.REF, Y.SKN.CLR.CODE.POS>
	Y.ID.BNK  = Y.SKN.CLR.CODE[1,3]
	Y.BNK.TYPE = R.RTGS.BANK.CODE<RTGS.BANK.CODE.LOCAL.REF, Y.SKN.BNK.TYPE.POS>
	R.NEW(FT.LOCAL.REF)<1,Y.IN.BENEF.BANK.POS> = Y.ID.BNK
	
	Y.CDTR.ACCTYPE = R.NEW(FT.LOCAL.REF)<1,Y.CDTR.ACCTYPE.POS>
	Y.DBTR.ACCTYPE = R.NEW(FT.LOCAL.REF)<1,Y.DBTR.ACCTYPE.POS>
	Y.CHNTYPE      = R.NEW(FT.LOCAL.REF)<1,Y.CHNTYPE.POS>
	Y.CDTR.NM      = R.NEW(FT.LOCAL.REF)<1,Y.CDTR.NM.POS>
	Y.DBTR.NM      = R.NEW(FT.LOCAL.REF)<1,Y.DBTR.NM.POS>
	Y.B.SEQNO      = R.NEW(FT.LOCAL.REF)<1,Y.B.SEQNO.POS>
	Y.INSTAN       = R.NEW(FT.LOCAL.REF)<1,Y.INSTAN.POS>
	Y.TELLER.ID    = R.NEW(FT.LOCAL.REF)<1,Y.TELLER.ID.POS>
	Y.CDTR.TYPE      = R.NEW(FT.LOCAL.REF)<1,Y.CDTR.TYPE.POS>
	Y.DBTR.RESSTS    = R.NEW(FT.LOCAL.REF)<1,Y.DBTR.RESSTS.POS>     
	Y.CDTR.RESSTS    = R.NEW(FT.LOCAL.REF)<1,Y.CDTR.RESSTS.POS>
	Y.DBTR.ID        = R.NEW(FT.LOCAL.REF)<1,Y.DBTR.ID.POS>
	Y.ATI.JNAME.1    = R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.1.POS>
	Y.IN.REVERSAL.ID = R.NEW(FT.LOCAL.REF)<1,Y.IN.REVERSAL.ID.POS>
*	Y.IN.REVERSAL.ID = Y.IN.REVERSAL.ID[12]
	
	Y.ATI.JNAME.3    = R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.3.POS>
	Y.DB.ACCT      = R.NEW(FT.DEBIT.ACCT.NO)
	Y.AMOUNT       = R.NEW(FT.DEBIT.AMOUNT)
	Y.DATE.TIME    = R.NEW(FT.DATE.TIME)
	Y.CO.CODE      = ID.COMPANY
	Y.AMOUNT       = FMT(Y.AMOUNT,"R2")
    Y.DEBIT.AMOUNT = R.NEW(FT.DEBIT.AMOUNT)
	
	CALL F.READ(FN.ACC,Y.DB.ACCT,R.ACC,F.ACC,ERR.ACC)
	Y.CATEGORY =  R.ACC<AC.CATEGORY>
	
	CALL F.READ(FN.BTPNS.TL.BFAST.INTERFACE.PARAM,"SYSTEM",R.BIFAST.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,READ.PAR.ERR)
    Y.AVAIL.AMT = 0
    IF Y.DEBIT.AMOUNT THEN
        Y.PAR.MINIMUM = R.BIFAST.PARAM<BF.INT.PAR.MIN.TXN.AMT>
        Y.PAR.MAXIMUM = R.BIFAST.PARAM<BF.INT.PAR.MAX.TXN.AMT>

        IF Y.DEBIT.AMOUNT LT Y.PAR.MINIMUM THEN
           RETURN
	    END

        IF Y.DEBIT.AMOUNT GT Y.PAR.MAXIMUM THEN
           RETURN
	    END
        IF Y.DB.ACCT[1,3] NE 'IDR' OR ( Y.CATEGORY LE '5001' AND Y.CATEGORY GT '5010' ) THEN
           CALL ID.AC.CHK.AVAIL.AMT(Y.DB.ACCT, Y.DEBIT.AMOUNT, Y.AVAIL.AMT, Y.MIN.BAL, Y.CATEGORY, Y.AMOUNT.TOT.LOCK)
           Y.AVAIL.AMT = Y.AVAIL.AMT - Y.FLAT.AMT
	       IF (Y.AVAIL.AMT LE 0) THEN
	    	  RETURN
	       END
		END
    END
	

*---RRN
    Y.MILLISECONDS = FIELD(Y.CURRENT.TIME,".",2)[1,2]
	Y.RRN = Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]:Y.MILLISECONDS
    
    R.NEW(FT.LOCAL.REF)<1,Y.B.SEQNO.POS> = Y.RRN
*---
	CALL F.READ(FN.COMPANY, Y.CO.CODE, R.COMP, F.COMPANY, COMPANY.ERR)
	Y.NAME.CO = R.COMP<EB.COM.COMPANY.NAME>
	CALL GET.LOC.REF('COMPANY','DISTRICT.CODE',DISTRICT.CODE.POS)
    Y.DISTRICT.CODE = R.COMP<EB.COM.LOCAL.REF,DISTRICT.CODE.POS>
    CALL F.READ(FN.DIS, Y.DISTRICT.CODE, R.DIS, F.DIS, DIS.ERR)
	Y.DISTRICT.NAME = R.DIS<IDCH.DISTRICT.DESCRIPTION><1,1>
	Y.DISTRICT.NAME = EREPLACE(Y.DISTRICT.NAME,".", " ")
	Y.DISTRICT.NAME = UPCASE(Y.DISTRICT.NAME)
    IF LEN(Y.DISTRICT.NAME) > 32 THEN
	   Y.DISTRICT.NAME = Y.DISTRICT.NAME[1.32]
	END
	
	Y.CCY.ID       = '360'
	Y.MSG.TYPE     = '0200' ; * Inquiry Transfer Req msg
	Y.TRX.ID       = '39'   ; * Inquiry
	Y.TRX.CODE     = Y.TRX.ID:Y.DBTR.ACCTYPE:Y.CDTR.ACCTYPE
	IF Y.DB.ACCT[1,3] = 'IDR' THEN
	   Y.TRX.PAN    = Y.CCY.ID:'92547':Y.DB.ACCT[4,11]
	END ELSE
	   Y.TRX.PAN    = Y.CCY.ID:'92547':'0':Y.DB.ACCT
	END
    Y.TRANSMIT.DT  = Y.MM:Y.DD:Y.TH:Y.TM:Y.TS
	Y.TRX.TIME     = Y.TH:Y.TM:Y.TS
	Y.TRX.DATE     = Y.MM:Y.DD
	Y.SETTLE.DATE  = Y.MM:Y.DD
	Y.MERCHANT.TYPE = Y.CHNTYPE
	Y.POS.ENTRY    = '011'
	Y.POS.COND     = '55'
	Y.ACQUIRER.ID  = '92547'
	Y.FORWARD.ID   = '360000'
	Y.RETRIEVE.REF = '0000':Y.RRN
*    Y.RETRIEVE.REF = Y.IN.REVERSAL.ID
	Y.TERMINAL.ID  = '00006010'
	Y.MERCHANT.ID  = FMT(Y.CO.CODE,"L#15")
*	Y.MERCHANT.LOC = FMT(Y.NAME.CO,"L#40")
    Y.MERCHANT.LOC = FMT(Y.DISTRICT.NAME,"L#33"):Y.DISTRICT.CODE:"IDN"
	
*	Y.ADD.DATA.PRIVATE = FMT(Y.CDTR.NM,L#30):FMT(Y.IN.REVERSAL.ID,L#16):FMT(Y.ATI.JNAME.1,L#30)
*   Y.ADD.DATA.PRIVATE = FMT("","L#30"):FMT(Y.RETRIEVE.REF,"L#16"):FMT(Y.DBTR.NM,"L#30")
	Y.ADD.DATA.PRIVATE = FMT("","L#30"):FMT(Y.RETRIEVE.REF,"L#16"):FMT("","L#30")
	
	Y.ISSUER.ID		= Y.ACQUIRER.ID
	Y.FROM.ACC		= Y.DB.ACCT
	Y.FROM.ACC.IA	= Y.FROM.ACC
	CHANGE "IDR" TO "" IN Y.FROM.ACC.IA
	Y.TO.ACC		= Y.CDTR.ACCID
	Y.TXN.INDICATOR	= '2'
	Y.BENEF.ID		= '9':Y.BNK.TYPE:Y.ID.BNK
	Y.RESP.MSG		= ''
    * -- Field additionalDataNational	
	Y.DBTR.RESSTS	= Y.DBTR.RESSTS[2,1]
	Y.CDTR.RESSTS	= Y.CDTR.RESSTS[2,1]
	Y.TM			= 'TM10':Y.CDTR.PRXYTYPE:Y.CDTR.TYPE:'0':Y.DBTR.RESSTS:Y.CDTR.RESSTS
	Y.TM			= FMT(Y.TM,"L#14")
	Y.TC			= FMT('TC0400',"L#8")
	Y.PI			= 'PI05B0510'
	* Jika pakai KTP digit nya 16
	Y.DI			= 'DI16':FMT(Y.DBTR.ID,"L#16")
	Y.CI			= FMT('CI16',"L#20")
	Y.RN			= 'RN12':FMT(Y.IN.REVERSAL.ID,"L#12")
	Y.ADD.DATA.NAS	= Y.TM:Y.TC:Y.PI:Y.DI:Y.CI:Y.RN
	
    GOSUB CONSTRUCT.REQUEST
	RESP.ERR = ''
	Y.RESPONSE.CODE.RES = ''
	Y.RESPONSE.CODE.DESC = ''
	
*	IF MESSAGE EQ 'VAL' THEN
	IF (MESSAGE EQ "VAL" AND OFS$OPERATION EQ "VALIDATE") OR OFS$OPERATION EQ "PROCESS" THEN
	   CALL BTPNSR.BIFAST.INTERFACE(Y.TYPE,Y.PARAM,RESP.POS,RESP.ERR)
	   GOSUB CHECK.RESPONSE
	END
	
    RETURN

*-----------------
CONSTRUCT.REQUEST:
*-----------------
    Y.PARAM = ''
    XX = ':'
    ZZ = ','
    Y.TYPE = 'BInqTrfRQ'
	Y.OPEN   = '{'
    Y.CLOSE = '}'
*   Y.PARAM = Y.HEADER
	Y.PARAM = Y.OPEN
	Y.PARAM :='"msgType"':XX:DQUOTE(Y.MSG.TYPE)
    Y.PARAM :=',"trxPAN"':XX:DQUOTE(Y.TRX.PAN)
    Y.PARAM :=',"trxCode"':XX:DQUOTE(Y.TRX.CODE)         
    Y.PARAM :=',"trxAmount"':XX:DQUOTE(Y.AMOUNT)
    Y.PARAM :=',"transmissionDateTime"':XX:DQUOTE(Y.TRANSMIT.DT)
    Y.PARAM :=',"msgSTAN"':XX:DQUOTE(Y.INSTAN)
	Y.PARAM :=',"trxTime"':XX:DQUOTE(Y.TRX.TIME)
	Y.PARAM :=',"trxDate"':XX:DQUOTE(Y.TRX.DATE)
	Y.PARAM :=',"settlementDate"':XX:DQUOTE(Y.SETTLE.DATE)
	Y.PARAM :=',"merchantType"':XX:DQUOTE(Y.MERCHANT.TYPE)
	Y.PARAM :=',"posEntryMode"':XX:DQUOTE(Y.POS.ENTRY)
	Y.PARAM :=',"posConditionMode"':XX:DQUOTE(Y.POS.COND)
	Y.PARAM :=',"acquirerID"':XX:DQUOTE(Y.ACQUIRER.ID)
	Y.PARAM :=',"forwardingID"':XX:DQUOTE(Y.FORWARD.ID)
	Y.PARAM :=',"retrievalReferenceNumber"':XX:DQUOTE(Y.RETRIEVE.REF)
	Y.PARAM :=',"terminalID"':XX:DQUOTE(Y.TERMINAL.ID)
	Y.PARAM :=',"merchantID"':XX:DQUOTE(Y.MERCHANT.ID)
	Y.PARAM :=',"merchantNameLocation"':XX:DQUOTE(Y.MERCHANT.LOC)
	Y.PARAM :=',"additionalDataPrivate"':XX:DQUOTE(Y.ADD.DATA.PRIVATE)
	Y.PARAM :=',"trxCurrencyCode"':XX:DQUOTE(Y.CCY.ID)
	Y.PARAM :=',"encryptedData"':XX:DQUOTE('')
	Y.PARAM :=',"additionalDataNational"':XX:DQUOTE(Y.ADD.DATA.NAS)
	Y.PARAM :=',"issuerID"':XX:DQUOTE(Y.ISSUER.ID)
*	Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.FROM.ACC)
	Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.FROM.ACC.IA)
	Y.PARAM :=',"toAccount"':XX:DQUOTE(Y.TO.ACC)
	Y.PARAM :=',"transactionIndicator"':XX:DQUOTE(Y.TXN.INDICATOR)
	Y.PARAM :=',"beneficiaryID"':XX:DQUOTE(Y.BENEF.ID)
	Y.PARAM := Y.CLOSE
	
	CRT '[BFAST-REQ] - ':Y.TRX.PAN

	RETURN
	
* ------------
CHECK.RESPONSE:
* ------------

   FINDSTR '"responseCode"' IN RESP.POS SETTING POS THEN
     Y.RESPONSE.TEMP = EREPLACE(EREPLACE(RESP.POS,'":"','|'),'","','|')
     Y.RESPONSE = CHANGE(CHANGE(Y.RESPONSE.TEMP,'"',''),'}','')
   END
   Y.RESPONSE.CODE.RES    = FIELDS(FIELDS(Y.RESPONSE,'responseCode',2),'|',2)
   Y.ADD.DATA.PRIVATE.RES = FIELDS(FIELDS(Y.RESPONSE,'additionalDataPrivate',2),'|',2)
   IF Y.RESPONSE.CODE.RES EQ '00' THEN
      Y.CDTR.NAME.RES = TRIM(Y.ADD.DATA.PRIVATE.RES[1,30],' ','D')
      Y.CUST.REFF.RES = TRIM(Y.ADD.DATA.PRIVATE.RES[31,16],' ','D')
	  Y.DBTR.NAME.RES = TRIM(Y.ADD.DATA.PRIVATE.RES[47,30],' ','D')
	  R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.2.POS> = Y.CDTR.NAME.RES
	  R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.3.POS> = Y.ADD.DATA.PRIVATE.RES

*20221220_RPU
		Y.CDTR.NAME.RES.UP = UPCASE(Y.CDTR.NAME.RES)
		Y.CDTR.NM.UP       = UPCASE(Y.CDTR.NM)
	  
*	  IF Y.CDTR.NAME.RES NE Y.CDTR.NM THEN
		IF Y.CDTR.NAME.RES.UP NE Y.CDTR.NM.UP THEN
*\20221220_RPU
		 TEXT  = "FT-BIFAST.CDTR.NM.DIFFERENCE"
		 NO.OF.OVERR = DCOUNT(R.NEW(V-9),VM)+1
		 CALL STORE.OVERRIDE(NO.OF.OVERR)
	  END
	
   END ELSE
      IF Y.RESPONSE.CODE.RES EQ '' THEN
	     IF RESP.ERR NE '' THEN
*		    R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.2.POS> = RESP.ERR
			ETEXT = RESP.ERR
		    CALL STORE.END.ERROR
		 END ELSE
*	        R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.2.POS> = "Response Code : null"
			ETEXT = "Response Code : null"
		    CALL STORE.END.ERROR
	     END
      END ELSE
*	     R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.2.POS> = "Response Code : ":Y.RESPONSE.CODE.RES		 
		 GOSUB RCCODE.FORMAT 
         ETEXT = "Response Code : ":Y.RESPONSE.CODE.RES:" - ":Y.RESPONSE.CODE.DESC
		 CALL STORE.END.ERROR
	  END
   END

   RETURN

*-------------
RCCODE.FORMAT:
*--------------

    ERR = Y.RESPONSE.CODE.RES

    BEGIN CASE
    CASE ERR = '01'
        Y.RESPONSE.CODE.DESC = "Refer to Card Issuer"
    CASE ERR = '02'
        Y.RESPONSE.CODE.DESC = "Refer to Card Issuer"
    CASE ERR = '03'
        Y.RESPONSE.CODE.DESC = "Invalid Merchant"
    CASE ERR = '04'
        Y.RESPONSE.CODE.DESC = "Pickup / Capture Card"
    CASE ERR = '05'
        Y.RESPONSE.CODE.DESC = "Do not honor"	
    CASE ERR = '12'
        Y.RESPONSE.CODE.DESC = "Invalid Transaction"	
    CASE ERR = '13'
        Y.RESPONSE.CODE.DESC = "Invalid Amount"	
    CASE ERR = '14'
        Y.RESPONSE.CODE.DESC = "Invalid Card Number"
    CASE ERR = '15'
        Y.RESPONSE.CODE.DESC = "No such Issuer"	
    CASE ERR = '20'
        Y.RESPONSE.CODE.DESC = "Invalid Response"	
    CASE ERR = '30'
        Y.RESPONSE.CODE.DESC = "Format Error"	
    CASE ERR = '31'
        Y.RESPONSE.CODE.DESC = "Bank Not Support By Switch"
    CASE ERR = '33'
        Y.RESPONSE.CODE.DESC = "Expired Card"
    CASE ERR = '36'
        Y.RESPONSE.CODE.DESC = "Restrict Card"	
    CASE ERR = '39'
        Y.RESPONSE.CODE.DESC = "No Credit Account"    
	CASE ERR = '40'
        Y.RESPONSE.CODE.DESC = "Request Function Not Supported"    
	CASE ERR = '51'
        Y.RESPONSE.CODE.DESC = "Insufficient Fund"	
    CASE ERR = '52'
        Y.RESPONSE.CODE.DESC = "No Checking Account"	
    CASE ERR = '53'
        Y.RESPONSE.CODE.DESC = "No Saving Account"	
    CASE ERR = '57'
        Y.RESPONSE.CODE.DESC = "Transaction not permitted"	
    CASE ERR = '58'
        Y.RESPONSE.CODE.DESC = "Transaction not permitted"	
    CASE ERR = '61'
        Y.RESPONSE.CODE.DESC = "Exceed Withdrawal amount limit"	
    CASE ERR = '63'
        Y.RESPONSE.CODE.DESC = "Security Violation"
    CASE ERR = '68'
        Y.RESPONSE.CODE.DESC = "Response received too late"	
    CASE ERR = '76'
        Y.RESPONSE.CODE.DESC = "Invalid to Account"	
    CASE ERR = '77'
        Y.RESPONSE.CODE.DESC = "Invalid from Account"	
    CASE ERR = '78'
        Y.RESPONSE.CODE.DESC = "Account is closed"	
    CASE ERR = '89'
        Y.RESPONSE.CODE.DESC = "Link to host down"	
    CASE ERR = '91'
        Y.RESPONSE.CODE.DESC = "Issuer or swith is inoperative Unable to route txn"	
    CASE ERR = '92'
        Y.RESPONSE.CODE.DESC = "Unable to route transaction"	
    CASE ERR = '94'
        Y.RESPONSE.CODE.DESC = "Duplicate transmission or request or reversal message"	
    CASE ERR = '96'
        Y.RESPONSE.CODE.DESC = "System malfunction or System error"   
    END CASE

    RETURN

*-----------------------------------------------------------------------------
END
