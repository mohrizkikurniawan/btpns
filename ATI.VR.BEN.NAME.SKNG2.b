SUBROUTINE ATI.VR.BEN.NAME.SKNG2
*-----------------------------------------------------------------------------
* Developer Name     : Friendly NS
* Development Date   : 20211012
* Description        : Subroutine to check length ATI.BEN.NAME & SKN.RCV.STREET
* Attached to        : ACTIVITY.API>ID.NDC.IS.DEP.API
*-----------------------------------------------------------------------------
* Modification History:-
* Name				 : Moh Rizki Kurniawan
* Date				 : 20 Agustus 2022
* Description		 : Add bifast check account
*-----------------------------------------------------------------------------
* Date            Modified by                Description
* 20221003        BSA                        SKN.TXN.CODE => Default 50 For SKN
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $USING AA.Settlement
    $USING EB.Updates
    $USING EB.ErrorProcessing
	$INSERT I_F.EB.LOOKUP
	$INSERT I_F.IDCH.RTGS.BANK.CODE.G2
	$USING AA.TermAmount
	$INSERT I_F.COMPANY
	$INSERT I_F.CUSTOMER
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
	$INSERT	I_F.BTPNS.TH.BIFAST.RC.PARAM
	$INSERT I_F.AA.ACCOUNT
	$INSERT I_F.OVERRIDE
	$INSERT I_TSA.COMMON
	$INSERT I_AA.ACTION.CONTEXT
	$INSERT I_F.BTPNS.TL.DEPO.KLIRING
	$INSERT I_F.FT.COMMISSION.TYPE
	$INSERT I_F.IDCH.DISTRICT
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
    GOSUB INIT
    GOSUB PROCESS
	GOSUB DEFAULT.PAYOUT.ACC
	

RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    Y.APP       = "AA.ARR.SETTLEMENT" :FM: "IDCH.RTGS.BANK.CODE.G2"
    Y.FLD       = "ATI.BEN.NAME" :VM: "SKN.RCV.STREET" :VM: "BEN.ACC" :VM: "MUD.CLEARED" :VM: "SKN.RTGS" :VM: "L.PFT.ACC.NUM" :VM: "ATI.BEN.NAME" :VM: "B.CDTR.PRXYTYPE" :VM: "ATI.JNAME.2" :VM: "B.SEQ.NO" :VM: "IN.STAN" :VM: "IN.TRNS.DT.TM" :VM: "IN.UNIQUE.ID" :VM: "IN.CHANNEL.ID" :VM: "IN.REVERSAL.ID" :VM: "B.COM.CODE" :VM: "B.COM.TYPE" :VM: "B.CDTR.AGTID" :VM: "SKN.RCV.TXN" :VM: "SKN.TXN.CODE" :VM: "SKN.RCV.TYPE" :VM: "SKN.RCV.RESIDE" :VM: "NATION.STATUS" :VM: "SKN.RECEIV.BANK" :VM: "SKN.RCV.ID" :VM: "SKN.RCV.STREET" :VM: "RTGS.BANK.G2" :VM: "TXN.CODE.G2" :VM: "TO.ACC.BRANCH" :VM: "BEN.ADDR" :VM: "BEN.NATIONALITY" :VM: "BEN.CITY.CODE" :VM: "BEN.CITY.NAME" :VM: "TO.CITY.CODE" :VM: "TO.CITY.NAME" :VM: "B.COM.AMT" :VM: "B.CHARGE.AMT" :VM: "B.CHARGE.TYPE"
	Y.FLD	   := FM: "SKN.CLR.CODE" :VM: "B.BANK.TYPE"
    Y.POS       = ""
    EB.Updates.MultiGetLocRef(Y.APP,Y.FLD,Y.POS)
    
    Y.ATI.BEN.NAME.POS  = Y.POS<1,1>
    Y.SKN.RCV.STREET.POS = Y.POS<1,2>
	Y.BEN.ACC.POS		= Y.POS<1,3>
	Y.MUD.CLEARED.POS	= Y.POS<1,4>
	Y.SKN.RTGS.POS		= Y.POS<1,5>
	Y.L.PFT.ACC.NUM.POS	= Y.POS<1,6>
	Y.ATI.BEN.NAME.POS	= Y.POS<1,7>
	Y.CDTR.PRXYTYPE.POS	= Y.POS<1,8>
	Y.ATI.JNAME.2.POS	= Y.POS<1,9>
	Y.B.SEQ.NO.POS       = Y.POS<1,10>
	Y.IN.STAN.POS        = Y.POS<1,11>
	Y.IN.TRNS.DT.TM.POS  = Y.POS<1,12>
	Y.IN.UNIQUE.ID.POS   = Y.POS<1,13>
	Y.IN.CHANNEL.ID.POS  = Y.POS<1,14>
	Y.IN.REVERSAL.ID.POS = Y.POS<1,15>
	Y.COM.CODE.POS	     = Y.POS<1,16>
	Y.COM.TYPE.POS		 = Y.POS<1,17>
	Y.CDTR.AGTID.POS	 = Y.POS<1,18>
	Y.SKN.RCV.TXN.POS	 = Y.POS<1,19>
	Y.SKN.TXN.CODE.POS	 = Y.POS<1,20>
	Y.SKN.RCV.TYPE.POS	 = Y.POS<1,21>
	Y.SKN.RCV.RESIDE.POS = Y.POS<1,22>
	Y.NATION.STATUS.POS	 = Y.POS<1,23>
	Y.SKN.RECEIV.BANK.POS= Y.POS<1,24>
	Y.SKN.RCV.ID.POS	 = Y.POS<1,25>
	Y.SKN.RCV.STREET.POS = Y.POS<1,26>
	Y.RTGS.BANK.G2.POS	 = Y.POS<1,27>
	Y.TXN.CODE.G2.POS	 = Y.POS<1,28>
	Y.TO.ACC.BRANCH.POS	 = Y.POS<1,29>
	Y.BEN.ADDR.POS		 = Y.POS<1,30>
	Y.BEN.NATIONALITY.POS= Y.POS<1,31>
	Y.BEN.CITY.CODE.POS	 = Y.POS<1,32>
	Y.BEN.CITY.NAME.POS	 = Y.POS<1,33>
	Y.TO.CITY.CODE.POS	 = Y.POS<1,34>
	Y.TO.CITY.NAME.POS	 = Y.POS<1,35>
	Y.COM.AMT.POS		 = Y.POS<1,36>
	Y.CHARGE.AMT.POS	 = Y.POS<1,37>
	posChargeAmt		 = Y.POS<1,38>
	
	Y.SKN.CLR.CODE.POS        = Y.POS<2,1>
	Y.SKN.BNK.TYPE.POS        = Y.POS<2,2>
	
	
	
	FN.EB.LOOKUP	= 'F.EB.LOOKUP'
	F.EB.LOOKUP		= ''
	CALL OPF(FN.EB.LOOKUP, F.EB.LOOKUP)
	
	FN.BANK = 'F.IDCH.RTGS.BANK.CODE.G2'
    F.BANK = ''
    CALL OPF(FN.BANK,F.BANK)
	
    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    CALL OPF(FN.COMPANY,F.COMPANY)
	
	FN.BTPNS.TH.BIFAST.RC.PARAM		= 'F.BTPNS.TH.BIFAST.RC.PARAM'
	F.BTPNS.TH.BIFAST.RC.PARAM		= ''
	CALL OPF(FN.BTPNS.TH.BIFAST.RC.PARAM, F.BTPNS.TH.BIFAST.RC.PARAM)
	
	FN.OVERRIDE	= 'F.OVERRIDE'
	F.OVERRIDE	= ''
	CALL OPF(FN.OVERRIDE, F.OVERRIDE)
	
	FN.BTPNS.TL.DEPO.KLIRING = 'F.BTPNS.TL.DEPO.KLIRING'
	F.BTPNS.TL.DEPO.KLIRING  = ''
	CALL OPF(FN.BTPNS.TL.DEPO.KLIRING, F.BTPNS.TL.DEPO.KLIRING)
	
	FN.FT.COMMISSION.TYPE	= 'F.FT.COMMISSION.TYPE'
	F.FT.COMMISSION.TYPE	= ''
	CALL OPF(FN.FT.COMMISSION.TYPE, F.FT.COMMISSION.TYPE)

    FN.DIS = "F.IDCH.DISTRICT"
    F.DIS = ""
    CALL OPF(FN.DIS,F.DIS)


RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.ATI.BEN.NAME      = R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.ATI.BEN.NAME.POS>
    Y.CNT2 = DCOUNT(Y.ATI.BEN.NAME,SM)
    CONVERT SM TO "" IN Y.ATI.BEN.NAME
    
    IF LEN(Y.ATI.BEN.NAME) GT 70 THEN
        AF = AA.Settlement.Settlement.SetLocalRef
        AV = Y.ATI.BEN.NAME.POS
        AS = Y.CNT2
        ETEXT<1> = "FT-REMARKS.SKN.G2"
        ETEXT<2> = "70"
        EB.ErrorProcessing.StoreEndError()
    END
    
    Y.SKN.RCV.STREET      = R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.RCV.STREET.POS>
    Y.CNT2 = DCOUNT(Y.SKN.RCV.STREET,SM)
    CONVERT SM TO "" IN Y.SKN.RCV.STREET
    
    IF LEN(Y.SKN.RCV.STREET) GT 140 THEN
        AF = AA.Settlement.Settlement.SetLocalRef
        AV = Y.SKN.RCV.STREET.POS
        AS = Y.CNT2
        ETEXT<1> = "FT-REMARKS.SKN.G2"
        ETEXT<2> = "140"
        EB.ErrorProcessing.StoreEndError()
    END
    
RETURN

*-----------------------------------------------------------------------------
DEFAULT.PAYOUT.ACC:
*-----------------------------------------------------------------------------
	
	Y.CDTR.ACCID 	= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.BEN.ACC.POS>
	Y.CNT2 			= DCOUNT(Y.CDTR.ACCID,SM)
	Y.MUD.CLEARED	= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.MUD.CLEARED.POS>
	Y.SKN.RTGS		= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.RTGS.POS>
	Y.SKN.TXN.CODE  = R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.TXN.CODE.POS>
	Y.ARR.ID		= c_aalocArrId

    IF Y.MUD.CLEARED EQ 'Y' AND Y.SKN.RTGS EQ '1' AND Y.SKN.TXN.CODE EQ '' THEN
	   R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.TXN.CODE.POS> = '50'
	END
	
