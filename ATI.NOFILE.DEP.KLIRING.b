	SUBROUTINE ATI.NOFILE.DEP.KLIRING(Y.OUTPUTLIST)
*-----------------------------------------------------------------------------
* Developer Name     : Laily Alfia
* Development Date   : 20200119
* Description        : Nofile routine to get Deposits with clearing
*-----------------------------------------------------------------------------
* Modification History:-
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 01 September 2022
* Description        : Add flag BIFAST
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ACCOUNT
	$INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.SETTLEMENT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
	$INSERT I_F.IDCH.RTGS.BANK.CODE.G2
	$INSERT I_F.BTPNS.TL.DEPO.KLIRING

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB CRITERIA
    GOSUB SELECT.QUERY

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
	F.AA.ARRANGEMENT   = ''
	CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
	
	FN.AA.ACCOUNT.DETAILS = "F.AA.ACCOUNT.DETAILS"
    F.AA.ACCOUNT.DETAILS  = ""
    CALL OPF(FN.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS)
	
	FN.ACCOUNT  = 'F.ACCOUNT'
	F.ACCOUNT   = ''
	CALL OPF(FN.ACCOUNT, F.ACCOUNT)
	
	FN.IDCH.RTGS.BANK.CODE.G2	= 'F.IDCH.RTGS.BANK.CODE.G2'
	F.IDCH.RTGS.BANK.CODE.G2	= ''
	CALL OPF(FN.IDCH.RTGS.BANK.CODE.G2, F.IDCH.RTGS.BANK.CODE.G2)
	
	FN.BTPNS.TL.DEPO.KLIRING = 'F.BTPNS.TL.DEPO.KLIRING'
	F.BTPNS.TL.DEPO.KLIRING  = ''
	CALL OPF(FN.BTPNS.TL.DEPO.KLIRING, F.BTPNS.TL.DEPO.KLIRING)

    Y.APP       = "AA.ARR.ACCOUNT" :FM: "AA.ARR.SETTLEMENT"
    Y.FLD.NAME  = "L.BILYET.NUM" :VM: "ATI.JOINT.NAME"
    Y.FLD.NAME := FM
    Y.FLD.NAME := "MUD.CLEARED" :VM: "SKN.RTGS" :VM: "BEN.ACC" :VM: "ATI.BEN.NAME" : VM : "SKN.RECEIV.BANK" :VM: "RTGS.BANK.G2" :VM: "B.CDTR.AGTID"
    Y.POS       = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)

	Y.L.BILYET.NUM.POS          = Y.POS<1,1>
	Y.ATI.JOINT.NAME.POS        = Y.POS<1,2>
	
	Y.MUD.CLEARED.POS           = Y.POS<2,1>
	Y.SKN.RTGS.POS              = Y.POS<2,2>
	Y.BEN.ACC.POS               = Y.POS<2,3>
	Y.BEN.NAME.POS              = Y.POS<2,4>
	Y.SKN.RECEIV.BANK.POS       = Y.POS<2,5>
	Y.RTGS.CODE.POS             = Y.POS<2,6>
	Y.CDTR.AGTID.POS			= Y.POS<2,7>
	
	Y.USR.DEP.CD = R.USER<EB.USE.DEPARTMENT.CODE>
	
	Y.CRITERIA = ''
	Y.OUTPUTLIST = ''
	
    RETURN	

