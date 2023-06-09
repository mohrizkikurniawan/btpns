*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.STO.DEPO.SELECT
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220809
* Description        : Routine to build BIFAST Deposito Standing Order
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
    $INCLUDE I_F.EB.LOOKUP
	$INCLUDE I_F.ACCOUNT
*-----------------------------------------------------------------------------
	
	COMMON/BIFAST.DEPO.STO.COM/fnTableParam,fvTableParam,fnAcctEntToday,fvAcctEntToday,fnStmtEntry,fvStmtEntry,
	fnTableTmp,fvTableTmp,fnAaArrangement,fvAaArrangement,fnAccount,fvAccount,fnEbLookup,fvEbLookup,fnFundsTransfer,fvFundsTransfer,
	fnFundsTransferHis,fvFundsTransferHis,fnAaArrSettlement,fvAaArrSettlement,fOthFlagPos,fOthTypePos,fDestAccPos,fDestNamePos,
	fProxyTypePos,fProxyIdPos,fDestBnkPos,fDestNameBIPos,fComCodePos,fComTypePos,idCategory,fnCustomer,fvCustomer,fCustTypePos,
	fLegalIDPos,fnTableInfo,fvTableInfo,fnAaArrangementActivity,fvAaArrangementActivity,fnRsdParameter,fvRsdParameter,fComAmtPos,fChargePenPos,
	fChargeBifastPos,fnFtCommissionType,fvftCommissionType,fComCodePos,FN.BTPNS.TL.BFAST.INTERFACE.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,
	vPercenTax,vOfsSource,vNarrProfit,vNarrPrincipal,vVersion,fMatModePos,fnAaArrTermAmount,fvAaArrTermAmount,fJnamePos,fChargeAddPos,fChargeAddAmtPos,fnIdiuDepoRtgs,fvIdiuDepoRtgs,fnIdiuStodepoClearing,fvIdiuStodepoClearing,fSysTaxablePos
	
	IF NOT(idCategory) THEN
		CALL OCOMO("Category SUSPENSE.CATEG must be set on ":fnEbLookup:">BIFAST.DEPOSITO*SYSTEM")
		RETURN
	END
	
	qryCmd = "SELECT ":fnAccount:" WITH CATEGORY EQ ":idCategory
	CALL EB.READLIST(qryCmd, qryList, "", qryNo, "")
	IF NOT(qryList) THEN RETURN
	
	vArray = ""
	FOR idx=1 TO qryNo
		idAccount = qryList<idx>
		rvAcctEntToday = ""
		CALL F.READ(fnAcctEntToday, idAccount, rvAcctEntToday, fvAcctEntToday, "")
		IF rvAcctEntToday THEN
			CALL OCOMO("Processing ":idAccount:" with ":DCOUNT(rvAcctEntToday, @FM):" entries")
			vArray<-1> = rvAcctEntToday
		END
	NEXT idx
	
	IF NOT(vArray) THEN RETURN
	
	CALL OCOMO("Entries to check: ":DCOUNT(vArray, @FM):" entries")
	
	vList = "" ; vParams = "" ; vSelectionFilter = ""
	fnTableTmp = ""
	
	vList = vArray
	
	vParams<1> = ""
	vParams<2> = fnTableTmp
	vParams<3> = vSelectionFilter
	vParams<6> = ""
	vParams<7> = ""
	CALL BATCH.BUILD.LIST(vParams,vList)

    RETURN

END 