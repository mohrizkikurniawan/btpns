*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.POST.SEND.SMS.NOTIF
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
	$INSERT I_F.AA.BILL.DETAILS
	$INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.TERM.AMOUNT
	$INSERT I_F.AA.CHANGE.PRODUCT
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.AA.ACCOUNT.DETAILS
	$INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
	$INSERT I_F.DATES
	$INSERT I_F.STMT.ENTRY
	$INSERT I_F.COMPANY
	$INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.IDIH.FUND.PRODUCT.PAR
	$INSERT I_F.BTPNS.TH.QUEUE.SMS.NOTIF
	$INSERT I_F.EB.CONTRACT.BALANCES
	$INSERT I_F.AA.PRODUCT
	$INSERT I_F.AA.PAYMENT.SCHEDULE
	$INSERT I_F.ATI.TH.PARAM.SMS
	$INSERT I_F.AA.SETTLEMENT
	$INSERT I_F.BTPNSH.SMS.MESSAGE.TEXT

    GOSUB INIT
	
	vActivityStatus	= c_arrActivityStatus
	idMasterAa		= AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.MASTER.AAA>	
	idChannel		= AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.CHANNEL>
	idContract		= FIELD(AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.TXN.CONTRACT.ID>,'\',1)
	vChannelAa		= AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.CHANNEL>
	
	IF (vActivityStatus EQ 'AUTH' AND idChannel NE 'IRISPA') THEN
		GOSUB GET.APPLICATION
	END

    RETURN
*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------
    fnArrangement  = 'F.AA.ARRANGEMENT'
	fvArrangement   = ''
	CALL OPF(fnArrangement, fvArrangement)
	
	fnAaSettlement	= 'F.AA.ARR.SETTLEMENT'
	fvAaSettlement	= ''
	CALL OPF(fnAaSettlement,fvAaSettlement)
	
	fnArrangementActivity	= 'F.AA.ARRANGEMENT.ACTIVITY'
	fvArrangementActivity	= ''
	CALL OPF(fnArrangementActivity, fvArrangementActivity)
	
	fnArrangementActivityHis	= 'F.AA.ARRANGEMENT.ACTIVITY$HIS'
	fvArrangementActivityHis	= ''
	CALL OPF(fnArrangementActivityHis, fvArrangementActivityHis)
	
	fnArrangementActivityNau	= 'F.AA.ARRANGEMENT.ACTIVITY$NAU'
	fvArrangementActivityNau	= ''
	CALL OPF(fnArrangementActivity, fvArrangementActivity)
	
	fnBtpnsThQueueSmsNotif = 'F.BTPNS.TH.QUEUE.SMS.NOTIF'
	fvBtpnsThQueueSmsNotif = ''
	CALL OPF(fnBtpnsThQueueSmsNotif,fvBtpnsThQueueSmsNotif)
	
	fnFundsTransfer	= 'F.FUNDS.TRANSFER'
    fvFundsTransfer	= ''
    CALL OPF(fnFundsTransfer,fvFundsTransfer)
   
    fnFundsTransferHis	= 'F.FUNDS.TRANSFER$HIS'
    fvFundsTransferHis	= ''
    CALL OPF(fnFundsTransferHis,fvFundsTransferHis)
	
	fnSms	= 'F.BTPNSH.SMS.MESSAGE.TEXT'
	fvSms	= ''
	CALL OPF(fnSms,fvSms)
	
	fnFprd	= 'F.IDIH.FUND.PRODUCT.PAR'
	fvFprd	= ''
	CALL OPF(fnFprd, fvFprd)
	
	fnAaAccDet = 'F.AA.ACCOUNT.DETAILS'
    fvAaAccDet  = ''
    CALL OPF(fnAaAccDet, fvAaAccDet)
	
	fnBillDetail	= 'F.AA.BILL.DETAILS'
	fvBillDetail	= ''
	CALL OPF(fnBillDetail, fvBillDetail)
	
	fnStmtEntry	= 'F.STMT.ENTRY'
	fvStmtEntry	= ''
	CALL OPF(fnStmtEntry,fvStmtEntry)
	
	fnParamSms = 'F.ATI.TH.PARAM.SMS'
    fvParamSms  = ''
    CALL OPF(fnParamSms,fvParamSms)
	
	fnCompany = 'F.COMPANY'
	fvCompany = ''
    CALL OPF(fnCompany,fvCompany)
	
	fnProduct	= 'F.AA.PRODUCT'
    fvProduct	= ''
    CALL OPF(fnProduct, fvProduct)
	
	fnCus  = 'F.CUSTOMER'
	fvCus   = ''
	CALL OPF(fnCus, fvCus)
	
	fnAcc	= 'F.ACCOUNT'
	fvAcc	= ''
	CALL OPF(fnAcc, fvAcc)
	
    fnDate	= 'F.DATES'
	fvDate	= '' 
	CALL OPF(fnDate,fvDate)
	
    vAppName	 = 'CUSTOMER' :FM: 'IDIH.FUND.PRODUCT.PAR' :FM: 'AA.ARR.ACCOUNT' :FM: 'AA.ARR.TERM.AMOUNT' :FM: 'BTPNSH.SMS.MESSAGE.TEXT' :FM:  'BTPNS.TH.QUEUE.SMS.NOTIF'
	vFldName	 = 'SMS.Y.N' :VM: 'ATI.MBIB.FLAG'
	vFldName	:= FM
	vFldName	:= 'SMS.Y.N' :VM: 'B.PROD.NAME'
	vFldName	:= FM
	vFldName	:= 'L.TENOR' :VM: 'L.MIG.PRD'
	vFldName	:= FM
	vFldName	:= 'L.MAT.MODE'
	vFldName	:= FM
	vFldName	:= 'TYPE.MASKING'
	vFldName	:= FM
	vFldName	:= 'B.FINAL.MESSAGE' :VM: 'B.CUSTOMER.ID'
	
    vLrefPos	= ''
    
    CALL MULTI.GET.LOC.REF (vAppName, vFldName, vLrefPos)
    vCusSmsYNPos	= vLrefPos<1, 1>
	vCusMbibFlagPos	= vLrefPos<1, 2>
    vFprdSmsYNPos	= vLrefPos<2, 1>
	vProdTextPos	= vLrefPos<2, 2>
    vLTenorPos		= vLrefPos<3, 1>
	vLMigPrdPos		= vLrefPos<3, 2>
	vLMatModePos	= vLrefPos<4, 1>
	posTypeMasking	= vLrefPos<5, 1>
	vFinaLMssgPos	= vLrefPos<6, 1>
	vCustomerIdPos	= vLrefPos<6, 2>
	
	CALL GET.LOC.REF("AA.ARR.SETTLEMENT","L.PRFT.RSD",vLPrftRsdPos)
	
    DATE.TIME	= TIMEDATE()
    Y.TIME		= DATE.TIME[1,2]:':':DATE.TIME[4,2]
    Y.TIME.CONV	= OCONV(TIME(),'MTS')   ;* Server Time
    
    CALL F.READ(fnDate,'ID0010001',rDate,fvDate,errDate)
    vBusDate	= rDate<EB.DAT.TODAY>
	
	CALL F.READ(fnParamSms,'SYSTEM',rParamSms,fvParamSms,errParamSms)
    vMinAmount	= rParamSms<SMS.PARAM.MIN.AMOUNT>
	
	X			= OCONV(DATE(),"D-")
    Y.TIME		= OCONV(TIME(),"MTS")
    DT			= X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    rTime		= X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
	
	vSmsNo		= ''
	vSmsFlag	= ''
	vMbibFlag	= ''
	vFlagRekSum	= ''
	
    RETURN
*------------------------------------------------------------------------------
GET.APPLICATION:
*------------------------------------------------------------------------------
	idAa			= AA$ARR.ID
	idTxnContract	= FIELD(AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.TXN.CONTRACT.ID>,'\',1)
	idTxnType		= idTxnContract[1,2]
	vTxnAmount		= AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.TXN.AMOUNT>
	vLinkedApplId	= AA$LINKED.ACCOUNT
	idCustomer		= AA$R.ARRANGEMENT<AA.ARR.CUSTOMER,1>
	vAaDateTime		= OCONV(DATE(), 'DY2'):OCONV(DATE(), 'DM') 'R%2':OCONV(DATE(), 'DD') 'R%2':CHANGE(OCONV(TIME(), 'MT' ),':','')
	vActivity		= AA$CURR.ACTIVITY
	vEffDate		= AA$ACTIVITY.EFF.DATE
	vArrStatus1		= c_aalocArrangementRec<AA.ARR.ARR.STATUS>
	vArrStatus2		= AA$ARRANGEMENT.STATUS
	
	idAccount		= vLinkedApplId
	idAccountDb		= ''
	
	IF vArrStatus1 THEN
		vArrStatus = vArrStatus1
	END ELSE
		vArrStatus = vArrStatus2
	END
	
	CALL F.READ(fnArrangement, idAa, rArrangement, fvArrangement, errAa)
	vProductGroup	= rArrangement<AA.ARR.PRODUCT.GROUP>
	vProductLine	= rArrangement<AA.ARR.PRODUCT.LINE>
	idProduct		= rArrangement<AA.ARR.PRODUCT>
	vCoBook			= rArrangement<AA.ARR.CO.CODE>
	vLinkType		= rArrangement<AA.ARR.LINK.TYPE>
	vLinkAaId		= rArrangement<AA.ARR.LINK.ARRANGEMENT>
	vLinkAaIdPayIn	= rArrangement<AA.ARR.LINK.ARRANGEMENT,1,2>
	IF idAccount ELSE
		idAccount	= rArrangement<AA.ARR.LINKED.APPL.ID,1>
	END
	
	vWorkBalAmt	= 0
	FIND 'PAYIN.ACCOUNT' IN vLinkType SETTING posFM, posVM, posSM THEN
		vLinkAaId	= vLinkAaId<posFM, posVM, posSM>
		CALL F.READ(fnArrangement, vLinkAaId, rArrangement, fvArrangement, errAa)
		vLinkAcct	= rArrangement<AA.ARR.LINKED.APPL.ID,1>
		CALL F.READ(fnAcc, vLinkAcct, rAccLink, fvAcc, errAccLink)
		vWorkBalAmt	= rAccLink<AC.WORKING.BALANCE>
		lLockAmt	= rAccLink<AC.LOCKED.AMOUNT>
		vLocKAmt	= 0
		cntLock		= DCOUNT(lLockAmt,VM)
		IF cntLock NE 0 THEN
			FOR Lock = 1 TO cntLock
				vLocKAmt =+ rAccLink<AC.LOCKED.AMOUNT,cntLock>
			NEXT Lock
		END
		vWorkBalAmt	= vWorkBalAmt - vLocKAmt
	END
	
	CALL F.READ(fnAcc, vLinkedApplId, rAcc, fvAcc, errAcc)
	idCateg		= rAcc<AC.CATEGORY>
	
	vPropertyIdPs		= 'SCHEDULE'
	vPropertyClassPs	= ''
	vEffectiveDatePs	= TODAY
	CALL AA.GET.PROPERTY.RECORD('', idAa, vPropertyIdPs, vEffectiveDatePs, vPropertyClassPs, '', rPaymentSchedule, errPaySch)
    vAmtAuto	= rPaymentSchedule<AA.PS.ACTUAL.AMT,1>
	
	CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
	vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
	vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>

	vPropertyIdAc		= 'ACCOUNT'
	vPropertyClassAc	= ''
	vEffectiveDateAc	= TODAY
	CALL AA.GET.PROPERTY.RECORD('', idAa, vPropertyIdAc, vEffectiveDateAc, vPropertyClassAc, '', rAaAccount, errAc)
	vLMigPrd	= rAaAccount<AA.AC.LOCAL.REF,vLMigPrdPos>
	vLTenor		= rAaAccount<AA.AC.LOCAL.REF,vLTenorPos>
	vLen		= LEN(vLTenor)
	
	vPropertyIdCo		= 'COMMITMENT'
	vPropertyClassCo	= ''
	vEffectiveDateCo	= TODAY
	CALL AA.GET.PROPERTY.RECORD('', idAa, vPropertyIdCo, vEffectiveDateCo, vPropertyClassCo, '', rTermAmount, errCo)
	vOrgAmt		= rTermAmount<AA.AMT.AMOUNT>
	vLMatMode	= rTermAmount<AA.AMT.LOCAL.REF,vLMatModePos>
	vCoCode		= rTermAmount<AA.AMT.CO.CODE>

	CALL F.READ(fnAaAccDet, idAa, rAccountDetails, fvAaAccDet, errAad)
	vRenewalDate	= rAccountDetails<AA.AD.RENEWAL.DATE>
	vBaseDate		= rAccountDetails<AA.AD.BASE.DATE>
	vLRD			= rAccountDetails<AA.AD.ACTUAL.RENEW.DATE>
	vCNT			= DCOUNT(vLRD,VM)
	vLastRenDate	= rAccountDetails<AA.AD.ACTUAL.RENEW.DATE,vCNT>
	vOrLastReDate	= rAccountDetails<AA.AD.ACTUAL.RENEW.DATE>
	cntLRD			= DCOUNT(vOrLastReDate,VM)
	vLastReDate		= rAccountDetails<AA.AD.ACTUAL.RENEW.DATE,cntLRD>
	vConvLastReDate	= OCONV(ICONV(vLastReDate,'D'),'D/')
	vValueDate		= rAccountDetails<AA.AD.VALUE.DATE>
	vValYear		= vValueDate[3,2]
	vValMounth		= vValueDate[5,2]
	vValDay			= vValueDate[7,2]
	orgMaturityDate	= rAccountDetails<AA.AD.PAYMENT.START.DATE>
	vValDateConv	= vValDay:'/':vValMounth:'/':vValYear
	vProcYear		= vBusDate[3,2]
	vProcMounth		= vBusDate[5,2]
	vProcDay		= vBusDate[7,2]
	vProcessingDate	= vProcDay:'/':vProcMounth:'/':vProcYear
	vMaturityDate	= vBusDate[1,4]:vBusDate[5,2]:orgMaturityDate[7,2]
	
	CALL F.READ(fnCompany, vCoBook, rCompany, fvCompany, errCom)
	vCoName = rCompany<EB.COM.COMPANY.NAME>
	
	CALL F.READ(fnProduct, idProduct, rAaProduct, fvProduct,errAaProd)
    vProdDesc	= rAaProduct<AA.PDT.DESCRIPTION>
	
	DATE.TIME	= TIMEDATE()
    vTime		= DATE.TIME[1,2]:'.':DATE.TIME[4,2]
    Y.TIME.CONV	= OCONV(TIME(),'MTS')   ;* Server Time
	
	BEGIN CASE
	CASE vLMatMode EQ 'SINGLE MATURITY'
		vAroStatus	= 'NON ARO'
		vTotAmount	= vOrgAmt
	CASE vLMatMode EQ 'PRINCIPAL ONLY ROLLOVER'
		vAroStatus	= 'ARO1'
		vTotAmount	= vOrgAmt
	CASE vLMatMode EQ 'PRINCIPAL + PROFIT ROLLOVER'
		vAroStatus	= 'ARO2'
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
	
	BEGIN CASE
*---Sms Notification for Product Account.
	CASE vActivity EQ 'ACCOUNTS-NEW-ARRANGEMENT' AND vProductLine EQ 'ACCOUNTS' AND vProductGroup EQ 'BTPN.TBNGAN.SA.IB'
	
		vAmount		= ''
		vAcctCr		= idAccount
		vAcctDb		= ''
		vAroStatus	= ''
		vSmsCode	= 'OPENTPTAB'
		idSmsText	= '11' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'ACCOUNTS-NEW-ARRANGEMENT' AND vProductLine EQ 'ACCOUNTS' AND vProductGroup EQ 'BTPNS.TTPIB'
		
		vAmount		= ''
		vAcctCr		= idAccount
		vAcctDb		= ''
		vAroStatus	= ''
		vSmsCode	= 'OPENTPTABPL'
		idSmsText	= '11' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'ACCOUNTS-NEW-ARRANGEMENT' AND vProductLine EQ 'ACCOUNTS' AND vProductGroup EQ 'BTPN.GIRO.IB.CA'
		
		vAmount		= ''
		vAcctCr		= idAccount
		vAcctDb		= ''
		vAroStatus	= ''
		vSmsCode	= 'OPENGIRO'
		idSmsText	= '11' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'ACCOUNTS-NEW-ARRANGEMENT' AND vProductLine EQ 'ACCOUNTS' AND vProductGroup EQ 'BTPN.TABUNGAN.HAJI'
		
		vAmount		= ''
		vAcctCr		= idAccount
		vAcctDb		= ''
		vAroStatus	= ''
		vSmsCode	= 'OPENRTJH'
		idSmsText	= '11' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' AND vProductLine EQ 'ACCOUNTS' AND vProductGroup EQ 'BTPN.TBNGAN.SA.IB'
		
		vAmount		= ''
		vAcctCr		= idAccount
		vAcctDb		= ''
		vAroStatus	= ''
		vSmsCode	= 'CLOSETPTAB'
		idSmsText	= '12' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' AND vProductLine EQ 'ACCOUNTS' AND vProductGroup EQ 'BTPNS.TTPIB'
		
		vAmount		= ''
		vAcctCr		= ''
		vAcctDb		= ''
		vAroStatus	= ''
		vSmsCode	= 'CLOSETPTABPL'
		idSmsText	= '12' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' AND vProductLine EQ 'ACCOUNTS' AND vProductGroup EQ 'BTPN.GIRO.IB.CA'
		
		vAmount		= ''
		vAcctCr		= ''
		vAcctDb		= ''
		vAroStatus	= ''
		vSmsCode	= 'CLOSEGIRO'
		idSmsText	= '12' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' AND vProductLine EQ 'ACCOUNTS' AND vProductGroup EQ 'BTPN.TABUNGAN.HAJI'
		
		vAmount		= ''
		vAcctCr		= ''
		vAcctDb		= ''
		vAroStatus	= ''
		vSmsCode	= 'CLOSERTJH'
		idSmsText	= '12' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
	
	CASE 1
		RETURN
	END CASE

	RETURN

*-----------------------------------------------------------------------------
WRITE.QUEUE:
*-----------------------------------------------------------------------------	
	CALL F.READ(fnArrangement, idAa, rArrangementJoin, fvArrangement, errAa)
	
	vCustomerId		= rArrangementJoin<AA.ARR.CUSTOMER>
	vJoinCustomer	= DCOUNT(vCustomerId,VM)
	
	FOR X=1 TO vJoinCustomer
		vSmsNo		= ''
		vSmsFlag	= ''
		vMbibFlag	= ''
		rSmsQueue	= ''
		idCustomer	= rArrangementJoin<AA.ARR.CUSTOMER,X>
		CALL F.READ(fnCus, idCustomer, rCus, fvCus, errCus)
		vSmsNo		= rCus<EB.CUS.SMS.1,1>
		vSmsFlag	= rCus<EB.CUS.LOCAL.REF,vCusSmsYNPos>
		vMbibFlag	= rCus<EB.CUS.LOCAL.REF,vCusMbibFlagPos>
		
		GOSUB FINAL.WRITE.QUEUE
	NEXT X
	
	RETURN
*-----------------------------------------------------------------------------
FINAL.WRITE.QUEUE:
*-----------------------------------------------------------------------------
*	IF (vSmsFlag EQ 'Y' AND vSmsNo NE '') OR vMbibFlag EQ 'Y' ELSE
*		RETURN
*	END

	IF (vSmsFlag EQ 'Y' AND vSmsNo NE '') ELSE
		RETURN
	END	

	IF idMasterAa ELSE
		idMasterAa	= idContract
	END
	IF idContract ELSE
		idContract	= idMasterAa
	END
	IF vProdText NE '' AND (vProdDesc NE 'TTR' OR vProdDesc NE 'TD') THEN
		vProdDesc	= vProdText
	END
	
	IF vCoName ELSE
		CALL F.READ(fnCompany, ID.COMPANY, rCompany, fvCompany, errCom)
		vCoName = rCompany<EB.COM.COMPANY.NAME>
	END
	
	vAmount	= FMT(vAmount,'18L,')
    CHANGE ',' TO '.' IN vAmount
	CHANGE ' ' TO '' IN vAmount
	
    idArrangement	= idAa:'-':idContract:'.':X
	
	CALL F.READ(fnBtpnsThQueueSmsNotif,idArrangement,rSmsQueue,fvBtpnsThQueueSmsNotif,errSms)
    rSmsQueue<SMS.NOTIF.ID.SMS>						= idMasterAa
	rSmsQueue<SMS.NOTIF.ID.TEXT.SMS>				= idSmsText
	rSmsQueue<SMS.NOTIF.DESC.SMS>					= vSmsCode
	rSmsQueue<SMS.NOTIF.SMS.FLAG>					= vSmsFlag:'|':vSmsNo
	rSmsQueue<SMS.NOTIF.INBOX.FLAG>					= vMbibFlag
	rSmsQueue<SMS.NOTIF.PRODUCT.FLAG>				= vFprdSmsFlag
	rSmsQueue<SMS.NOTIF.AMOUNT>						= vAmount
	rSmsQueue<SMS.NOTIF.ACCOUNT.CR>					= vAcctCr
	rSmsQueue<SMS.NOTIF.ACCOUNT.DB>					= vAcctDb
	rSmsQueue<SMS.NOTIF.TIME>						= vTime
	rSmsQueue<SMS.NOTIF.DATE>						= vProcessingDate
	rSmsQueue<SMS.NOTIF.PRODUCT.DESC>				= vProdDesc
	rSmsQueue<SMS.NOTIF.COMPANY>					= vCoName
	rSmsQueue<SMS.NOTIF.LOCAL.REF,vCustomerIdPos>	= idCustomer
	rSmsQueue<SMS.NOTIF.DATE.TIME>					= rTime
	rSmsQueue<SMS.NOTIF.INPUTTER>					= OPERATOR
	rSmsQueue<SMS.NOTIF.AUTHORISER>					= OPERATOR
	rSmsQueue<SMS.NOTIF.CO.CODE>					= ID.COMPANY
	
	CALL BTPNS.GET.SMS.TEXT(idSmsText,idAa,vAmount,vAcctCr,vAcctDb,vProcessingDate,vTime,'',vTerm,vProdDesc,vCoName,vMessage)
	
	rSmsQueue<SMS.NOTIF.LOCAL.REF,vFinaLMssgPos>	= vMessage
	
	WRITE rSmsQueue TO fvBtpnsThQueueSmsNotif,idArrangement
	
	RETURN
*-----------------------------------------------------------------------------	
	END
	