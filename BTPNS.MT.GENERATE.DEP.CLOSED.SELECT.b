	SUBROUTINE BTPNS.MT.GENERATE.DEP.CLOSED.SELECT
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 13 September 2022
* Description        : Routine multithread for generate report deposito dengan status tutup
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description		: 
*-----------------------------------------------------------------------------

    $INSERT I_GTS.COMMON
    $INSERT I_TSA.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.CHANGE.PRODUCT
    $INSERT I_F.USER
    $INSERT I_BTPNS.MT.GENERATE.DEP.CLOSED.COMMON
	
    SEL.CMD = "SELECT ":FN.AA.ARRANGEMENT:" WITH PRODUCT EQ 'BTPN.MUD.DEP.CHILD' AND ARR.STATUS EQ CLOSE MATURED PENDING.CLOSURE"

    CALL EB.READLIST(SEL.CMD,SEL.LIST,'','','')
    CALL BATCH.BUILD.LIST("",SEL.LIST)
	
    RETURN
END