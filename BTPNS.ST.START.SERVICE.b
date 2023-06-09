*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.ST.START.SERVICE
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20230130
* Description        : Routine to extract statement for IDR1523300019002 in EOD
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
    $INSERT I_BATCH.FILES
    $INSERT I_F.BATCH
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.TSA.SERVICE

*-----------------------------------------------------------------------------
    
	GOSUB Initialise
	GOSUB MainProcess
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

    fnTsaService    = "F.TSA.SERVICE"
    fvTsaService    = ""
    CALL OPF(fnTsaService, fvTsaService)

	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------

    batchDetails 	= BATCH.DETAILS<3,1>
    batchDetails    = batchDetails<1, 1, 1>
    idService       = batchDetails

    SERVICE.ID = ''
    CALL SERVICE.CONTROL(idService,'START',SERVICE.ID)

    RETURN

END 