*enhance transfer ke bank lain untuk skn rtgs
	CALL F.READ(FN.BTPNS.TL.DEPO.KLIRING, Y.ARR.ID, R.BTPNS.TL.DEPO.KLIRING, F.BTPNS.TL.DEPO.KLIRING, BTPNS.TL.DEPO.KLIRING.ERR)
	
	R.BTPNS.TL.DEPO.KLIRING<BtpnsTlDepoKliring_ProductLine> = 'DEPOSITS'
	R.BTPNS.TL.DEPO.KLIRING<BtpnsTlDepoKliring_TypeTransfer>= Y.SKN.RTGS
	R.BTPNS.TL.DEPO.KLIRING<BtpnsTlDepoKliring_IdCompany>	= ID.COMPANY
	
	CALL F.WRITE(FN.BTPNS.TL.DEPO.KLIRING, Y.ARR.ID, R.BTPNS.TL.DEPO.KLIRING)

	
	IF Y.MUD.CLEARED EQ 'Y' AND Y.SKN.RTGS EQ '3' THEN	
		Y.ACTIVITY.STATUS = c_arrActivityStatus
		Y.ARR.ID          = c_aalocArrId
	
		Y.COM.CODE		= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.COM.CODE.POS>
		IF Y.COM.CODE EQ '' THEN
			R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.COM.CODE.POS>	= 'DEBIT PLUS CHARGES'
		END
		Y.COM.TYPE		= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.COM.TYPE.POS>
		IF Y.CDTR.ACCID EQ '' THEN
			AF = AA.Settlement.Settlement.SetLocalRef
			AV = Y.BEN.ACC.POS
			ETEXT = "EB-DEPBIF.MANDATORY"
			EB.ErrorProcessing.StoreEndError()
		END
		
		Y.CDTR.AGTID	= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.CDTR.AGTID.POS>
		IF Y.CDTR.AGTID EQ '' THEN
			AF = AA.Settlement.Settlement.SetLocalRef
			AV = Y.CDTR.AGTID.POS
			ETEXT = "EB-DEPBIF.MANDATORY"
			EB.ErrorProcessing.StoreEndError()		
		END
		
		
		IF Y.COM.CODE EQ 'DEBIT PLUS CHARGES' AND Y.COM.TYPE EQ '' THEN
			AF = AA.Settlement.Settlement.SetLocalRef
			AV = Y.COM.TYPE.POS
			ETEXT = "EB-DEPBIF.MANDATORY"
			EB.ErrorProcessing.StoreEndError()
		END
		
		IF Y.COM.CODE EQ 'CREDIT LESS CHARGES' AND Y.COM.TYPE EQ '' THEN
			AF = AA.Settlement.Settlement.SetLocalRef
			AV = Y.COM.TYPE.POS
			ETEXT = "EB-DEPBIF.MANDATORY"
			EB.ErrorProcessing.StoreEndError()
		END

		IF Y.COM.CODE EQ 'WAIVE' AND Y.COM.TYPE NE '' THEN
			AF = AA.Settlement.Settlement.SetLocalRef
			AV = Y.COM.TYPE.POS
			ETEXT = "EB-DEPBIF.WAIVE"
			EB.ErrorProcessing.StoreEndError()
		END

		Y.CHARGE.AMT													= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.CHARGE.AMT.POS>
		Y.CHARGE.AMT.TRIM													=  FIELD(Y.CHARGE.AMT, "IDR", 2)
		IF Y.CHARGE.AMT.TRIM EQ '' THEN
			R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.CHARGE.AMT.POS> = Y.CHARGE.AMT
		END ELSE
			R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.CHARGE.AMT.POS> = Y.CHARGE.AMT.TRIM
		END

		vChargeAmt = R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,posChargeAmt>
		
		IF vChargeAmt EQ 'BYMATERAI' THEN
			IF Y.CHARGE.AMT EQ '' OR Y.CHARGE.AMT EQ 'IDR' THEN
				R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.CHARGE.AMT.POS> = 0
			END
		END ELSE
				R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.CHARGE.AMT.POS> = ""
		END
		
		CALL F.READ(FN.FT.COMMISSION.TYPE, Y.COM.TYPE, R.FT.COMMISSION.TYPE, F.FT.COMMISSION.TYPE, ERR.FT.COMMISSION.TYPE)
		Y.CHARGE.AMOUNT = R.FT.COMMISSION.TYPE<FtCommissionType_FlatAmt,1>
		R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.COM.AMT.POS,1>	= Y.CHARGE.AMOUNT
		
		
		CALL F.READ(FN.EB.LOOKUP, 'BIFAST.DEPOSITO*SYSTEM', R.EB.LOOKUP, F.EB.LOOKUP, EB.LOOKUP.ERR)
		Y.DATA.NAME	= R.EB.LOOKUP<EB.LU.DATA.NAME>
		FIND 'SUSPENSE.CATEG' IN Y.DATA.NAME SETTING Y.POSF, Y.POSV, Y.POSS THEN
			Y.DATA.VALUE	= R.EB.LOOKUP<EB.LU.DATA.VALUE, Y.POSV>
		END
		R.NEW(AA.Settlement.Settlement.SetPayoutAccount)					= "IDR" : Y.DATA.VALUE : "0001" : ID.COMPANY[6,4]
		R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.L.PFT.ACC.NUM.POS>	= "IDR" : Y.DATA.VALUE : "0001" : ID.COMPANY[6,4]
		
		GOSUB CLEAR.VALUE
		GOSUB OVERRIDE.CHARGE
		GOSUB BIFAST
	END
	
	RETURN