*-----------------------------------------------------------------------------
CRITERIA:
*-----------------------------------------------------------------------------
    Y.INPUT = ENQ.SELECTION<2>
	
    FIND "CUSTOMER" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
        Y.SEL.CUSTOMER = ENQ.SELECTION<4,Y.POSV>

        IF Y.SEL.CUSTOMER NE "" THEN
            Y.CRITERIA := " AND WITH CUSTOMER EQ ":Y.SEL.CUSTOMER
        END

    END

    FIND "LINKED.APPL.ID" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
        Y.SEL.LINKED.APPL.ID = ENQ.SELECTION<4,Y.POSV>

        IF Y.SEL.LINKED.APPL.ID NE "" THEN
            Y.CRITERIA := " AND WITH LINKED.APPL.ID EQ ":Y.SEL.LINKED.APPL.ID
        END
    END
	
    FIND "Y.ID" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
        Y.OPR.ID = ENQ.SELECTION<3,Y.POSV>
		Y.SEL.ID = ENQ.SELECTION<4,Y.POSV>
		CONVERT "..." TO "" IN Y.SEL.ID
		IF NUM(Y.SEL.ID) OR ISDIGIT(Y.SEL.ID) THEN
			ENQ.ERROR = "Inputkan ID Arrangement"
		END
		*IF Y.OPR.ID EQ "EQ" THEN
			*Y.CRITERIA := " AND WITH @ID EQ ":Y.SEL.ID
		*END
		*IF Y.OPR.ID EQ "LK" THEN
			*Y.CRITERIA := " AND WITH @ID LIKE ...":Y.SEL.ID:"..."
		*END
    END

    FIND "MUD.PRINTED.NAM" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
		Y.OPR.MUD.PRINTED.NAM = ENQ.SELECTION<3,Y.POSV>
        Y.SEL.MUD.PRINTED.NAM = ENQ.SELECTION<4,Y.POSV>
		CONVERT "..." TO "" IN Y.SEL.MUD.PRINTED.NAM
		CONVERT "" TO " " IN Y.SEL.MUD.PRINTED.NAM
    END

    FIND "MUD.BILYET" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
        Y.OPR.MUD.BILYET = ENQ.SELECTION<3,Y.POSV>
        Y.SEL.MUD.BILYET = ENQ.SELECTION<4,Y.POSV>
		CONVERT "..." TO "" IN Y.SEL.MUD.BILYET
    END
	
    FIND "SKN.RTGS" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
		Y.OPR.SKN.RTGS = ENQ.SELECTION<3,Y.POSV>
        Y.SEL.SKN.RTGS = ENQ.SELECTION<4,Y.POSV>
    END
	
    FIND "MATURITY.DATE" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
		Y.OPR.MATURITY.DATE = ENQ.SELECTION<3,Y.POSV>
        Y.SEL.MATURITY.DATE = ENQ.SELECTION<4,Y.POSV>
    END
	
	IF ID.COMPANY NE 'ID0010001' THEN
*		Y.CRITERIA := " AND WITH CO.CODE EQ " : ID.COMPANY
		Y.CRITERIA := " AND ID.COMPANY EQ " :ID.COMPANY
	END

    RETURN
*-----------------------------------------------------------------------------
SELECT.QUERY:
*-----------------------------------------------------------------------------
	
    IF Y.CRITERIA THEN
*        SEL.CMD ="SELECT ":FN.AA.ARRANGEMENT: " WITH PRODUCT.LINE EQ DEPOSITS AND ARR.STATUS NE CANCELLED CLOSE REVERSED" : Y.CRITERIA
		SEL.CMD	= "SELECT ":FN.BTPNS.TL.DEPO.KLIRING: " WITH TYPE.TRANSFER EQ ":Y.SEL.SKN.RTGS: Y.CRITERIA
    END ELSE
