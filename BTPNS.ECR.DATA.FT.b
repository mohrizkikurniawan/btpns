*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.ECR.DATA.FT
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20220103
* Description        : Routine to get data FT live or history
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
    $INCLUDE I_F.FUNDS.TRANSFER
    $INCLUDE I_F.IDCH.RTGS.BANK.CODE.G2
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB Initialise
	GOSUB Process
	
    RETURN

*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------
	
	fnFundsTransfer     = "F.FUNDS.TRANSFER"
    fvFundsTransfer     = ""
    CALL OPF(fnFundsTransfer, fvFundsTransfer)

    fnFundsTransferHis  = "F.FUNDS.TRANSFER$HIS"
    fvFundsTransferHis  = ""
    CALL OPF(fnFundsTransferHis, fvFundsTransferHis)

    fnIdchRtgsBankCodeG2    = "F.IDCH.RTGS.BANK.CODE.G2"
    fvIdchRtgsBankCodeG2    = ""
    CALL OPF(fnIdchRtgsBankCodeG2, fvIdchRtgsBankCodeG2)

	arrApp<1> = "FUNDS.TRANSFER"
	arrFld<1,1> = "B.CDTR.AGTID"
    arrFld<1,2> = "B.CDTR.ACCID"
    arrFld<1,3> = "ATI.JNAME.2"

	arrPos		= ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	bCtdrAgtidPos  	    = arrPos<1,1>
	bCdtrAccidPos	    = arrPos<1,2>
    atiJname2Pos        = arrPos<1,3>
	

	RETURN

*-----------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------
	
	CALL F.READ(fnFundsTransfer, O.DATA, rvFundsTransfer, fvFundsTransfer, '')  
    IF rvFundsTransfer EQ '' THEN
        CALL F.READ.HISTORY(fnFundsTransferHis, O.DATA, rvFundsTransferHis, fvFundsTransferHis, '')
        bCtdrAgtid      = rvFundsTransferHis<FundsTransfer_LocalRef, bCtdrAgtidPos>
        bCdtrAccid      = rvFundsTransferHis<FundsTransfer_LocalRef, bCdtrAccidPos>
        atiJname2       = rvFundsTransferHis<FundsTransfer_LocalRef, atiJname2Pos>
        commissionType  = rvFundsTransferHis<FundsTransfer_CommissionType>
        commissionAmt   = rvFundsTransferHis<FundsTransfer_CommissionAmt>
        paymentDetails  = rvFundsTransferHis<FundsTransfer_PaymentDetails>
    END ELSE
        bCtdrAgtid      = rvFundsTransfer<FundsTransfer_LocalRef, bCtdrAgtidPos>
        bCdtrAccid      = rvFundsTransfer<FundsTransfer_LocalRef, bCdtrAccidPos>
        atiJname2       = rvFundsTransfer<FundsTransfer_LocalRef, atiJname2Pos>
        commissionType  = rvFundsTransfer<FundsTransfer_CommissionType>
        commissionAmt   = rvFundsTransfer<FundsTransfer_CommissionAmt>
        paymentDetails  = rvFundsTransfer<FundsTransfer_PaymentDetails>

    END  

    CALL F.READ(fnIdchRtgsBankCodeG2, bCtdrAgtid, rvIdchRtgsBankCodeG2, fvIdchRtgsBankCodeG2, '')  
    bankName    = rvIdchRtgsBankCodeG2<IdchRtgsBankCodeG2_BankName>

    R.RECORD<401>   = bCtdrAgtid
    R.RECORD<402>   = bankName
    R.RECORD<403>   = bCdtrAccid
    R.RECORD<404>   = atiJname2
    R.RECORD<405>   = commissionType
    R.RECORD<406>   = commissionAmt
    R.RECORD<407>   = paymentDetails
 
	
	RETURN
*-----------------------------------------------------------------------------
END
