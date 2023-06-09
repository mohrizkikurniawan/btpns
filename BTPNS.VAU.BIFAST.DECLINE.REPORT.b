    SUBROUTINE BTPNS.VAU.BIFAST.DECLINE.REPORT
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220929
* Description        : write decline report
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.BTPNS.TH.BIFAST.OUTGOING
    $INSERT I_F.IDIH.WS.DATA.FT.MAP
    $INSERT I_F.FT.COMMISSION.TYPE

    GOSUB INIT
	
    RETURN
*----------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------

    FN.IDIH.WS.DATA.FT.MAP = "F.IDIH.WS.DATA.FT.MAP"
    F.IDIH.WS.DATA.FT.MAP  = ""
    CALL OPF(FN.IDIH.WS.DATA.FT.MAP, F.IDIH.WS.DATA.FT.MAP)

    FN.FT = "F.FUNDS.TRANSFER"
    F.FT  = ""
    CALL OPF(FN.FT, F.FT)

    FN.FT.HIS = "F.FUNDS.TRANSFER$HIS"
    F.FT.HIS  = ""
    CALL OPF(FN.FT.HIS, F.FT.HIS)

    FN.FT.COMMISSION.TYPE = "F.FT.COMMISSION.TYPE"
    F.FT.COMMISSION.TYPE  = ""
    CALL OPF(FN.FT.COMMISSION.TYPE, F.FT.COMMISSION.TYPE)

    Y.APP  = "FUNDS.TRANSFER":FM:"IDIH.WS.DATA.FT.MAP"
    Y.FLD  = "IN.REVERSAL.ID"
    Y.FLD := FM :"FT.CHARGES" :VM : "ATI.WAIVE.AMT" : VM :"ATI.FT.WAIVE"
    Y.POS  = ""
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FLD,Y.POS)
    Y.IN.REVERSAL.ID.POS = Y.POS<1,1>
    Y.FT.CHARGES.POS     = Y.POS<2,1>
    Y.ATI.WAIVE.AMT.POS  = Y.POS<2,2>
    Y.ATI.FT.WAIVE.POS   = Y.POS<2,3>

    Y.FOLDER   = "RPU"
    Y.FILENAME = TODAY:".":OPERATOR:".":TNO
    OPENSEQ Y.FOLDER, Y.FILENAME TO F.FOLDER
    ELSE
        CREATE F.FOLDER
        ELSE
            CRT 'Error open folder ':Y.FOLDER
        END
    END

    GOSUB PROCESS

    CLOSESEQ F.FOLDER


    RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
*    KODE CABANG|NO FT TRX|AMOUNT TRX|NOREK|FT BIAYA|NOMINAL BIAYA|INPUTTER
    Y.OUTPUT = ""

    Y.CO.CODE = ID.COMPANY
    Y.FT.ID   = ID.NEW
    Y.AMOUNT.TRX = R.NEW(BF.TOC.AMOUNT)
    Y.ACCOUNT = R.NEW(BF.TOC.DBTR.ACCID)

    CALL F.READ(FN.FT,ID.NEW,R.FT,F.FT,REAF.FT.LIVE.ERR)
    IF NOT(R.FT) THEN
        CALL F.READ.HISTORY(FN.FT.HIS,ID.NEW,R.FT,F.FT.HIS,READ.FT.HIS.ERR)
    END
    Y.IN.REVERSAL.ID = R.FT<FT.LOCAL.REF><1,Y.IN.REVERSAL.ID.POS>

    CALL F.READ(FN.IDIH.WS.DATA.FT.MAP,Y.IN.REVERSAL.ID,R.IDIH.WS.DATA.FT.MAP,F.IDIH.WS.DATA.FT.MAP,READ.IDIH.WS.ERR)
    Y.FT.FEE  = R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF><1,Y.FT.CHARGES.POS>
    Y.COMMISSION.TYPE = R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.COMMISSION.TYPE>

    CALL F.READ(FN.COMMISSION.TYPE,Y.COMMISSION.TYPE,R.COMM,F.COMMISSION.TYPE,READ.FTCOM.ERR)
    Y.FEE.AMT  = R.COMM<FT4.FLAT.AMT>

    IF NOT(Y.FT.FEE) THEN
        Y.FT.FEE  = R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF><1,Y.ATI.FT.WAIVE.POS>
        Y.FEE.AMT = R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.LOCAL.REF><1,Y.ATI.WAIVE.AMT.POS>
    END

    Y.INPUTTER = OPERATOR
    
    Y.OUTPUT = Y.CO.CODE :"|": Y.FT.ID :"|": Y.AMOUNT.TRX :"|": Y.ACCOUNT :"|": Y.FT.FEE:"|":Y.FEE.AMT:"|":Y.INPUTTER

    WRITESEQ Y.OUTPUT APPEND TO F.FOLDER ELSE CRT 'ERROR WRITING FILE'


    RETURN
*-----------------------------------------------------------------
END
