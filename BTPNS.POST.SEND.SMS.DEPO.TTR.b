*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.POST.SEND.SMS.DEPO.TTR
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
	
	fnEbContractBalances = "F.EB.CONTRACT.BALANCES"
	fvEbContractBalances = ""
	CALL OPF(fnEbContractBalances, fvEbContractBalances)
	
	fnSms	= 'F.BTPNSH.SMS.MESSAGE.TEXT'
	fvSms	= ''
	CALL OPF(fnSms,fvSms)
	
	fnCompany = 'F.COMPANY'
	fvCompany = ''
    CALL OPF(fnCompany,fvCompany)
	
	fnCus  = 'F.CUSTOMER'
	fvCus   = ''
	CALL OPF(fnCus, fvCus)
	
	fnAcc	= 'F.ACCOUNT'
	fvAcc	= ''
	CALL OPF(fnAcc, fvAcc)
	
	fnFprd	= 'F.IDIH.FUND.PRODUCT.PAR'
	fvFprd	= ''
	CALL OPF(fnFprd, fvFprd)
	
	fnAaAccDet = 'F.AA.ACCOUNT.DETAILS'
    fvAaAccDet  = ''
    CALL OPF(fnAaAccDet, fvAaAccDet)
	
    fnDate	= 'F.DATES'
	fvDate	= '' 
	CALL OPF(fnDate,fvDate)
	
	fnProduct	= 'F.AA.PRODUCT'
    fvProduct	= ''
    CALL OPF(fnProduct, fvProduct)
	
	fnBtpnsThQueueSmsNotif = 'F.BTPNS.TH.QUEUE.SMS.NOTIF'
	fvBtpnsThQueueSmsNotif = ''
	CALL OPF(fnBtpnsThQueueSmsNotif,fvBtpnsThQueueSmsNotif)
	
	fnFundsTransfer	= 'F.FUNDS.TRANSFER'
    fvFundsTransfer	= ''
    CALL OPF(fnFundsTransfer,fvFundsTransfer)
   
    fnFundsTransferHis	= 'F.FUNDS.TRANSFER$HIS'
    fvFundsTransferHis	= ''
    CALL OPF(fnFundsTransferHis,fvFundsTransferHis)
	
	fnBillDetail	= 'F.AA.BILL.DETAILS'
	fvBillDetail	= ''
	CALL OPF(fnBillDetail, fvBillDetail)
	
	fnStmtEntry	= 'F.STMT.ENTRY'
	fvStmtEntry	= ''
	CALL OPF(fnStmtEntry,fvStmtEntry)
	
	fnParamSms = 'F.ATI.TH.PARAM.SMS'
    fvParamSms  = ''
    CALL OPF(fnParamSms,fvParamSms)
	
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
	idAccPinbuk	= ''
	
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
	idAcct			= idAccount
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
		idAcct	 	= idAccount
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
	CASE vActivity EQ 'DEPOSITS-NEW-ARRANGEMENT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPN.MUD'
		
		IF idCateg ELSE
			idCateg	= '6601'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
			vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		
		vAmount		= vOrgAmt
		vAcctCr		= ''
		vAcctDb		= ''
		vProdDesc	= ''
		vCoName		= ''
		vAro		= vAroStatus:'|':vTerm
		vSmsCode	= 'DEPOPEN'
		idSmsText	= '1' ;*Open Deposito
		vAmountDep	= vAmount
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'DEPOSITS-APPLYPAYMENT-PR.DEPOSIT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPN.MUD' AND idTxnType EQ 'AA' AND vArrStatus EQ 'CURRENT'
		
		GOSUB PROCESS.AAA
		
		BEGIN CASE
		CASE vMinAmount GT vAmountLcy 
			RETURN
		CASE prefixAccount EQ 'IDR' AND vFlagRak NE 1
			RETURN
		END CASE
		
		vFlagRekSum		= 1
		IF vFlagRak EQ 1 THEN
			CALL F.READ(fnAcc, vRekSumber, rAcct, fvAcc, errAa)
			idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>
		END ELSE
			idAaRekSum	= vidRekSumber
			IF vidRekSumber ELSE
				CALL AA.PROPERTY.REF(idAa, 'SETTLEMENT', idSettlement)
				CALL F.READ(fnAaSettlement, idSettlement, rAaSett, fvAaSettlement, errSet)
				vLinkAcct	= rAaSett<AA.SET.PAYIN.ACCOUNT>
				
				IF vLinkAcct ELSE
					CALL F.READ(fnArrangement, vLinkAaIdPayIn, rArrangementNew, fvArrangement, errAa)
					vLinkAcct	= rArrangementNew<AA.ARR.LINKED.APPL.ID,1>
				END
				
				CALL F.READ(fnAcc, vLinkAcct, rAcct, fvAcc, errAa)
				idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>
			END
		END

		IF idCateg ELSE
			idCateg	= '6601'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
			vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		
		IF vAmountLcy GE vMinAmount ELSE
			RETURN
		END
		
		vAmount		= vAmountLcy
		vAcctCr		= ''
		vAcctDb		= ''
		vProdDesc	= 'TD'
		vCoName		= ''
		vAro		= vAroStatus:'|':vTerm
		vSmsCode	= 'DEPAUTODEBAAA'
		idSmsText	= '14' ;*Perpanjangan Deposito
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'DEPOSITS-APPLYPAYMENT-PO.WITHDRAWAL' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPN.MUD' AND vArrStatus EQ 'PENDING.CLOSURE'
		
		GOSUB PROCESS.AAA
		
		IF idCateg ELSE
			idCateg	= '6601'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
			vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		
		vAmount		= vAmountLcy
		vAcctCr		= ''
		vAcctDb		= ''
		vProdDesc	= ''
		vCoName		= ''
		vAro		= vAroStatus:'|':vTerm
		vSmsCode	= 'DEPCLOSE'
		idSmsText	= '5' ;*Penutupan Deposito
		vAmountDep	= vAmount
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'DEPOSITS-SETTLE-SETTLEMENT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPN.MUD' AND vArrStatus EQ 'PENDING.CLOSURE' AND vLMatMode EQ 'SINGLE MATURITY'
		
		GOSUB GET.CONTRACT.ID
		GOSUB PROCESS.AAA
		
		IF idCateg ELSE
			idCateg	= '6601'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
			vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		
		IF vAmountLcy EQ 0 OR vAmountLcy EQ '' THEN
			RETURN
		END
		
		vAmount		= vAmountLcy
		vAcctCr		= ''
		vAcctDb		= ''
		vProdDesc	= ''
		vCoName		= ''
		vAro		= vAroStatus:'|':vTerm
		vSmsCode	= 'DEPCLOSECOB'
		idSmsText	= '5' ;*Penutupan Deposito
		vAmountDep	= vAmount
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'DEPOSITS-APPLYPAYMENT-PR.DEPOSIT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPN.MUD' AND (vLMatMode EQ 'PRINCIPAL ONLY ROLLOVER' OR vLMatMode EQ 'PRINCIPAL + PROFIT ROLLOVER') AND idTxnType EQ 'FT'
		
		GOSUB PROCESS.FT
		
		IF vAroStatus EQ 'ARO2' ELSE
			GOSUB PROCESS.BGHS
		END
		
		IF ftTrxType NE 'ACDF' THEN
			RETURN
		END
		
		BEGIN CASE
		CASE vAroStatus EQ 'ARO2'
			CALL AA.GET.ECB.BALANCE.AMOUNT(idAccount, 'CURACCOUNT', TODAY, vCurrentAmount, errCurr)
			vAmountRoll	= ftAmount + vCurrentAmount
		CASE 1
			vAmountRoll	= ftAmount
		END CASE
		
		IF idCateg ELSE
			idCateg	= '6601'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
			vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		
		vBussYear		= vBusDate[3,2]
		vBussMounth		= vBusDate[5,2]
		vBussDay		= vBusDate[7,2]
		
		vRevYear		= vLastRenDate[3,2]
		vRevMounth		= vLastRenDate[5,2]
		vRevDay			= vLastRenDate[7,2]
		
		idAa		= idAaOrig
		vAmount		= vAmountRoll
		vAcctCr		= ''
		vAcctDb		= ''
		vProdDesc	= ''
		vCoName		= ''
		vAro		= vAroStatus:'|':vTerm
		
		BEGIN CASE
		CASE vChequeNum EQ idAa
			vSmsCode	= 'DEPROLLOVER'
			IF vRevMounth EQ vBussMounth AND vRevYear EQ vBussYear THEN
				vProcessingDate	= vRevDay:'/':vRevMounth:'/':vRevYear
			END ELSE 
				vProcessingDate	= vRevDay:'/':vBussMounth:'/':vBussYear
			END
			idSmsText	= '4' ;*Perpanjangan Deposito
		CASE vChequeNum EQ ''
			vFlagRekSum	= 1
			IF vFlagRak EQ 1 THEN
				CALL F.READ(fnAcc, vRekSumber, rAcct, fvAcc, errAa)
				idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>
			END ELSE
				idAaRekSum	= vidRekSumber
				IF vidRekSumber ELSE
					CALL AA.PROPERTY.REF(idAa, 'SETTLEMENT', idSettlement)
					CALL F.READ(fnAaSettlement, idSettlement, rAaSett, fvAaSettlement, errSet)
					vLinkAcct	= rAaSett<AA.SET.PAYIN.ACCOUNT>
					
					IF vLinkAcct ELSE
						CALL F.READ(fnArrangement, vLinkAaIdPayIn, rArrangementNew, fvArrangement, errAa)
						vLinkAcct	= rArrangementNew<AA.ARR.LINKED.APPL.ID,1>
					END
					
					CALL F.READ(fnAcc, vLinkAcct, rAcct, fvAcc, errAa)
					idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>
				END
			END
			
			vProdDesc	= 'TD'
			vSmsCode	= 'DEPAUTODEBFT'
			idSmsText	= '14' ;*Pinbuk Deposito
			IF vAmountRoll GE vMinAmount ELSE
				RETURN
			END
		CASE preAcct EQ 'PL'
			vFlagRekSum	= 1
			CALL F.READ(fnAcc, ftCrAcctNo, rAcct, fvAcc, errAa)
			idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>
			vSmsCode	= 'DEPAUTODEBBGHS'
			idSmsText	= '13'
			IF vAmountRoll GE vMinAmount ELSE
				RETURN
			END
		CASE 1
			RETURN
		END CASE
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'DEPOSITS-ROLLOVER-ARRANGEMENT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPN.MUD' AND (vLMatMode EQ 'PRINCIPAL ONLY ROLLOVER')
		CALL AA.GET.ECB.BALANCE.AMOUNT(idAccount, 'TOTCOMMITMENT', TODAY, vTotAmount, errCurr)
		
		IF idCateg ELSE
			idCateg	= '6601'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
			vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		
		vBussYear		= vBusDate[3,2]
		vBussMounth		= vBusDate[5,2]
		vBussDay		= vBusDate[7,2]
		
		vRevYear		= vLastRenDate[3,2]
		vRevMounth		= vLastRenDate[5,2]
		vRevDay			= vLastRenDate[7,2]
		
		IF vRevMounth EQ vBussMounth AND vRevYear EQ vBussYear THEN
			vProcessingDate	= vRevDay:'/':vRevMounth:'/':vRevYear
		END ELSE 
			vProcessingDate	= vRevDay:'/':vBussMounth:'/':vBussYear
		END
		
		vAmount		= vTotAmount
		vAcctCr		= ''
		vAcctDb		= ''
		vProdDesc	= ''
		vCoName		= ''
		vAro		= vAroStatus:'|':vTerm
		vSmsCode	= 'DEPROLLOVER'
		idSmsText	= '4' ;*Perpanjangan Deposito
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'DEPOSITS-APPLYPAYMENT-PO.WITHDRAWAL' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPNS.TMIB' AND vArrStatus EQ 'PENDING.CLOSURE'
		
		GOSUB PROCESS.AAA
		vFlagInfo	= 1
		
		IF idAccount EQ "" THEN
			CALL F.READ(fnArrangement, idAa, rArrangement, fvArrangement, errAa)
			vLinkAcct	= rArrangement<AA.ARR.LINKED.APPL.ID,1>
			idAccount	= vLinkAcct
		END
		
		IF vAmountLcy EQ "" THEN
			RETURN
		END
		
		IF vAmountLcy EQ 0 THEN
			RETURN
		END
		
		idCateg	= '6004'
		CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
		vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
		vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		
		GOSUB PROCESS.PINBUK
		
		vAmount		= vAmountLcy
		vAcctCr		= idAccount
		vAcctDb		= ''
		vAroStatus	= ''
		vProdDesc	= ''
		vCoName		= ''
		vSmsCode	= 'TTRCLOSE'
		idSmsText	= '9' ;*Penutupan Tepat Tabungan Rencana
		
		GOSUB WRITE.QUEUE
	
	CASE vActivity EQ 'DEPOSITS-SETTLE-SETTLEMENT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPNS.TMIB' AND vArrStatus EQ 'PENDING.CLOSURE'
		
		GOSUB GET.CONTRACT.ID
		GOSUB PROCESS.AAA
		
		vFlagInfo	= 2
		
		IF idAccount EQ "" THEN
			CALL F.READ(fnArrangement, idAa, rArrangement, fvArrangement, errAa)
			vLinkAcct	= rArrangement<AA.ARR.LINKED.APPL.ID,1>
			idAccount	= vLinkAcct
		END
		
		IF vAmountLcy EQ "" THEN
			RETURN
		END
		
		IF vAmountLcy EQ 0 THEN
			RETURN
		END
		
		GOSUB PROCESS.PINBUK
		
		idCateg	= '6004'
		CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
		vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
		vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		
		vAmount		= vAmountLcy
		vAcctCr		= idAccount
		vAcctDb		= ''
		vProdDesc	= ''
		vCoName		= ''
		vAro		= ''
		vSmsCode	= 'TTRCLOSECOB'
		idSmsText	= '9' ;*Penutupan Deposito
		vAmountDep	= vAmount
		
		GOSUB WRITE.QUEUE
	
	CASE vActivity EQ 'DEPOSITS-TMIB.CLOSURE-ARRANGEMENT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPNS.TMIB'
		
		GOSUB GET.CONTRACT.ID
		GOSUB PROCESS.AAA
		
		vFlagInfo	= 3
		
		IF idAccount EQ "" THEN
			CALL F.READ(fnArrangement, idAa, rArrangement, fvArrangement, errAa)
			vLinkAcct	= rArrangement<AA.ARR.LINKED.APPL.ID,1>
			idAccount	= vLinkAcct
		END
		
		CALL F.READ(fnArrangement, idAa, rArrangement, fvArrangement, errAa)
		idAcct	= rArrangement<AA.ARR.LINKED.APPL.ID>
	
		CALL F.READ(fnEbContractBalances, idAcct, rvEbContractBalances, fvEbContractBalances, "")
		vBillType	= rvEbContractBalances<EbContractBalances_CurrAssetType>
		
		FINDSTR "CURACCOUNT" IN vBillType SETTING YPOSF, YPOSV, YPOSM THEN 
			vAmountLcy	= rvEbContractBalances<EbContractBalances_OpenBalance,YPOSV>
			vAmountLcy = ABS(vAmountLcy)
		END
		
		vProcYear		= vBusDate[3,2]
		vProcMounth		= vBusDate[5,2]
		vProcDay		= vBusDate[7,2]
		vProcessingDate	= vProcDay:'/':vProcMounth:'/':vProcYear
		
		IF vAmountLcy EQ "" THEN
			RETURN
		END
		
		IF vAmountLcy EQ 0 THEN
			RETURN
		END
		
		GOSUB PROCESS.PINBUK
		
		idCateg	= '6004'
		CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
		vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
		vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
				
		vAmount		= vAmountLcy
		vAcctCr		= idAccount
		vAcctDb		= ''
		vAroStatus	= ''
		vProdDesc	= ''
		vCoName		= ''
		vSmsCode	= 'TTRAUTOCLOSE'
		idSmsText	= '9' ;*Penutupan Tepat Tabungan Rencana
		
		GOSUB WRITE.QUEUE
	
	CASE vActivity EQ 'DEPOSITS-NEW-ARRANGEMENT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPNS.TMIB'
		
		IF idCateg ELSE
			idCateg	= '6004'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
			vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		vAmount		= ''
		vAcctCr		= idAccount
		vAcctDb		= ''
		vAroStatus	= ''
		vProdDesc	= ''
		vCoName		= ''
		vSmsCode	= 'TTROPEN'
		idSmsText	= '11' ;*Pembukaan Rekening (Exc Depo)
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'DEPOSITS-ISSUEBILL-SCHEDULE*DEPOSIT.SAVINGS' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPNS.TMIB' AND vWorkBalAmt LT vAmtAuto
		
		IF idCateg ELSE
			idCateg	= '6004'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
			vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END

		CALL AA.PROPERTY.REF(idAa, 'SETTLEMENT', idSettlement)
		CALL F.READ(fnAaSettlement, idSettlement, rAaSett, fvAaSettlement, errSet)
		vLinkAcct	= rAaSett<AA.SET.PAYIN.ACCOUNT>
		
		IF vLinkAcct ELSE
			CALL F.READ(fnArrangement, vLinkAaIdPayIn, rArrangementNew, fvArrangement, errAa)
			vLinkAcct	= rArrangementNew<AA.ARR.LINKED.APPL.ID,1>
		END
		
		vJatTempo		= rAccountDetails<AA.AD.PAYMENT.START.DATE>
		vDateExp		= vJatTempo[7,2]
		vProcYear		= vBusDate[3,2]
		vProcMounth		= vBusDate[5,2]
		vProcDay		= vBusDate[7,2]
		vProcessingDate	= vProcDay:'/':vProcMounth:'/':vProcYear
		
		vAmount		= vAmtAuto
		vAcctCr		= idAccount
		vAcctDb		= vLinkAcct
		vAroStatus	= ''
		vProdDesc	= ''
		vCoName		= ''
		vSmsCode	= 'TTRAUTOFAIL'
		idSmsText	= '8' ;*Gagal Otodebit TTR
		
		GOSUB WRITE.QUEUE
	
	CASE vActivity EQ 'DEPOSITS-APPLYPAYMENT-PR.DEPOSIT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPNS.TMIB' AND idTxnType EQ 'FT'
		
		IF idCateg ELSE
			idCateg	= '6004'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vProdText	= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		
		GOSUB PROCESS.FT
		
		IF ftTrxType NE 'ACDF' THEN
			RETURN
		END
		
		vAmount		= ftAmount
		vAcctCr		= ftCrAcctNo
		vAcctDb		= ftDbAcctNo
		vAroStatus	= ''
		vProdDesc	= ''
		vCoName		= ''
		vSmsCode	= 'TTRAUTOSUCCESS'
		idSmsText	= '7' ;*Berhasil Otodebit TTR
		
		GOSUB WRITE.QUEUE
		
	CASE vActivity EQ 'DEPOSITS-APPLYPAYMENT-PR.DEPOSIT' AND vProductLine EQ 'DEPOSITS' AND vProductGroup EQ 'BTPNS.TMIB' AND idTxnType EQ 'AA' AND vArrStatus EQ 'CURRENT'
		
		IF idCateg ELSE
			idCateg	= '6004'
			CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
			vProdText	= rFprd<FPRD.LOCAL.REF,vProdTextPos>
		END
		
		GOSUB PROCESS.AAA
		
		CALL F.READ(fnAcc, vAccountNumber, rAcct, fvAcc, errAa)
		debCustomer	= rAcct<AC.CUSTOMER>
		
		IF prefixAccount EQ 'IDR' ELSE
			IF idCustomer NE debCustomer THEN
				idAa	= rAcct<AC.ARRANGEMENT.ID>
			END
		END
		
		IF vAmountLcy GE vMinAmount ELSE
			RETURN
		END
		
		vFlagRekSum		= 1
		IF vFlagRak EQ 1 THEN
			CALL F.READ(fnAcc, vRekSumber, rAcct, fvAcc, errAa)
			idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>
		END ELSE
			idAaRekSum	= vidRekSumber
			IF vidRekSumber ELSE
				CALL AA.PROPERTY.REF(idAa, 'SETTLEMENT', idSettlement)
				CALL F.READ(fnAaSettlement, idSettlement, rAaSett, fvAaSettlement, errSet)
				vLinkAcct	= rAaSett<AA.SET.PAYIN.ACCOUNT>
				
				IF vLinkAcct ELSE
					CALL F.READ(fnArrangement, vLinkAaIdPayIn, rArrangementNew, fvArrangement, errAa)
					vLinkAcct	= rArrangementNew<AA.ARR.LINKED.APPL.ID,1>
				END
				
				CALL F.READ(fnAcc, vLinkAcct, rAcct, fvAcc, errAa)
				idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>
			END
		END
		
		
		vAmount		= vAmountLcy
		vAcctCr		= ''
		vAcctDb		= ''
		vAroStatus	= ''
		vProdDesc	= 'TTR'
		vCoName		= ''
		vSmsCode	= 'TTRSETAWAL'
		idSmsText	= '14' ;*Berhasil Otodebit TTR
		
		GOSUB WRITE.QUEUE

	CASE 1
		RETURN
	END CASE

	RETURN
