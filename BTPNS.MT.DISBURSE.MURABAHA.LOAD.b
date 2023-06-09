*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.DISBURSE.MURABAHA.LOAD
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
	$INSERT I_F.IS.PARAMETER
	$INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.LIMIT
	$INSERT I_F.ACCOUNT
	$INSERT I_BTPNS.MT.DISBURSE.MURABAHA.COMMON
*-----------------------------------------------------------------------------

    GOSUB INIT
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	FN.IS.PARAMETER	= "F.IS.PARAMETER"
	F.IS.PARAMETER	= ""
	CALL OPF(FN.IS.PARAMETER, F.IS.PARAMETER)
	
	FN.ATI.TH.PRODUCT.PARAMETER	= "F.ATI.TH.PRODUCT.PARAMETER"
	F.ATI.TH.PRODUCT.PARAMETER = ""
	CALL OPF(FN.ATI.TH.PRODUCT.PARAMETER,F.ATI.TH.PRODUCT.PARAMETER)
	
	FN.ATI.TH.LIQ.GENERAL.PARAM	= "F.ATI.TH.LIQ.GENERAL.PARAM"
	F.ATI.TH.LIQ.GENERAL.PARAM	= ""
	CALL OPF(FN.ATI.TH.LIQ.GENERAL.PARAM, F.ATI.TH.LIQ.GENERAL.PARAM)
	
	FN.CUSTOMER		= "F.CUSTOMER"
	F.CUSTOMER		= ""
	CALL OPF(FN.CUSTOMER, F.CUSTOMER)
	
	FN.ACCOUNT		= "F.ACCOUNT"
	F.ACCOUNT		= ""
	CALL OPF(FN.ACCOUNT, F.ACCOUNT)
	
	FN.AA.ARRANGEMENT	= "F.AA.ARRANGEMENT"
	F.AA.ARRANGEMENT	= ""
	CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
	
	FN.LIMIT.LIABILITY = "F.LIMIT.LIABILITY"
	F.LIMIT.LIABILITY = ""
	CALL OPF(FN.LIMIT.LIABILITY, F.LIMIT.LIABILITY)
	
	FN.LIMIT = 'F.LIMIT'
    F.LIMIT  = ''
    CALL OPF(FN.LIMIT,F.LIMIT)
	
	FN.BTPNS.TT.DUP.UPLOAD.FILE	= "F.BTPNS.TT.DUP.UPLOAD.FILE"
	F.BTPNS.TT.DUP.UPLOAD.FILE	= ""
	CALL OPF(FN.BTPNS.TT.DUP.UPLOAD.FILE, F.BTPNS.TT.DUP.UPLOAD.FILE)
	
    Y.APP      = "LIMIT"
    Y.FLD.NAME = "CO.BOOK"
    Y.POS      = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)
    Y.CO.BOOK.POS = Y.POS<1, 1>	
	
    Y.APP      = "AA.ARRANGEMENT.ACTIVITY"
    Y.FLD.NAME = "IS.PRODUCT" :VM: "IS.CONTRACT.REF"
    Y.POS      = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)
    Y.IS.PRODUCT.POS 		= Y.POS<1, 1>
	Y.IS.CONTRACT.REF.POS	= Y.POS<1, 2>
	
	Y.APP        = "CUSTOMER"
    Y.FLD.NAME   = "DISTRICT.CODE"
	Y.POS        = ""
	CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)
	Y.DISTRICT.CODE.POS	= Y.POS<1,1>
	
    Y.APP      = "IS.CONTRACT"
    Y.FLD.NAME = "IS.PRODUCT"
    Y.POS      = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)
    Y.IS.PRODUCT.IC.POS 	= Y.POS<1, 1>
	
	CALL F.READ(FN.ATI.TH.LIQ.GENERAL.PARAM,"INDIVIDUAL.FINANCING",R.ATI.TH.LIQ.GENERAL.PARAM,F.ATI.TH.LIQ.GENERAL.PARAM,LIQ.PAR.ERR)
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