*-----------------------------------------------------------------------------
BIFAST:
*-----------------------------------------------------------------------------

	IF RUNNING.UNDER.BATCH EQ 1 THEN
		RETURN
	END

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

	IF Y.CDTR.AGTID = 'PUBAIDJ1' THEN
	   ETEXT = "EB-ACDB.SAME.INS"
	   CALL STORE.END.ERROR
	END
	CALL F.READ(FN.BANK,Y.CDTR.AGTID,R.RTGS.BANK.CODE,F.BANK,RTGSBCG2.ERR)
    Y.SKN.CLR.CODE 	= R.RTGS.BANK.CODE<RTGS.BANK.CODE.LOCAL.REF, Y.SKN.CLR.CODE.POS>
	Y.ID.BNK  		= Y.SKN.CLR.CODE[1,3]
	Y.BNK.TYPE 		= R.RTGS.BANK.CODE<RTGS.BANK.CODE.LOCAL.REF, Y.SKN.BNK.TYPE.POS>
	Y.CDTR.ACCTYPE	= 10
	Y.DBTR.ACCTYPE	= 10
	Y.CHNTYPE		= '6847'
	Y.CDTR.NM		= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.ATI.BEN.NAME.POS>
	Y.DBTR.NM		= "TEST"
	
	GOSUB DEFAULT.DBTR.ID
	Y.DBTR.ID		= Y.LEGAL.ID.NO
	
	Y.DB.ACCT		= Y.ACCOUNT.REFERENCE
	Y.AMOUNT 		= 100000
	Y.DATE.TIME		= Y.DATE.TIME
	Y.CO.CODE      = ID.COMPANY
	Y.AMOUNT       = FMT(Y.AMOUNT,"R2")

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
	Y.TRX.PAN       = Y.CCY.ID:'92547':Y.DB.ACCT:'0'
    Y.TRANSMIT.DT  = Y.MM:Y.DD:Y.TH:Y.TM:Y.TS
	Y.TRX.TIME     = Y.TH:Y.TM:Y.TS
	Y.TRX.DATE     = Y.MM:Y.DD
	Y.SETTLE.DATE  = Y.MM:Y.DD
	Y.MERCHANT.TYPE = Y.CHNTYPE
	Y.POS.ENTRY    = '011'
	Y.POS.COND     = '55'
	Y.ACQUIRER.ID  = '92547'
	Y.FORWARD.ID   = '360000'
    
	Y.TERMINAL.ID  = '00006010'
	Y.MERCHANT.ID  = FMT(Y.CO.CODE,"L#15")
	Y.MERCHANT.LOC = FMT(Y.DISTRICT.NAME,"L#33"):Y.DISTRICT.CODE:"IDN"

	Y.ISSUER.ID    = Y.ACQUIRER.ID
	Y.FROM.ACC     = Y.DB.ACCT
	Y.TO.ACC       = Y.CDTR.ACCID
	Y.TXN.INDICATOR = '2'
	Y.BENEF.ID     = '9':Y.BNK.TYPE:Y.ID.BNK
	Y.RESP.MSG = ''
    * -- Field additionalDataNational	
	Y.CDTR.PRXYTYPE	= R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.CDTR.PRXYTYPE.POS>
	IF Y.CDTR.PRXYTYPE EQ '' THEN
		Y.CDTR.PRXYTYPE = '0'
	END
	Y.CDTR.TYPE		= 1
	Y.DBTR.RESSTS	= '01'
	Y.CDTR.RESSTS	= '01'

	Y.DBTR.RESSTS    = Y.DBTR.RESSTS[2,1]
	Y.CDTR.RESSTS    = Y.CDTR.RESSTS[2,1]
	Y.TM             = 'TM10':Y.CDTR.PRXYTYPE:Y.CDTR.TYPE:'0':Y.DBTR.RESSTS:Y.CDTR.RESSTS
	
	Y.TM             = FMT(Y.TM,"L#14")
	Y.TC             = FMT('TC0400',"L#8")
	Y.PI             = 'PI05B0510'
	* Jika pakai KTP digit nya 16
	Y.DI             = 'DI16':FMT(Y.DBTR.ID,"L#16")
	Y.CI             = FMT('CI16',"L#20")

	Y.FRONT.DATNAS	 = Y.TM:Y.TC:Y.PI:Y.DI:Y.CI	
	
