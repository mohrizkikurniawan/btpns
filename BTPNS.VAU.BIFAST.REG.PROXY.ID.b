	SUBROUTINE BTPNS.VAU.BIFAST.REG.PROXY.ID
*-----------------------------------------------------------------------------
* Developer Name     : Budi Saptono
* Development Date   : 20220729
* Description        : Auth Routine to Proxy Alias BIFAST Register
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
	$INSERT I_F.BTPNS.TH.BIFAST.PROXY.MGMT
	$INSERT I_F.BTPNS.TH.BIFAST.PROXY.CONC
	$INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM

    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    FN.ACC = 'F.ACCOUNT'
    F.ACC = ''
    CALL OPF(FN.ACC,F.ACC)
	
    FN.CU = 'F.CUSTOMER'
    F.CU = ''
    CALL OPF(FN.CU,F.CU)
	
	FN.PROXY.MGMT = 'F.BTPNS.TH.BIFAST.PROXY.MGMT'
	F.PROXY.MGMT = ''
	CALL OPF(FN.PROXY.MGMT,F.PROXY.MGMT)
	
	FN.PROXY.CONC = 'F.BTPNS.TH.BIFAST.PROXY.CONC'
	F.PROXY.CONC = ''
	CALL OPF(FN.PROXY.CONC,F.PROXY.CONC)
	
	FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
    F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
    CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)
		
	Y.DATE = TODAY
	
	Y.APP  = "ACCOUNT" :FM: "CUSTOMER" 
	Y.FLD.NAME  = "B.PROXY.TYPE" :VM: "B.PROXY.ID" :VM: "B.PROXY.STATUS" :VM: "ATI.JOINT.NAME" :VM: "B.PROXY.REG.ID"
	Y.FLD.NAME := FM: "LEGAL.TYPE" :VM: "LEGAL.ID.NO" :VM: "PROVINCE" :VM: "RESIDE.Y.N"
	
	Y.POS       = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)

    Y.PROXY.TYPE.POS    = Y.POS<1,1>
    Y.PROXY.ID.POS      = Y.POS<1,2>
	Y.PROXY.STATUS.POS  = Y.POS<1,3>
	Y.ATI.JNAME.POS     = Y.POS<1,4>
	Y.PROXY.REG.ID.POS  = Y.POS<1,5>
    Y.LEGAL.TYPE.POS    = Y.POS<2,1>
    Y.LEGAL.ID.NO.POS   = Y.POS<2,2>
	Y.PROVINCE.POS      = Y.POS<2,3>
	Y.RESIDE.Y.N.POS    = Y.POS<2,4>
	
	
	RETURN
	
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
   Y.ID              = ID.NEW
   Y.REFF.NO         = R.NEW(BF.PM.REFF.NO)
   Y.ACCT.NO          = R.NEW(BF.PM.ACCOUNT.NO)
   Y.ACCT.NAME        = R.NEW(BF.PM.ACCOUNT.NAME)
   Y.ACCT.TYPE       = R.NEW(BF.PM.ACCOUNT.TYPE)
   Y.CUST.TYPE       = FMT(R.NEW(BF.PM.CUSTOMER.TYPE),"R0%2") 
   Y.CUST.NO         = R.NEW(BF.PM.CUSTOMER.NO)
   Y.LEGAL.ID.TYPE   = R.NEW(BF.PM.LEGAL.ID.TYPE) 
   Y.LEGAL.ID.NO     = R.NEW(BF.PM.LEGAL.ID.NO)
   Y.RESS.STATUS     = R.NEW(BF.PM.RESS.STATUS)
   Y.TOWN.ID         = R.NEW(BF.PM.TOWN.ID)
   Y.PROXY.TYPE.1    = R.NEW(BF.PM.PROXY.TYPE)
   Y.PROXY.TYPE      = FMT(R.NEW(BF.PM.PROXY.TYPE),"R0%2")
   Y.PROXY.ID        = R.NEW(BF.PM.PROXY.ID)
   Y.ID.SCOPES       = R.NEW(BF.PM.ID.SCOPES)