*        SEL.CMD ="SELECT ":FN.AA.ARRANGEMENT: " WITH PRODUCT.LINE EQ DEPOSITS AND ARR.STATUS NE CANCELLED CLOSE REVERSED"
		SEL.CMD	= "SELECT ":FN.BTPNS.TL.DEPO.KLIRING: " WITH TYPE.TRANSFER EQ ":Y.SEL.SKN.RTGS
    END

    SEL.LIST =''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.REC,ERR.MM)

    FOR I = 1 TO NO.REC
        Y.AA.ID = SEL.LIST<I>
        GOSUB PROCESS
    NEXT I

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ERR.AAR)

    Y.LINKED.APPL.ID    = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL>
    Y.CUSTOMER          = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
    Y.CO.CODE           = R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
	
    CALL F.READ(FN.ACCOUNT,Y.LINKED.APPL.ID,REC.ACCOUNT,F.ACCOUNT,ERR.AC)

    Y.ACCOUNT.OFFICER   = REC.ACCOUNT<AC.ACCOUNT.OFFICER>
	
    Y.PROPERTY.ID.AC = "ACCOUNT"
    Y.PROPERTY.CLASS.AC = ""
    Y.EFFECTIVE.DATE.AC = TODAY
    CALL AA.GET.PROPERTY.RECORD("",Y.AA.ID,Y.PROPERTY.ID.AC,Y.EFFECTIVE.DATE.AC,Y.PROPERTY.CLASS.AC,"",R.AA.ACCOUNT,RET.ERROR.AC)

	Y.L.BILYET.NUM      = R.AA.ACCOUNT<AA.AC.LOCAL.REF,Y.L.BILYET.NUM.POS>
	Y.ATI.JOINT.NAME    = R.AA.ACCOUNT<AA.AC.LOCAL.REF,Y.ATI.JOINT.NAME.POS>
	
	IF NOT(Y.ATI.JOINT.NAME) THEN
		Y.ATI.JOINT.NAME = REC.ACCOUNT<AC.ACCOUNT.TITLE.1>
	END

    Y.PROPERTY.ID.CO = "COMMITMENT"
    Y.PROPERTY.CLASS.CO = ""
    Y.EFFECTIVE.DATE.CO = TODAY
    CALL AA.GET.PROPERTY.RECORD("",Y.AA.ID,Y.PROPERTY.ID.CO,Y.EFFECTIVE.DATE.CO,Y.PROPERTY.CLASS.CO,"",R.AA.TERM.AMOUNT,RET.ERROR.CO)

    Y.AMOUNT            = R.AA.TERM.AMOUNT<AA.AMT.AMOUNT>
	Y.MATURITY.DATE     = R.AA.TERM.AMOUNT<AA.AMT.MATURITY.DATE>
	
	

    Y.PROPERTY.ID.SET = "SETTLEMENT"
    Y.PROPERTY.CLASS.SET = ""
    Y.EFFECTIVE.DATE.SET = TODAY
    CALL AA.GET.PROPERTY.RECORD("",Y.AA.ID,Y.PROPERTY.ID.SET,Y.EFFECTIVE.DATE.SET,Y.PROPERTY.CLASS.SET,"",R.AA.SETTLEMENT,RET.ERROR.SET)
    Y.SKN.RTGS          = R.AA.SETTLEMENT<AA.SET.LOCAL.REF,Y.SKN.RTGS.POS>
	Y.BEN.ACC           = R.AA.SETTLEMENT<AA.SET.LOCAL.REF,Y.BEN.ACC.POS>
	Y.BEN.NAME          = R.AA.SETTLEMENT<AA.SET.LOCAL.REF,Y.BEN.NAME.POS>
	Y.SKN.RECEIV.BANK   = R.AA.SETTLEMENT<AA.SET.LOCAL.REF,Y.SKN.RECEIV.BANK.POS>
	Y.RTGS.CODE         = R.AA.SETTLEMENT<AA.SET.LOCAL.REF,Y.RTGS.CODE.POS>
	IF Y.RTGS.CODE EQ '' THEN
		Y.RTGS.CODE		= R.AA.SETTLEMENT<AA.SET.LOCAL.REF,Y.CDTR.AGTID.POS>
	END
	CALL F.READ(FN.IDCH.RTGS.BANK.CODE.G2, Y.RTGS.CODE, R.IDCH.RTGS.BANK.CODE.G2, F.IDCH.RTGS.BANK.CODE.G2, IDCH.RTGS.BANK.CODE.G2.ERR)
	Y.RTGS.CODE			= R.IDCH.RTGS.BANK.CODE.G2<IdchRtgsBankCodeG2_BankName>
	
	Y.MUD.CLEARED       = R.AA.SETTLEMENT<AA.SET.LOCAL.REF,Y.MUD.CLEARED.POS>
	
	FINDSTR "ACCOUNT" IN R.AA.SETTLEMENT<AA.SET.PAYOUT.PPTY.CLASS> SETTING FPOS, VPOS THEN
		Y.PAYOUT.ACCOUNT = R.AA.SETTLEMENT<AA.SET.PAYOUT.ACCOUNT, VPOS>
	END
	
	CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ERR.AAD)
	Y.LRD				= R.AA.ACCOUNT.DETAILS<AA.AD.LAST.RENEW.DATE>
	Y.CNT			    = DCOUNT(Y.LRD,VM)
    Y.LAST.RENEW.DATE   = R.AA.ACCOUNT.DETAILS<AA.AD.LAST.RENEW.DATE,Y.CNT>
	Y.RENEWAL.DATE      = R.AA.ACCOUNT.DETAILS<AA.AD.RENEWAL.DATE>
	
	IF Y.MATURITY.DATE EQ "" THEN
		Y.MATURITY.DATE = Y.RENEWAL.DATE
	END 

