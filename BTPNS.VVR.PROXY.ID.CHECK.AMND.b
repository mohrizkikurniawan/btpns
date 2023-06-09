	SUBROUTINE BTPNS.VVR.PROXY.ID.CHECK.AMND
*-----------------------------------------------------------------------------
* Developer Name     : Budi Saptono
* Development Date   : 20220729
* Description        : Routine to Validate Proxy ID Alias BIFAST Amend
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
	  IF Y.ACCT.NO <> Y.ACC.CONC AND Y.PROXY.STATUS.CONC = 'ACTV' THEN
	     ETEXT = "Proxy Status Sudah digunakan pada rekening : ":Y.ACC.CONC
	     CALL STORE.END.ERROR	
      END
	  CALL F.READ(FN.ACC, Y.ACCT.NO, R.ACC, F.ACC, ACC.ERR)
	  Y.AC.PROXY.STATUS = R.ACC<AC.LOCAL.REF, Y.AC.PROXY.STATUS.POS>
	  IF Y.AC.PROXY.STATUS NE 'ACTV' THEN
	     ETEXT = "Proxy Status sudah tidak Active : ":Y.AC.PROXY.STATUS
	     CALL STORE.END.ERROR
      END
   END
   
   CALL F.READ(FN.CU, Y.CIF, R.CUS, F.CU, CU.ERR)
   Y.SMS.1   = R.CUS<EB.CUS.SMS.1>
   Y.EMAIL.1 = R.CUS<EB.CUS.EMAIL.1>

  BEGIN CASE
  CASE Y.PROXY.TYPE EQ "1"
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
        Y.PROXY.ID = UPCASE(Y.PROXY.ID)
		Y.EMAIL.1  = UPCASE(Y.EMAIL.1) 
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
   
*-------------------
CHECK.RESOLUTION:
*-------------------
   Y.REFF.NO         = R.NEW(BF.PM.REFF.NO)
   Y.ACCT.NO         = R.NEW(BF.PM.ACCOUNT.NO)
   Y.ONBOARD.PARTNER = R.NEW(BF.PM.ONBOARD.PARTNER)
   Y.RECEIVE.PARTNER = R.NEW(BF.PM.RECEIVE.PARTNER)
   Y.CHANNEL.TYPE    = R.NEW(BF.PM.CHANNEL.TYPE)
   Y.REQ.ID          = Y.REFF.NO[1,16]:'O':RIGHT(Y.REFF.NO,8)
    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
	Y.DAYS = OCONV(DATE(),"DWA")
	Y.DAYS = Y.DAYS[1,3]
	Y.DD.MMM.YY = OCONV(DATE(), "D2")
	Y.YY = X[9,2]
	Y.MM = X[1,2]
	Y.DD = X[4,2]
	Y.TH = Y.TIME[1,2]
	Y.TM = Y.TIME[4,2]
	Y.TS = Y.TIME[7,2]
	
   Y.CREATE.DT.TM = Y.DAYS:", ":Y.DD.MMM.YY[1,6]:" ":X[7,4]:" ":Y.TH:":":Y.TM:":":Y.TS
   R.NEW(BF.PM.CREATE.DT.TIME) = Y.CREATE.DT.TM 

*validate resolution via API

   IF (MESSAGE EQ "VAL" AND OFS$OPERATION EQ "VALIDATE") OR OFS$OPERATION EQ "PROCESS" THEN

   Y.PROXY.TYPE.1          = FMT(Y.PROXY.TYPE,"R0%2")
   Y.TYPE = "BAliasRsltRQ"
   Y.DATA = "||PXRS|":Y.PROXY.TYPE.1:"|":Y.PROXY.ID:"|6847|":Y.ACCT.NO
   CALL BTPNS.API.ALIAS.INQ(Y.TYPE,Y.DATA,RESP.POS,RESP.ERR,Y.REQUEST.JSON)
   GOSUB CHECK.RESPONSE

   *CALL BTPNSR.BIFAST.INTERFACE(Y.TYPE,Y.PARAM,RESP.POS,RESP.ERR)

   END 

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
   Y.TO.ACC.RES           = FIELDS(FIELDS(Y.RESPONSE,'toAccount',2),'|',2)
   Y.NAME.RES             = FIELDS(FIELDS(Y.RESPONSE,'name',2),'|',2)
   Y.BANK.ID.RES          = FIELDS(FIELDS(Y.RESPONSE,'bankID',2),'|',2)
   
   IF Y.RESPONSE.CODE.RES = 'ACTC' AND Y.BANK.ID.RES THEN
      ETEXT = "Proxy ID Sudah terdaftar di Bank lain !"
	  CALL STORE.END.ERROR
   END
   RETURN
END
   