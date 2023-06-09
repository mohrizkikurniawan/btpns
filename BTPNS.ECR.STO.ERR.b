*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.ECR.STO.ERR
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20230126
* Description        : Routine to get data ft sto error
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: -
* Modified by    	: -
* Description		: -
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_GTS.COMMON
    $INCLUDE I_ENQUIRY.COMMON
    $INCLUDE I_F.SPF
    $INCLUDE I_F.FUNDS.TRANSFER
*-----------------------------------------------------------------------------
	
	idFt = O.DATA
	
	GOSUB Initialise
	GOSUB Process

    RETURN
	
Initialise:

	fnFundsTransferNau = "F.FUNDS.TRANSFER$NAU"
    fvFundsTransferNau = ""
    CALL OPF(fnFundsTransferNau, fvFundsTransferNau)
	
	arrApp<1> = "FUNDS.TRANSFER"
	arrFld<1,1> = "B.CHARGE.TYPE"
	arrFld<1,2> = "B.CHARGE.AMT"
    arrFld<1,3> = "B.CDTR.AGTID"
    arrFld<1,4> = "B.CDTR.ACCID"
    arrFld<1,5> = "ATI.JNAME.2"
    arrFld<1,6> = "B.CHNTYPE"
    arrFld<1,7> = "B.TXNTYPE"
    arrFld<1,8> = "ATI.MIR"

	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	otherChargeTypePos 	= arrPos<1,1>
	otherChargeAmtPos 	= arrPos<1,2>
    vCdtrAgtidPos       = arrPos<1,3>
    vCdtrAccidPos       = arrPos<1,4>
    vAtiJname2Pos       = arrPos<1,5>
    vChntypePos         = arrPos<1,6>
    vTxnTypePos         = arrPos<1,7>
	
	RETURN
	
Process:

    CALL F.READ(fnFundsTransferNau, idFt, rvFundsTransferNau, fvFundsTransferNau, '')
    vDebitValueDate     = rvFundsTransferNau<FundsTransfer_DebitValueDate>
    vCdtrAgtid          = rvFundsTransferNau<FundsTransfer_LocalRef, vCdtrAgtidPos>
    vCdtrAccid          = rvFundsTransferNau<FundsTransfer_LocalRef, vCdtrAccidPos>
    vAtiJname2          = rvFundsTransferNau<FundsTransfer_LocalRef, vAtiJname2Pos>
    vDistAmount         = rvFundsTransferNau<FundsTransfer_DebitAmount>
    vDebitAcctNo        = rvFundsTransferNau<FundsTransfer_DebitAcctNo>
    vChntype            = rvFundsTransferNau<FundsTransfer_LocalRef, vChntypePos>
    vTxntype            = rvFundsTransferNau<FundsTransfer_LocalRef, vTxnTypePos>


    R.RECORD<301> = vDebitValueDate
	R.RECORD<302> = vCdtrAgtid
	R.RECORD<303> = vCdtrAccid
	R.RECORD<304> = vAtiJname2
	R.RECORD<305> = vDistAmount
	R.RECORD<306> = vDebitAcctNo
	R.RECORD<307> = vChntype
	R.RECORD<308> = vTxntype
	
	RETURN

END 