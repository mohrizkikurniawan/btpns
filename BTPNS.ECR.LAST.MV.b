*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.ECR.LAST.MV
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20220808
* Description        : Conversion routine for get last multivalue
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
*-----------------------------------------------------------------------------
	$INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
	$INSERT I_F.BTPNS.TH.BIFAST.STO.DEPO
	$INCLUDE I_F.FUNDS.TRANSFER

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB INIT
	GOSUB PROCESS
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	fnBtpnsThBifastStoDepo	= "F.BTPNS.TH.BIFAST.STO.DEPO"
	fvBtpnsThBifastStoDepo  = ""
	CALL OPF(fnBtpnsThBifastStoDepo, fvBtpnsThBifastStoDepo)

	fnFundsTransfer     = "F.FUNDS.TRANSFER"
    fvFundsTransfer     = ""
    CALL OPF(fnFundsTransfer, fvFundsTransfer)

    fnFundsTransferHis  = "F.FUNDS.TRANSFER$HIS"
    fvFundsTransferHis  = ""
    CALL OPF(fnFundsTransferHis, fvFundsTransferHis)

	RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	CALL F.READ(fnBtpnsThBifastStoDepo, O.DATA, rvBtpnsThBifastStoDepo, fvBtpnsThBifastStoDepo, "")
	vDistAmount	= rvBtpnsThBifastStoDepo<BtpnsThBifastStoDepo_DistAmount>
	cntDistAmount = DCOUNT(vDistAmount, @VM)

	IF cntDistAmount EQ 1 THEN
		idFt	= FIELD(O.DATA, ".", 3)
		CALL F.READ(fnFundsTransfer, idFt, rvFundsTransfer, fvFundsTransfer, '')  
    	IF rvFundsTransfer EQ '' THEN
    	    CALL F.READ.HISTORY(fnFundsTransferHis, idFt, rvFundsTransferHis, fvFundsTransferHis, '')
    	    O.DATA  = rvFundsTransferHis<FundsTransfer_DebitAmount>
    	END ELSE
			O.DATA  = rvFundsTransfer<FundsTransfer_DebitAmount>
    	END  
	END ELSE
		O.DATA	= vDistAmount<1, cntDistAmount>
	END
 
	
	RETURN
*-----------------------------------------------------------------------------
END
