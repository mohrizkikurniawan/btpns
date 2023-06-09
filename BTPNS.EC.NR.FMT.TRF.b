*-----------------------------------------------------------------------------
* <Rating>-100</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.EC.NR.FMT.TRF(Y.APPLIC.ID, Y.APPLIC.REC, Y.STMT.ID, Y.STMT.REC, Y.OUT.TEXT)
*-----------------------------------------------------------------------------
* Developer Name     : ATIC Ratih Purwaning Utami
* Development Date   : 20220511
* Description        : Conversion routine that attached to STMT.NARR.FORMAT>FTTRANS
*                      This routine convert the payment details of TRANSACTION>213
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.COMPANY
    $INSERT I_F.FUNDS.TRANSFER
	
	GOSUB INIT
	GOSUB PROCESS 
	
	RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    Y.APPLICATION = 'FUNDS.TRANSFER'
    CALL GET.STANDARD.SELECTION.DETS(Y.APPLICATION,REC.SS)
    CALL FIELD.NAMES.TO.NUMBERS("DEBIT.CUSTOMER",REC.SS,Y.DEBIT.CUSTOMER.POS,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
    CALL FIELD.NAMES.TO.NUMBERS("CREDIT.CUSTOMER",REC.SS,Y.CREDIT.CUSTOMER.POS,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
    CALL FIELD.NAMES.TO.NUMBERS("DEBIT.ACCT.NO",REC.SS,Y.DEBIT.ACCT.NO.POS,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
    CALL FIELD.NAMES.TO.NUMBERS("CREDIT.ACCT.NO",REC.SS,Y.CREDIT.ACCT.NO.POS,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
    CALL FIELD.NAMES.TO.NUMBERS("LOCAL.REF",REC.SS,Y.LOCAL.REF.POS,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)

    Y.LT.FIELD.NAME = "IN.BENEF.BANK":@VM:"IN.BENEF.ACCT":@VM:"IN.LOCATION":@VM:"IN.SRC.BANK":@VM:"IN.SRC.ACCT"
    Y.POS = ""
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,Y.LT.FIELD.NAME,Y.POS)
    Y.IN.BENEF.BANK.POS = Y.POS<1,1>
    Y.IN.BENEF.ACCT.POS = Y.POS<1,2>
    Y.IN.LOCATION.POS   = Y.POS<1,3>
    Y.IN.SRC.BANK.POS   = Y.POS<1,4>
    Y.IN.SRC.ACCT.POS   = Y.POS<1,5>

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    
    Y.DEBIT.CUSTOMER  = Y.APPLIC.REC<Y.DEBIT.CUSTOMER.POS>
    Y.CREDIT.CUSTOMER = Y.APPLIC.REC<Y.CREDIT.CUSTOMER.POS>
    Y.DEBIT.ACCT.NO   = Y.APPLIC.REC<Y.DEBIT.ACCT.NO.POS>
    Y.CREDIT.ACCT.NO  = Y.APPLIC.REC<Y.CREDIT.ACCT.NO.POS>

    Y.IN.BENEF.BANK = Y.APPLIC.REC<Y.LOCAL.REF.POS><1,Y.IN.BENEF.BANK.POS>
    Y.IN.BENEF.ACCT = Y.APPLIC.REC<Y.LOCAL.REF.POS><1,Y.IN.BENEF.ACCT.POS>
    Y.IN.LOCATION   = Y.APPLIC.REC<Y.LOCAL.REF.POS><1,Y.IN.LOCATION.POS>
    Y.IN.SRC.BANK   = Y.APPLIC.REC<Y.LOCAL.REF.POS><1,Y.IN.SRC.BANK.POS>
    Y.IN.SRC.ACCT   = Y.APPLIC.REC<Y.LOCAL.REF.POS><1,Y.IN.SRC.ACCT.POS>

    Y.LEN.BENEF.ACCT = LEN(Y.IN.BENEF.ACCT)
    Y.MASK.BENEF.ACCT = FMT(Y.IN.BENEF.ACCT[4], 'R*':Y.LEN.BENEF.ACCT)
    Y.MASK.BENEF.ACCT = EREPLACE(Y.MASK.BENEF.ACCT,"*","X")

    Y.LEN.CREDIT.ACCT.NO = LEN(Y.CREDIT.ACCT.NO)
    Y.MASK.CREDIT.ACCT.NO = FMT(Y.CREDIT.ACCT.NO[4], 'R*':Y.LEN.CREDIT.ACCT.NO)
    Y.MASK.CREDIT.ACCT.NO = EREPLACE(Y.MASK.CREDIT.ACCT.NO,"*","X")

    BEGIN CASE
    CASE Y.DEBIT.CUSTOMER AND Y.CREDIT.CUSTOMER
        Y.OUT.TEXT = "PB dari ":Y.DEBIT.ACCT.NO:" ke ": Y.MASK.CREDIT.ACCT.NO
    CASE Y.DEBIT.CUSTOMER AND Y.CREDIT.ACCT.NO[1,3] EQ 'IDR' AND Y.IN.BENEF.ACCT
        Y.OUT.TEXT = "TRF ke ":Y.IN.BENEF.BANK:" ":Y.MASK.BENEF.ACCT
    CASE Y.CREDIT.CUSTOMER AND Y.DEBIT.ACCT.NO[1,3] EQ 'IDR'
        Y.OUT.TEXT = "TRF dari ":Y.IN.LOCATION:" ":Y.IN.SRC.BANK:" ":Y.IN.SRC.ACCT
    END CASE

	RETURN
*-----------------------------------------------------------------------------
END
