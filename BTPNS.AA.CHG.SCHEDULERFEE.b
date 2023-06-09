*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.AA.CHG.SCHEDULERFEE(Y.CHARGE.PROPERTY, Y.R.CHARGE.RECORD, Y.BASE.AMOUNT, Y.CHARGE)
*-----------------------------------------------------------------------------
* Author	: BTPNS - Alamsyah Rizki Isroi
* Usage		: Charge routine by average balance of number of days in a month from date 1 in current month (MTD balance by no of days month)
* Date		: 20220321
* Reference	: https://jira.twprisma.com/browse/CBA-33
*-----------------------------------------------------------------------------------
* Modification History:
* YYYYMMDD - Name - Reference
*-----------------------------------------------------------------------------------	
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.CHARGE
	$INSERT I_F.AA.ARRANGEMENT

    GOSUB Initialise
    GOSUB Process

    RETURN

*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------
	
	fnAaArrangement		= "F.AA.ARRANGEMENT"
	fvAaArrangement		= ""
	CALL OPF(fnAaArrangement, fvAaArrangement)
	
    RETURN

*-----------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------

	vAmountFee = 0 ; Y.CHARGE = 0
	
	idArrangement 		= Y.R.CHARGE.RECORD<AA.CHG.ID.COMP.1>
	idChargeProperty		= Y.R.CHARGE.RECORD<AA.CHG.ID.COMP.2>
	
	rvAaArrangement = "" ; errAaArrangement = ""
	CALL F.READ(fnAaArrangement, idArrangement, rvAaArrangement, fvAaArrangement, errAaArrangement)
	idAccount		= rvAaArrangement<AaArrangement_LinkedApplId,1>
	vToDate 		= TODAY
	
	vAvgBal = "" ; vErrMsg = ""
	CALL BTPNSR.GET.AVG.BAL.MTD(idAccount, vToDate, vAvgBal, vErrMsg)
* if balance greater than zero, then customer has no loan amount
	IF vAvgBal GT 0 THEN RETURN
	vAvgBal = ABS(vAvgBal)
	
	IF NOT(vErrMsg) THEN
		FOR idx=1 TO DCOUNT(Y.R.CHARGE.RECORD<AaSimCharge_TierAmount>, @VM)
			IF vAvgBal LE Y.R.CHARGE.RECORD<AaSimCharge_TierAmount,idx> THEN
				vAmountFee = Y.R.CHARGE.RECORD<AaSimCharge_ChgAmount,idx>
				BREAK
			END
		NEXT idx
	END ELSE
		CRT "Error Calculate charge ":idAccount:"-":idArrangement:":":vErrMsg
	END
	
*	Y.CHARGE	= vAmountFee
	Y.CHARGE	= 0
	
    RETURN
*-----------------------------------------------------------------------------
END