*-----------------------------------SELECTION---------------------------------
    Y.FLAG = 0
	IF Y.MUD.CLEARED NE 'Y' THEN
		Y.FLAG = 1
	END
	
	IF Y.SEL.ID THEN
        Y.OPERAND     = Y.OPR.ID
        Y.SEL.VALUE   = Y.SEL.ID
        Y.FIX.VALUE   = Y.AA.ID
        GOSUB OPERAND.SELECTION
    END
	
	IF Y.SEL.MUD.BILYET THEN
        Y.OPERAND     = Y.OPR.MUD.BILYET
        Y.SEL.VALUE   = Y.SEL.MUD.BILYET
        Y.FIX.VALUE   = Y.L.BILYET.NUM
        GOSUB OPERAND.SELECTION
    END
	
	IF Y.SEL.MUD.PRINTED.NAM THEN
        Y.OPERAND     = Y.OPR.MUD.PRINTED.NAM
        Y.SEL.VALUE   = Y.SEL.MUD.PRINTED.NAM
        Y.FIX.VALUE   = Y.ATI.JOINT.NAME
        GOSUB OPERAND.SELECTION
	END
	
	IF Y.SEL.SKN.RTGS THEN
        Y.OPERAND     = Y.OPR.SKN.RTGS
        Y.SEL.VALUE   = Y.SEL.SKN.RTGS
        Y.FIX.VALUE   = Y.SKN.RTGS
        GOSUB OPERAND.SELECTION
	END
	
    IF Y.SEL.MATURITY.DATE NE "" THEN
        Y.OPERAND     = Y.OPR.MATURITY.DATE
        Y.SEL.VALUE   = Y.SEL.MATURITY.DATE
        Y.FIX.VALUE   = Y.MATURITY.DATE
        GOSUB OPERAND.SELECTION
    END
	
	IF (LEN(Y.USR.DEP.CD) EQ 6) AND (Y.USR.DEP.CD[1,2] EQ '12') THEN
        Y.OPERAND     = "EQ"
        Y.SEL.VALUE   = Y.USR.DEP.CD
        Y.FIX.VALUE   = Y.ACCOUNT.OFFICER
        GOSUB OPERAND.SELECTION
	END
	
    IF Y.FLAG EQ 0 THEN
        GOSUB WRITE.OUTPUT
    END

	RETURN
*-----------------------------------------------------------------------------
OPERAND.SELECTION:
*-----------------------------------------------------------------------------
    BEGIN CASE
    CASE Y.OPERAND EQ 'EQ'
        IF Y.SEL.VALUE NE Y.FIX.VALUE THEN
            Y.FLAG = 1
        END
    CASE Y.OPERAND EQ 'CT'
		FINDSTR Y.SEL.VALUE IN Y.FIX.VALUE SETTING Y.POSF, Y.POSV, Y.POSS ELSE
            Y.FLAG = 1
        END
	CASE Y.OPERAND EQ 'LK'
        FINDSTR Y.SEL.VALUE IN Y.FIX.VALUE SETTING Y.POSF, Y.POSV, Y.POSS ELSE
            Y.FLAG = 1
        END
	CASE Y.OPERAND EQ 'LT'
		IF Y.FIX.VALUE GE Y.SEL.VALUE THEN
            Y.FLAG = 1
        END
		
		IF NOT(Y.FIX.VALUE) AND Y.SEL.VALUE THEN
			Y.FLAG = 1
		END
	CASE Y.OPERAND EQ 'GT'
		IF Y.FIX.VALUE LE Y.SEL.VALUE THEN
            Y.FLAG = 1
        END
	CASE Y.OPERAND EQ 'GE'
		IF Y.FIX.VALUE LT Y.SEL.VALUE THEN
            Y.FLAG = 1
        END
	CASE Y.OPERAND EQ 'LE'
		IF Y.FIX.VALUE GT Y.SEL.VALUE THEN
            Y.FLAG = 1
        END
		
		IF NOT(Y.FIX.VALUE) AND Y.SEL.VALUE THEN
			Y.FLAG = 1
		END
	CASE Y.OPERAND EQ 'RG'
		Y.SEL.VALUE.1 = FIELD(Y.SEL.VALUE, @SM, 1)
		Y.SEL.VALUE.2 = FIELD(Y.SEL.VALUE, @SM, 2)
		
		IF Y.FIX.VALUE GE Y.SEL.VALUE.1 AND Y.FIX.VALUE LE Y.SEL.VALUE.2 ELSE
            Y.FLAG = 1
        END
    END CASE

    RETURN

*-----------------------------------------------------------------------------
WRITE.OUTPUT:
*-----------------------------------------------------------------------------
    Y.OUTPUT =  Y.AA.ID                     ; *1
    Y.OUTPUT := "*" : Y.LINKED.APPL.ID      ; *2
    Y.OUTPUT := "*" : Y.ATI.JOINT.NAME      ; *3
    Y.OUTPUT := "*" : Y.L.BILYET.NUM        ; *4
    Y.OUTPUT := "*" : Y.AMOUNT              ; *5
    Y.OUTPUT := "*" : Y.PAYOUT.ACCOUNT      ; *6
    Y.OUTPUT := "*" : Y.BEN.ACC             ; *7
    Y.OUTPUT := "*" : Y.BEN.NAME            ; *8
    Y.OUTPUT := "*" : Y.SKN.RECEIV.BANK     ; *9
    Y.OUTPUT := "*" : Y.RTGS.CODE           ; *10
    Y.OUTPUT := "*" : Y.CUSTOMER            ; *11
	
	Y.OUTPUTLIST<-1> = Y.OUTPUT

    RETURN	

*-----------------------------------------------------------------------------
END
