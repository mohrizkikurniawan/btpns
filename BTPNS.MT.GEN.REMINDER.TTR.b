*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.GEN.REMINDER.TTR(idAa)
*-----------------------------------------------------------------------------
* Developer Name     : Kania Farhaning Lydia
* Development Date   : 4 Oktober 2022
* Description        : Routine To generate list sms notification for reminder autodebit.
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
	$INSERT I_F.ATI.TH.LOG.INBOX
	$INSERT I_F.AA.ACCOUNT.DETAILS
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
	$INSERT I_F.AA.SETTLEMENT
	
	GOSUB INIT
	
	RETURN
	
*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------
	
	X			= OCONV(DATE(),"D-")
    Y.TIME		= OCONV(TIME(),"MTS")
    DT			= X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    rTime	= X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
	
	vTime = FIELD(OCONV( TIME(), "MTS" ),":",1):":":FIELD(OCONV( TIME(), "MTS" ),":",2)
	
	CALL F.READ(fnDate,"ID0010001",rDate,fvDate,errDate)
    vBusDate	= rDate<EB.DAT.TODAY>
	
	CALL F.READ(fnArrangement, idAa, rArrangement, fvArrangement, errAa)
	vLinkedApplId	= rArrangement<AA.ARR.LINKED.APPL.ID,1>
	vArrStatus		= rArrangement<AA.ARR.ARR.STATUS>
	
	CALL F.READ(fnAcc, vLinkedApplId, rAcc, fvAcc, errAcc)
	idCateg		= rAcc<AC.CATEGORY>
	
	CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
	dayAutoRem	= rFprd<FPRD.LOCAL.REF,vAutoRemPos>
	
	vCycleDate = TODAY
	vTotPayment	= ''
	vDueDate	= ''
	vDueTypeAmt	= ''
	CALL AA.SCHEDULE.PROJECTOR(idAa, '', '', vCycleDate, vTotPayment, vDueDate, '', '', vDueTypeAmt, '', '', '', '')
	cntDueDate	= DCOUNT(vDueDate,FM)
	
	vMaturityDate	= vDueDate<1>
	vYear			= vMaturityDate[1,4]
	vMounth			= vMaturityDate[5,2]
	vDatePay		= vMaturityDate[7,2]
	vProcessingDate	= vDatePay:"/":vMounth:"/":vYear 

	vDays	= ''
	flagTTR	= 0
	IF vDueDate NE "" AND dayAutoRem NE "" THEN
		vDays	= 'C'
		CALL CDD('',vBusDate,vMaturityDate,vDays)
		IF vDays LE '12' AND vDays GE '3' THEN		;*ANTISIPASI JIKA TERDAPAT LIBUR PANJANG DGN MAKSIMAL TOTAL 12 HARI LIBUR
			vDiff = '-':dayAutoRem:'C'
			CALL CDT('',vMaturityDate,vDiff)
			CALL AWD('',vMaturityDate,vDayCheck)
			
			BEGIN CASE
			CASE vDayCheck NE 'H' AND vMaturityDate EQ vBusDate
				flagTTR	= 1
			CASE vDayCheck EQ 'H'
				vDiff = '-1W'
				CALL CDT('',vMaturityDate,vDiff)
				IF vMaturityDate EQ vBusDate THEN
					flagTTR	= 1
				END
			END CASE
		END
	END

	IF flagTTR EQ 1 AND vArrStatus EQ 'CURRENT' THEN
		GOSUB PROCESS.WRITE
	END
	
	RETURN
*-----------------------------------------------------------------------------
PROCESS.WRITE:
*-----------------------------------------------------------------------------
	CALL F.READ(fnArrangement, idAa, rArrangementJoin, fvArrangement, errAa)
	vCustomerId		= rArrangementJoin<AA.ARR.CUSTOMER>
	vJoinCustomer	= DCOUNT(vCustomerId,VM)
	
	FOR X=1 TO vJoinCustomer
		vSmsNo		= ''
		vSmsFlag	= ''
		vMbibFlag	= ''
		idCustomer	= rArrangementJoin<AA.ARR.CUSTOMER,X>
		CALL F.READ(fnCus, idCustomer, rCus, fvCus, errCus)
		vSmsNo		= rCus<EB.CUS.SMS.1,1>
		vSmsFlag	= rCus<EB.CUS.LOCAL.REF,vCusSmsYNPos>
		vMbibFlag	= rCus<EB.CUS.LOCAL.REF,vCusMbibFlagPos>
		
		GOSUB FINAL.WRITE.QUEUE
	NEXT vJoinCustomer
	
	RETURN
