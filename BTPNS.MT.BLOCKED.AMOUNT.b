*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BLOCKED.AMOUNT(rFileName)
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia
* Development Date   : 20220816
* Description        : Job untuk memproses Data textfile terkait disburse murabaha
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
	$INSERT I_F.ACCOUNT
	$INSERT I_F.AC.LOCKED.EVENTS
	$INSERT I_F.ATI.TH.LIQ.GENERAL.PARAM
	$INSERT I_BTPNS.MT.BLOCKED.AMOUNT.COMMON
	
*-----------------------------------------------------------------------------

	Y.OFS.SOURCE	= "FINANCING.OFS"
    GOSUB INIT	
	GOSUB FINAL.WRITE
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	CALL F.READ(FN.PROCESS, rFileName, rListRec, F.PROCESS, ERR.PROCESS)
	
	FOR Y = 1 TO DCOUNT(rListRec, FM)
		idAccount	= ""
		vAmount		= 0
		vStatus		= ""
		rAccountRec	= rListRec<Y>
		GOSUB PROCESS
	NEXT Y
	
    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	idAccount	= FIELD(rAccountRec,"|",1)
	vAmount		= FIELD(rAccountRec,"|",2)
	vIdLock		= FIELD(rAccountRec,"|",3)
	vStatus		= FIELD(rAccountRec,"|",4)
	
	CALL F.READ(fnAccount, idAccount, rAccount, fvAccount, ERR.AC)
    vCoCode	= rAccount<AC.CO.CODE>
	
	CALL F.READ(fnLockedEvents, vIdLock, rAcLockEvent, fvLockedEvents, ERrAcLockEvent)
	Y.FROM.DATE      	= rAcLockEvent<AC.LCK.FROM.DATE>
	Y.AMOUNT.LOCK    	= rAcLockEvent<AC.LCK.LOCKED.AMOUNT>
	
	BEGIN CASE
	CASE rAccount EQ ""
		vRespError	= "@ID ":idAccount:" RECORD MISSING"
		GOSUB vFailed
	CASE vAmount EQ ""
		vRespError	= "AMOUNT BLOCKED CANNOT BE NULL"
		GOSUB vFailed
	CASE vIdLock EQ "" AND vStatus EQ "UNBLOCKED"
		vRespError	= "ID LOCKED CANNOT BE NULL"
		GOSUB vFailed
	CASE rAcLockEvent EQ "" AND vStatus EQ "UNBLOCKED" 
		vRespError	= "@ID ":vIdLock:" IS MISSING"
		GOSUB vFailed
	CASE 1
		BEGIN CASE
		CASE vStatus EQ "BLOCKED"
			GOSUB vProcessLock
		CASE vStatus EQ "UNBLOCKED"
			GOSUB vProcessReve
		CASE 2
			vRespError	= "STATUS MUST BE BLOCK OR UNBLOCKED"
			GOSUB vFailed
		END CASE
	END CASE

    RETURN
	
*-----------------------------------------------------------------------------
vProcessLock:
*-----------------------------------------------------------------------------

    Y.APP.NAME			= "AC.LOCKED.EVENTS"
    Y.OFS.FUNCT			= "I"
    Y.PROCESS			= "PROCESS"
    Y.OFS.VERSION		= Y.APP.NAME : ",ATI.OFS"
    Y.GTS.MODE			= ""
    Y.NO.OF.AUTH		= ""
    Y.TRANSACTION.ID	= ""
    Y.OFS.RESPONSE		= ""
    R.ACL.OFS			= ""
    Y.FLAG.PROCESS		= ""

	R.ACL.OFS<AC.LCK.ACCOUNT.NUMBER>	= idAccount
	R.ACL.OFS<AC.LCK.LOCKED.AMOUNT>		= vAmount
	R.ACL.OFS<AC.LCK.FROM.DATE>			= TODAY
	R.ACL.OFS<AC.LCK.TO.DATE>			= '20991231'
	R.ACL.OFS<AC.LCK.DESCRIPTION>		= 'BLOKIR SALDO'	
	
	CALL LOAD.COMPANY(vCoCode)
    CALL OFS.BUILD.RECORD(Y.APP.NAME, Y.OFS.FUNCT, Y.PROCESS, Y.OFS.VERSION, Y.GTS.MODE, Y.NO.OF.AUTH, Y.TRANSACTION.ID, R.ACL.OFS, Y.OFS.MESSAGE)
	
    Y.REQUEST.COMMITED = ''
    CALL OFS.CALL.BULK.MANAGER(Y.OFS.SOURCE,Y.OFS.MESSAGE,Y.OFS.RESPONSE,Y.REQUEST.COMMITED)	
	
	Y.OFS.RESPONSE.HDR  = FIELD(Y.OFS.RESPONSE,',',1)
    vFlagProcessLock	= FIELD(Y.OFS.RESPONSE.HDR,'/',3)	
	vIdLock				= FIELD(Y.OFS.RESPONSE, '/', 1)		
	vRespError			= "PROCESS BLOCK - ":FIELD(Y.OFS.RESPONSE,Y.OFS.RESPONSE.HDR:',',2)
	
	
	IF vFlagProcessLock EQ 1 THEN
		GOSUB vSuccess
	END ELSE
		GOSUB vFailed
	END
	
    RETURN
