*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.INQUIRY.LIMIT.LOAD
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia
* Development Date   : 20220916
* Description        : Job untuk memproses Data textfile
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.LIMIT
	$INSERT I_F.ACCOUNT
	$INSERT I_F.AA.ACCOUNT
	$INSERT I_F.AA.ACCOUNT.DETAILS
	$INSERT I_F.ATI.TH.LIQ.GENERAL.PARAM
	$INSERT I_F.AA.BILL.DETAILS
	$INSERT I_BTPNS.MT.INQUIRY.LIMIT.COMMON
	
*-----------------------------------------------------------------------------
    GOSUB INIT
	
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
	
	FN.LIMIT = "F.LIMIT"
    F.LIMIT  = ""
    CALL OPF(FN.LIMIT,F.LIMIT)
	
	FN.LIMIT.LIABILITY = "F.LIMIT.LIABILITY"
	F.LIMIT.LIABILITY = ""
	CALL OPF(FN.LIMIT.LIABILITY,F.LIMIT.LIABILITY)
	
	FN.ATI.TH.LIQ.GENERAL.PARAM	= "F.ATI.TH.LIQ.GENERAL.PARAM"
	F.ATI.TH.LIQ.GENERAL.PARAM	= ""
	CALL OPF(FN.ATI.TH.LIQ.GENERAL.PARAM,F.ATI.TH.LIQ.GENERAL.PARAM)
	
	CALL F.READ(FN.ATI.TH.LIQ.GENERAL.PARAM,"INQUIRY.LIMIT",R.ATI.TH.LIQ.GENERAL.PARAM,F.ATI.TH.LIQ.GENERAL.PARAM,LIQ.PAR.ERR)
	Y.PATH.ID = R.ATI.TH.LIQ.GENERAL.PARAM<LIQ.GEN.PAR.PATH.ID>
	
	FN.PROCESS 	= Y.PATH.ID:"/Process"
	OPEN FN.PROCESS TO F.PROCESS ELSE
        Y.EXEC.CMD = "CREATE.FILE ":FN.PROCESS:" TYPE=UD"
        EXECUTE Y.EXEC.CMD
        OPEN FN.PROCESS TO F.PROCESS ELSE
            RETURN
        END
    END

	FN.BACKUP 	= Y.PATH.ID:"/Backup"
	OPEN FN.BACKUP TO F.BACKUP ELSE
        Y.EXEC.CMD = "CREATE.FILE ":FN.BACKUP:" TYPE=UD"
        EXECUTE Y.EXEC.CMD
        OPEN FN.BACKUP TO F.BACKUP ELSE
            RETURN
        END
    END

	FN.RESULT 	= Y.PATH.ID:"/Result"
	OPEN FN.RESULT TO F.RESULT ELSE
        Y.EXEC.CMD = "CREATE.FILE ":FN.RESULT:" TYPE=UD"
        EXECUTE Y.EXEC.CMD
        OPEN FN.RESULT TO F.RESULT ELSE
            RETURN
        END
    END	
	
    RETURN
	
*-----------------------------------------------------------------------------

END





