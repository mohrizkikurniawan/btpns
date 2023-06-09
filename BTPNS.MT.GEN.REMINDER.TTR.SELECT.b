*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.GEN.REMINDER.TTR.SELECT
*-----------------------------------------------------------------------------
* Developer Name     : Kania Farhaning Lydia
* Development Date   : 4 Oktober 2022
* Description        : Routine To send SMS notification for Open and Close product Account and Deposito. Autodebit (success/fail) TTR/Savplan. Rollover Deposito.
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
	
	$INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.DATES
	$INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.ACTION.CONTEXT
	$INSERT I_F.BTPNS.TH.QUEUE.SMS.NOTIF
	$INSERT I_BTPNS.MT.GEN.REMINDER.TTR.COMMON

	GOSUB PROCESS
	
	RETURN
*------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------
	
	SelCmd	= "SELECT ":fnArrangement:" WITH PRODUCT.GROUP EQ BTPNS.TMIB AND ARR.STATUS NE CLOSE"
	CALL EB.READLIST(SelCmd,SelList,'','','')
	
	CALL BATCH.BUILD.LIST("",SelList)
	
	RETURN
*------------------------------------------------------------------------------
END