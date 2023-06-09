*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.STO.DEPO.LOAD
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
    $INCLUDE I_F.IDIH.PMS.CALC.PARAMETER
	$INCLUDE I_F.ACCOUNT
*----------------------------------------------------------------------------
	
	COMMON/BIFAST.DEPO.STO.COM/fnTableParam,fvTableParam,fnAcctEntToday,fvAcctEntToday,fnStmtEntry,fvStmtEntry,
	fnTableTmp,fvTableTmp,fnAaArrangement,fvAaArrangement,fnAccount,fvAccount,fnEbLookup,fvEbLookup,fnFundsTransfer,fvFundsTransfer,
	fnFundsTransferHis,fvFundsTransferHis,fnAaArrSettlement,fvAaArrSettlement,fOthFlagPos,fOthTypePos,fDestAccPos,fDestNamePos,
	fProxyTypePos,fProxyIdPos,fDestBnkPos,fDestNameBIPos,fComCodePos,fComTypePos,idCategory,fnCustomer,fvCustomer,fCustTypePos,
	fLegalIDPos,fnTableInfo,fvTableInfo,fnAaArrangementActivity,fvAaArrangementActivity,fnRsdParameter,fvRsdParameter,fComAmtPos,fChargePenPos,
	fChargeBifastPos,fnFtCommissionType,fvftCommissionType,fComCodePos,FN.BTPNS.TL.BFAST.INTERFACE.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,
	vPercenTax,vOfsSource,vNarrProfit,vNarrPrincipal,vVersion,fMatModePos,fnAaArrTermAmount,fvAaArrTermAmount,fJnamePos,fChargeAddPos,fChargeAddAmtPos,fnIdiuDepoRtgs,fvIdiuDepoRtgs,fnIdiuStodepoClearing,fvIdiuStodepoClearing,fSysTaxablePos
	
	GOSUB Initialise
	GOSUB Process
	
	RETURN
	
Initialise:

	fnRsdParameter = "F.IDIH.PMS.CALC.PARAMETER"
	fvRsdParameter = ""
	CALL OPF(fnRsdParameter, fvRsdParameter)
	
	fnTableInfo = "F.BTPNS.TH.BIFAST.STO.DEPO"
	fvTableInfo = ""
	CALL OPF(fnTableInfo, fvTableInfo)
	
	fnCustomer = "F.CUSTOMER"
	fvCustomer = ""
	CALL OPF(fnCustomer, fvCustomer)
	
	fnAccount = "F.ACCOUNT"
	fvAccount = ""
	CALL OPF(fnAccount, fvAccount)
	
	fnTableTmp = "F.BTPNS.TL.BIFAST.DEPO.STMT.TMP"
	fvTableTmp = ""
	CALL OPF(fnTableTmp, fvTableTmp)
	
	fnAaArrangement = "F.AA.ARRANGEMENT"
	fvAaArrangement = ""
	CALL OPF(fnAaArrangement, fvAaArrangement)
	
	fnAaArrangementActivity = "F.AA.ARRANGEMENT.ACTIVITY"
	fvAaArrangementActivity = ""
	CALL OPF(fnAaArrangementActivity, fvAaArrangementActivity)
	
	fnAcctEntToday = "F.ACCT.ENT.TODAY"
	fvAcctEntToday = ""
	CALL OPF(fnAcctEntToday, fvAcctEntToday)
	
	fnStmtEntry = "F.STMT.ENTRY"
	fvStmtEntry = ""
	CALL OPF(fnStmtEntry, fvStmtEntry)
	
	fnTableParam = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
	fvTableParam = ""
	CALL OPF(fnTableParam, fvTableParam)
	
	fnEbLookup = "F.EB.LOOKUP"
	fvEbLookup = ""
	CALL OPF(fnEbLookup, fvEbLookup)
	
	fnFundsTransfer = "F.FUNDS.TRANSFER"
	fvFundsTransfer = ""
	CALL OPF(fnFundsTransfer, fvFundsTransfer)
	
	fnFundsTransferHis = "F.FUNDS.TRANSFER$HIS"
	fvFundsTransferHis = ""
	CALL OPF(fnFundsTransferHis, fvFundsTransferHis)
	
	fnAaArrSettlement = "F.AA.ARR.SETTLEMENT"
	fvAaArrSettlement = ""
	CALL OPF(fnAaArrSettlement, fvAaArrSettlement)

	fnFtCommissionType = "F.FT.COMMISSION.TYPE"
	fvftCommissionType = ""
	CALL OPF(fnFtCommissionType, fvftCommissionType)

    FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
    F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
    CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)

	fnAaArrTermAmount = "F.AA.ARR.TERM.AMOUNT"
	fvAaArrTermAmount = ""
	CALL OPF(fnAaArrTermAmount, fvAaArrTermAmount)

	fnIdiuDepoRtgs		= "F.IDIU.DEPO.RTGS"
	fvIdiuDepoRtgs		= ""
	CALL OPF(fnIdiuDepoRtgs, fvIdiuDepoRtgs)

	fnIdiuStodepoClearing = "F.IDIU.STODEPO.CLEARING"
	fvIdiuStodepoClearing = ""
	CALL OPF(fnIdiuStodepoClearing, fvIdiuStodepoClearing)

	
	arrApp<1> = "AA.PRD.DES.SETTLEMENT"
	arrApp<2> = "CUSTOMER"
	arrApp<3> = "AA.ARR.TERM.AMOUNT"
	arrApp<4> = "ACCOUNT"

	arrFld<1,1> = "MUD.CLEARED"
	arrFld<1,2> = "SKN.RTGS"
	arrFld<1,3> = "BEN.ACC"
	arrFld<1,4> = "ATI.BEN.NAME"
	arrFld<1,5> = "B.CDTR.PRXYTYPE"
	arrFld<1,6> = "B.CDTR.PRXYID"
	arrFld<1,7> = "B.CDTR.AGTID"
	arrFld<1,8> = "ATI.JNAME.2"
	arrFld<1,9> = "B.COM.CODE"
	arrFld<1,10> = "B.COM.TYPE"
	arrFld<1,11> = "L.PFT.ACC.NUM"
	arrFld<1,12> = "B.COM.AMT"
	arrFld<1,13> = "L.CHARGE"
	arrFld<1,14> = "B.COM.TYPE"
	arrFld<1,15> = "B.COM.CODE"
	arrFld<1,16> = "ATI.JNAME.2"
	arrFld<1,17> = "B.CHARGE.TYPE"
	arrFld<1,18> = "B.CHARGE.AMT"
	arrFld<2,1> = "CUST.TYPE"
	arrFld<2,2> = "LEGAL.ID.NO"
	arrFld<3,1> = "L.MAT.MODE"
	arrFld<4,1> = "SYS.TAXABLE"
	arrPos = ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	fOthFlagPos 	= arrPos<1,1>
	fOthTypePos 	= arrPos<1,2>
	fDestAccPos 	= arrPos<1,3>
	fDestNamePos 	= arrPos<1,4>
	fProxyTypePos 	= arrPos<1,5>
	fProxyIdPos 	= arrPos<1,6>
	fDestBnkPos 	= arrPos<1,7>
	fDestNameBIPos 	= arrPos<1,8>
	fComCodePos 	= arrPos<1,9>
	fComTypePos 	= arrPos<1,10>
	fProfitAccPos 	= arrPos<1,11>
	fComAmtPos 		= arrPos<1,12>
	fChargePenPos	= arrPos<1,13>
	fChargeBifastPos= arrPos<1,14>
	fComCodePos		= arrPos<1,15>
	fJnamePos		= arrPos<1,16>
	fChargeAddPos	= arrPos<1,17>
	fChargeAddAmtPos= arrPos<1,18>
	fCustTypePos 	= arrPos<2,1>
	fLegalIDPos 	= arrPos<2,2>
	fMatModePos	    = arrPos<3,1>
	fSysTaxablePos  = arrPos<4,1>
	
    RETURN

