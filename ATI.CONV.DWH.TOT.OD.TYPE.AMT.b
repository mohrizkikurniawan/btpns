	SUBROUTINE ATI.CONV.DWH.TOT.OD.TYPE.AMT(Y.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20200212
* Description        : Conversion routine to get data related to overdue
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
* 20230308        Moh Rizki Kurniawan        [CBA 202 - MRK] - Get Y.TOT.INT from SCHEDULEFEE product qardh
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    
    FN.AA.ACCOUNT.DETAILS = "F.AA.ACCOUNT.DETAILS"
    F.AA.ACCOUNT.DETAILS  = ""
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = "F.AA.BILL.DETAILS"
    F.AA.BILL.DETAILS  = ""
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

* [CBA 202 - MRK]
    fnAaArrangement    = "F.AA.ARRANGEMENT"
    fvAaArrangement     = ""
    CALL OPF(fnAaArrangement, fvAaArrangement)
* [CBA 202 - MRK]

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.ARRANGEMENT.ID = Y.DATA

* [CBA 202 - MRK]
    CALL F.READ(fnAaArrangement, Y.ARRANGEMENT.ID, rvAaArrangement, fvAaArrangement, '')
    productGroup    = rvAaArrangement<AaArrangement_ProductGroup>
* [CBA 202 - MRK]

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.ARRANGEMENT.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ERR.AA.DET)

    Y.BILL.STATUS  = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.STATUS>
    Y.BILL.IDS     = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.BILL.TYPE    = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>
    Y.SET.STATUS   = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
    Y.BILL.DATE    = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.DATE>

    Y.BILL.CNT     = DCOUNT(Y.BILL.IDS,VM)

    Y.TOT.PRIN = 0
    Y.TOT.INT  = 0
    Y.TOT.PE   = 0
    FOR Y.J = 1 TO Y.BILL.CNT
        Y.SM.CNT = DCOUNT(Y.BILL.IDS<1,Y.J>,SM)
        FOR Y.K = 1 TO Y.SM.CNT
            IF Y.BILL.STATUS<1,Y.J,Y.K> EQ 'AGING' OR (Y.BILL.STATUS<1,Y.J,Y.K> EQ 'DUE' AND (Y.BILL.TYPE<1,Y.J,Y.K> EQ 'INSTALLMENT' OR Y.BILL.TYPE<1,Y.J,Y.K> EQ 'PAYMENT') AND Y.SET.STATUS<1,Y.J,Y.K> EQ 'UNPAID') THEN
                Y.VM +=1
                GOSUB BILL.PROCESS
            END
        NEXT Y.K
    NEXT Y.J

    Y.DATA = Y.TOT.PRIN + Y.TOT.INT
    Y.DATA<-1> = "PR" : VM : "IN" : VM : "PE"
    Y.DATA<-1> =  Y.TOT.PRIN : VM : Y.TOT.INT : VM : Y.TOT.PE

*------ PENALTY -------*

    Y.SCHD.DATE = Y.PE.DATE.LIST
    Y.SCHD.AMT  = Y.PE.AMT.LIST
    Y.TOTAL.PE.OVERDUE   = Y.TOT.PE

    Y.DATA<-1> = Y.SCHD.DATE
    Y.DATA<-1> = Y.SCHD.AMT
    Y.DATA<-1> = Y.TOTAL.PE.OVERDUE

    RETURN

*-----------------------------------------------------------------------------
BILL.PROCESS:
*-----------------------------------------------------------------------------

    CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.IDS<1,Y.J,Y.K>,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,ERR.BILL)

    Y.PROPERTY = R.AA.BILL.DETAILS<AA.BD.PROPERTY>
    Y.PROP.CNT = DCOUNT(Y.PROPERTY,VM)
    FOR Y.I = 1 TO Y.PROP.CNT
        IF Y.PROPERTY<1,Y.I> EQ "ACCOUNT" THEN
            Y.TOT.PRIN += R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,Y.I>
        END
* [CBA 202 - MRK]
        IF productGroup EQ 'BTPNS.QARD.FINANCE' OR productGroup EQ 'BTPNS.PRK.FINANCE' THEN
            IF Y.PROPERTY<1,Y.I> EQ "SCHEDULERFEE" THEN
                Y.TOT.INT += R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,Y.I>
            END
        END ELSE
            IF Y.PROPERTY<1,Y.I> EQ "PRINCIPALPFT" THEN
                Y.TOT.INT += R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,Y.I>
            END
        END
* [CBA 202 - MRK]

        IF Y.PROPERTY<1,Y.I> EQ "PENALTYPFT" THEN
            Y.PE.DATE.LIST<1,Y.VM,-1> = R.AA.BILL.DETAILS<AA.BD.PAYMENT.DATE,Y.I>
            Y.PE.AMT.LIST<1,Y.VM,-1>  = R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,Y.I>
            Y.TOT.PE += R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,Y.I>
        END
    NEXT Y.I 

    RETURN
*-----------------------------------------------------------------------------
END
