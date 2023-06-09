*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.INQUIRY.LIMIT(rFileName)
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia
* Development Date   : 20220916
* Description        : Job for generate several data by cif id to textfile
*						>> BNK/ATI.BM.AGRI.BULK.POST.PROCESS
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* 
*-----------------------------------------------------------------------------

    $INSERT I_F.ATI.TH.PRODUCT.PARAMETER
    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.LIMIT
	$INSERT I_F.ACCOUNT
	$INSERT I_F.AA.ACCOUNT
	$INSERT I_F.AA.ACCOUNT.DETAILS
	$INSERT I_F.AA.BILL.DETAILS
	$INSERT I_F.ATI.TH.LIQ.GENERAL.PARAM
	$INSERT I_BTPNS.MT.INQUIRY.LIMIT.COMMON
	
*-----------------------------------------------------------------------------
	
    GOSUB INIT	
	GOSUB FINAL.WRITE
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	FN.ACCT.DET = "F.AA.ACCOUNT.DETAILS"
    F.ACCT.DET  = ""
    CALL OPF(FN.ACCT.DET,F.ACCT.DET)
	
	FN.AA.BILL.DETAILS    = "F.AA.BILL.DETAILS"
    F.AA.BILL.DETAILS     = ""
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)
	
	FN.ACCT	= "F.ACCOUNT"
	F.ACCT	= ""
	CALL OPF(FN.ACCT,F.ACCT)
	
	rListRec = ""
	CALL F.READ(FN.PROCESS, rFileName, rListRec, F.PROCESS, ERR.PROCESS)
	
	FOR Y = 1 TO DCOUNT(rListRec, FM)
		idCif	= rListRec<Y>
		GOSUB PROCESS
	NEXT Y
	
    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	CALL F.READ(FN.LIMIT.LIABILITY, idCif, R.LIMIT.LIABILITY, F.LIMIT.LIABILITY, ERR.LIMIT.LIABILITY)
	Y.CLN		= R.LIMIT.LIABILITY
	Y.CLN.CNT	= DCOUNT(Y.CLN, FM)

	FOR X = 1 TO Y.CLN.CNT
		vInternalAmount	= 0
		vApprovalDate	= ""
		vExpiryDate		= ""
		vAvailAmount	= 0
		vAvailMarker	= ""
		vReducingLimit	= ""
		vStatusLimit	= ""
		vLimitType		= ""
		vALcnt			= ""
		vAcctList		= ""
	
		idLimit	= R.LIMIT.LIABILITY<X>
		
		CALL F.READ(FN.LIMIT, idLimit, REC.LIMIT, F.LIMIT, ERR.LIMIT)
		vInternalAmount	= REC.LIMIT<LI.INTERNAL.AMOUNT>
		vApprovalDate	= REC.LIMIT<LI.APPROVAL.DATE>
		vExpiryDate		= REC.LIMIT<LI.EXPIRY.DATE>
		vAvailAmount	= REC.LIMIT<LI.AVAIL.AMT>
		vAvailMarker	= REC.LIMIT<LI.AVAILABLE.MARKER>
		vReducingLimit	= REC.LIMIT<LI.REDUCING.LIMIT>
		vStatusLimit	= RIGHT(idLimit,4)
		vStatusLimit	= LEFT(vStatusLimit,1)
		vAcctList		= REC.LIMIT<LI.ACCOUNT>
		vALcnt			= DCOUNT(vAcctList,VM)
		
		IF vStatusLimit EQ 0 THEN
			vLimitType 	= "LIMIT PARENT"
		END ELSE
			vLimitType	= "LIMIT CHILD"
		END
		
		GOSUB GetUseAmt
		GOSUB WRITE
	NEXT X
			
    RETURN

*-----------------------------------------------------------------------------	
GetUseAmt:
*-----------------------------------------------------------------------------
	
	FOR Y=1 TO vALcnt
		vAmount		= 0
		IdBillId	= ''
		idAa		= ''
		IdAcct		= ''
		
		IdAcct	= REC.LIMIT<LI.ACCOUNT,Y>
		CALL F.READ(FN.ACCT,IdAcct,R.ACCT,F.ACCT,errAa)
		idAa	= R.ACCT<AC.ARRANGEMENT.ID>
		
		CALL F.READ(FN.ACCT.DET,idAa,R.ACCT.DET,F.ACCT.DET, errAad)
		IdBillId	= R.ACCT.DET<AA.AD.RPY.BILL.ID,1,1>
		
		CALL F.READ(FN.AA.BILL.DETAILS,IdBillId,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,ERR.BILL)
		vAmount = R.AA.BILL.DETAILS<AA.BD.OR.TOTAL.AMOUNT>
		vTotAmt	=+ vAmount 
	NEXT Y
	RETURN
*-----------------------------------------------------------------------------
WRITE:
*-----------------------------------------------------------------------------

	rAllRec<-1>	= idLimit:"|":vApprovalDate:"|":vExpiryDate:"|":vInternalAmount:"|":vTotAmt:"|":vReducingLimit:"|":vAvailMarker:"|":vLimitType

    RETURN
	
*-----------------------------------------------------------------------------
FINAL.WRITE:
*-----------------------------------------------------------------------------
	
	Y.PROC.ID		= rFileName:".res"
	Y.FILE.BACKUP	= rFileName:".bkp"
	
*---WRITE NEW PROCESS FILE---
	WRITE rAllRec TO F.RESULT, Y.PROC.ID
	
*---WRITE BACKUP FILE---	
	WRITE rListRec TO F.BACKUP,Y.FILE.BACKUP

*---DELETE FILE---
	DELETE F.PROCESS, rFileName
	
	RETURN

*-----------------------------------------------------------------------------
END
