   SUBROUTINE BTPNS.VAA.GEN.SMS.PROFIT.SHARE
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia
* Development Date   : 20221026
* Description        : Routine to generate sms queue for profit share from PL to customer (Tepat Tabungan)  FUNDS.TRANSFER,RSD.DIST
*-----------------------------------------------------------------------------
* Modification History:
*-----------------------------------------------------------------------------
* Date               :
* Modified by        : 
* Description        : 
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ATI.TH.WRITE.OFF.PROC
    $INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.CUSTOMER
	$INSERT I_F.ACCOUNT
	$INSERT I_F.COMPANY
	$INSERT I_F.IDIH.FUND.PRODUCT.PAR
	$INSERT I_F.BTPNS.TH.QUEUE.SMS.NOTIF
	$INSERT I_F.AA.PRODUCT
	$INSERT I_F.AA.TERM.AMOUNT
	$INSERT I_F.AA.ACCOUNT
	$INSERT I_F.BTPNSH.SMS.MESSAGE.TEXT
	$INSERT I_F.ATI.TH.PARAM.SMS

    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    fnArrangement  = 'F.AA.ARRANGEMENT'
	fvArrangement   = ''
	CALL OPF(fnArrangement, fvArrangement)
	
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
	
	fnProduct	= 'F.AA.PRODUCT'
    fvProduct	= ''
    CALL OPF(fnProduct, fvProduct)
	
	fnParamSms = 'F.ATI.TH.PARAM.SMS'
    fvParamSms  = ''
    CALL OPF(fnParamSms,fvParamSms)
	
	fnBtpnsThQueueSmsNotif = 'F.BTPNS.TH.QUEUE.SMS.NOTIF'
	fvBtpnsThQueueSmsNotif = ''
	CALL OPF(fnBtpnsThQueueSmsNotif,fvBtpnsThQueueSmsNotif)
	
	fnSms	= 'F.BTPNSH.SMS.MESSAGE.TEXT'
	fvSms	= ''
	CALL OPF(fnSms,fvSms)
	
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
	
	X			= OCONV(DATE(),"D-")
    Y.TIME		= OCONV(TIME(),"MTS")
    DT			= X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    rTime	= X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
	vTime = FIELD(OCONV( TIME(), 'MTS' ),':',1):':':FIELD(OCONV( TIME(), 'MTS' ),':',2)

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	idFt		= ID.NEW
	vTranType	= R.NEW(FT.TRANSACTION.TYPE)
	vDebAcct	= R.NEW(FT.DEBIT.ACCT.NO)
	vCreAcct	= R.NEW(FT.CREDIT.ACCT.NO)
	vAmount		= R.NEW(FT.DEBIT.AMOUNT)
	vProcDate	= R.NEW(FT.PROCESSING.DATE)
	vChequeNum	= R.NEW(FT.CHEQUE.NUMBER)
	vCreCust	= R.NEW(FT.CREDIT.CUSTOMER)
	
	CALL F.READ(fnParamSms,'SYSTEM',rParamSms,fvParamSms,errParamSms)
    vMinAmount	= rParamSms<SMS.PARAM.MIN.AMOUNT>
	
	sufDebAcct	= vDebAcct[1,2]
	sufvCreAcct	= vCreAcct[1,3]
	vMatDate	= vProcDate[7,2]:'/':vProcDate[5,2]:'/':vProcDate[1,4]
	idAa		= FIELD(vChequeNum,'*',1)
	idCateg		= '6601'
	
	CALL F.READ(fnArrangement, idAa, rArrangement, fvArrangement, errAa)
	vProductGroup	= rArrangement<AA.ARR.PRODUCT.GROUP>
	idAccount		= rArrangement<AA.ARR.LINKED.APPL.ID,1>
	idProduct		= rArrangement<AA.ARR.PRODUCT>
	vArrStatus		= rArrangement<AA.ARR.ARR.STATUS>
	
	CALL F.READ(fnAcc, idAccount, rAcc, fvAcc, errAcc)
	vCateg		= rAcc<AC.CATEGORY>
	
	CALL F.READ(fnCus, vCreCust, rCus, fvCus, errCus)
	vSmsNo		= rCus<EB.CUS.SMS.1,1>
	vSmsFlag	= rCus<EB.CUS.LOCAL.REF,vCusSmsYNPos>
	vMbibFlag	= rCus<EB.CUS.LOCAL.REF,vCusMbibFlagPos>
	
	CALL F.READ(fnProduct, idProduct, rAaProduct, fvProduct,errAaProd)
    vProdDesc	= rAaProduct<AA.PDT.DESCRIPTION>
	
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
	vLMatMode	= rTermAmount<AA.AMT.LOCAL.REF,vLMatModePos>
	
	CALL F.READ(fnAcc, vCreAcct, rAcct, fvAcc, errAa)
	idAaRekSum	= rAcct<AC.ARRANGEMENT.ID>

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
	CASE vLMatMode EQ 'SINGLE MATURITY'
		vAroStatus	= 'NON ARO'
	CASE vLMatMode EQ 'PRINCIPAL ONLY ROLLOVER'
		vAroStatus	= 'ARO1'
	CASE vLMatMode EQ 'PRINCIPAL + PROFIT ROLLOVER'
		vAroStatus	= 'ARO2'
	END CASE
	
	BEGIN CASE
	CASE vTranType NE 'ACRD'
		RETURN
	CASE sufDebAcct NE 'PL'
		RETURN
	CASE sufvCreAcct EQ 'IDR'
		RETURN
	CASE vAroStatus	EQ 'ARO2' AND vArrStatus NE 'PENDING.CLOSURE'
		RETURN
