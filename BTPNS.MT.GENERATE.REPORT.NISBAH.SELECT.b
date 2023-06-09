	SUBROUTINE BTPNS.MT.GENERATE.REPORT.NISBAH.SELECT
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 13 September 2022
* Description        : ROutine multithread for generate report changes nisbah in deposits
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description		: 
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_TSA.COMMON
    $INSERT I_BATCH.FILES
	$INSERT I_BTPNS.MT.GENERATE.REPORT.NISBAH.COMMON
	
	*SEL.CMD  = "SELECT ":FN.AA.ARR.ACCOUNT:" WITH CATEGORY EQ 6601 AND (ACTIVITY EQ 'DEPOSITS-NEW-ARRANGEMENT' 'DEPOSITS-TAKEOVER-ARRANGEMENT' 'DEPOSITS-CHANGE.CUR.NISBAH-ACCOUNT' 'DEPOSITS-CHANGE.FUT.NISBAH-ACCOUNT') AND @ID LIKE ...":TODAY:"..."
    *SEL.CMD  = "SELECT ":FN.AA.ARR.ACCOUNT:" WITH CATEGORY EQ 6601 AND (ACTIVITY EQ 'DEPOSITS-NEW-ARRANGEMENT' 'DEPOSITS-TAKEOVER-ARRANGEMENT' 'DEPOSITS-CHANGE.CUR.NISBAH-ACCOUNT' 'DEPOSITS-CHANGE.FUT.NISBAH-ACCOUNT')"
    SEL.CMD  = "SELECT ":FN.AA.ARRANGEMENT:" WITH PRODUCT.LINE EQ DEPOSITS AND ARR.STATUS EQ CURRENT"
    SEL.LIST = ''
    

    CALL EB.READLIST(SEL.CMD,SEL.LIST,'','','')
    CALL BATCH.BUILD.LIST("",SEL.LIST)
	
    RETURN
END