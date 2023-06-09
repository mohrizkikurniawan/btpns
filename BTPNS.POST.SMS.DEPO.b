*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.POST.SMS.DEPO
*------------------------------------------------------------------------------
* Re-create by Kania Lydia
* Date			: 26-09-2022
* Description	: Subroutine for colecting sms message close Deposito and renewal depo to table queue sms.
* Attach in		: Post routine AA.PRD.DES.ACTIVITY.API>ID.NDC.IS.DEP.API-20000101
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* 
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_AA.APP.COMMON
	$INSERT I_AA.LOCAL.COMMON
	$INSERT I_AA.ACTION.CONTEXT
	$INSERT I_F.AA.ACCOUNT
	$INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.TERM.AMOUNT
	$INSERT I_F.AA.CHANGE.PRODUCT
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.AA.ACCOUNT.DETAILS
	$INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
	$INSERT I_F.DATES
	$INSERT I_F.COMPANY
    $INSERT I_F.IDIH.FUND.PRODUCT.PAR
	$INSERT I_F.BTPNS.TH.QUEUE.SEND.SMS
	
    GOSUB INIT
	
	vActivityStatus	= c_arrActivityStatus
	idMasterAa		= AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.MASTER.AAA>	
	idChannel		= AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.CHANNEL>
	
	IF (vActivityStatus EQ "AUTH") THEN
		GOSUB GET.APPLICATION
	END

    RETURN

*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------
	
    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
	F.AA.ARRANGEMENT   = ''
	CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
	
	FN.AA.ACTIVITY	= 'F.AA.ARRANGEMENT.ACTIVITY'
	F.AA.ACTIVITY	= ''
	CALL OPF(FN.AA.ACTIVITY, F.AA.ACTIVITY)
	
	FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY  = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY, F.AA.ACTIVITY.HISTORY)
	
	fnCompany = 'F.COMPANY'
	fvCompany = ''
    CALL OPF(fnCompany,fvCompany)
	
	fnCus  = 'F.CUSTOMER'
	fvCus   = ''
	CALL OPF(fnCus, fvCus)
	
	fnAcc	= 'F.ACCOUNT'
	fvAcc	= ''
	CALL OPF(fvAcc, fvAcc)
	
	fnFprd	= 'F.IDIH.FUND.PRODUCT.PAR'
	fvFprd	= ''
	CALL OPF(fnFprd, fvFprd)
	
	fnAaAccDet = 'F.AA.ACCOUNT.DETAILS'
    fvAaAccDet  = ''
    CALL OPF(fnAaAccDet, fvAaAccDet)
	
    fnDate	= 'F.DATES'
	fvDate	= '' 
	CALL OPF(fnDate,fvDate)
	
	fnBtpnsThQueueSendSms = 'F.BTPNS.TH.QUEUE.SEND.SMS'
	fvBtpnsThQueueSendSms = ''
	CALL OPF(fnBtpnsThQueueSendSms,fvBtpnsThQueueSendSms)
	
    vAppName	 = "CUSTOMER" :FM: "IDIH.FUND.PRODUCT.PAR" :FM: "AA.ARR.ACCOUNT" :FM: "AA.ARR.TERM.AMOUNT"
	vFldName	 = "SMS.Y.N" :@VM: 'ATI.MBIB.FLAG'
	vFldName	:= FM
	vFldName	:= "SMS.Y.N"
	vFldName	:= FM
	vFldName	:= "L.TENOR" :VM: "L.MIG.PRD"
	vFldName	:= FM
	vFldName	:= "L.MAT.MODE"
	
    LREF.POS	= ""
    
    CALL MULTI.GET.LOC.REF (vAppName, vFldName, vLrefPos)
    Y.CUS.SMS.Y.N.POS	= vLrefPos<1, 1>
	Y.CUS.MBIB.FLAG.POS	= vLrefPos<1, 2>
    Y.FPRD.SMS.Y.N.POS	= vLrefPos<2, 1>
    Y.L.TENOR.POS		= vLrefPos<3, 1>
	Y.L.MIG.PRD.POS		= vLrefPos<3, 2>
	Y.L.MAT.MODE.POS	= vLrefPos<4, 1>
	Y.DESC.TRX.POS      = vLrefPos<5, 1>
	
    DATE.TIME	= TIMEDATE()
    Y.TIME		= DATE.TIME[1,2]:':':DATE.TIME[4,2]
    Y.TIME.CONV	= OCONV(TIME(),'MTS')   ;* Server Time
    
    CALL F.READ(fnDate,"ID0010001",rDate,fvDate,errDate)
    vBusDate	= rDate<EB.DAT.TODAY>
	
	vTime = FIELD(OCONV( TIME(), "MTS" ),":",1):":":FIELD(OCONV( TIME(), "MTS" ),":",2)

    RETURN