Process:
	
	idParam = "BIFAST.DEPOSITO*SYSTEM"
	rvEbLookup = ""
	idCategory = ""
	CALL F.READ(fnEbLookup, idParam, rvEbLookup, fvEbLookup, "")
	
	IF NOT(rvEbLookup) THEN
		CALL OCOMO("Parameter need to set ":fnEbLookup:">":idParam)
		RETURN
	END
	
	LOCATE "SUSPENSE.CATEG" IN rvEbLookup<EB.LU.DATA.NAME,1> SETTING vPos THEN
		idCategory = rvEbLookup<EB.LU.DATA.VALUE,vPos>
	END ELSE
		CALL OCOMO("Parameter SUSPENSE.CATEG need to set ":fnEbLookup:">":idParam)
		RETURN		
	END
	
	LOCATE "OFS.SOURCE" IN rvEbLookup<EB.LU.DATA.NAME,1> SETTING vPos THEN
		vOfsSource = rvEbLookup<EB.LU.DATA.VALUE,vPos>
	END ELSE
		vOfsSource = "BIFAST"
	END
	
	LOCATE "VERSION.POSTING" IN rvEbLookup<EB.LU.DATA.NAME,1> SETTING vPos THEN
		vVersion = rvEbLookup<EB.LU.DATA.VALUE,vPos>
	END ELSE
		vVersion = "FUNDS.TRANSFER,BTPNS.BFAST.DATA.OUT.CR.MANUAL"
	END
	
	LOCATE "NARR.PROFIT" IN rvEbLookup<EB.LU.DATA.NAME,1> SETTING vPos THEN
		vNarrProfit = rvEbLookup<EB.LU.DATA.VALUE,vPos>
	END ELSE
		vNarrProfit = "BAGI HASIL DEPO "
	END
	
	LOCATE "NARR.PRINCIPAL" IN rvEbLookup<EB.LU.DATA.NAME,1> SETTING vPos THEN
		vNarrPrincipal = rvEbLookup<EB.LU.DATA.VALUE,vPos>
	END ELSE
		vNarrPrincipal = "REDEEM DEPO "
	END
	
	CALL F.READ(fnRsdParameter, "SYSTEM", rvRsdParameter, fvRsdParameter, "")
	vPercenTax = rvRsdParameter<IdihPmsCalcParameter_TaxRate>
	
	RETURN
	
END 