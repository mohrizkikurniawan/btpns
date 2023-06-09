    SUBROUTINE BTPNS.AA.PST.ACCT.CLOSURE.OFS
*-----------------------------------------------------------------------------
* Developer Name    : Hillmar Fatkhul Ilmi
* Development Date  : 04 Jan 2023
* Description       : 
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date              :
* Modified by       :
* Description       :
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_AA.APP.COMMON
	$INSERT I_AA.LOCAL.COMMON
	$INSERT I_AA.ACTION.CONTEXT
	$INSERT I_F.AA.SETTLEMENT
	$INSERT I_F.ACCOUNT
	$INSERT I_F.ACCOUNT.CLOSURE
    COMMON/AUTO.CLOSE.NTA.COM/Y.AA.ID,Y.PAYIN.ACCOUNT
    
    IF c_arrActivityStatus NE "AUTH" THEN RETURN

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------	

	FN.AA.SETTLEMENT	= 'F.AA.ARR.SETTLEMENT'
	F.AA.SETTLEMENT	= ''
	CALL OPF(FN.AA.SETTLEMENT, F.AA.SETTLEMENT)
	
	FN.ACCOUNT = 'F.ACCOUNT'
	F.ACCOUNT = ''
	CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------	

    IF Y.AA.ID NE AA$ARR.ID THEN
        Y.AA.ID = AA$ARR.ID
    END ELSE
        RETURN
    END

*	IF Y.AA.ID EQ 'AA22284MK02J' THEN DEBUG
*	IF Y.AA.ID EQ 'AA22284GP4S9' THEN DEBUG

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