*------------------------------------------------------------------------------
GET.APPLICATION:
*------------------------------------------------------------------------------

	idAa			= AA$ARR.ID
	vTxnAmount		= AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.TXN.AMOUNT>
	vLinkedApplId	= AA$LINKED.ACCOUNT
	idCustomer		= AA$R.ARRANGEMENT<AA.ARR.CUSTOMER,1>
	vAaDateTime		= OCONV(DATE(), 'DY2'):OCONV(DATE(), 'DM') "R%2":OCONV(DATE(), 'DD') "R%2":CHANGE(OCONV(TIME(), "MT" ),":","")
	vActivity		= AA$CURR.ACTIVITY
	vEffDate		= AA$ACTIVITY.EFF.DATE
	vArrStatus1		= c_aalocArrangementRec<AA.ARR.ARR.STATUS>
	vArrStatus2		= AA$ARRANGEMENT.STATUS
	
	IF vArrStatus1 THEN
		vArrStatus = vArrStatus1
	END ELSE
		vArrStatus = vArrStatus2
	END
	
	CALL F.READ(fnCusS, idCustomer, rCus, fvCus, errCus)
	vSmsNo		= rCus<EB.CUS.SMS.1,1>
	vSmsFlag	= rCus<EB.CUS.LOCAL.REF,Y.CUS.SMS.Y.N.POS>
	vMbibFlag	= rCus<EB.CUS.LOCAL.REF,Y.CUS.MBIB.FLAG.POS>
	
	CALL F.READ(fnAcc, vLinkedApplId, rAcc, fvAcc, errAcc)
	idCateg		= rAcc<AC.CATEGORY>
	
	CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
	vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,Y.FPRD.SMS.Y.N.POS>
	
	vPropertyIdAc		= "ACCOUNT"
	vPropertyClassAc	= ""
	vEffectiveDateAc	= TODAY
	CALL AA.GET.PROPERTY.RECORD("", idAa, vPropertyIdAc, vEffectiveDateAc, vPropertyClassAc, "", rAaAccount, errAc)
	vLMigPrd	= rAaAccount<AA.AC.LOCAL.REF,Y.L.MIG.PRD.POS>
	vLTenor		= rAaAccount<AA.AC.LOCAL.REF,Y.L.TENOR.POS>
	vLen		= LEN(vLTenor)
	
	vPropertyIdCo		= "COMMITMENT"
	vPropertyClassCo	= ""
	vEffectiveDateCo	= TODAY
	CALL AA.GET.PROPERTY.RECORD("", idAa, vPropertyIdCo, vEffectiveDateCo, vPropertyClassCo, "", rTermAmount, errCo)
	vOrgAmt		= rTermAmount<AA.AMT.AMOUNT>
	vLMatMode	= rTermAmount<AA.AMT.LOCAL.REF,Y.L.MAT.MODE.POS>
	vCoCode		= rTermAmount<AA.AMT.CO.CODE>
	vConvAmt	= FMT(vOrgAmt,'R,')
	CHANGE "," TO "." IN vConvAmt
	
	CALL AA.GET.ECB.BALANCE.AMOUNT(vLinkedApplId, "TOTCOMMITMENT", TODAY, vTotcommitAmount, errEcb)
	vTotcommitment	= vTotcommitAmount
	
	IF vTotcommitment ELSE
		vTotcommitment	= vOrgAmt
	END
	
	CALL AA.GET.ECB.BALANCE.AMOUNT(vLinkedApplId, "CURACCOUNT", TODAY, vCurAmount, errEcb)
	vTotAmount	= vCurAmount + vTxnAmount
	vAmount		= FMT(vTotAmount,'R,')
	CHANGE "," TO "." IN vAmount

	CALL F.READ(fnAaAccDet, idAa, rAccountDetails, fvAaAccDet, errAad)
	vRenewalDate	= rAccountDetails<AA.AD.RENEWAL.DATE>
	vOrLastReDate	= rAccountDetails<AA.AD.LAST.RENEW.DATE>
	cntLRD			= DCOUNT(vOrLastReDate,VM)
	vLastReDate		= rAccountDetails<AA.AD.LAST.RENEW.DATE,cntLRD>
	vConvLastReDate	= OCONV(ICONV(vLastReDate,'D'),'D/')
	vValueDate		= rAccountDetails<AA.AD.VALUE.DATE>
	vValYear		= vValueDate[2,4]
	vValMounth		= vValueDate[5,2]
	vValDay			= vValueDate[7,2]
	vMaturityDate	= rAccountDetails<AA.AD.MATURITY.DATE>
	vMatYear		= vMaturityDate[2,4]  
	vMatMounth		= vMaturityDate[5,2]
	vMatDay			= vMaturityDate[7,2]
	vValDateConv	= vValDay:"/":vValMounth:"/":vValYear
	vMatDateConv	= vMatDay:"/":vMatMounth:"/":vMatYear
	vProcYear		= vBusDate[2,4]
	vProcMounth		= vBusDate[5,2]
	vProcDay		= vBusDate[7,2]
	vProcDateConv	= vProcDay:"/":vProcMounth:"/":vProcYear
	
	CALL F.READ(fnCompany, vCoCode, rCompany, fvCompany, errCom)
	vCoName = rCompany<EB.COM.COMPANY.NAME>
	
	DATE.TIME	= TIMEDATE()
    vTime		= DATE.TIME[1,2]:'.':DATE.TIME[4,2]
    Y.TIME.CONV	= OCONV(TIME(),'MTS')   ;* Server Time
	
	BEGIN CASE
	CASE vLMatMode EQ "SINGLE MATURITY"
		vAroStatus	= "NON ARO"
	CASE vLMatMode EQ "PRINCIPAL ONLY ROLLOVER"
		vAroStatus	= "ARO 1"
	CASE vLMatMode EQ "PRINCIPAL + PROFIT ROLLOVER"
		vAroStatus	= "ARO 2"
	END CASE
	
	IF vLen EQ 3 THEN
		vTerm	= CHANGE(vLTenor,'M','')
	IF LEFT(vTerm,1) EQ '0' THEN
			vTerm	= RIGHT(vTerm,1)
		END
	END ELSE
		vTerm	= CHANGE(vLTenor,'Y','')
		IF LEFT(vTerm,1) EQ '0' THEN
			vTerm = RIGHT(vTerm,1)
			vTerm = vTerm * 12
		END ELSE
			vTerm = vTerm * 12
		END
	END
	
	vCdtDate	= "+1C"
	CALL CDT("",vMaturityDate,vCdtDate)
	
	BEGIN CASE
	CASE vActivity EQ "DEPOSITS-CLOSE-ARRANGEMENT"
		vSmsCode		= "DEPCLOSE"
		idSmsText		= '5' ;*Penutupan Deposito
		GOSUB WRITE.QUEUE
	CASE vActivity EQ "DEPOSITS-ROLLOVER-ARRANGEMENT" AND (vLMatMode EQ "PRINCIPAL ONLY ROLLOVER" OR vLMatMode EQ "PRINCIPAL + PROFIT ROLLOVER")
		vSmsCode		= "DEPROLLOVER"
		idSmsText		= '4' ;*Perpanjangan Deposito
		GOSUB WRITE.QUEUE
	CASE 1
		RETURN
	END CASE

	RETURN