*	CASE vAroStatus	EQ 'ARO2'
*		RETURN
	CASE vCateg NE '6601'
		RETURN
	CASE vAmount LT vMinAmount
		RETURN
	CASE 1
		GOSUB PROCESS.WRITE
	END CASE	

    RETURN

*-----------------------------------------------------------------------------
PROCESS.WRITE:
*-----------------------------------------------------------------------------
	CALL F.READ(fnArrangement, idAaRekSum, rArrangementJoin, fvArrangement, errAa)
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
	
	vAcctCr		= vCreAcct
	vAcctDb		= vDebAcct
	vProdDesc	= 'TD'
	vCoName		= ''
	vAro		= vAroStatus:'|':vTerm
	vSmsCode	= 'DEPAUTODEBBGHS'
	idSmsText	= '13' ;*Bagihasil Deposito
	
	vAmount	= FMT(vAmount,'18L,')
    CHANGE ',' TO '.' IN vAmount
	CHANGE ' ' TO '' IN vAmount
	
	idStmtNos		= R.NEW(FT.STMT.NOS,1):'000':R.NEW(FT.STMT.NOS,2)
    idArrangement	= idAa:'-':idFt:'.':X
	
	CALL F.READ(fnBtpnsThQueueSmsNotif,idArrangement,rSmsQueue,fvBtpnsThQueueSmsNotif,errSms)
    rSmsQueue<SMS.NOTIF.ID.SMS>						= idFt
	rSmsQueue<SMS.NOTIF.ID.TEXT.SMS>				= idSmsText
	rSmsQueue<SMS.NOTIF.DESC.SMS>					= vSmsCode
	rSmsQueue<SMS.NOTIF.SMS.FLAG>					= vSmsFlag:'|':vSmsNo
	rSmsQueue<SMS.NOTIF.INBOX.FLAG>					= vMbibFlag
	rSmsQueue<SMS.NOTIF.PRODUCT.FLAG>				= vFprdSmsFlag
	rSmsQueue<SMS.NOTIF.AMOUNT>						= vAmount
	rSmsQueue<SMS.NOTIF.ACCOUNT.CR>					= vAcctCr
	rSmsQueue<SMS.NOTIF.ACCOUNT.DB>					= vAcctDb
	rSmsQueue<SMS.NOTIF.TIME>						= vTime
	rSmsQueue<SMS.NOTIF.DATE>						= vMatDate
	rSmsQueue<SMS.NOTIF.PRODUCT.DESC>				= vProdDesc
	rSmsQueue<SMS.NOTIF.COMPANY>					= vCoName
	rSmsQueue<SMS.NOTIF.ARO.STATUS>					= vAro
	rSmsQueue<SMS.NOTIF.LOCAL.REF,vCustomerIdPos>	= idCustomer
	rSmsQueue<SMS.NOTIF.DATE.TIME>					= rTime
	rSmsQueue<SMS.NOTIF.INPUTTER>					= OPERATOR
	rSmsQueue<SMS.NOTIF.AUTHORISER>					= OPERATOR
	rSmsQueue<SMS.NOTIF.CO.CODE>					= ID.COMPANY
	
	CALL BTPNS.GET.SMS.TEXT(idSmsText,idAa,vAmount,vAcctCr,vAcctDb,vProcessingDate,vTime,vAroStatus,vTerm,vProdDesc,vCoName,vMessage)
	
	rSmsQueue<SMS.NOTIF.LOCAL.REF,vFinaLMssgPos>	= vMessage
	
	WRITE rSmsQueue TO fvBtpnsThQueueSmsNotif,idArrangement
	
	RETURN
	
*-----------------------------------------------------------------------------
END
