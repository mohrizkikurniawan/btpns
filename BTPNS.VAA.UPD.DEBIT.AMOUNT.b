	SUBROUTINE BTPNS.VAA.UPD.DEBIT.AMOUNT
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 12 September 2022
* Description        : write successed when authorized
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : 
* Modified by        : 
* Description        : 
*-----------------------------------------------------------------------------

	$INSERT I_COMMON
	$INSERT I_EQUATE
	$INSERT I_BATCH.FILES
	$INSERT I_TSA.COMMON
	$INSERT I_F.FUNDS.TRANSFER


*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	

	vRecordStatus	= R.NEW(FT.RECORD.STATUS)

	IF vRecordStatus EQ 'IHLD' THEN RETURN
	GOSUB INIT
	GOSUB PROCESS

	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

*	arrApp<1> = "FUNDS.TRANSFER"
*
*	arrFld<1,1> = "ATI.TXN.FLAG"
*
*	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
*	vAtiTxnFlagPos 	= arrPos<1,1>

	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------


*	R.NEW(FT.LOCAL.REF)<1,vAtiTxnFlagPos>	= ""

	vOfsMessageRequest = "FUNDS.TRANSFER,/I/PROCESS/0/1,//":ID.COMPANY:",":ID.NEW:",ATI.TXN.FLAG:1:1="
	OFS.MSG.ID    = ''
	OPTIONS       = OPERATOR
	Y.OFS.TEMP.MESSAGE = vOfsMessageRequest
	Y.OFS.SOURCE	   = 'BIFAST'
	CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)


	RETURN
*-----------------------------------------------------------------------------
END




