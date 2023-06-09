    SUBROUTINE BTPNS.VAU.BIFAST.SEND.RACTV
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 1 Agusuts 2022
* Description        : auth routine for send message reactivate proxy
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
* No Log             :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BTPNS.TH.BIFAST.PROXY.MGMT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.BTPNS.TH.BIFAST.PROXY.CONC

    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    
    Y.FILES   = "ACCOUNT"
    Y.FIELDS  = "B.PROXY.STATUS"    : VM : "B.PROXY.REG.ID"
    Y.POS        = "" 
    CALL MULTI.GET.LOC.REF(Y.FILES, Y.FIELDS, Y.POS)

    Y.PROXY.STATUS.POS   = Y.POS<1,1>
    Y.PROXY.REG.ID.POS   = Y.POS<1,2>
    
    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT  = ""
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    
    FN.BTPNS.TH.BIFAST.PROXY.CONC = "F.BTPNS.TH.BIFAST.PROXY.CONC"
    F.BTPNS.TH.BIFAST.PROXY.CONC  = ""
    CALL OPF(FN.BTPNS.TH.BIFAST.PROXY.CONC,F.BTPNS.TH.BIFAST.PROXY.CONC)
    
    Y.ID.ACCOUNT = R.NEW(BF.PM.ACCOUNT.NO)
    
    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.DATE                 = TODAY
    Y.ID                 = ID.NEW
    
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
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]

    Y.ONBOARD.PARTNER    = R.NEW(BF.PM.ONBOARD.PARTNER)
    Y.RRN                = Y.DATE:'000':Y.ONBOARD.PARTNER:'720':Y.ID
    R.NEW(BF.PM.REFF.NO)  = Y.RRN
    R.NEW(BF.PM.CREATE.DT.TIME) = Y.CREATE.DT.TM  
    Y.REC.PARTNER        = R.NEW(BF.PM.RECEIVE.PARTNER)
    Y.CHANNEL.TYPE       = R.NEW(BF.PM.CHANNEL.TYPE)
    Y.SCOPES             = "ACTV"
    Y.ACC.NAME           = R.NEW(BF.PM.ACCOUNT.NAME)
    Y.ACC.TYPE           = R.NEW(BF.PM.ACCOUNT.TYPE)
    Y.ACCOUNT.NO         = R.NEW(BF.PM.ACCOUNT.NO)
    Y.REGISTER.ID       = R.NEW(BF.PM.REGISTER.ID)
    Y.PROXY.TYPE.1       = R.NEW(BF.PM.PROXY.TYPE)
    Y.PROXY.TYPE         = FMT(R.NEW(BF.PM.PROXY.TYPE),"R0%2")
    Y.PROXY.VALUE        = R.NEW(BF.PM.PROXY.ID)
    Y.LEGAL.TYPE         = R.NEW(BF.PM.LEGAL.ID.TYPE)
    Y.LEGAL.ID           = R.NEW(BF.PM.LEGAL.ID.NO)
    Y.CUSTOMER.TYPE      = FMT(R.NEW(BF.PM.CUSTOMER.TYPE),"R0%2")
    Y.CUSTOMER.NO         = R.NEW(BF.PM.CUSTOMER.NO)
    Y.RES.STATUS          = R.NEW(BF.PM.RESS.STATUS)
    Y.TOWN.ID            = R.NEW(BF.PM.TOWN.ID) 

*Get Register id via API
*for re activated dont need resolution because if we send resolution we get reject alias is suspended, we get register id from t24 not BI Connector
*  Y.TYPE = "BAliasRsltRQ"
*  Y.DATA = "||PXRS|":Y.PROXY.TYPE:"|":Y.PROXY.VALUE:"|6847|":Y.ACCOUNT.NO
*  CALL BTPNS.API.ALIAS.INQ(Y.TYPE,Y.DATA,Y.RESPON.REG.ID,RESP.ERR.REG.ID,Y.REQUEST.JSON)
*  FINDSTR '"responseCode"' IN Y.RESPON.REG.ID SETTING POS THEN
*        Y.RESPONSE.TEMP = EREPLACE(EREPLACE(Y.RESPON.REG.ID,'":"','|'),'","','|')
*        Y.RESPONSE = CHANGE(CHANGE(Y.RESPONSE.TEMP,'"',''),'}','')
*  END
*   Y.RESPONSE.CODE.RES.1    = FIELDS(FIELDS(Y.RESPONSE,'responseCode',2),'|',2)
*   Y.REASON.CODE.RES.1      = FIELDS(FIELDS(Y.RESPONSE,'reasonCode',2),'|',2)
*   Y.REGISTER.ID           = FIELDS(FIELDS(Y.RESPONSE,'registrationIdentifier',2),'|',2)

*  IF Y.RESPONSE.CODE.RES.1 EQ 'ACTC' THEN
     GOSUB CONSTRUCT.REQUEST
