    SUBROUTINE BTPNS.VVR.PROXY.ID.CHECK
*-----------------------------------------------------------------------------
* Developer Name     : Budi Saptono
* Development Date   : 20220729
* Description        : Routine to Validate Proxy ID Alias BIFAST
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
    
    Y.APP  = "ACCOUNT" 
    Y.FLD.NAME  = "B.PROXY.TYPE" :VM: "B.PROXY.ID" :VM: "B.PROXY.STATUS" :VM: "ATI.JOINT.NAME" :VM: "B.PROXY.REG.ID"
    
    Y.POS       = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)

    Y.AC.PROXY.TYPE.POS    = Y.POS<1,1>
    Y.AC.PROXY.ID.POS      = Y.POS<1,2>
    Y.AC.PROXY.STATUS.POS  = Y.POS<1,3>
    Y.ATI.JNAME.POS     = Y.POS<1,4>
    Y.PROXY.REG.ID.POS  = Y.POS<1,5>
 
    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
   Y.PROXY.ID = COMI
   *Y.PROXY.TYPE = R.NEW(BF.PM.PROXY.TYPE)
   Y.PROXY.TYPE          = FMT(R.NEW(BF.PM.PROXY.TYPE),"R0%2")
   Y.CIF      = R.NEW(BF.PM.CUSTOMER.NO)
   Y.ACCT.NO  = R.NEW(BF.PM.ACCOUNT.NO)
   SEL.LIST = ''
   
   CALL F.READ(FN.PROXY.CONC, Y.PROXY.ID, R.PC, F.PROXY.CONC, CONC.ERR)
   
   IF NOT(CONC.ERR) THEN
      Y.ACC.CONC = R.PC<BF.PC.ACCOUNT.NO>
      Y.PROXY.STATUS.CONC = R.PC<BF.PC.PROXY.STATUS>
      IF Y.ACCT.NO <> Y.ACC.CONC THEN
         ETEXT = "Proxy Alias Sudah di Register pada Rekening : ":Y.ACC.CONC
         CALL STORE.END.ERROR
      END ELSE
         IF Y.PROXY.STATUS.CONC = 'ACTV' THEN
            ETEXT = "Proxy Alias Sudah Active !"
            CALL STORE.END.ERROR
         END 
      END
      
   END
   
   CALL F.READ(FN.CU, Y.CIF, R.CUS, F.CU, CU.ERR)
   Y.SMS.1   = R.CUS<EB.CUS.SMS.1>
   Y.EMAIL.1 = R.CUS<EB.CUS.EMAIL.1>

  BEGIN CASE
  CASE Y.PROXY.TYPE EQ "1"
      GOSUB CHECK.FORMAT
      IF Y.SMS.1 = '' THEN
         ETEXT = "No HP Belum terdaftar pada CIF : ":Y.CIF
         CALL STORE.END.ERROR
      END
      Y.LEN = LEN(Y.PROXY.ID)
      IF Y.PROXY.ID[1,2] = '62' THEN 
         Y.NO.HP = Y.PROXY.ID[3,(Y.LEN - 2)]
         FINDSTR Y.NO.HP IN Y.SMS.1 SETTING Ap,Vp THEN
         END ELSE
             ETEXT = "No HP Tidak terdaftar pada CIF : ":Y.CIF
             CALL STORE.END.ERROR
         END
      END
   CASE Y.PROXY.TYPE EQ "2"
	    GOSUB CHECK.FORMAT
		Y.EMAIL.1 = UPCASE(Y.EMAIL.1)
		Y.PROXY.ID = UPCASE(Y.PROXY.ID)
        FINDSTR Y.PROXY.ID IN Y.EMAIL.1 SETTING Ap,Vp THEN
        END ELSE
            ETEXT = "Email Tidak terdaftar pada CIF : ":Y.CIF
            CALL STORE.END.ERROR
        END

   CASE Y.PROXY.TYPE EQ "0"
        IF Y.PROXY.ID NE Y.ACCT.NO THEN 
           ETEXT = "Proxy ID harus sama dengan No Account yang diisi !"
           CALL STORE.END.ERROR
       END
   END CASE
   GOSUB CHECK.RESOLUTION
   RETURN
   
