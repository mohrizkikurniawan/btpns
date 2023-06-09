*-*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.INQUIRY.LIMIT.SELECT
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia
* Development Date   : 20220916
* Description        : Job untuk memproses Data Textfile
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
	$INSERT I_F.ATI.TH.LIQ.GENERAL.PARAM
	$INSERT I_BTPNS.MT.INQUIRY.LIMIT.COMMON
	
*----------------------------------------------------------------------

	GOSUB PROCESS
	
    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	SEL.CMD	= "SELECT " : FN.PROCESS
	CALL EB.READLIST(SEL.CMD, SEL.LIST, "", SEL.CNT, SEL.ERR)
	
	FOR X = 1 TO SEL.CNT
		Y.FILE.ID		= SEL.LIST<X>
		Y.TYPE.FILE		= RIGHT(Y.FILE.ID,4)
		IF Y.TYPE.FILE EQ ".txt" THEN
			rListRec<-1>	= Y.FILE.ID
		END
	NEXT X
	
	rListRec		= CHANGE(CHANGE(CHANGE(rListRec, CRLF, @FM),CR, @FM),LF, @FM)
	CALL BATCH.BUILD.LIST('', rListRec)

	RETURN

*-----------------------------------------------------------------------------
END




