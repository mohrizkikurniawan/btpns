*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.SEND.SMS.NOTIF.LOAD
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
	$INSERT I_F.COMPANY
	$INSERT I_F.AA.PRODUCT
	$INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.BTPNSH.ACK.LOG.SMS
	$INSERT I_F.ATI.TH.LOG.INBOX
	$INSERT I_F.BTPNS.TH.QUEUE.SMS.NOTIF
	$INSERT I_F.BTPNSH.SMS.MESSAGE.TEXT
	$INSERT I_BTPNS.MT.SEND.SMS.NOTIF.COMMON
	$INSERT I_F.AA.ACCOUNT
	
	*vScheduler = OCONV(TIME(),'MTS')
	*IF (vScheduler GE '08:00:00' AND vScheduler LE '17:00:00') OR vFlagAtm EQ 1 THEN
		GOSUB INIT
	*END
	
	RETURN
*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------
	
	fnSms	= 'F.BTPNSH.SMS.MESSAGE.TEXT'
	fvSms	= ''
	CALL OPF(fnSms,fvSms)
	
	fnDate	= 'F.DATES'
	fvDate	= '' 
	CALL OPF(fnDate,fvDate)
	
	fnAcc	= 'F.ACCOUNT'
	fvAcc	= ''
	CALL OPF(fnAcc, fvAcc)
	
	fnArrangement	= 'F.AA.ARRANGEMENT'
	fvArrangement	= ''
	CALL OPF(fnArrangement,fvArrangement)
	
	fnArrangementActivity	= 'F.AA.ARRANGEMENT.ACTIVITY'
	fvArrangementActivity  	= ''
	CALL OPF(fnArrangementActivity,fvArrangementActivity)
	
	fnLogSms	= 'F.BTPNSH.ACK.LOG.SMS'
	fvLogSms	= ''
	CALL OPF(fnLogSms,fvLogSms)
	
	fnLogInbox	= 'F.ATI.TH.LOG.INBOX'
	fvLogInbox	= ''
	CALL OPF(fnLogInbox,fvLogInbox)
	
	fnBtpnsThQueueSms	= 'F.BTPNS.TH.QUEUE.SMS.NOTIF'
	fvBtpnsThQueueSms	= ''
	CALL OPF(fnBtpnsThQueueSms,fvBtpnsThQueueSms)
	
	fnBtpnsThQueueSmsHis	= 'F.BTPNS.TH.QUEUE.SMS.NOTIF$HIS'
	fvBtpnsThQueueSmsHis	= ''
	CALL OPF(fnBtpnsThQueueSmsHis,fvBtpnsThQueueSmsHis)
	
	fnProduct	= 'F.AA.PRODUCT'
    fvProduct	= ''
    CALL OPF(fnProduct, fvProduct)
	
	fnCompany = 'F.COMPANY'
	fvCompany = ''
    CALL OPF(fnCompany,fvCompany)
	
	fnEcb = 'F.EB.CONTRACT.BALANCES'
    fvEcb = ''
    CALL OPF(fnEcb, fvEcb)
	
	Y.APP.NAME	= 'BTPNSH.SMS.MESSAGE.TEXT' :FM:  'BTPNS.TH.QUEUE.SMS.NOTIF' :FM: 'BTPNSH.ACK.LOG.SMS'
	Y.FLD.NAME	= 'TYPE.MASKING'
	Y.FLD.NAME	:= FM
	Y.FLD.NAME	:= 'B.FINAL.MESSAGE' :VM: 'B.CUSTOMER.ID'
	Y.FLD.NAME	:= FM
	Y.FLD.NAME	:= 'DESC.TRX'
	LREF.POS	= ''
	
	CALL MULTI.GET.LOC.REF (Y.APP.NAME, Y.FLD.NAME, LREF.POS)
    posTypeMasking	= LREF.POS<1, 1>
	vFinaLMssgPos	= LREF.POS<2, 1>
	vCustomerIdPos	= LREF.POS<2, 2>
	vDescTrxPos		= LREF.POS<3, 1>
	
	DATE.TIME	= TIMEDATE()
    Y.TIME		= DATE.TIME[1,2]:':':DATE.TIME[4,2]
    Y.TIME.CONV	= OCONV(TIME(),'MTS')   ;* Server Time

    CALL F.READ(fnDate,'ID0010001',rDate,fvDate,errDate)
    vBussDate 		= rDate<EB.DAT.TODAY>

	RETURN
*------------------------------------------------------------------------------
END