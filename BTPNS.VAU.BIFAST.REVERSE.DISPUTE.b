    SUBROUTINE BTPNS.VAU.BIFAST.REVERSE.DISPUTE
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20221117
* Description        : reverse dispute transaction
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.BTPNS.TH.BIFAST.OUTGOING

    GOSUB INIT
    GOSUB PROCESS
	
    RETURN
*----------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------

    RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    Y.COMPANY.BOOK = R.NEW(BF.TOC.COMPANY.BOOK)
    Y.OFS.MESSAGE = "FUNDS.TRANSFER,BIFAST.OUTGOING.REVE/R/PROCESS//0,//":Y.COMPANY.BOOK:",":ID.NEW
	
	OFS.SOURCE.ID = "BIFAST"
    OFS.MSG.ID = ''
    OPTIONS = OPERATOR
    CALL OFS.POST.MESSAGE(Y.OFS.MESSAGE, OFS.MSG.ID, OFS.SOURCE.ID, OPTIONS)

    RETURN
*-----------------------------------------------------------------
END
