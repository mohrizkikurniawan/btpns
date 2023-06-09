    SUBROUTINE BTPNS.DSF.GET.PROXY.TYPE.DESC(Y.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami (BTPNS SQUAD)
* Development Date   : 20220818
* Description        : Conversion routine to get proxy description
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : 
* Modified by        : 
* Description        : 
* No Log             :
*-----------------------------------------------------------------------------
	$INSERT I_COMMON
	$INSERT I_EQUATE
	$INSERT I_F.BTPNS.TL.BFAST.PROXY.TYPE

    GOSUB INIT
    GOSUB PROCESS
    
*-----------------------------------------------------------------------------
INIT:
*-------
    FN.BTPNS.TL.BFAST.PROXY.TYPE = "F.BTPNS.TL.BFAST.PROXY.TYPE"
	F.BTPNS.TL.BFAST.PROXY.TYPE  = ""
	CALL OPF(FN.BTPNS.TL.BFAST.PROXY.TYPE, F.BTPNS.TL.BFAST.PROXY.TYPE)

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-------
    Y.PROXY.TYPE = Y.DATA
    CALL F.READ(FN.BTPNS.TL.BFAST.PROXY.TYPE,Y.PROXY.TYPE,R.PROXY.TYPE,F.BTPNS.TL.BFAST.PROXY.TYPE,READ.PROXY.TYPE.PAR.ERR)
    Y.PROXY.TYPE.DESC = R.PROXY.TYPE<BF.PT.DESCRIPTION>

	Y.DATA = Y.PROXY.TYPE.DESC
    
    RETURN
*-----------------------------------------------------------------------------
END

