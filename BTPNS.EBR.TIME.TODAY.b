    SUBROUTINE BTPNS.EBR.TIME.TODAY(ENQ.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20230214
* Description        : Build routine for selection time TODAY
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON       

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    
    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------


    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    FIND "DEBIT.VALUE.DATE" IN ENQ.DATA<2> SETTING POSF, POSV, POSS THEN
        vDebitValueDate = ENQ.DATA<4,POSV>
        IF vDebitValueDate EQ '' THEN
			ENQ.DATA<2,POSV>	= "DEBIT.VALUE.DATE"
            ENQ.DATA<3,POSV>	= "EQ"
			ENQ.DATA<4,POSV>	= TODAY       
        END
    END
	
	RETURN
*-----------------------------------------------------------------------------
END

