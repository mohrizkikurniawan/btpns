*-*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BLOCKED.AMOUNT.SELECT
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia
* Development Date   : 20220816

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
	$INSERT I_F.ACCOUNT
	$INSERT I_F.AC.LOCKED.EVENTS
	$INSERT I_F.ATI.TH.LIQ.GENERAL.PARAM
	$INSERT I_BTPNS.MT.BLOCKED.AMOUNT.COMMON
	
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
		Y.FILE.RAW		= Y.FILE.ID
		Y.FILE.DUP		= Y.FILE.ID:".BLOCKED.AMT"
		Y.FILE.BACKUP	= Y.FILE.ID:".bkp"
		Y.TYPE.FILE		= RIGHT(Y.FILE.ID,4)
		IF Y.TYPE.FILE EQ ".txt" THEN
			GOSUB GET.DATA
		END
	NEXT X
	
	rListRec		= CHANGE(CHANGE(CHANGE(rListRec, CRLF, @FM),CR, @FM),LF, @FM)
	CALL BATCH.BUILD.LIST('', rListRec)
	
	RETURN

*-----------------------------------------------------------------------------
GET.DATA:
*-----------------------------------------------------------------------------

	CALL F.READ(FN.BTPNS.TT.DUP.UPLOAD.FILE, Y.FILE.DUP, R.BTPNS.DUP, F.BTPNS.TT.DUP.UPLOAD.FILE, BTPNS.DUP.ERR)
	
	IF R.BTPNS.DUP THEN
		Y.ERROR			= "Nama textfile sudah pernah digunakan"
		Y.DATA.ERROR	= Y.FILE.ID :"|DUPLICATE|": Y.ERROR
		F.NEW.FOL.ERROR	= F.RESULT
		Y.FILE.ID.DUP	= Y.FILE.ID:".dup"
		GOSUB DUP.FILE
	END ELSE
		rListRec<-1>	= Y.FILE.ID
	END
	
    RETURN
*-----------------------------------------------------------------------------
DUP.FILE:
*-----------------------------------------------------------------------------
	
*---WRITE DUPLICATE LOG ON RESULT FOLDER---
	WRITE Y.DATA.ERROR TO F.NEW.FOL.ERROR,Y.FILE.ID.DUP

	RETURN
*-----------------------------------------------------------------------------
END




