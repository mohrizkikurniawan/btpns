*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.VAA.BIFAST.INCOMING.REVERSE
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220628
* Description        : Routine to process BIFAST Incoming Transaction to FT
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: -
* Modified by    	: -
* Description		: -
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_GTS.COMMON
    $INCLUDE I_F.BTPNS.TH.BIFAST.INCOMING
    $INCLUDE I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
    $INCLUDE I_F.IDCH.SKN.CLEARING.CODE
	$INCLUDE I_F.IDIH.WS.DATA.FT.MAP
    $INCLUDE I_F.OVERRIDE
    $INCLUDE I_F.TELLER
    $INCLUDE I_F.FUNDS.TRANSFER
*-----------------------------------------------------------------------------

	GOSUB Initialise
	GOSUB MainProcess
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

	fnTableReversalMap = "F.IDIH.WS.DATA.FT.MAP"
	fvTableReversalMap = ""
	CALL OPF(fnTableReversalMap, fvTableReversalMap)

	
	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------
	
	
	RETURN

END 