*-----------------------------------------------------------------------------
PROCESS.FT:
*-----------------------------------------------------------------------------
	CALL F.READ(fnFundsTransfer,idTxnContract,rFt,fvFundsTransfer,errFt)
	
    IF NOT(rFt) THEN
       CALL F.READ.HISTORY(fnFundsTransferHis,idTxnContract,rFt,fvFundsTransferHis,errFtHis)
    END
	
	ftDbAcctNo	= rFt<FT.DEBIT.ACCT.NO>
    ftCrAcctNo 	= rFt<FT.CREDIT.ACCT.NO>
	ftAmtCr		= rFt<FT.CREDIT.AMOUNT>
	ftAmtDb		= rFt<FT.DEBIT.AMOUNT>
	ftCustDb	= rFt<FT.DEBIT.CUSTOMER>
    ftInputter	= rFt<FT.INPUTTER>
    ftProcDate	= rFt<FT.PROCESSING.DATE>
	ftTrxType	= rFt<FT.TRANSACTION.TYPE>
	vChequeNum	= rFt<FT.CHEQUE.NUMBER>
	
	IF ftAmtCr THEN
		ftAmount	= ABS(ftAmtCr)
	END ELSE
		ftAmount	= ABS(ftAmtDb)
	END
	
	ftProcYear		= ftProcDate[3,2]
	ftProcMounth	= ftProcDate[5,2]
	ftProcDay		= ftProcDate[7,2]
	ftProcDateConv	= ftProcDay:'/':ftProcMounth:'/':ftProcYear
	vProcessingDate	= ftProcDateConv
	
	preAcct	= ftDbAcctNo[1,2]
	
	CALL F.READ(fnAcc, ftDbAcctNo, rAcct, fvAcc, errAa)
	debCustomer	= rAcct<AC.CUSTOMER>
	
	idAaOrig	= idAa
	IF ftCustDb NE '' THEN
		IF preAcct EQ 'ID' OR preAcct EQ 'PL' ELSE
			IF idCustomer NE ftCustDb AND rAcct NE '' THEN
				idAa	= rAcct<AC.ARRANGEMENT.ID>
			END
		END
	END

	RETURN