*-----------------------------------------------------------------------------
FINAL.WRITE.QUEUE:
*-----------------------------------------------------------------------------	
	CALL F.READ(fnArrangement, idAa, rArrangement, fvArrangement, errAa)
	vLinkType	= rArrangement<AA.ARR.LINK.TYPE>
	idLinked	= rArrangement<AA.ARR.LINKED.APPL.ID,1>
	vLinkAaId	= rArrangement<AA.ARR.LINK.ARRANGEMENT>
	
	vPropertyIdPs		= "SCHEDULE"
	vPropertyClassPs	= ""
	vEffectiveDatePs	= TODAY
	CALL AA.GET.PROPERTY.RECORD("", idAa, vPropertyIdPs, vEffectiveDatePs, vPropertyClassPs, "", rPaymentSchedule, errPaySch)
    vAmtAuto	= rPaymentSchedule<AA.PS.ACTUAL.AMT,1>
	
*	IF (vSmsFlag EQ 'Y' OR vMbibFlag EQ 'Y') AND vSmsNo NE '' ELSE
*		RETURN
*	END
	
	IF (vSmsFlag EQ 'Y' AND vSmsNo NE '') ELSE
		RETURN
	END
	
	CALL F.READ(fnFprd, '6004', rFprd, fvFprd, errFprd)
	vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
	
	FINDSTR 'PAYIN.ACCOUNT' IN vLinkType SETTING posFM, posVM, posSM THEN
		vLinkAaId	= vLinkAaId<posFM, posVM, posSM>
		CALL F.READ(fnArrangement, vLinkAaId, rArrangement, fvArrangement, errAa)
		vLinkAcct	= rArrangement<AA.ARR.LINKED.APPL.ID,1>
	END
	
	IF vLinkAcct ELSE
		CALL AA.GET.PROPERTY.RECORD('', idAa, SETTLEMENT, TODAY,'' ,'' , R.SETTLEMENT, ERR.SETT)
		vLinkAcct  = R.SETTLEMENT<AA.SET.PAYIN.ACCOUNT,1>
	END
	
	idTime	= vTime
	vAmount	= FMT(vAmtAuto,"18L,")
    CHANGE ',' TO '.' IN vAmount
	CHANGE ' ' TO '' IN vAmount
	CHANGE ':' TO '' IN idTime
	
	idArrangement	= idAa : "-" : vBusDate:idTime
	
	CALL F.READ(fnBtpnsThQueueSms,idArrangement,rSmsQueue,fvBtpnsThQueueSms,errSms)
    rSmsQueue<SMS.NOTIF.ID.SMS>						= idAa:idTime
	rSmsQueue<SMS.NOTIF.ID.TEXT.SMS>				= '6'
	rSmsQueue<SMS.NOTIF.DESC.SMS>					= 'TTRREMAINDER'
	rSmsQueue<SMS.NOTIF.SMS.FLAG>					= vSmsFlag:'|':vSmsNo
	rSmsQueue<SMS.NOTIF.INBOX.FLAG>					= vMbibFlag
	rSmsQueue<SMS.NOTIF.PRODUCT.FLAG>				= vFprdSmsFlag
	rSmsQueue<SMS.NOTIF.AMOUNT>						= vAmount
	rSmsQueue<SMS.NOTIF.ACCOUNT.CR>					= idLinked
	rSmsQueue<SMS.NOTIF.ACCOUNT.DB>					= vLinkAcct
	rSmsQueue<SMS.NOTIF.TIME>						= vTime
	rSmsQueue<SMS.NOTIF.DATE>						= vProcessingDate
	rSmsQueue<SMS.NOTIF.LOCAL.REF,vCustomerIdPos>	= idCustomer
	rSmsQueue<SMS.NOTIF.DATE.TIME>					= vTime
	rSmsQueue<SMS.NOTIF.INPUTTER>					= OPERATOR
	rSmsQueue<SMS.NOTIF.AUTHORISER>					= OPERATOR
	rSmsQueue<SMS.NOTIF.CO.CODE>					= ID.COMPANY
	
	CALL BTPNS.GET.SMS.TEXT('6',idAa,vAmount,idLinked,vLinkAcct,vProcessingDate,vTime,'','','','',vMessage)
	
	rSmsQueue<SMS.NOTIF.LOCAL.REF,vFinaLMssgPos>	= vMessage
	
	WRITE rSmsQueue TO fvBtpnsThQueueSms,idArrangement

	RETURN
*------------------------------------------------------------------------------
END

