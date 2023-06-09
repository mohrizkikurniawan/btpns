*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BLOCKED.AMOUNT.LOAD
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
	$INSERT I_F.ACCOUNT
	$INSERT I_F.AC.LOCKED.EVENTS
	$INSERT I_F.ATI.TH.LIQ.GENERAL.PARAM
	$INSERT I_BTPNS.MT.BLOCKED.AMOUNT.COMMON
	
*-----------------------------------------------------------------------------
    GOSUB INIT
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	fnLockedEvents	= "F.AC.LOCKED.EVENTS"
	fvLockedEvents	= ""
	CALL OPF(fnLockedEvents, fvLockedEvents)
	
	fnAccount	= "F.ACCOUNT"
	fvAccount	= ""
	CALL OPF(fnAccount, fvAccount)
	
	FN.BTPNS.TT.DUP.UPLOAD.FILE	= "F.BTPNS.TT.DUP.UPLOAD.FILE"
	F.BTPNS.TT.DUP.UPLOAD.FILE	= ""
	CALL OPF(FN.BTPNS.TT.DUP.UPLOAD.FILE, F.BTPNS.TT.DUP.UPLOAD.FILE)
	
	FN.ATI.TH.LIQ.GENERAL.PARAM	= "F.ATI.TH.LIQ.GENERAL.PARAM"
	F.ATI.TH.LIQ.GENERAL.PARAM	= ""
	CALL OPF(FN.ATI.TH.LIQ.GENERAL.PARAM, F.ATI.TH.LIQ.GENERAL.PARAM)
	
	CALL F.READ(FN.ATI.TH.LIQ.GENERAL.PARAM,"BLOCKED.AMOUNT",R.ATI.TH.LIQ.GENERAL.PARAM,F.ATI.TH.LIQ.GENERAL.PARAM,LIQ.PAR.ERR)
	Y.PATH.ID = R.ATI.TH.LIQ.GENERAL.PARAM<LIQ.GEN.PAR.PATH.ID>
	
	FN.PROCESS 	= Y.PATH.ID:"/Process"
	OPEN FN.PROCESS TO F.PROCESS ELSE
        Y.EXEC.CMD = 'CREATE.FILE ':FN.PROCESS:' TYPE=UD'
        EXECUTE Y.EXEC.CMD
        OPEN FN.PROCESS TO F.PROCESS ELSE
            RETURN
        END
    END

	FN.BACKUP 	= Y.PATH.ID:"/Backup"
	OPEN FN.BACKUP TO F.BACKUP ELSE
        Y.EXEC.CMD = 'CREATE.FILE ':FN.BACKUP:' TYPE=UD'
        EXECUTE Y.EXEC.CMD
        OPEN FN.BACKUP TO F.BACKUP ELSE
            RETURN
        END
    END

	FN.RESULT 	= Y.PATH.ID:"/Result"
	OPEN FN.RESULT TO F.RESULT ELSE
        Y.EXEC.CMD = 'CREATE.FILE ':FN.RESULT:' TYPE=UD'
        EXECUTE Y.EXEC.CMD
        OPEN FN.RESULT TO F.RESULT ELSE
            RETURN
        END
    END	
	
    RETURN
	
*-----------------------------------------------------------------------------

END