*-----------------------------------------------------------------------------
PROCESS.BGHS:
*-----------------------------------------------------------------------------
	IF idCateg ELSE
		idCateg	= '6601'
		CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
		vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
		vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
	END
	
	vFlagRekSum	= 1
	
	CALL F.READ(fnAcc, ftCrAcctNo, rAcct, fvAcc, errAa)
	idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>
	
	vAmount		= ftAmount
	vAcctCr		= ''
	vAcctDb		= ''
	vProdDesc	= ''
	vCoName		= ''
	vAro		= vAroStatus:'|':vTerm
	vSmsCode	= 'DEPBGHSROLL'
	idSmsText	= '13'
	prefixAcct	= ftDbAcctNo[1,3]
	
	IF idAaRekSum EQ '' OR vMinAmount GT ftAmount OR prefixAcct EQ 'IDR' THEN
		RETURN
	END ELSE
		GOSUB WRITE.QUEUE
	END
	
	vFlagRekSum	= ''
	
	RETURN
*-----------------------------------------------------------------------------
PROCESS.PINBUK:
*-----------------------------------------------------------------------------
	
	CALL AA.PROPERTY.REF(idAa, 'SETTLEMENT', idSettlement)
	CALL F.READ(fnAaSettlement, idSettlement, rAaSett, fvAaSettlement, errSet)
	vLinkAcct	= rAaSett<AA.SET.PAYOUT.ACCOUNT>
	
	CALL F.READ(fnAcc, vLinkAcct, rAccPnb, fvAcc, errAcc)
	idCateg		= rAccPnb<AC.CATEGORY>
	idAccPinbuk	= rAccPnb<AC.ARRANGEMENT.ID>
	
	CALL F.READ(fnArrangement, idAccPinbuk, rArrPinBook, fvArrangement, errAa)
	vAccPinBook	= rArrPinBook<AA.ARR.LINKED.APPL.ID,1>
	
	CALL F.READ(fnFprd, idCateg, rFprd, fvFprd, errFprd)
	vFprdSmsFlag	= rFprd<FPRD.LOCAL.REF,vFprdSmsYNPos>
	vProdText		= rFprd<FPRD.LOCAL.REF,vProdTextPos>
	
	vAmount		= vAmountLcy
	vAcctCr		= ''
	vAcctDb		= ''
	vProdDesc	= ''
	vCoName		= ''
	vAro		= ''
	vSmsCode	= 'TTRAUDEBCLS':vFlagInfo
	idSmsText	= '14' ;*PINBUK TTR
	
	IF vAmountLcy GE vMinAmount THEN
		vFlag	= 1
		GOSUB WRITE.QUEUE
		vFlag	= 0
	END
	
	RETURN
