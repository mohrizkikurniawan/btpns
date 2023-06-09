    SUBROUTINE BTPNS.VAA.FT.BIFAST.UPD.DECLINED

    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_F.FUNDS.TRANSFER
    $INCLUDE I_F.BTPNS.TH.BIFAST.INCOMING
    
    fnFundsTranfer  = "F.FUNDS.TRANSFER"
    fvFundsTransfer = ""
    CALL OPF(fnFundsTranfer, fvFundsTransfer)

    fnBtpnsThBifastIncoming = "F.BTPNS.TH.BIFAST.INCOMING"
    fvBtpnsThBifastIncoming = ""
    CALL OPF(fnBtpnsThBifastIncoming, fvBtpnsThBifastIncoming)
    
    idFt    = R.NEW(BtpnsThBifastIncoming_FtSettlement)

	OFS.MSG.ID          = ''
	OPTIONS             = OPERATOR
	Y.OFS.SOURCE	    = 'BIFAST'

    vOfsMessageRequest  = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/D/PROCESS//,//":ID.COMPANY:",":idFt
    Y.OFS.TEMP.MESSAGE  = vOfsMessageRequest
	CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)


    RETURN

END

