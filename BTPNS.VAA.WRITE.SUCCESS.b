	SUBROUTINE BTPNS.VAA.WRITE.SUCCESS
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 12 September 2022
* Description        : write successed when authorized
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
	
	GOSUB INIT
	GOSUB PROCESS

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
	R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_Status> = "SUCCESS"
	
	CALL F.WRITE(FN.BTPNS.TH.BIFAST.STO.DEPO,Y.ID.STODEPO,R.BTPNS.TH.BIFAST.STO.DEPO)

	GOSUB CreateFtMaterai

	RETURN
*-----------------------------------------------------------------------------
CreateFtMaterai:
*-----------------------------------------------------------------------------

	vTransactionType		= "ACBM"
	vCoCode					= ID.COMPANY
    vOfsSource			    = 'BIFAST'
    vOfsQueue    			= ''
    vOption       			= OPERATOR
	vOtherChargeType		= R.NEW(FundsTransfer_LocalRef)<1, otherChargeTypePos>
	vOtherChargeAmt			= R.NEW(FundsTransfer_LocalRef)<1, otherChargeAmtPos>
	vDebitAcctNo			= R.NEW(FundsTransfer_DebitAcctNo)
	vDebitTheirRef			= R.NEW(FundsTransfer_DebitTheirRef)

	FINDSTR 'IDR' IN vOtherChargeAmt SETTING vPosV, vPosF, vPosS THEN
		vOtherChargeAmt		= FIELD(vOtherChargeAmt, "IDR", 2)
	END
	
	CALL F.READ(fnFtCommissionType, vOtherChargeType, rvFtCommissionType, fvFtCommissionType, '')
	vCategAccount			= rvFtCommissionType<FtCommissionType_CategoryAccount>
	vCreditAcctNo			= vCategAccount[1, 12] : vCoCode[4]

	vOfsMessageApplication	= 'FUNDS.TRANSFER,BIFAST.MATERAI':'/I/PROCESS,//'
	

    vOfsMessageData  = 'TRANSACTION.TYPE::=':vTransactionType
    vOfsMessageData	:= ',DEBIT.ACCT.NO::=':vDebitAcctNo
    vOfsMessageData	:= ',DEBIT.CURRENCY::=IDR'
    vOfsMessageData	:= ',DEBIT.VALUE.DATE::=':TODAY
    vOfsMessageData	:= ',CREDIT.ACCT.NO::=':vCreditAcctNo
    vOfsMessageData	:= ',CREDIT.CURRENCY::=IDR'
    vOfsMessageData	:= ',CREDIT.VALUE.DATE::=':TODAY
    vOfsMessageData	:= ',DEBIT.AMOUNT::=':vOtherChargeAmt
    
    vOfsMessageData	:= ',COMMISSION.CODE::=':'WAIVE'
    vOfsMessageData	:= ',PAYMENT.DETAILS::=':'Biaya Materai - ':vDebitTheirRef
    vOfsMessageData	:= ',REMARKS::=STO.DEPO'

    ofsMessage = vOfsMessageApplication:vCoCode:',':'':',':vOfsMessageData
    CALL OFS.POST.MESSAGE(ofsMessage, vOfsQueue, vOfsSource, vOption)

	RETURN
*-----------------------------------------------------------------------------
END




