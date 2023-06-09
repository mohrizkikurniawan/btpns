	SUBROUTINE BTPNS.VAU.BLANK.STO.DEPO
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 12 September 2022
* Description        : default blank Charges Acct No
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : 
* Modified by        : 
* Description        : 
*-----------------------------------------------------------------------------

	$INSERT I_COMMON
	$INSERT I_EQUATE
	$INSERT I_BATCH.FILES
	$INSERT I_TSA.COMMON
	$INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.BTPNS.TH.BIFAST.STO.DEPO
	$INSERT I_F.FT.COMMISSION.TYPE

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	IF V$FUNCTION EQ 'A' THEN
		RETURN
	END ELSE
		GOSUB INIT
		GOSUB PROCESS
	END	
	
	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	FN.BTPNS.TH.BIFAST.STO.DEPO	= 'F.BTPNS.TH.BIFAST.STO.DEPO'
	F.BTPNS.TH.BIFAST.STO.DEPO	= ''
	CALL OPF(FN.BTPNS.TH.BIFAST.STO.DEPO, F.BTPNS.TH.BIFAST.STO.DEPO)

	fnFtCommissionType			= 'F.FT.COMMISSION.TYPE'
	fvFtCommissionType			= ''
	CALL OPF(fnFtCommissionType, fvFtCommissionType)

	arrApp<1> = "FUNDS.TRANSFER"

	arrFld<1,1> = "B.CHARGE.TYPE"
	arrFld<1,2> = "B.CHARGE.AMT"

	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	otherChargeTypePos 	= arrPos<1,1>
	otherChargeAmtPos 	= arrPos<1,2>

	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	Y.AA.ID		= R.NEW(FundsTransfer_DebitTheirRef)
	Y.DATE		= R.NEW(FundsTransfer_DebitValueDate)
	Y.ID.STODEPO= Y.AA.ID : "." : Y.DATE : "." : ID.NEW
	
	CALL F.READ(FN.BTPNS.TH.BIFAST.STO.DEPO, Y.ID.STODEPO, R.BTPNS.TH.BIFAST.STO.DEPO, F.BTPNS.TH.BIFAST.STO.DEPO, BTPNS.TH.BIFAST.STO.DEPO.ERR)
	IF R.BTPNS.TH.BIFAST.STO.DEPO NE '' THEN
		GOSUB UpdateTableSto
	END

	RETURN
*-----------------------------------------------------------------------------
UpdateTableSto:
*-----------------------------------------------------------------------------
	
	vChargesType = R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesType>
	vChargesTypeCnt	= DCOUNT(vChargesType, @VM)


	FOR loopJ = 2 TO vChargesTypeCnt
*		test 	= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesType, 2>
		DEL R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesType, loopJ>
	NEXT loopJ

	R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesType> = ""
	
	chargeBefore = R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesAmt>

	chargeType = R.NEW(FundsTransfer_CommissionType)
	chargeAmt = R.NEW(FundsTransfer_CommissionAmt)
	chargeTotalCnt = DCOUNT(chargeAmt, @VM)

	chargeTotal = 0
	FOR I = 1 TO chargeTotalCnt
		CALL F.READ(fnFtCommissionType, chargeType<1, I>, rvFtCommissionType, fvFtCommissionType, "")
		vFlatAmt	= rvFtCommissionType<FtCommissionType_FlatAmt>
		vFlatAmt    = vFlatAmt<1, 1>
		IF vFlatAmt NE '' AND vFlatAmt NE '0' THEN
			chargeTotal	= vFlatAmt + chargeTotal
		END ELSE
			chargeTotal	= FIELD(chargeAmt<1, I>, "IDR", 2) + chargeTotal
		END	
		R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesType, -1> = chargeType<1, I>
	NEXT Y.I
	
	vOtherChargeType	= R.NEW(FundsTransfer_LocalRef)<1, otherChargeTypePos>
	vOtherChargeAmt		= R.NEW(FundsTransfer_LocalRef)<1, otherChargeAmtPos>
	IF vOtherChargeType NE '' THEN
		FINDSTR 'IDR' IN vOtherChargeAmt SETTING vPosV, vPosF, vPosS THEN
		END ELSE
			IF vOtherChargeAmt NE '' THEN
				vOtherChargeAmt = "IDR" : vOtherChargeAmt
			END ELSE
				vOtherChargeAmt = "IDR0"
			END
		END
	END ELSE
		R.NEW(FundsTransfer_LocalRef)<1, otherChargeTypePos>	= ''
		R.NEW(FundsTransfer_LocalRef)<1, otherChargeAmtPos>		= ''
	END

	IF vOtherChargeType EQ '' THEN
		vOtherChargeAmt = ""	
	END

	CALL F.READ(fnFtCommissionType, vOtherChargeType, rvFtCommissionType, fvFtCommissionType, "")
	vFlatAmtOther	= rvFtCommissionType<FtCommissionType_FlatAmt>
	vFlatAmtOther	= vFlatAmtOther<1, 1>
	IF vFlatAmtOther NE '' AND vFlatAmtOther NE '0' THEN
		chargeTotal	= vFlatAmtOther + chargeTotal
	END ELSE
		chargeTotal = FIELD(vOtherChargeAmt, "IDR", 2) + chargeTotal
	END
	R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesType, -1> = vOtherChargeType

	amountNew	= R.NEW.LAST(FundsTransfer_DebitAmount) + (chargeBefore - chargeTotal)

	R.NEW(FundsTransfer_DebitAmount) = amountNew
	R.NEW(FundsTransfer_LocAmtDebited)  = amountNew
	R.NEW(FundsTransfer_LocAmtCredited) = amountNew
	R.NEW(FundsTransfer_AmountDebited)  = "IDR" : amountNew
	R.NEW(FundsTransfer_AmountCredited) = "IDR" : amountNew
	R.NEW(FundsTransfer_LocalRef)<1, otherChargeAmtPos> = vOtherChargeAmt

	R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_Status> = "PROCESS"
	R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ErrorMessage> = ""
	R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ChargesAmt> = chargeTotal
	R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_DistAmount, -1> = amountNew
	R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_ComCode>	= R.NEW(FundsTransfer_CommissionCode)
	CALL F.WRITE(FN.BTPNS.TH.BIFAST.STO.DEPO,Y.ID.STODEPO,R.BTPNS.TH.BIFAST.STO.DEPO)
	

	RETURN
*-----------------------------------------------------------------------------
END




