*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.ENR.BIFAST.STO.DEPO(Y.OUTPUT)
*-----------------------------------------------------------------------------
* Developer Name : 20220914
* Description    : Nofile routine for authorize ft auth from bifast sto depo
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Developer Name     :
* Development Date   :  
* Description        : 
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
	$INSERT I_F.BTPNS.TH.BIFAST.STO.DEPO
	$INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.IDCH.RTGS.BANK.CODE.G2
	$INSERT I_F.COMPANY
	$INSERT I_F.IDIH.PMS.CALC.PARAMETER
	$INCLUDE I_F.AA.SETTLEMENT
	$INCLUDE I_F.AA.TERM.AMOUNT
	$INCLUDE I_F.AA.ARRANGEMENT
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB INIT
    GOSUB PUT.DATA

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	FN.BTPNS.TH.BIFAST.STO.DEPO	= 'F.BTPNS.TH.BIFAST.STO.DEPO'
	F.BTPNS.TH.BIFAST.STO.DEPO	= ''
	CALL OPF(FN.BTPNS.TH.BIFAST.STO.DEPO, F.BTPNS.TH.BIFAST.STO.DEPO)
	
    FN.FUNDS.TRANSFER.NAU = "F.FUNDS.TRANSFER$NAU"
    F.FUNDS.TRANSFER.NAU  = ""
    CALL OPF(FN.FUNDS.TRANSFER.NAU, F.FUNDS.TRANSFER.NAU)
	
	FN.IDCH.RTGS.BANK.CODE.G2	= "F.IDCH.RTGS.BANK.CODE.G2"
	F.IDCH.RTGS.BANK.CODE.G2	= ""
	CALL OPF(FN.IDCH.RTGS.BANK.CODE.G2, F.IDCH.RTGS.BANK.CODE.G2)
	
	FN.COMPANY				= "F.COMPANY"
	F.COMPANY				= ""
	CALL OPF(FN.COMPANY, F.COMPANY)
	
	FN.IDIH.PMS.CALC.PARAMETER	= 'F.IDIH.PMS.CALC.PARAMETER'
	F.IDIH.PMS.CALC.PARAMETER	= ''
	CALL OPF(FN.IDIH.PMS.CALC.PARAMETER, F.IDIH.PMS.CALC.PARAMETER)

	fnAaArrSettlement = "F.AA.ARR.SETTLEMENT"
	fvAaArrSettlement = ""
	CALL OPF(fnAaArrSettlement, fvAaArrSettlement)
	
	fnAaArrangement	 = "F.AA.ARRANGEMENT"
	fvAaArrangement	 = ""
	CALL OPF(fnAaArrangement, fvAaArrangement)

    Y.APP 		= "FUNDS.TRANSFER"
    Y.FIELDS  	= "B.CDTR.AGTID" : @VM : "B.CDTR.ACCID" : @VM: "ATI.JNAME.2" :@VM: "PAYMENT.DETAIL" :@VM: "ATI.TXN.FLAG" :@VM: "B.CHARGE.TYPE" :@VM: "B.CHARGE.AMT"
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FIELDS,Y.POS)

	Y.B.CDTR.AGTID.POS		= Y.POS<1,1>
	Y.B.CDTR.ACCID.POS		= Y.POS<1,2>
	Y.ATI.JNAME.2.POS		= Y.POS<1,3>
	fPaymentDetailPos 		= Y.POS<1,4>
	fAtiTxnFlagPos			= Y.POS<1,5>
	otherChargeTypePos		= Y.POS<1,6>
	otherChargeAmtPos		= Y.POS<1,7>

	Y.FIELDS	= ""
	Y.POS		= ""
    Y.APP 		= "AA.PRD.DES.SETTLEMENT"
    Y.FIELDS  	= "L.CHARGE"
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FIELDS,Y.POS)	
	fChargePenPos	= Y.POS<1,1>	

	fnAaArrTermAmount = "F.AA.ARR.TERM.AMOUNT"
	fvAaArrTermAmount = ""
	CALL OPF(fnAaArrTermAmount, fvAaArrTermAmount)
	Y.FIELDS	= ""
	Y.POS		= ""
	arrApp<1> = "AA.ARR.TERM.AMOUNT"
	arrFld<1,1> = "L.MAT.MODE"
	arrPos		= ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	fMatModePos	= arrPos<1,1>

    Y.INPUT = ENQ.SELECTION<2>
	
	*SEL.1 ------------------------------------------------------
    FIND "ARRANGEMENT" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
		Y.OPR.ARRANGEMENT.ID = ENQ.SELECTION<3,Y.POSV>
        Y.SEL.ARRANGEMENT.ID = ENQ.SELECTION<4,Y.POSV>
	END
	
	FIND "DATE.TIME" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
		Y.OPR.DATE.TIME = ENQ.SELECTION<3,Y.POSV>
        Y.SEL.DATE.TIME = ENQ.SELECTION<4,Y.POSV>
	END

	FIND "FT.REFERENCE" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
		Y.OPR.FT.REFERENCE	= ENQ.SELECTION<3,Y.POSV>
		Y.SEL.FT.REFERENCE	= ENQ.SELECTION<4,Y.POSV>
	END
	
	RETURN	
	
