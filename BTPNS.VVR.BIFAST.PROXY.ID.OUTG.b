	SUBROUTINE BTPNS.VVR.BIFAST.PROXY.ID.OUTG
*-----------------------------------------------------------------------------
* Developer Name     : Budi Saptono
* Development Date   : 20220919
* Description        : Routine to Validate Proxy ID Outgoing
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
	$INSERT I_F.IDCH.SKN.PROVINCE 
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
	
	FN.BANK = 'F.IDCH.RTGS.BANK.CODE.G2'
    F.BANK = ''
    CALL OPF(FN.BANK,F.BANK)
	
	FN.DISTRICT = 'F.IDCH.DISTRICT'
    F.DISTRICT = ''
    CALL OPF(FN.DISTRICT,F.DISTRICT)
	
    FN.PROVINCE = 'F.IDCH.SKN.PROVINCE'
    F.PROVINCE = ''
    CALL OPF(FN.PROVINCE,F.PROVINCE)
	
	FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
    F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
    CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)
	
	FN.FT.COMMISSION.TYPE = "F.FT.COMMISSION.TYPE"
    F.FT.COMMISSION.TYPE  = ""
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)
	
	FN.ACC = "F.ACCOUNT"
    CALL OPF(FN.ACC, F.ACC)
	
    Y.AMT.WORDS = '' ; Y.ERR.MSG = '' ; Y.OUT = ''
    Y.LANGUAGE = 'ID' ; Y.CUR = "IDR" ; Y.TRANS.CODE = ""
    
    Y.DATE = TODAY

    Y.APP       = "FUNDS.TRANSFER" :FM: "IDCH.RTGS.BANK.CODE.G2"
    Y.FLD.NAME  = "B.CDTR.NM":VM: "B.DBTR.NM" :VM: "B.CDTR.PRXYID" :VM: "B.CDTR.AGTID" :VM: "B.CDTR.ACCID" :VM: "B.CDTR.ACCTYPE" :VM: "B.CHNTYPE"
    Y.FLD.NAME  := VM: "B.DBTR.ACCTYPE" :VM: "B.SEQ.NO" :VM: "IN.STAN" :VM: "TELLER.ID" :VM: "B.CDTR.PRXYTYPE" :VM: "B.CDTR.TYPE" :VM: "B.DBTR.RESSTS" :VM: "B.CDTR.RESSTS"
    Y.FLD.NAME  := VM: "B.DBTR.ID" :VM: "ATI.JNAME.1" :VM: "IN.REVERSAL.ID" :VM: "ATI.JNAME.2" :VM: "ATI.JNAME.3" :VM: "IN.BENEF.BANK" :VM: "B.CDTR.TWNID" :VM: "B.CDTR.ID"
    Y.FLD.NAME  := VM: "B.CDTR.TWNNM"
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
	Y.CDTR.TOWN.ID.POS        = Y.POS<1,22>
	Y.CDTR.ID.POS             = Y.POS<1,23>
	Y.CDTR.TOWN.NM.POS        = Y.POS<1,24>
	Y.SKN.CLR.CODE.POS        = Y.POS<2,1>
	Y.SKN.BNK.TYPE.POS        = Y.POS<2,2>
	
	
    RETURN	
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.DATE         = TODAY
    
*construct date
    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
	Y.CURRENT.TIME = TIMESTAMP()
    Y.DAYS = OCONV(DATE(),"DWA")
    Y.DAYS = Y.DAYS[1,3]
    Y.DD.MMM.YY = OCONV(DATE(), "D2")
    Y.YY = X[9,2]
    Y.MM = X[1,2]
    Y.DD = X[4,2]
    Y.TH = Y.TIME[1,2]
    Y.TM = Y.TIME[4,2]
    Y.TS = Y.TIME[7,2]

	Y.FT.ID        	= ID.NEW
	Y.DB.ACCT      	= R.NEW(FT.DEBIT.ACCT.NO)
    Y.CDTR.AGTID   	= R.NEW(FT.LOCAL.REF)<1,Y.CDTR.AGTID.POS>
    Y.SEQ.NO       	= R.NEW(FT.LOCAL.REF)<1,Y.B.SEQNO.POS>
    Y.PROXY.TYPE   	= R.NEW(FT.LOCAL.REF)<1,Y.CDTR.PRXYTYPE.POS>
	Y.CHANNEL.TYPE 	= R.NEW(FT.LOCAL.REF)<1,Y.CHNTYPE.POS>
	Y.ATI.JNAME.2  	= R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.2.POS>
	Y.CDTR.NM      	= R.NEW(FT.LOCAL.REF)<1,Y.CDTR.NM.POS>
	Y.COMM.CODE    	= R.NEW(FT.COMMISSION.CODE)
	Y.COMM.ID      	= R.NEW(FT.COMMISSION.TYPE)
    Y.PROXY.VALUE  	= COMI
	
	Y.FROM.ACC.IA	= Y.DB.ACCT
	CHANGE "IDR" TO "" IN Y.FROM.ACC.IA
	
	IF Y.PROXY.TYPE EQ '0' THEN
	   RETURN
	END
	CALL F.READ(FN.ACC,Y.DB.ACCT,R.ACC,F.ACC,ERR.ACC)
	Y.CATEGORY =  R.ACC<AC.CATEGORY>
	
	Y.DEBIT.AMOUNT = R.NEW(FT.DEBIT.AMOUNT)
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
           RETURN
	    END

        IF Y.DEBIT.AMOUNT GT Y.PAR.MAXIMUM THEN
           RETURN
	    END

