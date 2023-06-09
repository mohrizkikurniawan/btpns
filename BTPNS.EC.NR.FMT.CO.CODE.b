*-----------------------------------------------------------------------------
* <Rating>-100</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.EC.NR.FMT.CO.CODE(Y.APPLIC.ID, Y.APPLIC.REC, Y.STMT.ID, Y.STMT.REC, Y.OUT.TEXT)
*-----------------------------------------------------------------------------
* Developer Name     : ATIC Ratih Purwaning Utami
* Development Date   : 20220511
* Description        : Conversion routine that attached to STMT.NARR.FORMAT>TTD.CO
*                      This routine does convert FT>CO.CODE to COMPANY>COMPANY.NAME
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.COMPANY
	
	GOSUB INIT
	GOSUB PROCESS
	
	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    FN.COMPANY = "F.COMPANY"
    F.COMPANY  = ""
    CALL OPF(FN.COMPANY, F.COMPANY)

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.APPLICATION = 'TELLER'
    CALL GET.STANDARD.SELECTION.DETS(Y.APPLICATION,REC.SS)
    CALL FIELD.NAMES.TO.NUMBERS("CO.CODE",REC.SS,FIELD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)

    Y.CO.CODE = Y.APPLIC.REC<FIELD.NO>

    CALL F.READ(FN.COMPANY, Y.CO.CODE, R.COMP, F.COMPANY, READ.COMP.ERR)
    Y.OUT.TEXT  = R.COMP<EB.COM.COMPANY.NAME>
	
	RETURN
*-----------------------------------------------------------------------------
END
