*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.ECR.AA.DEPOSITS
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220901
* Description        : Routine to provide AA Deposits information on enquiry
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
    $INCLUDE I_F.CUSTOMER
    $INCLUDE I_F.ACCOUNT
    $INCLUDE I_F.EB.LOOKUP
    $INCLUDE I_F.AA.SETTLEMENT
    $INCLUDE I_F.AA.ARRANGEMENT
    $INCLUDE I_F.AA.ARRANGEMENT.ACTIVITY
    $INCLUDE I_F.AA.ACTIVITY.HISTORY
    $INCLUDE I_F.AA.TERM.AMOUNT
*-----------------------------------------------------------------------------
	DEBUG
	idAa = O.DATA
	O.DATA = ""
	IF idAa[1,2] NE "AA" THEN RETURN
	
	GOSUB Initialise
	GOSUB Process

    RETURN
	
Initialise:

	fnAaArrangement = "F.AA.ARRANGEMENT"
	fvAaArrangement = ""
	CALL OPF(fnAaArrangement, fvAaArrangement)
	
	fnAaArrTermAmount = "F.AA.ARR.TERM.AMOUNT"
	fvAaArrTermAmount = ""
	CALL OPF(fnAaArrTermAmount, fvAaArrTermAmount)
	
	fnAccount = "F.ACCOUNT"
	fvAccount = ""
	CALL OPF(fnAccount,fvAccount)
	
	fnAaActivityHistory = "F.AA.ACTIVITY.HISTORY"
	fvAaActivityHistory = ""
	CALL OPF(fnAaActivityHistory, fvAaActivityHistory)
	
	fnEbLookup = "F.EB.LOOKUP"
	fvEbLookup = ""
	CALL OPF(fnEbLookup, fvEbLookup)
	
	arrApp<1> = "AA.ARR.TERM.AMOUNT"
	arrApp<2> = "ACCOUNT"
	arrFld<1,1> = "L.TENOR"
	arrFld<1,2> = "PERIODE.RSD"
	arrFld<1,3> = "L.MAT.MODE"
	arrFld<2,1> = "L.FINAL.NISBA"
	arrFld<2,2> = "L.TENOR"
	arrFld<2,3> = "ATI.JOINT.NAME"
	arrPos		= ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	fTenorPos	= arrPos<1,1>
	fPeriodPos	= arrPos<1,2>
	fMatModePos	= arrPos<1,3>
	fNisbahPos	= arrPos<2,1>
	fAcTenorPos	= arrPos<2,2>
	fAcNamePos	= arrPos<2,3>
	
	RETURN
	
Process:

	rvEbLookup = ""
	CALL F.READ(fnEbLookup, "BIFAST.DEPOSITO*SYSTEM", rvEbLookup, fvEbLookup, "")
	LOCATE "VERSION.POSTING" IN rvEbLookup<EB.LU.DATA.NAME,1> SETTING vPos THEN
		vVersion = rvEbLookup<EB.LU.DATA.VALUE,vPos>
	END ELSE
		vVersion = "FUNDS.TRANSFER,BTPNS.BFAST.DATA.OUT.CR.MANUAL"
	END
	
	rvAaArrangement = "" ; rvAccount = "" ; vTenor = "" ; vStartDate = "" ; vAltId = ""
	rvAaActivityHistory = "" ; vLastDateRollover = "" ; vLastDateNisbah = ""
	CALL F.READ(fnAaArrangement, idAa, rvAaArrangement, fvAaArrangement, "")
	CALL F.READ(fnAaActivityHistory, idAa, rvAaActivityHistory, fvAaActivityHistory, "")
	
*	LOCATE "DEPOSITS-ROLLOVER-ARRANGEMENT" IN rvAaActivityHistory<AaActivityHistory_>
	FIND "DEPOSITS-ROLLOVER-ARRANGEMENT" IN rvAaActivityHistory<AaActivityHistory_Activity> SETTING vFm, vVm,vSm THEN
		vLastDateRollover = rvAaActivityHistory<AaActivityHistory_SystemDate,vVm,vSm>
	END

	FIND "DEPOSITS-CHANGE.CUR.NISBAH-ACCOUNT" IN rvAaActivityHistory<AaActivityHistory_Activity> SETTING vFm, vVm,vSm THEN
		vLastDateNisbah = rvAaActivityHistory<AaActivityHistory_SystemDate,vVm,vSm>
	END

	idContract = rvAaArrangement<AaArrangement_LinkedApplId,1>
	typeAsset<1> 	= "TOTCOMMITMENT"
	valueAsset = ""
	CALL EB.GET.ECB.TYPE.VAL(idContract, typeAsset, valueAsset)
	vBalCommitment 	= valueAsset<1>
	
	CALL F.READ(fnAccount, idContract, rvAccount, fvAccount, "")
	
	idProperty = 'COMMITMENT'
	idLinkRef = ""
	CALL AA.PROPERTY.REF(idAa, idProperty, idLinkRef)
    CALL F.READ(fnAaArrTermAmount, idLinkRef, rvAaArrTermAmount, fvAaArrTermAmount,'')
    vTenor = rvAaArrTermAmount<AaSimTermAmount_LocalRef,fTenorPos>
	IF NOT(vTenor) THEN vTenor = rvAccount<Account_LocalRef,fAcTenorPos>
	vStartDate = rvAaArrangement<AaArrangement_OrigContractDate>
	IF NOT(vStartDate) THEN vStartDate = rvAccount<Account_OpeningDate>
	IF NOT(vStartDate) THEN vStartDate = rvAaArrangement<AaArrangement_StartDate>
	vAltId = rvAccount<Account_AltAcctId,1>
	IF NOT(vAltId) THEN vAltId = idAa
	vName = rvAccount<Account_LocalRef,fAcNamePos>
	IF NOT(vName) THEN vName = rvAccount<Account_ShortTitle>
	vName = CHANGE(CHANGE(vName, @VM, " "), @SM, " ")
	
    R.RECORD<301> = vTenor
	R.RECORD<302> = rvAaArrTermAmount<AaSimTermAmount_LocalRef,fPeriodPos>
	R.RECORD<303> = rvAaArrTermAmount<AaSimTermAmount_LocalRef,fMatModePos>
	R.RECORD<304> = vBalCommitment
	R.RECORD<305> = vStartDate
	R.RECORD<306> = rvAccount<Account_LocalRef,fNisbahPos>
	R.RECORD<307> = vAltId
	R.RECORD<308> = vLastDateRollover
	R.RECORD<309> = vLastDateNisbah
	R.RECORD<310> = vName
	R.RECORD<311> = vVersion
	
	RETURN

END 