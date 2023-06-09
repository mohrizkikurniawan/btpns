*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.DEPO.KLIRING.SELECT
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
	
    SEL.CMD ="SELECT ":FN.AA.ARRANGEMENT: " WITH PRODUCT.LINE EQ DEPOSITS AND ARR.STATUS NE CANCELLED CLOSE REVERSED"

    SEL.LIST =''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.REC,ERR.MM)
	
	CALL BATCH.BUILD.LIST("", SEL.LIST)

    RETURN

END 