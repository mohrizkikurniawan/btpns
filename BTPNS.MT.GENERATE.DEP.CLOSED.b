	SUBROUTINE BTPNS.MT.GENERATE.DEP.CLOSED(Y.AA.ID)
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 13 September 2022
* Description        : Routine multithread for generate report deposito dengan status tutup
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description		: 
*-----------------------------------------------------------------------------

    $INSERT I_GTS.COMMON
    $INSERT I_TSA.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.CHANGE.PRODUCT
    $INSERT I_F.USER
    $INSERT I_BTPNS.MT.GENERATE.DEP.CLOSED.COMMON
    $INSERT I_F.BTPNS.TH.POOL.DEP.CLOSE

    GOSUB PROCESS
	
    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	*-AA.ARRANGEMENT-------------------------------------------------------------------------------
		CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ERR.AAR)
		Y.LINKED.APPL.ID    = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
		Y.CUSTOMER			= R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
		Y.PRODUCT			= R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
		Y.CURRENCY			= R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
		Y.CO.CODE           = R.AA.ARRANGEMENT<AA.ARR.CO.CODE>

	*--AA.ACCOUNT.DETAILS-------------------------------------------------------------------------------
		CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.ACCOUNT.DETAILS.ERR)
		Y.RENEWAL.DATE  	= R.AA.ACCOUNT.DETAILS<AA.AD.RENEWAL.DATE>
		Y.VALUE.DATE 		= R.AA.ACCOUNT.DETAILS<AA.AD.VALUE.DATE>
        Y.COUNT.RENEW.DATE  = DCOUNT(R.AA.ACCOUNT.DETAILS<AA.AD.LAST.RENEW.DATE>,VM)
        Y.LAST.RENEW.DATE   = R.AA.ACCOUNT.DETAILS<AA.AD.LAST.RENEW.DATE,Y.COUNT.RENEW.DATE>
		Y.START.DATE		= R.AA.ACCOUNT.DETAILS<AA.AD.START.DATE>
	
	*--ACCOUNT-------------------------------------------------------------------------------
		CALL F.READ(FN.ACCOUNT,Y.LINKED.APPL.ID,REC.ACCOUNT,F.ACCOUNT,ERR.AC)
		Y.ACCOUNT.OFFICER   = REC.ACCOUNT<AC.ACCOUNT.OFFICER>
		Y.CONTRACT.DATE 	= REC.ACCOUNT<AC.OPENING.DATE>
		
		IF Y.CONTRACT.DATE EQ '' THEN
		    CALL F.READ.HISTORY(FN.ACCOUNT.HIS,Y.LINKED.APPL.ID,R.ACCOUNT.HIS,F.ACCOUNT.HIS,ERR.ACCOUNT.HIS)
		    Y.CONTRACT.DATE = R.ACCOUNT.HIS<AC.OPENING.DATE>
		END

    *--AA.ACCOUNT-------------------------------------------------------------------------------

        idProperty = "ACCOUNT"
        idLinkRef = ""
        CALL AA.PROPERTY.REF(Y.AA.ID, idProperty, idLinkRef)
        IF idLinkRef THEN CALL F.READ(FN.AA.ARR.ACCOUNT, idLinkRef, R.AA.ACCOUNT, F.AA.ARR.ACCOUNT, "")
        Y.L.COUNTER.NISBA    = R.AA.ACCOUNT<AA.AC.LOCAL.REF,Y.L.COUNTER.NISBA.POS>
        Y.L.FINAL.NISBA      = R.AA.ACCOUNT<AA.AC.LOCAL.REF,Y.L.FINAL.NISBA.POS>
        Y.L.BILYET.NUM       = R.AA.ACCOUNT<AA.AC.LOCAL.REF,Y.L.BILYET.NUM.POS>
        Y.ATI.JOINT.NAME     = R.AA.ACCOUNT<AA.AC.LOCAL.REF,Y.ATI.JOINT.NAME.POS>
        Y.L.MIG.PRD          = R.AA.ACCOUNT<AA.AC.LOCAL.REF,Y.L.MIG.PRD.POS>
        Y.USER.ID            = R.AA.ACCOUNT<AA.AC.INPUTTER>
        Y.AUTHORISER.ID      = R.AA.ACCOUNT<AA.AC.AUTHORISER>
        Y.DATE.TIME1         = R.AA.ACCOUNT<AA.AC.DATE.TIME>
        Y.TIME.RECORD        = Y.DATE.TIME1[7,2]:":":Y.DATE.TIME1[9,2]
    
    *--COMMITMENT-------------------------------------------------------------------------------
        idProperty = "COMMITMENT"
        idLinkRef = ""
        CALL AA.PROPERTY.REF(Y.AA.ID, idProperty, idLinkRef)
        IF idLinkRef THEN CALL F.READ(FN.AA.ARR.TERM.AMOUNT, idLinkRef, R.AA.TERM.AMOUNT, F.AA.ARR.TERM.AMOUNT, "")
        Y.MAT.DATE             = R.AA.TERM.AMOUNT<AA.AMT.MATURITY.DATE>
        Y.PRINCIPAL         = R.AA.TERM.AMOUNT<AA.AMT.AMOUNT>
        Y.TERM              = R.AA.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.TERM.POS>
        Y.L.MAT.MODE        = R.AA.TERM.AMOUNT<AA.AMT.LOCAL.REF, Y.L.MAT.MODE.POS>
        Y.L.ORG.MAT.DATE    = R.AA.TERM.AMOUNT<AA.AMT.LOCAL.REF, Y.L.ORG.MAT.DATE.POS>

    *--RENEWAL-------------------------------------------------------------------------------
        idProperty = "RENEWAL"
        idLinkRef = ""
        CALL AA.PROPERTY.REF(Y.AA.ID, idProperty, idLinkRef)
        IF idLinkRef THEN CALL F.READ(FN.AA.ARR.CHANGE.PRODUCT, idLinkRef, R.AA.CHANGE.PRODUCT, F.AA.ARR.CHANGE.PRODUCT, "")
        Y.CHANGE.PERIOD     = R.AA.CHANGE.PRODUCT<AA.CP.CHANGE.PERIOD>
        
    *ARO/NON ARO CONDITION    
        IF Y.L.MAT.MODE EQ "SINGLE MATURITY" THEN
            Y.MAT.DATE.ORI        = Y.L.ORG.MAT.DATE
        END ELSE
            Y.MAT.DATE.ORI        = Y.RENEWAL.DATE
        END

        Y.MUD.TENOR     = Y.TERM
        Y.MATURITY.DATE    = Y.MAT.DATE
    
        BEGIN CASE
        CASE Y.LAST.RENEW.DATE NE ""
    	    Y.INT.PERIOD.START	= Y.LAST.RENEW.DATE
        CASE Y.L.MIG.PRD NE ""
     	    Y.INT.PERIOD.START	= Y.L.MIG.PRD
        CASE Y.START.DATE NE ""
    	    Y.INT.PERIOD.START	= Y.START.DATE
        END CASE

        GOSUB WRITE.OUTPUT


	RETURN