* Using core overdraft validation 
*        Y.FMT.AMOUNT     = LEN(R.NEW(FT.AMOUNT.DEBITED))
*		Y.AMOUNT.DEBITED = R.NEW(FT.AMOUNT.DEBITED)[4,Y.FMT.AMOUNT]

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
	Y.SEQ.NO = Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]:Y.MILLISECONDS
    
    R.NEW(FT.LOCAL.REF)<1,Y.B.SEQNO.POS> = Y.SEQ.NO
*---
	
	Y.CREATE.DT.TM = Y.DAYS:", ":Y.DD.MMM.YY[1,6]:" ":X[7,4]:" ":Y.TH:":":Y.TM:":":Y.TS
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME       = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
	Y.REC.PARTNER     = "360000"
	Y.ONBOARD.PARTNER = "92547"
    Y.TRX.TYPE        = "610"
	Y.LOOKUP.TYPE     = 'PXRS'
	Y.PROXY.TYPE      = '0':Y.PROXY.TYPE
	Y.RRN             = Y.DATE:'000':Y.ONBOARD.PARTNER:Y.TRX.TYPE:Y.SEQ.NO
	Y.REQUEST.ID      = Y.DATE:'000':Y.ONBOARD.PARTNER:"O":Y.SEQ.NO

	Y.TYPE = "BAliasRsltRQ"
	Y.PARAM = ''
    XX = ':'
    ZZ = ','
    Y.OPEN   = '{'
    Y.CLOSE = '}'
    Y.PARAM = Y.OPEN
    Y.PARAM :='"partnerReferenceNo"':XX:DQUOTE(Y.RRN)
    Y.PARAM :=',"creationDateTime"':XX:DQUOTE(Y.CREATE.DT.TM)
    Y.PARAM :=',"onboardingPartner"':XX:DQUOTE(Y.ONBOARD.PARTNER)
*   Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.DB.ACCT)
    Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.FROM.ACC.IA)
    Y.PARAM :=',"receivingPartner"':XX:DQUOTE(Y.REC.PARTNER)
    Y.PARAM :=',"channelType"':XX:DQUOTE(Y.CHANNEL.TYPE)
    Y.PARAM :=',"additionalInfo"':XX:Y.OPEN
    Y.PARAM :='"lookupType"':XX:DQUOTE(Y.LOOKUP.TYPE)
    Y.PARAM :=',"requestID"':XX:DQUOTE(Y.REQUEST.ID)
	Y.PARAM :=',"proxyType"':XX:DQUOTE(Y.PROXY.TYPE)
    Y.PARAM :=',"proxyValue"':XX:DQUOTE(Y.PROXY.VALUE)
    Y.PARAM := Y.CLOSE
    Y.PARAM := Y.CLOSE
  
    	CRT '[BFASTPROXYRESOLUTION-REQ] - ':Y.PARAM
    	RESP.ERR = ''
    	CALL BTPNSR.BIFAST.INTERFACE(Y.TYPE,Y.PARAM,RESP.POS,RESP.ERR)
	GOSUB CHECK.RESPONSE
	
    RETURN
	
