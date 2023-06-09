    SUBROUTINE BTPNS.EBR.TO.DEPO.ERR(ENQ.DATA)
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
    $INSERT I_F.FUNDS.TRANSFER  
    $INSERT I_F.BTPNS.TH.BIFAST.STO.DEPO

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    
    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    fnFundsTransferNau  = "F.FUNDS.TRANSFER$NAU"
    fvFundsTransferNau  = ""
    CALL OPF(fnFundsTransferNau, fvFundsTransferNau)

    fnBtpnsThBifastStoDepo  = "F.BTPNS.TH.BIFAST.STO.DEPO"
    fvBtnpsThBifastStoDepo  = ""
    CALL OPF(fnBtpnsThBifastStoDepo, fvBtnpsThBifastStoDepo)

	arrApp<1> 	= "FUNDS.TRANSFER"
	arrFld<1,1>	= "ATI.MIR"
	arrPos		= ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	vAtiMirPos	 	 = arrPos<1,1>

    FIND "DEBIT.VALUE.DATE" IN ENQ.DATA<2> SETTING POSF, POSV, POSS THEN
		Y.OPR.DATE.TIME = ENQ.SELECTION<3,POSV>
        Y.SEL.DATE.TIME = ENQ.SELECTION<4,POSV>
        vDebitValueDate = ENQ.DATA<4,POSV>
        IF vDebitValueDate EQ '' THEN
            selCmd = "SELECT ":fnFundsTransferNau:" WITH REMARKS EQ 'STO.DEPO' AND TRANSACTION.TYPE EQ 'AC35' AND AT.TXN.DESC NE 'ARO2.CURRENT' AND CO.CODE EQ ":ID.COMPANY : " AND DEBIT.VALUE.DATE " : Y.OPR.DATE.TIME : " " : TODAY     
        END ELSE
            selCmd = "SELECT ":fnFundsTransferNau:" WITH REMARKS EQ 'STO.DEPO' AND TRANSACTION.TYPE EQ 'AC35' AND AT.TXN.DESC NE 'ARO2.CURRENT' AND CO.CODE EQ ":ID.COMPANY : " AND DEBIT.VALUE.DATE " : Y.OPR.DATE.TIME : " " : vDebitValueDate
        END
    END ELSE
        selCmd = "SELECT ":fnFundsTransferNau:" WITH REMARKS EQ 'STO.DEPO' AND TRANSACTION.TYPE EQ 'AC35' AND AT.TXN.DESC NE 'ARO2.CURRENT' AND CO.CODE EQ ":ID.COMPANY : " AND DEBIT.VALUE.DATE EQ " : Y.OPR.DATE.TIME : " " : TODAY 
    END

    IF Y.OPR.DATE.TIME EQ 'RG' THEN
        fDebitValueDate = FIELD(Y.SEL.DATE.TIME, " ", 1)
        bDebitValueDate = FIELD(Y.SEL.DATE.TIME, " ", 2)
        IF fDebitValueDate EQ '' OR bDebitValueDate EQ '' THEN
            selCmd  = ''
        END ELSE
            selCmd  = ''
            selCmd = "SELECT ":fnFundsTransferNau:" WITH REMARKS EQ 'STO.DEPO' AND TRANSACTION.TYPE EQ 'AC35' AND AT.TXN.DESC NE 'ARO2.CURRENT' AND CO.CODE EQ ":ID.COMPANY : " AND DEBIT.VALUE.DATE GE " : fDebitValueDate : " AND DEBIT.VALUE.DATE LE " : bDebitValueDate           
        END     
    END

    FIND "DEBIT.THEIR.REF" IN ENQ.DATA<2> SETTING posF, posV, posS THEN
        oprDebitTheirRef    = ENQ.SELECTION<3,POSV>
        selDebitTheirRef    = ENQ.SELECTION<4,POSV>
    END

    IF selDebitTheirRef NE '' THEN
        selCmd  = ""
        selCmd  = "SELECT ":fnFundsTransferNau:" WITH REMARKS EQ 'STO.DEPO' AND TRANSACTION.TYPE EQ 'AC35' AND AT.TXN.DESC NE 'ARO2.CURRENT' AND CO.CODE EQ ":ID.COMPANY : " AND DEBIT.THEIR.REF LIKE " : selDebitTheirRef : "..."
    END

    FIND "@ID" IN ENQ.DATA<2> SETTING posF, posV, posS THEN
        oprFtReference      = ENQ.SELECTION<3,POSV>
        selFtReference      = ENQ.SELECTION<4,POSV>
    END

    IF selFtReference NE '' THEN
        selCmd  = ""
        selCmd  = "SELECT ":fnFundsTransferNau:" WITH REMARKS EQ 'STO.DEPO' AND TRANSACTION.TYPE EQ 'AC35' AND AT.TXN.DESC NE 'ARO2.CURRENT' AND CO.CODE EQ ":ID.COMPANY : " AND @ID " : oprFtReference : " " : selFtReference
    END

    IF selDebitTheirRef NE '' AND selFtReference NE '' THEN
        selCmd  = ""
        selCmd  = "SELECT ":fnFundsTransferNau:" WITH REMARKS EQ 'STO.DEPO' AND TRANSACTION.TYPE EQ 'AC35' AND AT.TXN.DESC NE 'ARO2.CURRENT' AND CO.CODE EQ ":ID.COMPANY : " AND @ID " : oprFtReference : " " : selFtReference : " AND DEBIT.THEIR.REF LIKE " : selDebitTheirRef : "..."
    END

    IF selDebitTheirRef NE '' AND selFtReference NE '' AND vDebitValueDate NE '' THEN
        selCmd  = ""
        selCmd  = "SELECT ":fnFundsTransferNau:" WITH REMARKS EQ 'STO.DEPO' AND TRANSACTION.TYPE EQ 'AC35' AND AT.TXN.DESC NE 'ARO2.CURRENT' AND CO.CODE EQ ":ID.COMPANY : " AND @ID " : oprFtReference : " " : selFtReference : " AND DEBIT.THEIR.REF LIKE " : selDebitTheirRef : "... AND DEBIT.VALUE.DATE " : Y.OPR.DATE.TIME : " " : vDebitValueDate
    END

    CALL EB.READLIST(selCmd,selList,'',selCnt,selErr)

    vIdSelection = ''

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    FOR idx = 1 TO selCnt
        vIdFt   = selList<idx>
        CALL F.READ(fnFundsTransferNau, vIdFt, rvFundsTransferNau, fvFundsTransferNau, '')
        vAtiMir = rvFundsTransferNau<FundsTransfer_LocalRef, vAtiMirPos>
        
        CALL F.READ(fnBtpnsThBifastStoDepo, vAtiMir, rvBtpnsThBifastStoDepo, fvBtnpsThBifastStoDepo, '')
        vErrorMessage   = rvBtpnsThBifastStoDepo<BtpnsThBifastStoDepo_ErrorMessage>
        IF vErrorMessage EQ '' THEN
            vIdSelection   := vIdFt : " "
        END
    NEXT idx

	ENQ.DATA<2,POSV>	= "@ID"
    ENQ.DATA<3,POSV>	= "EQ"
	ENQ.DATA<4,POSV>	= vIdSelection  
	
	RETURN
*-----------------------------------------------------------------------------
END