*-----------------------------------------------------------------------------
PROCESS.AAA:
*-----------------------------------------------------------------------------
	CALL F.READ(fnArrangementActivity,idTxnContract,rAaa,fvArrangementActivity,errAaa)
	
    IF NOT(rAaa) THEN
       CALL F.READ.HISTORY(fnArrangementActivityHis,idTxnContract,rAaa,fvArrangementActivityHis,errAaaHis)
    END
	
	vSquential	= rAaa<AA.ARR.ACT.STMT.NOS,2>
	IF LEN(vSquential) GT 1 THEN
		vSquential	= FIELD(vSquential,'-',1)
	END
	
	idStmtNos	= rAaa<AA.ARR.ACT.STMT.NOS,1>:'000':vSquential
	idArrAct	= rAaa<AA.ARR.ACT.ARRANGEMENT>
	
	CALL F.READ(fnStmtEntry, idStmtNos, rStmtEntry, fvStmtEntry, errStmt)
	vAccountNumber	= rStmtEntry<AC.STE.ACCOUNT.NUMBER>
	vidRekSumber	= rStmtEntry<AC.STE.THEIR.REFERENCE>
	
	IF vidRekSumber ELSE
		accRekSumber	= rStmtEntry<AC.STE.OUR.REFERENCE>
		CALL F.READ(fnAcc, accRekSumber, rAcctPin, fvAcc, errAa)
		vidRekSumber	= rAcctPin<AC.ARRANGEMENT.ID>
	END
	
	prefixAccount	= vAccountNumber[1,3]
	vAmountLcy		= rStmtEntry<AC.STE.AMOUNT.LCY>
	vAmountLcy		= ABS(vAmountLcy)
	vValueDate		= rStmtEntry<AC.STE.VALUE.DATE>
	vPrefixRak		= vAccountNumber[1,8]
	vFlagRak		= ''
	
	IF vPrefixRak EQ 'IDR12800' THEN
		vFlagRak	= 1
		vRekSumber	= rStmtEntry<AC.STE.OUR.REFERENCE>
	END
	
	aaProcYear		= vValueDate[3,2]
	aaProcMounth	= vValueDate[5,2]
	aaProcDay		= vValueDate[7,2]
	aaProcDateConv	= aaProcDay:'/':aaProcMounth:'/':aaProcYear
	vProcessingDate	= aaProcDateConv

	RETURN
