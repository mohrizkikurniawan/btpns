*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BOOKING.QARDH.LOAD
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

    GOSUB INIT
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	fnAtiThStagingLiqAgent	= 'F.ATI.TH.STAGING.LIQ.AGENT'
	fvAtiThStagingLiqAgent	= ''
	CALL OPF(fnAtiThStagingLiqAgent, fvAtiThStagingLiqAgent)
	
	fnAtiThProdParam	= 'F.ATI.TH.PRODUCT.PARAMETER'
	fvAtiThProdParam = ''
	CALL OPF(fnAtiThProdParam,fvAtiThProdParam)
	
	fnAtiLiqGenParam	= 'F.ATI.TH.LIQ.GENERAL.PARAM'
	fvAtiLiqGenParam	= ''
	CALL OPF(fnAtiLiqGenParam, fvAtiLiqGenParam)
	
	fnCustomer		= 'F.CUSTOMER'
	fvCustomer		= ''
	CALL OPF(fnCustomer, fvCustomer)
	
	fnAccount		= 'F.ACCOUNT'
	fvAccount		= ''
	CALL OPF(fnAccount, fvAccount)
	
	fnArrangement	= 'F.AA.ARRANGEMENT'
	fvArrangement	= ''
	CALL OPF(fnArrangement, fvArrangement)
	
	fnLimit = 'F.LIMIT'
    fvLimit  = ''
    CALL OPF(fnLimit,fvLimit)
	
	fnBtpnsTtDup	= 'F.BTPNS.TT.DUP.UPLOAD.FILE'
	fvBtpnsTtDup	= ''
	CALL OPF(fnBtpnsTtDup, fvBtpnsTtDup)
	
    vAppName	 = 'LIMIT' :FM: 'ATI.TH.STAGING.LIQ.AGENT'
	vFldName	 = 'CO.BOOK'
	vFldName	:= FM
	vFldName	:= 'B.UPDATE.FLAG'
	
    vLrefPos	= ''
    
    CALL MULTI.GET.LOC.REF (vAppName, vFldName, vLrefPos)
    vCooBookPos		= vLrefPos<1, 1>
	vUpdateFlagPos	= vLrefPos<2, 1>
	
	CALL F.READ(fnAtiLiqGenParam,'UPDATE.BOOKING',recGenParam,fvAtiLiqGenParam,LiqParErr)
	idPath = recGenParam<LIQ.GEN.PAR.PATH.ID>
	
	fnProcess 	= idPath:'/Process'
	OPEN fnProcess TO fvProcess ELSE
        vExecCmd = 'CREATE.FILE ':fnProcess:' TYPE=UD'
        EXECUTE vExecCmd
        OPEN fnProcess TO fvProcess ELSE
            RETURN
        END
    END

	fnBakup 	= idPath:'/Backup'
	OPEN fnBakup TO fvBakup ELSE
        vExecCmd = 'CREATE.FILE ':fnBakup:' TYPE=UD'
        EXECUTE vExecCmd
        OPEN fnBakup TO fvBakup ELSE
            RETURN
        END
    END

	fnResult 	= idPath:'/Result'
	OPEN fnResult TO fvResult ELSE
        vExecCmd = 'CREATE.FILE ':fnResult:' TYPE=UD'
        EXECUTE vExecCmd
        OPEN fnResult TO fvResult ELSE
            RETURN
        END
    END	
	
    RETURN
	
*-----------------------------------------------------------------------------

END