*	GOSUB DEFAULT.SEQNO
*RRN
	Y.MILLISECONDS = FIELD(Y.CURRENT.TIME,".",2)[1,2]
	Y.RRN = Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]:Y.MILLISECONDS

	Y.RETRIEVE.REF 	 = '0000':Y.RRN
	Y.RN			 = 'RN12':FMT(Y.RETRIEVE.REF,"L#12")
	Y.ADD.DATA.NAS	 = Y.FRONT.DATNAS : Y.RN
	
	Y.ADD.DATA.PRIVATE = FMT("","L#30"):FMT(Y.RETRIEVE.REF,"L#16"):FMT("","L#30")
	
	GOSUB CONSTRUCT.REQUEST
	RESP.ERR = ''
	Y.RESPONSE.CODE.RES = ''
	Y.RESPONSE.CODE.DESC = ''
	
	CALL BTPNSR.BIFAST.INTERFACE(Y.TYPE,Y.PARAM,RESP.POS,RESP.ERR)
	GOSUB CHECK.RESPONSE   


	RETURN

*-----------------------------------------------------------------------------
CONSTRUCT.REQUEST:
*-----------------------------------------------------------------------------

    Y.PARAM = ''
    XX = ':'
    ZZ = ','
    Y.TYPE = 'BInqTrfRQ'
	Y.OPEN   = '{'
    Y.CLOSE = '}'

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
	Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.FROM.ACC)
	Y.PARAM :=',"toAccount"':XX:DQUOTE(Y.TO.ACC)
	Y.PARAM :=',"transactionIndicator"':XX:DQUOTE(Y.TXN.INDICATOR)
*	Y.BENEF.ID	= 91014
	Y.PARAM :=',"beneficiaryID"':XX:DQUOTE(Y.BENEF.ID)
	Y.PARAM := Y.CLOSE
	
	CRT '[BFAST-REQ] - ':Y.TRX.PAN

	
	RETURN

*-----------------------------------------------------------------------------
CHECK.RESPONSE:
*-----------------------------------------------------------------------------
	
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
	  R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.ATI.JNAME.2.POS> = Y.CDTR.NAME.RES
	  
*case upcase nama BI
	  Y.ATI.BEN.NAME	= UPCASE(Y.ATI.BEN.NAME)
	  Y.CDTR.NAME.RES	= UPCASE(Y.CDTR.NAME.RES)

	  IF Y.ATI.BEN.NAME NE Y.CDTR.NAME.RES THEN
		TEXT = "FT-BIFAST.CDTR.NM.DIFFERENCE"
		NO.OF.OVERR = DCOUNT(R.NEW(V-9),VM)+1
		CALL STORE.OVERRIDE(NO.OF.OVERR) 
	  END

   END ELSE
      IF Y.RESPONSE.CODE.RES EQ '' THEN
	     IF RESP.ERR NE '' THEN
			AF = AA.Settlement.Settlement.SetLocalRef
			AV = Y.BEN.ACC.POS
			ETEXT = RESP.ERR
			EB.ErrorProcessing.StoreEndError()
		 END ELSE
			AF = AA.Settlement.Settlement.SetLocalRef
			AV = Y.BEN.ACC.POS
			ETEXT = "Response Code : null"
			EB.ErrorProcessing.StoreEndError()
	     END
      END ELSE
		 GOSUB RCCODE.FORMAT 
         
		 AF = AA.Settlement.Settlement.SetLocalRef
		 AV = Y.BEN.ACC.POS
		 ETEXT = "Response Code : ":Y.RESPONSE.CODE.RES:" - ":Y.RESPONSE.CODE.DESC
		 EB.ErrorProcessing.StoreEndError()
	  END
   END

	
	RETURN

