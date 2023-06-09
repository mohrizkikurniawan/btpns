*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.EC.NR.STO.DEPO(vApplicId, vApplicRec, vStmtId, vStmtRec, vOutText)
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20220727
* Description        : Narasi for sto deposito (charges)
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.FT.COMMISSION.TYPE

	GOSUB INIT
	GOSUB PROCESS
	
	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    fnFundsTransfer     = "F.FUNDS.TRANSFER"
    fvFundsTransfer     = ""
    CALL OPF(fnFundsTransfer, fvFundsTransfer)

    fnFtCommissionType  = "F.FT.COMMISSION.TYPE"
    fvFtCommissionType  = ""
    CALL OPF(fnFtCommissionType, fvFtCommissionType)

    vOutText = ''

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    vApplication    = "FUNDS.TRANSFER"
    CALL GET.STANDARD.SELECTION.DETS(vApplication, vRecordSs)
    CALL FIELD.NAMES.TO.NUMBERS("COMMISSION.TYPE", vRecordSs, vFieldNo, vAf, vAv, vAs, vDataType, vErrMsg)
    vCommissionType = vApplicRec<vFieldNo>

    vApplication    = "FUNDS.TRANSFER"
    CALL GET.STANDARD.SELECTION.DETS(vApplication, vRecordSs)
    CALL FIELD.NAMES.TO.NUMBERS("COMMISSION.AMT", vRecordSs, vFieldNo, vAf, vAv, vAs, vDataType, vErrMsg)
    vCommissionAmt = vApplicRec<vFieldNo>

    cntCommissionType   = DCOUNT(vCommissionType, @VM)
    FOR I = 1 TO cntCommissionType
        sCommissionType = vCommissionType<1, I>
        CALL F.READ(fnFtCommissionType, sCommissionType, rCommissionType, fvFtCommissionType, "")
        vShortName  = rCommissionType<FtCommissionType_ShortDescr>
        vFlatAmt    = rCommissionType<FtCommissionType_FlatAmt>
        IF vFlatAmt EQ '0' OR vFlatAmt EQ '' THEN
            vFlatAmt = FIELD(vCommissionAmt<1, I>, "IDR", 2)
        END

        IF I EQ '1' THEN
            vOutText := vShortName : " " : vFlatAmt
        END ELSE
            vOutText := ", " : vShortName : " " : vFlatAmt
        END

    NEXT I
	
	RETURN
*-----------------------------------------------------------------------------
END
