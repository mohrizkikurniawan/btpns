    SUBROUTINE BTPNS.VAA.FT.BIFAST.UPD.DISPUTE

    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_F.FUNDS.TRANSFER
    $INCLUDE I_F.BTPNS.TH.BIFAST.INCOMING

    IF V$FUNCTION NE "A" THEN RETURN

    arrApp<1> = APPLICATION
    arrFld<1,1> = "IN.REVERSAL.ID"
    arrPos = ""
    CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
    fInRevId = arrPos<1,1>
    IF NOT(fInRevId) THEN RETURN

    fnTableStaging = "F.BTPNS.TH.BIFAST.INCOMING"
    fvTableStaging = ""
    CALL OPF(fnTableStaging, fvTableStaging)

    idTableStaging = R.NEW(LOCAL.REF.FIELD)<1,fInRevId>
    IF NOT(idTableStaging) THEN RETURN
    
    rvTableStaging = ""
    CALL F.READ(fnTableStaging, idTableStaging, rvTableStaging, fvTableStaging, "")
    IF NOT(rvTableStaging) THEN RETURN

    rvTableStaging<BtpnsThBifastIncoming_SettlementStatus> = "PROCESSED"
    rvTableStaging<BtpnsThBifastIncoming_RetryCounter> = ""
    rvTableStaging<BtpnsThBifastIncoming_ResponseCode> = "00"

    CALL F.LIVE.WRITE(fnTableStaging, idTableStaging, rvTableStaging)

    RETURN

END