*-----------------------------------------------------------------------------
RCCODE.FORMAT:
*-----------------------------------------------------------------------------

    ERR = Y.RESPONSE.CODE.RES
	
	CALL F.READ(FN.BTPNS.TH.BIFAST.RC.PARAM, ERR, R.BTPNS.TH.BIFAST.RC.PARAM, F.BTPNS.TH.BIFAST.RC.PARAM, BTPNS.TH.BIFAST.RC.PARAM.ERR)
		Y.RESPONSE.CODE.DESC	= R.BTPNS.TH.BIFAST.RC.PARAM<BF.RC.PARAM.DESCRIPTION>
	
	
	RETURN

*-----------------------------------------------------------------------------
DEFAULT.SEQNO:
*-----------------------------------------------------------------------------

    FN.LOCK = "F.LOCKING"
	F.LOCK  = ""
	CALL OPF(FN.LOCK, F.LOCK)
	
	FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
	F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
	CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)
	
    Y.LOCK.ID = 'BIFAST.OUTCR'
    CALL F.READ(FN.LOCK, Y.LOCK.ID, R.LOCK, F.LOCK, ERR2)

    IF R.LOCK EQ '' THEN
        Y.SEQ.NO = TODAY : '00000001'
    END ELSE
        GOSUB BATCH.SEQ
    END

    R.LOCK<1> = Y.SEQ.NO
    WRITE R.LOCK TO F.LOCK, Y.LOCK.ID
	
	Y.B.SEQNO	= Y.SEQ.NO[8]
	
	X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
	
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
	Y.TM = Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]

	Y.STAN.1 = RND(100)
    IF LEN(Y.STAN.1) EQ 1 THEN
        Y.STAN.1 = Y.STAN.1:RND(10)
    END
    Y.STAN.2 = RND(100)
    IF LEN(Y.STAN.2) EQ 1 THEN
        Y.STAN.2 = Y.STAN.2:RND(10)
    END
    Y.STAN.3 = RND(100)
    IF LEN(Y.STAN.3) EQ 1 THEN
        Y.STAN.3 = Y.STAN.3:RND(10)
    END
    Y.STAN = Y.STAN.1:Y.STAN.2:Y.STAN.3
	
	Y.RND = RND(100)
    IF LEN(Y.RND) EQ 1 THEN
        Y.RND = Y.RND:RND(10)
    END
	Y.CHANNEL = "6010"    ;*TELLER
	
	CALL F.READ(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, "SYSTEM",R.BTPNS.INT.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,READ.PAR.ERR)
	Y.ID.TC = R.BTPNS.INT.PARAM<BF.INT.PAR.ID.TC>
	
	*R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.IN.STAN.POS>		= Y.STAN
	*R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.IN.TRNS.DT.TM.POS>	= DT
	*R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.IN.CHANNEL.ID.POS>	= Y.CHANNEL
	*R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.IN.UNIQUE.ID.POS>	= Y.ID.TC
	*R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.IN.REVERSAL.ID.POS>	= "BI.":DT[1,6]:".":"0000":Y.RND:Y.STAN

	Y.INSTAN			= Y.STAN
	*Y.IN.REVERSAL.ID	= "BI.":DT[1,6]:".":"0000":Y.RND:Y.STAN
	Y.IN.REVERSAL.ID	= "0000":Y.RND:Y.STAN
   
	RETURN

