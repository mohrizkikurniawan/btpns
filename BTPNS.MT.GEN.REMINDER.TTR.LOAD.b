*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.GEN.REMINDER.TTR.LOAD
*-----------------------------------------------------------------------------
* Developer Name     : Kania Farhaning Lydia
* Development Date   : 4 Oktober 2022
* Description        : Routine To send SMS notification for Open and Close product Account and Deposito. Autodebit (success/fail) TTR/Savplan. Rollover Deposito.
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
	
	$INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.DATES
	$INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.ACTION.CONTEXT
	$INSERT I_F.BTPNSH.ACK.LOG.SMS
	$INSERT I_F.AA.ACCOUNT.DETAILS
	$INSERT I_F.ATI.TH.LOG.INBOX
	$INSERT I_F.COMPANY
	$INSERT I_F.AA.PRODUCT
	$INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
	$INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.BTPNS.TH.QUEUE.SMS.NOTIF
	$INSERT I_F.BTPNSH.SMS.MESSAGE.TEXT
	$INSERT I_F.IDIH.FUND.PRODUCT.PAR
	$INSERT I_BTPNS.MT.GEN.REMINDER.TTR.COMMON
	$INSERT I_F.EB.CONTRACT.BALANCES
	$INSERT I_F.AA.PAYMENT.SCHEDULE
	$INSERT I_F.BTPNSH.SMS.MESSAGE.TEXT
	
	GOSUB INIT
	
	RETURN
*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------
	
	fnDate	= 'F.DATES'
	fvDate	= '' 
	CALL OPF(fnDate,fvDate)
	
	fnCus  = 'F.CUSTOMER'
	fvCus   = ''
	CALL OPF(fnCus, fvCus)
	
	fnArrangement	= 'F.AA.ARRANGEMENT'
	fvArrangement	= ''
	CALL OPF(fnArrangement,fvArrangement)
	
	fnAaAccDet = 'F.AA.ACCOUNT.DETAILS'
    fvAaAccDet  = ''
    CALL OPF(fnAaAccDet, fvAaAccDet)
	
	fnBtpnsThQueueSms	= 'F.BTPNS.TH.QUEUE.SMS.NOTIF'
	fvBtpnsThQueueSms	= ''
	CALL OPF(fnBtpnsThQueueSms,fvBtpnsThQueueSms)
	
	fnFprd	= 'F.IDIH.FUND.PRODUCT.PAR'
	fvFprd	= ''
	CALL OPF(fnFprd, fvFprd)
	
	fnAcc	= 'F.ACCOUNT'
	fvAcc	= ''
	CALL OPF(fnAcc, fvAcc)
	
	fnCompany = 'F.COMPANY'
	fvCompany = ''
    CALL OPF(fnCompany,fvCompany)
	
	fnSms	= 'F.BTPNSH.SMS.MESSAGE.TEXT'
	fvSms	= ''
	CALL OPF(fnSms,fvSms)
	
	Y.APP.NAME	= "BTPNSH.SMS.MESSAGE.TEXT"
	Y.FLD.NAME	= "TYPE.MASKING"
	
	LREF.POS1	= ""
	CALL MULTI.GET.LOC.REF (Y.APP.NAME, Y.FLD.NAME, LREF.POS)
    posTypeMasking	= LREF.POS1<1, 1>
	
	vAppName	 = "CUSTOMER" :FM: "IDIH.FUND.PRODUCT.PAR" :FM: "BTPNS.TH.QUEUE.SMS.NOTIF"
	vFldName	 = "SMS.Y.N" :VM: "ATI.MBIB.FLAG"
	vFldName	:= FM
	vFldName	:= "SMS.Y.N":VM:"B.PROD.NAME":VM:"B.AUTO.REMINDER"
	vFldName	:= FM
	vFldName	:= 'B.FINAL.MESSAGE' :VM: 'B.CUSTOMER.ID'
	
    vLrefPos	= ""
    
    CALL MULTI.GET.LOC.REF (vAppName, vFldName, vLrefPos)
    vCusSmsYNPos	= vLrefPos<1, 1>
	vCusMbibFlagPos	= vLrefPos<1, 2>
    vFprdSmsYNPos	= vLrefPos<2, 1>
	vProdTextPos	= vLrefPos<2, 2>
	vAutoRemPos		= vLrefPos<2, 3>
	vFinaLMssgPos	= vLrefPos<3, 1>
	vCustomerIdPos	= vLrefPos<3, 2>

	RETURN
*------------------------------------------------------------------------------
END