*-----------------------------------------------------------------------------
WRITE.QUEUE:
*-----------------------------------------------------------------------------
	idContract		= FIELD(AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.TXN.CONTRACT.ID>,'\',1)
    idArrangement	= AA$ARR.ID : "-" : idContract
	
	CALL F.READ(fnBtpnsThQueueSendSms,idArrangement,rSmsQueue,fvBtpnsThQueueSendSms,errSms)
    rSmsQueue<BQUE.SMS.ID.SMS>			= idContract
	rSmsQueue<BQUE.SMS.ID.TEXT.SMS>		= idSmsText
	rSmsQueue<BQUE.SMS.DESC.SMS>		= vSmsCode
	rSmsQueue<BQUE.SMS.SMS.FLAG>		= vSmsFlag
	rSmsQueue<BQUE.SMS.AMOUNT>			= vAmount
	rSmsQueue<BQUE.SMS.ACCOUNT>			= ""
	rSmsQueue<BQUE.SMS.ACCOUNT.DEBIT>	= ""
	rSmsQueue<BQUE.SMS.TIME>			= vTime
	rSmsQueue<BQUE.SMS.DATE>			= vProcDateConv
	rSmsQueue<BQUE.SMS.PRODUCT.DESC>	= vTime
	rSmsQueue<BQUE.SMS.COMPANY>			= vCoName
	rSmsQueue<BQUE.SMS.ARO.STATUS>		= vAroStatus
	CALL ID.LIVE.WRITE(fnBtpnsThQueueSendSms,idArrangement,rSmsQueue)
	
	RETURN
*-----------------------------------------------------------------------------	
	END