*-----------------------------------------------------------------------------
CHECK.RESPONSE:
*-----------------------------------------------------------------------------

   FINDSTR '"responseCode"' IN RESP.POS SETTING POS THEN
        Y.RESPONSE.TEMP = EREPLACE(EREPLACE(RESP.POS,'":"','|'),'","','|')
        Y.RESPONSE = CHANGE(CHANGE(Y.RESPONSE.TEMP,'"',''),'}','')
   END
  
   Y.RESPONSE.CODE.RES    = FIELDS(FIELDS(Y.RESPONSE,'responseCode',2),'|',2)
   Y.REASON.CODE.RES      = FIELDS(FIELDS(Y.RESPONSE,'reasonCode',2),'|',2)
   Y.REG.ID.RES           = FIELDS(FIELDS(Y.RESPONSE,'registrationIdentifier',2),'|',2)
   Y.TO.ACC.RES           = FIELDS(FIELDS(Y.RESPONSE,'toAccount',2),'|',2)
   Y.NAME.RES             = FIELDS(FIELDS(Y.RESPONSE,'name',2),'|',2)
   Y.BANK.ID.RES          = FIELDS(FIELDS(Y.RESPONSE,'bankID',2),'|',2)
   Y.ACC.TYPE.RES         = FIELDS(FIELDS(Y.RESPONSE,'accountType',2),'|',2)
   Y.CUST.ID.RES          = FIELDS(FIELDS(Y.RESPONSE,'customerID',2),'|',2)
   Y.RES.STATUS.RES       = FIELDS(FIELDS(Y.RESPONSE,'residentSatus',2),'|',2)
   Y.TOWN.CODE.RES        = FIELDS(FIELDS(Y.RESPONSE,'townCode',2),'|',2)
   
   IF Y.RESPONSE.CODE.RES = 'RJCT' THEN
      IF Y.REASON.CODE.RES EQ '' THEN
         ETEXT = "Error RJCT ":"Reason Err : NULL "
         CALL STORE.END.ERROR
	  END ELSE
		 GOSUB REASON.CODE.FORMAT
		 ETEXT = "Error RJCT ":"Reason Err : ":Y.REASON.CODE.RES:"-":Y.REASON.CODE.DESC
         CALL STORE.END.ERROR
      END
   END ELSE
      Y.TOWN.NAME = ''
      CALL F.READ(FN.DISTRICT, Y.TOWN.CODE.RES, R.DISTRICT, F.DISTRICT, DISTRICT.ERR)
      IF DISTRICT.ERR THEN
	     CALL F.READ(FN.PROVINCE, Y.TOWN.CODE.RES, R.PROVINCE, F.PROVINCE, PROVINCE.ERR)
		 Y.TOWN.NAME = R.PROVINCE<SKN.PROVINCE.DESCRIPTION><1,1>
	  END ELSE
		 Y.TOWN.NAME = R.DISTRICT<IDCH.DISTRICT.DESCRIPTION><1,1>
	  END
      R.NEW(FT.LOCAL.REF)<1,Y.ATI.JNAME.2.POS>  = Y.NAME.RES
      R.NEW(FT.LOCAL.REF)<1,Y.CDTR.ACCID.POS>   = Y.TO.ACC.RES
      R.NEW(FT.LOCAL.REF)<1,Y.CDTR.ACCTYPE.POS> = Y.ACC.TYPE.RES
      R.NEW(FT.LOCAL.REF)<1,Y.CDTR.RESSTS.POS>  = Y.RES.STATUS.RES 
      R.NEW(FT.LOCAL.REF)<1,Y.CDTR.TOWN.ID.POS>  = Y.TOWN.CODE.RES
	  R.NEW(FT.LOCAL.REF)<1,Y.CDTR.TOWN.NM.POS>  = Y.TOWN.NAME
      R.NEW(FT.LOCAL.REF)<1,Y.CDTR.ID.POS>       = Y.CUST.ID.RES
	  
	  
*20221220_RPU
		Y.NAME.RES.UP = UPCASE(Y.NAME.RES)
		Y.CDTR.NM.UP  = UPCASE(Y.CDTR.NM)

*		IF Y.NAME.RES NE Y.CDTR.NM THEN
		IF Y.NAME.RES.UP NE Y.CDTR.NM.UP THEN
*\20221220_RPU
		 TEXT  = "FT-BIFAST.CDTR.NM.DIFFERENCE"
		 NO.OF.OVERR = DCOUNT(R.NEW(V-9),VM)+1
		 CALL STORE.OVERRIDE(NO.OF.OVERR)
	  END 
   END

   RETURN
   