*-----------------------------------------------------------------------------
WRITE.QUEUE:
*-----------------------------------------------------------------------------
	
	BEGIN CASE
	CASE vFlagRekSum EQ 1 
		CALL F.READ(fnArrangement, idAaRekSum, rArrangementJoin, fvArrangement, errAa)
	CASE vFlag EQ 1 
		CALL F.READ(fnArrangement, idAccPinbuk, rArrangementJoin, fvArrangement, errAa)
	CASE 1
		CALL F.READ(fnArrangement, idAa, rArrangementJoin, fvArrangement, errAa)
	END CASE
	
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
* MBIB tidak digunakan karena kebutuhan development hanya untuk SMS Notif saja

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
	
	IF vFlag EQ 1 THEN
		idArrangement	= idAccPinbuk:'-':idContract:'.':X
	END ELSE
		idArrangement	= idAa:'-':idContract:'.':X
	END
	
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
	rSmsQueue<SMS.NOTIF.ARO.STATUS>					= vAro
	rSmsQueue<SMS.NOTIF.LOCAL.REF,vCustomerIdPos>	= idCustomer
	rSmsQueue<SMS.NOTIF.DATE.TIME>					= rTime
	rSmsQueue<SMS.NOTIF.INPUTTER>					= OPERATOR
	rSmsQueue<SMS.NOTIF.AUTHORISER>					= OPERATOR
	rSmsQueue<SMS.NOTIF.CO.CODE>					= ID.COMPANY
	
	IF vFlag EQ 1 OR (vFlagRekSum EQ 1 AND idCateg EQ '6004') THEN
		IF vFlag EQ 1 THEN
			vPinBook	= RIGHT(vLinkAcct,3)
			vPinBook	= 'XXX':vPinBook
		END ELSE
			vPinBook	= RIGHT(idAccount,3)
			vPinBook	= 'XXX':vPinBook
		END
		CALL BTPNS.GET.SMS.TEXT(idSmsText,vPinBook,vAmount,vAcctCr,vAcctDb,vProcessingDate,vTime,vAroStatus,vTerm,vProdDesc,vCoName,vMessage)
	END ELSE
		CALL BTPNS.GET.SMS.TEXT(idSmsText,idAa,vAmount,vAcctCr,vAcctDb,vProcessingDate,vTime,vAroStatus,vTerm,vProdDesc,vCoName,vMessage)
	END
	
	rSmsQueue<SMS.NOTIF.LOCAL.REF,vFinaLMssgPos>	= vMessage
	
	WRITE rSmsQueue TO fvBtpnsThQueueSmsNotif,idArrangement
	
	RETURN
