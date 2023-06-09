    SUBROUTINE ATI.POST.CLOSE.SUMMRY
*-----------------------------------------------------------------------------
* Developer Name     : Saidah Manshuroh
* Development Date   : 20201015
* Description        : Routine for update ATI.TH.AA.SUMMARY>STATUS
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description		: 
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
	$INSERT I_F.ATI.TH.AA.SUMMARY
	$INSERT	I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_AA.ACTION.CONTEXT
	$INSERT I_F.AA.SETTLEMENT
	$INSERT I_F.ACCOUNT
	$INSERT I_F.ACCOUNT.CLOSURE
	$INSERT I_AA.ACTION.CONTEXT
	$INSERT I_F.AA.ARRANGEMENT
	COMMON/AUTO.CLOSE.NTA.COM/Y.AA.ID,Y.PAYIN.ACCOUNT

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
    GOSUB INIT
    GOSUB PROCESS

	product		= c_aalocArrangementRec<AA.ARR.PRODUCT>

	IF product EQ 'BTPNS.MUR.PAYLATER.EXT' THEN
		GOSUB NTA.CLOSE
	END

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	FN.ATI.TH.AA.SUMMARY		= "F.ATI.TH.AA.SUMMARY"
	F.ATI.TH.AA.SUMMARY			= ""
	CALL OPF(FN.ATI.TH.AA.SUMMARY, F.ATI.TH.AA.SUMMARY)	

	Y.ARRANGEMENT.ID			= c_aalocArrId
	Y.ACTIVITY.STATUS 			= c_aalocActivityStatus
	
    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	CALL F.READ(FN.ATI.TH.AA.SUMMARY, Y.ARRANGEMENT.ID, R.ATI.TH.AA.SUMMARY, F.ATI.TH.AA.SUMMARY, Y.ERR.ATI.TH.AA.SUMMARY)
	
	BEGIN CASE
	
		CASE Y.ACTIVITY.STATUS EQ 'AUTH' 
			R.ATI.TH.AA.SUMMARY<AA.SUM.STATUS>	= "CLOSED"
			CALL ID.LIVE.WRITE(FN.ATI.TH.AA.SUMMARY, Y.ARRANGEMENT.ID, R.ATI.TH.AA.SUMMARY)
			
		CASE Y.ACTIVITY.STATUS EQ 'AUTH-REV' 
			R.ATI.TH.AA.SUMMARY<AA.SUM.STATUS>	= ""
			CALL ID.LIVE.WRITE(FN.ATI.TH.AA.SUMMARY, Y.ARRANGEMENT.ID, R.ATI.TH.AA.SUMMARY)
			
	END CASE
	
		
    RETURN
*-----------------------------------------------------------------------------
NTA.CLOSE:
*-----------------------------------------------------------------------------
	
*	IF c_arrActivityStatus NE "AUTH" THEN RETURN

	FN.AA.SETTLEMENT	= 'F.AA.ARR.SETTLEMENT'
	F.AA.SETTLEMENT	= ''
	CALL OPF(FN.AA.SETTLEMENT, F.AA.SETTLEMENT)
	
	FN.ACCOUNT = 'F.ACCOUNT'
	F.ACCOUNT = ''
	CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    IF Y.AA.ID NE AA$ARR.ID THEN
        Y.AA.ID = AA$ARR.ID
    END ELSE
        RETURN
    END

	idLinkRef 	= ''
	CALL AA.PROPERTY.REF(Y.AA.ID, 'SETTLEMENT', idLinkRef)
	
	CALL F.READ(FN.AA.SETTLEMENT, idLinkRef, R.AA.SET, F.AA.SETTLEMENT, ERR.AA.SETTLEMENT)
	Y.PAYIN.ACCOUNT = R.AA.SET<AA.SET.PAYIN.ACCOUNT>
	Y.PAYOUT.ACCOUNT = R.AA.SET<AA.SET.PAYOUT.ACCOUNT>
	
	CALL F.READ(FN.ACCOUNT, Y.PAYIN.ACCOUNT, R.ACCOUNT, F.ACCOUNT, ERR.ACCOUNT)
	Y.CO.CODE = R.ACCOUNT<AC.CO.CODE>
    IF NOT(R.ACCOUNT) THEN RETURN

	IF R.AA.SET THEN GOSUB PROCESS.OFS.CLOSURE
	
		
    RETURN
*-----------------------------------------------------------------------------
PROCESS.OFS.CLOSURE:
*-----------------------------------------------------------------------------	

	Y.OFS.SOURCE     = "ATI.OFS"
    Y.APP.NAME       = "ACCOUNT.CLOSURE"
    Y.OFS.FUNCT      = "I"
    Y.PROCESS        = "PROCESS"
    Y.OFS.VERSION    = Y.APP.NAME : ",INPUT"
    Y.GTS.MODE       = ""
    Y.NO.OF.AUTH     = 0
    Y.TRANSACTION.ID = Y.PAYIN.ACCOUNT
    Y.OPTIONS        = OPERATOR

    R.AC.CLOSURE.OFS     = ""
    R.AC.CLOSURE.OFS<AC.ACL.SETTLEMENT.ACCT>     	= Y.PAYOUT.ACCOUNT
    R.AC.CLOSURE.OFS<AC.ACL.POSTING.RESTRICT>     	= 90
    R.AC.CLOSURE.OFS<AC.ACL.CAP.INTEREST>     		= 'WAIVE'
    R.AC.CLOSURE.OFS<AC.ACL.CLOSE.ONLINE>     		= 'Y'

    CALL LOAD.COMPANY(Y.CO.CODE)
    CALL OFS.BUILD.RECORD(Y.APP.NAME, Y.OFS.FUNCT, Y.PROCESS, Y.OFS.VERSION, Y.GTS.MODE, Y.NO.OF.AUTH, Y.TRANSACTION.ID, R.AC.CLOSURE.OFS, Y.OFS.MESSAGE)

    OFS.MESSAGE = Y.OFS.MESSAGE
*    CALL OFS.GLOBUS.MANAGER(OFS.SOURCE.ID,OFS.MESSAGE)
*    CALL OFS.CALL.BULK.MANAGER(Y.OFS.SOURCE, Y.OFS.MESSAGE, Y.OFS.RESPONSE, Y.TXN.RESULT)
*   MSG.ID = ""
   CALL OFS.POST.MESSAGE(Y.OFS.MESSAGE, MSG.ID, Y.OFS.SOURCE, Y.OPTIONS)	;*Posting OFS MESSAGE

*
	
    RETURN
*-----------------------------------------------------------------------------	
	END