*-----------------------------------------------------------------------------
PUT.DATA:
*-----------------------------------------------------------------------------
	
	IF Y.SEL.ARRANGEMENT.ID NE "" THEN
		SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.STO.DEPO:" WITH ARRANGEMENT LIKE " : Y.SEL.ARRANGEMENT.ID : "... AND STATUS EQ PROCESS AND CO.CODE EQ " : ID.COMPANY
	*END ELSE
	*	SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.STO.DEPO:" WITH STATUS EQ PROCESS AND CO.CODE EQ " : ID.COMPANY
	END

	IF Y.SEL.FT.REFERENCE NE '' THEN
		SEL.CMD	= ''
		SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.STO.DEPO:" WITH FT.REFERENCE " :Y.OPR.FT.REFERENCE: " " : Y.SEL.FT.REFERENCE: " AND STATUS EQ PROCESS AND CO.CODE EQ " : ID.COMPANY
	*END ELSE
	*	SEL.CMD	= ''
	*	SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.STO.DEPO:" WITH STATUS EQ PROCESS AND CO.CODE EQ " : ID.COMPANY
	END

	IF Y.SEL.ARRANGEMENT.ID NE '' AND Y.SEL.FT.REFERENCE NE '' THEN
		SEL.CMD	= ''
		SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.STO.DEPO:" WITH ARRANGEMENT LIKE " : Y.SEL.ARRANGEMENT.ID : " AND FT.REFERENCE " : Y.OPR.FT.REFERENCE : " " : Y.SEL.FT.REFERENCE : " AND STATUS EQ PROCESS AND CO.CODE EQ " : ID.COMPANY
	*END ELSE
	*	SEL.CMD	= ''
	*	SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.STO.DEPO:" WITH STATUS EQ PROCESS AND CO.CODE EQ " : ID.COMPANY
	END

	IF SEL.CMD EQ '' THEN
		SEL.CMD	= ''
		SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.STO.DEPO:" WITH STATUS EQ PROCESS AND CO.CODE EQ " : ID.COMPANY
	END

	GOSUB PROCESS

	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	IF Y.SEL.ARRANGEMENT.ID NE '' OR Y.SEL.FT.REFERENCE NE '' THEN
		SEL.CMD := " BY-DSND DATE"
	END ELSE
		IF Y.SEL.DATE.TIME EQ '' THEN
			SEL.CMD := " AND DATE EQ " : TODAY : " BY-DSND DATE"
		END ELSE
			IF Y.OPR.DATE.TIME EQ 'RG' THEN
				fTime	= FIELD(Y.SEL.DATE.TIME, @SM, 1)
				bTime	= FIELD(Y.SEL.DATE.TIME, @SM, 2)
				IF fTime EQ '' OR bTime EQ '' THEN
					SEL.CMD = ""
				END ELSE
					SEL.CMD := " AND DATE GE " : fTime : " AND DATE LE " : bTime : " BY-DSND DATE"
				END
			END ELSE
				SEL.CMD := " AND DATE " : Y.OPR.DATE.TIME : " " : Y.SEL.DATE.TIME : " BY-DSND DATE"
			END
		END
	END
    SEL.LIST =''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.REC,ERR.MM)
	
    FOR I = 1 TO NO.REC
		Y.ID.STO.DEPO				= SEL.LIST<I>


		Y.ARRANGEMENT.ID			= FIELD(SEL.LIST<I>, ".", 1)
		Y.FT.ID						= FIELD(SEL.LIST<I>, ".", 3)
		
		CALL F.READ(FN.BTPNS.TH.BIFAST.STO.DEPO, Y.ID.STO.DEPO, R.BTPNS.TH.BIFAST.STO.DEPO, F.BTPNS.TH.BIFAST.STO.DEPO, ERR.BTPNS.TH.BIFAST.STO.DEPO)				
		Y.ARRANGEMENT		= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_Arrangement>
		Y.DATE				= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_Date>
		Y.DIST.ENTRY		= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_DistEntry>
		Y.DIST.REFERENCE	= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_DistReference>
		Y.DIST.PMA			= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_DistPma>
		Y.DIST.AMT			= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_DistAmount>
		
		Y.DIST.AMT.CNT		= DCOUNT(Y.DIST.AMT, @VM)
		Y.DIST.AMOUNT		= Y.DIST.AMT<1, Y.DIST.AMT.CNT>
		
		
		Y.DIST.ACCOUNT		= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_DistAccount>
		Y.AMOUNT.TYPE		= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_AmountType>
		Y.FT.REFERENCE		= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_FtReference>
		Y.CO.CODE			= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_CoCode>
		chargeAmt			= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesAmt>
		
		CALL F.READ(FN.IDIH.PMS.CALC.PARAMETER, "SYSTEM", R.IDIH.PMS.CALC.PARAMETER, F.IDIH.PMS.CALC.PARAMETER, IDIH.PMS.CALC.PARAMETER.ERR)
		Y.PERCENTAX	= R.IDIH.PMS.CALC.PARAMETER<IdihPmsCalcParameter_TaxRate>

		idProperty = "SETTLEMENT"
		idLinkRef = ""
		CALL AA.PROPERTY.REF(Y.ARRANGEMENT.ID, idProperty, idLinkRef)	
		IF idLinkRef THEN CALL F.READ(fnAaArrSettlement, idLinkRef, rvAaArrSettlement, fvAaArrSettlement, "")
		chargePenalty	= rvAaArrSettlement<AaSimSettlement_LocalRef,fChargePenPos>	
		
		IF Y.AMOUNT.TYPE EQ 'PRINCIPAL' THEN
			IF Y.DIST.AMT.CNT EQ 1 THEN
				Y.DIST.AMOUNT = Y.DIST.AMOUNT - chargePenalty - chargeAmt
			END ELSE
				Y.DIST.AMOUNT = Y.DIST.AMOUNT
			END
		END ELSE
			IF Y.DIST.AMT.CNT EQ 1 THEN
				Y.DIST.AMOUNT = DROUND((Y.DIST.AMOUNT * ((100 - Y.PERCENTAX)/100)),0) - chargeAmt
			END ELSE
				Y.DIST.AMOUNT = Y.DIST.AMOUNT
			END
		END
	
		CALL F.READ(FN.COMPANY, Y.CO.CODE, R.COMPANY, F.COMPANY, ERR.COMPANY)
		Y.CO.NAME			= R.COMPANY<Company_CompanyName>
		
		CALL F.READ(FN.FUNDS.TRANSFER.NAU, Y.FT.ID, R.FUNDS.TRANSFER.NAU, F.FUNDS.TRANSFER.NAU, ERR.FUNDS.TRANSFER.NAU)
		Y.B.CDTR.AGTID		= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.B.CDTR.AGTID.POS>
		Y.B.CDTR.ACCID		= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.B.CDTR.ACCID.POS>
		Y.ATI.JNAME.2		= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.ATI.JNAME.2.POS>
		Y.COMMISION.TYPE	= R.FUNDS.TRANSFER.NAU<FundsTransfer_CommissionType>
		Y.COMMISSION.AMT	= R.FUNDS.TRANSFER.NAU<FundsTransfer_CommissionAmt>
		Y.PAYMENT.DETAILS	= R.FUNDS.TRANSFER.NAU<FundsTransfer_PaymentDetails>
		Y.DATE.TIME			= R.FUNDS.TRANSFER.NAU<FundsTransfer_DateTime>
		paymentDetail 		= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, fPaymentDetailPos>
		atiTxnFlag			= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, fAtiTxnFlagPos>
		vOtherChargeType	= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, otherChargeTypePos>
		vOtherChargeAmt		= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, otherChargeAmtPos>


		IF atiTxnFlag NE '' THEN CONTINUE
		
		CALL F.READ(FN.IDCH.RTGS.BANK.CODE.G2, Y.B.CDTR.AGTID, R.IDCH.RTGS.BANK.CODE.G2, F.IDCH.RTGS.BANK.CODE.G2, ERR.IDCH.RTGS.BANK.CODE.G2)
		Y.BANK.NAME = R.IDCH.RTGS.BANK.CODE.G2<IdchRtgsBankCodeG2_BankName>

		CALL F.READ(fnAaArrangement, Y.ARRANGEMENT.ID, rvAaArrangement, fvAaArrangement, '')
		arrStatus	= rvAaArrangement<AaArrangement_ArrStatus>
		
		IF Y.BANK.NAME NE '' THEN
			idProperty = 'COMMITMENT'
			idLinkRef = ""
			CALL AA.PROPERTY.REF(Y.ARRANGEMENT.ID, idProperty, idLinkRef)
    		CALL F.READ(fnAaArrTermAmount, idLinkRef, rvAaArrTermAmount, fvAaArrTermAmount,'')
			matMode	= rvAaArrTermAmount<AaSimTermAmount_LocalRef,fMatModePos>

			IF matMode EQ 'PRINCIPAL + PROFIT ROLLOVER' THEN
				IF arrStatus EQ 'PENDING.CLOSURE' OR arrStatus EQ 'CLOSE' THEN
					GOSUB WriteOutput
				END
			END ELSE
				GOSUB WriteOutput
			END
		END
			
    NEXT I	
	
    RETURN