*------------------
REASON.CODE.FORMAT:
*------------------
    ERR = Y.REASON.CODE.RES

    BEGIN CASE
    CASE ERR = 'U799'
        Y.REASON.CODE.DESC = "Alias Management Rule not found"
    CASE ERR = 'U800'
        Y.REASON.CODE.DESC = "Alias Rules Not Configured"
    CASE ERR = 'U801'
        Y.REASON.CODE.DESC = "Addressing Agency cannot be determined"
    CASE ERR = 'U802'
        Y.REASON.CODE.DESC = "Addressing Privilege not defined"
	CASE ERR = 'U803' 
		Y.REASON.CODE.DESC = "Insufficient Privilege"
	CASE ERR = 'U804'  
		Y.REASON.CODE.DESC = "Alias Not Found Or Inactive"    
	CASE ERR = 'U805'  
		Y.REASON.CODE.DESC = "Alias Is Suspended / Activated"    
	CASE ERR = 'U806'  
		Y.REASON.CODE.DESC = "Alias belongs to same FI but different account"    
	CASE ERR = 'U807'  
	    Y.REASON.CODE.DESC = "Alias already registered with another FI"    
	CASE ERR = 'U808'  
		Y.REASON.CODE.DESC = "Alias already registered with the same account"    
	CASE ERR = 'U809'  
		Y.REASON.CODE.DESC = "Not sufficient privilege to perform addressing action on an alias"  		
	CASE ERR = 'U810'  
		Y.REASON.CODE.DESC = "Alias Request Failed" 
	CASE ERR = 'U811'  
		Y.REASON.CODE.DESC = "Alias suspended by Administrator" 
	CASE ERR = 'U812'  
		Y.REASON.CODE.DESC = "Alias Destination Not Configured" 
	CASE ERR = 'U813'  
		Y.REASON.CODE.DESC = "Cache Alias Maintenance Failed"
	CASE ERR = 'U814'  
		Y.REASON.CODE.DESC = "Alias already registered with same FI"
	CASE ERR = 'U815'  
		Y.REASON.CODE.DESC = "Duplicate Alias Service Request"
	CASE ERR = 'U816'  
		Y.REASON.CODE.DESC = "Duplicate Alias Service Request Detected"
	CASE ERR = 'U850' 
		Y.REASON.CODE.DESC = "System Notification Event Code or Rules Not Found"
	CASE ERR = 'U851' 
		Y.REASON.CODE.DESC = "General Purpose Rules Not Found"
	CASE ERR = 'U890' 
		Y.REASON.CODE.DESC = "Invalid Business Hierarchy"
	CASE ERR = 'U900'  
		Y.REASON.CODE.DESC = "Internal Timeout"
	CASE ERR = 'U901'  
		Y.REASON.CODE.DESC = "System Malfunction"
	CASE ERR = 'U902' 
		Y.REASON.CODE.DESC = "Connection Or Communication Error"
	CASE ERR = 'U903' 
		Y.REASON.CODE.DESC = "Scripting Error"
	CASE ERR = 'U904'  
		Y.REASON.CODE.DESC = "Endpoint Error"
	CASE ERR = 'U905' 
		Y.REASON.CODE.DESC = "Configuration Error"
	CASE ERR = 'U906' 
		Y.REASON.CODE.DESC = "Logging Or Database Error"
	CASE ERR = 'U907' 
		Y.REASON.CODE.DESC = "Session Error No Plan Executed"
	CASE ERR = 'U908' 
		Y.REASON.CODE.DESC = "Validation Error"
	CASE ERR = 'U909' 
		Y.REASON.CODE.DESC = "Available Response Code"
	CASE ERR = 'U910' 
		Y.REASON.CODE.DESC = "No Session Response Within Timeout"
	CASE ERR = 'U911' 
		Y.REASON.CODE.DESC = "No Such Session"
	CASE ERR = 'U912' 
		Y.REASON.CODE.DESC = "Session Validation Error"
	CASE ERR = 'U913' 
		Y.REASON.CODE.DESC = "No Session Request Variable"
	CASE ERR = 'U990'  
		Y.REASON.CODE.DESC = "Session Error"
	CASE ERR = 'U992'  
		Y.REASON.CODE.DESC = "Response Not Delivered"
	CASE ERR = 'U993'  
		Y.REASON.CODE.DESC = "Reason Code not determined in response"
	CASE ERR = 'U999'  
		Y.REASON.CODE.DESC = "Signature Verification Failure"
	END CASE
	RETURN
*-----------------------------------------------------------------------------


END
	