*construct date
    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
    Y.CURRENT.TIME = TIMESTAMP()
    Y.DAYS = OCONV(DATE(),"DWA")
    Y.DAYS = Y.DAYS[1,1]:LOWCASE(Y.DAYS[2,2])
    Y.DD.MMM.YY = OCONV(DATE(), "D2")
    Y.DD.MMM.YY =  Y.DD.MMM.YY[1,3]:Y.DD.MMM.YY[4,1]:LOWCASE(Y.DD.MMM.YY[5,2])
    Y.YY = X[9,2]
    Y.MM = X[1,2]
    Y.DD = X[4,2]
    Y.TH = Y.TIME[1,2]
    Y.TM = Y.TIME[4,2]
    Y.TS = Y.TIME[7,2]
    Y.CREATE.DT.TM = Y.DAYS:", ":Y.DD.MMM.YY:" ":X[7,4]:" ":Y.TH:":":Y.TM:":":Y.TS
    
   Y.CHANNEL.TYPE    = R.NEW(BF.PM.CHANNEL.TYPE)
   Y.ONBOARD.PARTNER = R.NEW(BF.PM.ONBOARD.PARTNER)
   Y.RECEIVE.PARTNER = R.NEW(BF.PM.RECEIVE.PARTNER)   
   Y.REG.ID          = ''

   XX = ':'
   Y.TYPE = 'BAliasMgtRQ'
   Y.OPEN   = '{'
   Y.CLOSE = '}'
   Y.PARAM = Y.OPEN
   Y.PARAM :='"partnerReferenceNo"':XX:DQUOTE(Y.REFF.NO)
   Y.PARAM :=',"creationDateTime"':XX:DQUOTE(Y.CREATE.DT.TM)
   Y.PARAM :=',"onboardingPartner"':XX:DQUOTE(Y.ONBOARD.PARTNER)
   Y.PARAM :=',"receivingPartner"':XX:DQUOTE(Y.RECEIVE.PARTNER)
   Y.PARAM :=',"channelType"':XX:DQUOTE(Y.CHANNEL.TYPE)
   Y.PARAM :=',"scopes"':XX:DQUOTE(Y.ID.SCOPES)
   Y.PARAM :=',"name"':XX:DQUOTE(Y.ACCT.NAME)
   Y.PARAM :=',"accountType"':XX:DQUOTE(Y.ACCT.TYPE)
   Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.ACCT.NO)
   Y.PARAM :=',"registrationIdentifier"':XX:DQUOTE(Y.REG.ID)
   Y.PARAM :=',"additionalInfo"':XX:Y.OPEN
   Y.PARAM :='"proxyType"':XX:DQUOTE(Y.PROXY.TYPE)
   Y.PARAM :=',"proxyValue"':XX:DQUOTE(Y.PROXY.ID)
   Y.PARAM :=',"idType"':XX:DQUOTE(Y.LEGAL.ID.TYPE)
   Y.PARAM :=',"id"':XX:DQUOTE(Y.LEGAL.ID.NO)
   Y.PARAM :=',"customerType"':XX:DQUOTE(Y.CUST.TYPE)
   Y.PARAM :=',"customerID"':XX:DQUOTE(Y.CUST.NO)
   Y.PARAM :=',"residentStatus"':XX:DQUOTE(Y.RESS.STATUS)
   Y.PARAM :=',"townCode"':XX:DQUOTE(Y.TOWN.ID)
   Y.PARAM := Y.CLOSE
   Y.PARAM := Y.CLOSE
   
   	CRT '[BFAST-REQ] - ':Y.TYPE
    RESP.ERR = ''
	CALL BTPNSR.BIFAST.INTERFACE(Y.TYPE,Y.PARAM,RESP.POS,RESP.ERR)
	GOSUB CHECK.RESPONSE

    RETURN

* ------------
CHECK.RESPONSE:
* ------------
   FINDSTR '"responseCode"' IN RESP.POS SETTING POS THEN
		Y.RESPONSE.TEMP = EREPLACE(EREPLACE(RESP.POS,'":"','|'),'","','|')
		Y.RESPONSE = CHANGE(CHANGE(Y.RESPONSE.TEMP,'"',''),'}','')
   END
   Y.RESPONSE.CODE.RES    = FIELDS(FIELDS(Y.RESPONSE,'responseCode',2),'|',2)
   Y.REASON.CODE.RES      = FIELDS(FIELDS(Y.RESPONSE,'reasonCode',2),'|',2)
   Y.REG.ID.RES           = FIELDS(FIELDS(Y.RESPONSE,'registrationIdentifier',2),'|',2)

   IF Y.RESPONSE.CODE.RES EQ 'ACTC' THEN
      R.NEW(BF.PM.RESPONSE.CODE) =  Y.RESPONSE.CODE.RES
      R.NEW(BF.PM.REASON.CODE) = Y.REASON.CODE.RES
      R.NEW(BF.PM.REGISTER.ID) = Y.REG.ID.RES 
      R.NEW(BF.PM.PROXY.STATUS) = 'ACTV'
	  
	  CALL F.READ(FN.ACC, Y.ACCT.NO, R.ACC, F.ACC, ACC.ERR)
	  R.ACC<AC.LOCAL.REF, Y.PROXY.TYPE.POS>   = Y.PROXY.TYPE.1
	  R.ACC<AC.LOCAL.REF, Y.PROXY.ID.POS>     = Y.PROXY.ID
	  R.ACC<AC.LOCAL.REF, Y.PROXY.REG.ID.POS> = Y.REG.ID.RES
	  R.ACC<AC.LOCAL.REF, Y.PROXY.STATUS.POS> = 'ACTV'
	  WRITE R.ACC TO F.ACC, Y.ACCT.NO

	  CALL F.READ(FN.PROXY.CONC, Y.PROXY.ID, R.PC, F.PROXY.CONC, CONC.ERR)
	  R.PC<BF.PC.PROXY.STATUS> = 'ACTV'
	  R.PC<BF.PC.PROXY.TYPE>   = Y.PROXY.TYPE.1
	  R.PC<BF.PC.ACCOUNT.NO>   = Y.ACCT.NO
	  WRITE R.PC TO F.PROXY.CONC, Y.PROXY.ID
   END ELSE
      IF Y.RESPONSE.CODE.RES EQ '' THEN
         IF RESP.ERR NE '' THEN
            E = RESP.ERR
            CALL ERR
         END ELSE
            E = "Response Code : null"
            CALL ERR
         END
      END ELSE
         GOSUB REASON.CODE.FORMAT
         E = "Error RJCT ":"Reason Err : ":Y.REASON.CODE.RES:"-":Y.REASON.CODE.DESC
         CALL ERR
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
   


