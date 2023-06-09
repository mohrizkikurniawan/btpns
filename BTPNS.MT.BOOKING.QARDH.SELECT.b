*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BOOKING.QARDH.SELECT
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia
* Development Date   : 20220816
* Description        : Job untuk memproses Data textfile
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.ATI.TH.LIQ.GENERAL.PARAM
	$INSERT I_F.LIMIT
	$INSERT I_F.CUSTOMER
	$INSERT I_F.IS.MISCASSET
	$INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.IS.CONTRACT
	$INSERT I_F.ATI.TH.PRODUCT.PARAMETER
	$INSERT I_F.ATI.TH.STAGING.LIQ.AGENT
	$INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.LIMIT
	$INSERT I_F.ACCOUNT
	$INSERT I_BTPNS.MT.BOOKING.QARDH.COMMON
*-----------------------------------------------------------------------------

	GOSUB PROCESS
	
    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	vSelCmd	= "SELECT " : fnProcess
	CALL EB.READLIST(vSelCmd, vSelList, "", vSelCnt, errSel)
	
	FOR X = 1 TO vSelCnt
		idFile			= vSelList<X>
		idRawFile		= idFile
		idRecDupFile	= idFile:".DISB.INDV.FINACING"
		idBkpFile		= idFile:".bkp"
		vTypeFile		= RIGHT(idFile,3)
		IF vTypeFile EQ "txt" THEN
			GOSUB GET.DATA
		END
	NEXT X
	
	rListRec	= CHANGE(CHANGE(CHANGE(rListRec, CRLF, @FM),CR, @FM),LF, @FM)
	CALL BATCH.BUILD.LIST('', rListRec)

	RETURN

*-----------------------------------------------------------------------------
GET.DATA:
*-----------------------------------------------------------------------------

	CALL F.READ(fnBtpnsTtDup, idRecDupFile, recBtpnsTtDup, fvBtpnsTtDup, BTPNS.DUP.ERR)
	
	IF recBtpnsTtDup THEN
		vError		= "Nama textfile sudah pernah digunakan"
		vDataError	= idFile :"|DUPLICATE|": vError
		fvNewFolErr	= fvResult
		idDupFile	= idFile:".dup"
		GOSUB DUP.FILE
	END ELSE
		rListRec<-1>	= idFile
	END
	
    RETURN
*-----------------------------------------------------------------------------
DUP.FILE:
*-----------------------------------------------------------------------------
	CALL F.READ(fnProcess, idFile, recProcess, fvProcess, errProc)
	
*---WRITE DUPLICATE LOG ON RESULT FOLDER---
	WRITE vDataError TO fvNewFolErr,idDupFile
	
	RETURN
	
*-----------------------------------------------------------------------------

END





