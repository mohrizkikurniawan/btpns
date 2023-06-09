*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.VID.BIFAST.INCOMING
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220621
* Description        : To format @ID into TODAY.TIMESTAMP e.g: 20220621.13523166871156
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* 20220621		Alamsyah Rizki Isroi		Initial
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
	
	IF V$FUNCTION NE "I" THEN RETURN
	
	idFt = ""
	CALL IDC.AP.GET.NEXT.ID("FUNDS.TRANSFER",idFt)
	
*	COMI = TODAY:".":CHANGE(TIMESTAMP(),".","")
	COMI = TODAY:".":idFt
	ID.NEW = COMI

    RETURN
*-----------------------------------------------------------------------------
END
