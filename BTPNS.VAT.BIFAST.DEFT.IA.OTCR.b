*-----------------------------------------------------------------------------
* <Rating>-56</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.VAT.BIFAST.DEFT.IA.OTCR
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220615
* Description        : Routine to default BI FAST OUT CR fields
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
*    $INSERT I_F.COMPANY
	$INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
    
*------------------------------------------------------------------------------
MAIN:
*------------------------------------------------------------------------------
    GOSUB INITIAL
    GOSUB PROCESS

    RETURN

*------------------------------------------------------------------------------
INITIAL:
*------------------------------------------------------------------------------

*    FN.COMPANY = 'F.COMPANY'
*    F.COMPANY  = ''
*    CALL OPF(FN.COMPANY,F.COMPANY)

    FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
    F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
    CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)

    RETURN

*------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------
*    Y.COMP = "ID0010001"
*    CALL F.READ(FN.COMPANY,Y.COMP,R.COMP,F.COMPANY,COMP.ERR)
*    Y.SUB.CODE = R.COMP<EB.COM.SUB.DIVISION.CODE>

    CALL F.READ(FN.BTPNS.TL.BFAST.INTERFACE.PARAM,"SYSTEM",R.BIFAST.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,READ.PAR.ERR)
*    Y.CATEG = R.BIFAST.PARAM<BF.INT.PAR.IA.CATEG.OUT>
*    Y.DEFT.ACCOUNT = LCCY:Y.CATEG:"0001":Y.SUB.CODE
*    R.NEW(FT.CREDIT.ACCT.NO) = Y.DEFT.ACCOUNT
	R.NEW(FT.CREDIT.ACCT.NO) = R.BIFAST.PARAM<BF.INT.PAR.BI.NOSTRO>

    RETURN

*-----------------------------------------------------------
END