*-----------------------------------------------------------------------------
BATCH.SEQ:
*-----------------------------------------------------------------------------

    Y.CUR.SEQ.NO = R.LOCK<1>
    Y.SEQ.NO.TGL = SUBSTRINGS(Y.CUR.SEQ.NO,1,8)
    Y.CUR.TGL = TODAY

    IF Y.SEQ.NO.TGL NE Y.CUR.TGL THEN
        Y.SEQ.NO = Y.CUR.TGL : '00001'
    END ELSE
        Y.SEQ.NO = R.LOCK<1>+1
    END	
     

	RETURN

*-----------------------------------------------------------------------------
DEFAULT.DBTR.ID:
*-----------------------------------------------------------------------------

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER  = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
     
	Y.APP       = "CUSTOMER" 
    Y.FLD.NAME = "CUST.TYPE" :VM: "RESIDE.Y.N" :VM: "LEGAL.ID.NO"
	
    Y.CUST.TYPE.POS            = Y.POS<1,1>
    Y.RESIDE.Y.N.POS           = Y.POS<1,2>
    Y.LEGAL.ID.NOE.POS         = Y.POS<1,3>	
	
	Y.CUSTOMER	= R.NEW(AaArrangementActivity_Customer)
	CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUS,F.CUSTOMER,CUS.ERR)
    Y.LEGAL.ID.NO   = R.CUS<EB.CUS.LOCAL.REF><1,Y.LEGAL.ID.NOE.POS>	
	
	Y.ARRANGEMENT.ID = c_aalocArrId
	CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARRANGEMENT.ID, "", "ACCOUNT", Y.EFFECTIVE.DATE, Y.PROPERTY.IDS, Y.PROPERTY.CONDITIONS, READ.ERR)
    Y.ARRANGEMENT.RULES.COND = RAISE(Y.PROPERTY.CONDITIONS)
	
	Y.ACCOUNT.REFERENCE 	= Y.ARRANGEMENT.RULES.COND<AA.AC.ACCOUNT.REFERENCE, 1>

	RETURN

*-----------------------------------------------------------------------------
CLEAR.VALUE:
*-----------------------------------------------------------------------------

	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.RCV.TXN.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.TXN.CODE.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.RCV.TYPE.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.RCV.RESIDE.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.NATION.STATUS.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.RECEIV.BANK.POS>= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.RCV.ID.POS>		= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.SKN.RCV.STREET.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.RTGS.BANK.G2.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.TXN.CODE.G2.POS	>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.TO.ACC.BRANCH.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.BEN.ADDR.POS>		= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.BEN.NATIONALITY.POS>= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.BEN.CITY.CODE.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.BEN.CITY.NAME.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.TO.CITY.CODE.POS>	= ''
	R.NEW(AA.Settlement.Settlement.SetLocalRef)<1,Y.TO.CITY.NAME.POS>	= ''
	

	RETURN

*-----------------------------------------------------------------------------
OVERRIDE.CHARGE:
*-----------------------------------------------------------------------------
	
	FIND 'BYMATERAI' IN Y.COM.TYPE SETTING Y.POSF, Y.POSV, Y.POSS THEN
		Y.COM.AMT	= R.NEW.LAST(AA.Settlement.Settlement.SetLocalRef)<1,Y.COM.AMT.POS><1, 1, Y.POSS>	
		
		CALL F.READ(FN.OVERRIDE, 'FT-CHARGE.MATERAI', R.OVERRIDE, F.OVERRIDE, OVERRIDE.ERR)
		Y.MESSAGE	= R.OVERRIDE<Override_Message>
		
		IF Y.COM.AMT NE '' THEN
			TEXT  	= Y.MESSAGE : Y.COM.AMT
			NO.OF.OVERR = DCOUNT(R.NEW(V-9),VM)+1
			CALL STORE.OVERRIDE(NO.OF.OVERR)		
		END
	END

	RETURN

*-----------------------------------------------------------------------------
END