*-----------------------------------------------------------------------------
WRITE.OUTPUT:
*-----------------------------------------------------------------------------
	
    Y.OUTPUT = Y.AA.ID    	          	; *1
    Y.OUTPUT := "|" : Y.CUSTOMER         ; *2
    Y.OUTPUT := "|" : Y.ATI.JOINT.NAME        ; *6
    Y.OUTPUT := "|" : Y.PRODUCT                ; *7
    Y.OUTPUT := "|" : Y.CURRENCY            ; *8
    Y.OUTPUT := "|" : Y.PRINCIPAL             ; *14
    Y.OUTPUT := "|" : Y.L.COUNTER.NISBA     ; *9	
    Y.OUTPUT := "|" : Y.L.BILYET.NUM        ; *11	
    Y.OUTPUT := "|" : Y.VALUE.DATE    	; *4
    Y.OUTPUT := "|" : Y.MUD.TENOR            ; *12 
    Y.OUTPUT := "|" : Y.CONTRACT.DATE          ; *5
    Y.OUTPUT := "|" : Y.MATURITY.DATE        ; *13
    Y.OUTPUT := "|" : Y.INT.PERIOD.START    ; *19
    Y.OUTPUT := "|" : Y.L.FINAL.NISBA        ; *10
    Y.OUTPUT := "|" : Y.CO.CODE        ; *3
    
    CALL F.READ(FN.BTPNS.TH.POOL.DEP.CLOSE,Y.AA.ID,R.BTPNS.TH.POOL.DEP.CLOSE,F.BTPNS.TH.POOL.DEP.CLOSE,ERR.BTPNS.TH.POOL.DEP.CLOSE)
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.AA.ID>           = Y.AA.ID
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.CUSTOMER>        = Y.CUSTOMER
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.ATI.JOINT.NAME>  = Y.ATI.JOINT.NAME
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.PRODUCT>         = Y.PRODUCT
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.CURRENCY>        = Y.CURRENCY
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.PRINCIPAL>       = Y.PRINCIPAL
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.L.COUNTER.NISBAH>= Y.L.COUNTER.NISBA
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.L.BILYET.NUM>    = Y.L.BILYET.NUM
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.VALUE.DATE>      = Y.VALUE.DATE
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.MUD.TENOR>       = Y.MUD.TENOR
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.CONTRACT.DATE>   = Y.CONTRACT.DATE
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.MATURITY.DATE>   = Y.MATURITY.DATE
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.INT.PERIOD.START>= Y.INT.PERIOD.START
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.L.FINAL.NISBAH>  = Y.L.FINAL.NISBA
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.CO.CODE>         = Y.CO.CODE
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.INPUTTER>        = Y.USER.ID
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.AUTHORISER>      = Y.AUTHORISER.ID
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.TIME.AUTHOR>     = Y.TIME.RECORD
    
    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
    R.BTPNS.TH.POOL.DEP.CLOSE<POOL.DEP.DATE.TIME>         = Y.DATE.TIME

    CALL F.WRITE(FN.BTPNS.TH.POOL.DEP.CLOSE,Y.AA.ID,R.BTPNS.TH.POOL.DEP.CLOSE)

RETURN    
*-----------------------------------------------------------------------------
END