*-----------------------------------------------------------------------------
vProcessReve:
*-----------------------------------------------------------------------------
	
    Y.APP.NAME			= "AC.LOCKED.EVENTS"
    Y.OFS.FUNCT			= "R"
    Y.PROCESS			= "PROCESS"
    Y.OFS.VERSION		= Y.APP.NAME : ",ATI.OFS"
    Y.GTS.MODE			= ""
    Y.NO.OF.AUTH		= ""
    Y.TRANSACTION.ID	= vIdLock
    Y.OFS.RESPONSE		= ""
    R.ACL.OFS			= ""
    Y.FLAG.PROCESS		= ""	
	
	CALL LOAD.COMPANY(vCoCode)
    CALL OFS.BUILD.RECORD(Y.APP.NAME, Y.OFS.FUNCT, Y.PROCESS, Y.OFS.VERSION, Y.GTS.MODE, Y.NO.OF.AUTH, Y.TRANSACTION.ID, R.ACL.OFS, Y.OFS.MESSAGE)
	
    Y.REQUEST.COMMITED = ''
    CALL OFS.CALL.BULK.MANAGER(Y.OFS.SOURCE,Y.OFS.MESSAGE,Y.OFS.RESPONSE,Y.REQUEST.COMMITED)	
	
	Y.OFS.RESPONSE.HDR  = FIELD(Y.OFS.RESPONSE,',',1)
    vFlagReve        	= FIELD(Y.OFS.RESPONSE.HDR,'/',3)	
	idvProcessReve		= FIELD(Y.OFS.RESPONSE, '/', 1)		
	vRespError			= "PROCESS UNBLOCK - ":FIELD(Y.OFS.RESPONSE,Y.OFS.RESPONSE.HDR:',',2)
	
	IF vFlagReve EQ 1 THEN
		GOSUB vSuccess
	END ELSE
		GOSUB vFailed
	END
	
    RETURN

*-----------------------------------------------------------------------------
vFailed:
*-----------------------------------------------------------------------------

	rAllRec<-1>	= rAccountRec:"|ERROR|":vRespError	
	
    RETURN
*-----------------------------------------------------------------------------
vSuccess:
*-----------------------------------------------------------------------------

	rAllRec<-1>	= idAccount:"|":vAmount:"|":vIdLock:"|":vStatus:"|SUCCESS"	

    RETURN
	
*-----------------------------------------------------------------------------
FINAL.WRITE:
*-----------------------------------------------------------------------------
	
	Y.PROC.ID		= rFileName:".res"
	Y.FILE.DUP		= rFileName:".BLOCKED.AMT"
	Y.FILE.BACKUP	= rFileName:".bkp"
	
*---WRITE NEW PROCESS FILE---
	WRITE rAllRec TO F.RESULT, Y.PROC.ID
	
*---WRITE FILE NAME TO TABLE DUPLICATE---	
	WRITE rFileName TO F.BTPNS.TT.DUP.UPLOAD.FILE,Y.FILE.DUP 
	
*---WRITE BACKUP FILE---	
	WRITE rListRec TO F.BACKUP,Y.FILE.BACKUP

*---DELETE FILE---
	DELETE F.PROCESS, rFileName
	
	RETURN

*-----------------------------------------------------------------------------
END