*-----------------------------------------------------------------------------
GET.CONTRACT.ID:
*-----------------------------------------------------------------------------
	CALL F.READ(fnAaAccDet, idAa, rAccountDetails, fvAaAccDet, errAad)
	vValueDate		= rAccountDetails<AA.AD.VALUE.DATE>
	vRepayRef		= rAccountDetails<AA.AD.REPAY.REFERENCE>
	vCntRepay		= DCOUNT(vRepayRef,VM)
	vRepayRef		= rAccountDetails<AA.AD.REPAY.REFERENCE,vCntRepay>
	idAaa			= FIELD(vRepayRef,'-',1)
	dateCon			= FIELD(vRepayRef,'-',2)
	
	CALL F.READ(fnArrangementActivity,idAaa,rAaaNew,fvArrangementActivity,errFt)
	IF NOT(rAaaNew) THEN
	CALL F.READ.HISTORY(fnArrangementActivityHis,idAaa,rAaaNew,fvArrangementActivityHis,errAaaHis)
	END
	
	vAmtTxn			= rAaaNew<AA.ARR.ACT.TXN.AMOUNT>
	idTxnContract	= rAaaNew<AA.ARR.ACT.TXN.CONTRACT.ID>
	idTxnContract	= FIELD(idTxnContract,'\',1)
	idTxnContractX	= idTxnContract
	
	RETURN
*-----------------------------------------------------------------------------	
	END
	