*-----------------------------------------------------------------------------
CHECK.RESOLUTION:
*-----------------------------------------------------------------------------
   Y.REFF.NO         = R.NEW(BF.PM.REFF.NO)
   Y.ACCT.NO         = R.NEW(BF.PM.ACCOUNT.NO)
   Y.ONBOARD.PARTNER = R.NEW(BF.PM.ONBOARD.PARTNER)
   Y.RECEIVE.PARTNER = R.NEW(BF.PM.RECEIVE.PARTNER)
   Y.CHANNEL.TYPE    = R.NEW(BF.PM.CHANNEL.TYPE)
   Y.REQ.ID          = Y.REFF.NO[1,16]:'O':RIGHT(Y.REFF.NO,8)
   IF (MESSAGE EQ "VAL" AND OFS$OPERATION EQ "VALIDATE") OR OFS$OPERATION EQ "PROCESS" THEN
     Y.TYPE = "BAliasRsltRQ"
     Y.DATA = "||PXRS|":Y.PROXY.TYPE:"|":Y.PROXY.ID:"|6847|":Y.ACCT.NO
     CALL BTPNS.API.ALIAS.INQ(Y.TYPE,Y.DATA,RESP.POS,RESP.ERR.REG.ID,Y.REQUEST.JSON)
     GOSUB CHECK.RESPONSE
   END
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
   
   IF Y.RESPONSE.CODE.RES = 'RJCT' THEN
      IF Y.REASON.CODE.RES EQ '' THEN
         ETEXT = "Error RJCT ":"Reason Err : NULL "
         CALL STORE.END.ERROR
	  END ELSE
     IF Y.REASON.CODE.RES NE 'U804' THEN
		    GOSUB REASON.CODE.FORMAT
		    ETEXT = "Error RJCT ":"Reason Err : ":Y.REASON.CODE.RES:"-":Y.REASON.CODE.DESC
           CALL STORE.END.ERROR
        END		 
     END 
   END
   RETURN
*-----------------------------------------------------------------------------
CHECK.FORMAT:
*-----------------------------------------------------------------------------
    BEGIN CASE

    CASE Y.PROXY.TYPE EQ "1" AND Y.PROXY.ID          ;*Mobile Phone Number
        IF NOT(ISDIGIT(Y.PROXY.ID)) THEN
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
        END
        Y.PROXY.ID = TRIM(Y.PROXY.ID)
		IF Y.PROXY.ID[1,2] <> '62' THEN
		   AF = BF.PM.PROXY.ID
		   AV = Y.PROXY.ID
		   ETEXT = "Mobile No Harus di awali dengan kode 62"
		   CALL STORE.END.ERROR
		END
		
    CASE Y.PROXY.TYPE EQ "2" AND Y.PROXY.ID          ;*Email Address
        Y.EMAIL.ADDR = Y.PROXY.ID

        Y.EMAIL1 = FIELD(Y.EMAIL.ADDR,"@",1)          ;* get the part before @
        Y.EMAIL2 = FIELD(Y.EMAIL.ADDR,"@",2)          ;* get the part after @
        Y.INDEX1 = INDEX(Y.EMAIL.ADDR,"@",1)          ;* get the position of the first occurence of @
        Y.INDEX2 = INDEX(Y.EMAIL.ADDR,"@",2)          ;* get the position of the second occurence of @
        Y.DOTINDEX1= INDEX(Y.EMAIL1,".",1)  ;* position of dot in the first part
        Y.DOTINDEX2= INDEX(Y.EMAIL2,".",1)  ;* position of dot in the second part

        * '@' Validations
        * There should be atleast one occurence of '@' character and it should not be the first character in the
        * email address and not more than one '@' character in the email address.
        IF NOT(Y.INDEX1) OR Y.INDEX1 = 1 OR Y.INDEX2  THEN
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
			RETURN
        END


        * '.' Validations
        *  In either part of the email address separated by '@' ,the '.' can neither be the first
        *  character nor the last character.There should  not be consecutive occurence of '.' in the email address.
        *  Atleast there should be a single dot in the second part of email address.

        IF Y.DOTINDEX1=1 OR Y.DOTINDEX1=LEN(Y.EMAIL1) THEN        ;* dot present in the first character or last character of the first part of email address
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
			RETURN
        END

        IF NOT(Y.DOTINDEX2) OR Y.DOTINDEX2=1 OR Y.DOTINDEX2=LEN(Y.EMAIL2) THEN          ;* dot present in the first character or last character of the second part of email address
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
			RETURN
        END

        IF INDEX(Y.EMAIL.ADDR,'..',1) OR INDEX(Y.EMAIL.ADDR,' ',1) THEN   ;*two dots consecutively present or space present in the email address
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
			RETURN
        END
    END CASE
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
   