*  END ELSE
*      IF Y.RESPONSE.CODE.RES.1 EQ '' THEN
*         IF RESP.ERR.REG.ID NE '' THEN
*            E = RESP.ERR.REG.ID
*            CALL ERR
*         END ELSE
*            E = "Response Code : null"
*            CALL ERR
*         END
*      END ELSE
*         GOSUB REASON.CODE.FORMAT
*         E = "Error RJCT ":"Reason Err : ":Y.REASON.CODE.RES.1:"-":Y.REASON.CODE.DESC
*         CALL ERR
*      END
*  END

  RETURN
*-----------------------------------------------------------------------------
CONSTRUCT.REQUEST:
*-----------------------------------------------------------------------------
    
    Y.PARAM = ''
    XX = ':'
    ZZ = ','
    Y.TYPE = 'BAliasMgtRQ'
    Y.OPEN   = '{'
    Y.CLOSE = '}'
    Y.PARAM = Y.OPEN
    Y.PARAM :='"partnerReferenceNo"':XX:DQUOTE(Y.RRN)
    Y.PARAM :=',"creationDateTime"':XX:DQUOTE(Y.CREATE.DT.TM)
    Y.PARAM :=',"onboardingPartner"':XX:DQUOTE(Y.ONBOARD.PARTNER)    
    Y.PARAM :=',"receivingPartner"':XX:DQUOTE(Y.REC.PARTNER)
    Y.PARAM :=',"channelType"':XX:DQUOTE(Y.CHANNEL.TYPE)
    Y.PARAM :=',"scopes"':XX:DQUOTE(Y.SCOPES)
    Y.PARAM :=',"name"':XX:DQUOTE(Y.ACC.NAME)
    Y.PARAM :=',"accountType"':XX:DQUOTE(Y.ACC.TYPE)
    Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.ACCOUNT.NO)
    Y.PARAM :=',"registrationIdentifier"':XX:DQUOTE(Y.REGISTER.ID)
    Y.PARAM :=',"additionalInfo"':XX:Y.OPEN
    Y.PARAM :='"proxyType"':XX:DQUOTE(Y.PROXY.TYPE)
    Y.PARAM :=',"proxyValue"':XX:DQUOTE(Y.PROXY.VALUE)
    Y.PARAM :=',"idType"':XX:DQUOTE(Y.LEGAL.TYPE)
    Y.PARAM :=',"id"':XX:DQUOTE(Y.LEGAL.ID)
    Y.PARAM :=',"customerType"':XX:DQUOTE(Y.CUSTOMER.TYPE)    
    Y.PARAM :=',"customerID"':XX:DQUOTE(Y.CUSTOMER.NO)
    Y.PARAM :=',"residentStatus"':XX:DQUOTE(Y.RES.STATUS)
    Y.PARAM :=',"townCode"':XX:DQUOTE(Y.TOWN.ID)
    Y.PARAM := Y.CLOSE
    Y.PARAM := Y.CLOSE
    
    CRT '[BFASTPROXY-REQ] - ':Y.PARAM
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
   
   IF Y.RESPONSE.CODE.RES EQ 'ACTC' THEN
      Y.PROXY.STATUS = "ACTV"
      R.NEW(BF.PM.RESPONSE.CODE) = Y.RESPONSE.CODE.RES
      R.NEW(BF.PM.REASON.CODE)   = Y.REASON.CODE.RES
      R.NEW(BF.PM.REGISTER.ID)   = Y.REG.ID.RES 
      R.NEW(BF.PM.PROXY.STATUS)  = Y.PROXY.STATUS

      CALL F.READ(FN.ACCOUNT,Y.ID.ACCOUNT,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
      R.ACCOUNT<AC.LOCAL.REF,Y.PROXY.STATUS.POS> = Y.PROXY.STATUS
      R.ACCOUNT<AC.LOCAL.REF,Y.PROXY.REG.ID.POS> = Y.REG.ID.RES
      CALL F.WRITE(FN.ACCOUNT,Y.ID.ACCOUNT,R.ACCOUNT)
      
      CALL F.READ(FN.BTPNS.TH.BIFAST.PROXY.CONC,Y.PROXY.VALUE,R.BTPNS.TH.BIFAST.PROXY.CONC,F.BTPNS.TH.BIFAST.PROXY.CONC,ERR.BTPNS.TH.BIFAST.PROXY.CONC)
      R.BTPNS.TH.BIFAST.PROXY.CONC<BF.PC.ACCOUNT.NO>    = Y.ID.ACCOUNT
      R.BTPNS.TH.BIFAST.PROXY.CONC<BF.PC.PROXY.TYPE>    = Y.PROXY.TYPE.1
      R.BTPNS.TH.BIFAST.PROXY.CONC<BF.PC.PROXY.STATUS>  = Y.PROXY.STATUS
      CALL F.WRITE(FN.BTPNS.TH.BIFAST.PROXY.CONC,Y.PROXY.VALUE,R.BTPNS.TH.BIFAST.PROXY.CONC)
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
