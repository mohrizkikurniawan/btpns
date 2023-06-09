*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.DEPO.KLIRING.LOAD
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 05 Sept 2022
* Description        : Flag account depo existing to BTPNS.TL.DEPO.KLIRING
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
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.SETTLEMENT
	$INSERT I_F.BTPNS.TL.DEPO.KLIRING
	$USING EB.Updates
*-----------------------------------------------------------------------------
	
	COMMON/DEPO.KLIRING.COM/FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT,FN.BTPNS.TL.DEPO.KLIRING,F.BTPNS.TL.DEPO.KLIRING,Y.SKN.RTGS.POS
	
    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
	F.AA.ARRANGEMENT   = ''
	CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
	
	FN.BTPNS.TL.DEPO.KLIRING = 'F.BTPNS.TL.DEPO.KLIRING'
	F.BTPNS.TL.DEPO.KLIRING  = ''
	CALL OPF(FN.BTPNS.TL.DEPO.KLIRING, F.BTPNS.TL.DEPO.KLIRING)
	
    Y.APP       = "AA.ARR.SETTLEMENT"
    Y.FLD       = "SKN.RTGS"
    Y.POS       = ""
    EB.Updates.MultiGetLocRef(Y.APP,Y.FLD,Y.POS)
	Y.SKN.RTGS.POS		= Y.POS<1,1>
	
    RETURN

END 