*-----------------------------------------------------------------------------
WriteOutput:
*-----------------------------------------------------------------------------
	
	Y.OUT.TEMP	= SEL.LIST<I>
	Y.OUT.TEMP := "|" : Y.ARRANGEMENT		
	Y.OUT.TEMP := "|" : Y.FT.ID	
	Y.OUT.TEMP := "|" : Y.DATE
	Y.OUT.TEMP := "|" : Y.DIST.ENTRY
	Y.OUT.TEMP := "|" : Y.DIST.REFERENCE
	Y.OUT.TEMP := "|" : Y.DIST.PMA
	Y.OUT.TEMP := "|" : Y.DIST.AMOUNT
	Y.OUT.TEMP := "|" : Y.DIST.ACCOUNT
	Y.OUT.TEMP := "|" : Y.AMOUNT.TYPE
	Y.OUT.TEMP := "|" : Y.FT.REFERENCE
	Y.OUT.TEMP := "|" : Y.B.CDTR.AGTID
	Y.OUT.TEMP := "|" : Y.BANK.NAME
	Y.OUT.TEMP := "|" : Y.B.CDTR.ACCID
	Y.OUT.TEMP := "|" : Y.ATI.JNAME.2
	Y.OUT.TEMP := "|" : Y.COMMISION.TYPE
	Y.OUT.TEMP := "|" : Y.COMMISSION.AMT
	Y.OUT.TEMP := "|" : Y.PAYMENT.DETAILS
	Y.OUT.TEMP := "|" : Y.CO.CODE
	Y.OUT.TEMP := "|" : Y.CO.NAME
	Y.OUT.TEMP := "|" : Y.DATE.TIME
	Y.OUT.TEMP := "|" : vOtherChargeType
	Y.OUT.TEMP := "|" : vOtherChargeAmt
	Y.OUTPUT<-1> = Y.OUT.TEMP

    RETURN

*-----------------------------------------------------------------------------
END