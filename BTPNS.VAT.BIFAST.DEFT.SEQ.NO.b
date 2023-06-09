*-----------------------------------------------------------------------------
* <Rating>-56</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.VAT.BIFAST.DEFT.SEQ.NO
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220705
* Description        : Routine to default BI FAST OUT CR fields
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
    
*------------------------------------------------------------------------------
MAIN:
*------------------------------------------------------------------------------
    GOSUB INITIAL
    GOSUB PROCESS

    RETURN

*------------------------------------------------------------------------------
INITIAL:
*------------------------------------------------------------------------------

    FN.LOCK = "F.LOCKING"
	F.LOCK  = ""
	CALL OPF(FN.LOCK, F.LOCK)
	
	FN.BTPNS.TL.BFAST.INTERFACE.PARAM = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
	F.BTPNS.TL.BFAST.INTERFACE.PARAM  = ""
	CALL OPF(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, F.BTPNS.TL.BFAST.INTERFACE.PARAM)
	
	Y.APP = "FUNDS.TRANSFER"
	Y.FLD = "B.SEQ.NO" : VM : "IN.STAN" : VM : "IN.TRNS.DT.TM" : VM : "IN.UNIQUE.ID" : VM : "IN.CHANNEL.ID"
	Y.FLD := VM : "IN.REVERSAL.ID"
	Y.POS = ""
	CALL MULTI.GET.LOC.REF(Y.APP,Y.FLD,Y.POS)
	
	Y.B.SEQ.NO.POS       = Y.POS<1,1>
	Y.IN.STAN.POS        = Y.POS<1,2>
	Y.IN.TRNS.DT.TM.POS  = Y.POS<1,3>
	Y.IN.UNIQUE.ID.POS   = Y.POS<1,4>
	Y.IN.CHANNEL.ID.POS  = Y.POS<1,5>
	Y.IN.REVERSAL.ID.POS = Y.POS<1,6>

    RETURN

*------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------

*    Y.LOCK.ID = 'BIFAST.OUTCR'
*    CALL F.READ(FN.LOCK, Y.LOCK.ID, R.LOCK, F.LOCK, ERR2)
*
*    IF R.LOCK EQ '' THEN
*        Y.SEQ.NO = TODAY : '00000001'
*    END ELSE
*        GOSUB BATCH.SEQ
*    END
*
*    R.LOCK<1> = Y.SEQ.NO
*    WRITE R.LOCK TO F.LOCK, Y.LOCK.ID
*	
*	R.NEW(FT.LOCAL.REF)<1,Y.B.SEQ.NO.POS> = Y.SEQ.NO[8]
	
	
	X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
    Y.CURRENT.TIME = TIMESTAMP()
    Y.MILLISECONDS = FIELD(Y.CURRENT.TIME,".",2)[1,2]
	
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
	Y.TM = Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]:Y.MILLISECONDS
    
    R.NEW(FT.LOCAL.REF)<1,Y.B.SEQ.NO.POS> = Y.TM

	Y.STAN.1 = RND(100)
    IF LEN(Y.STAN.1) EQ 1 THEN
        Y.STAN.1 = Y.STAN.1:RND(10)
    END
    Y.STAN.2 = RND(100)
    IF LEN(Y.STAN.2) EQ 1 THEN
        Y.STAN.2 = Y.STAN.2:RND(10)
    END
    Y.STAN.3 = RND(100)
    IF LEN(Y.STAN.3) EQ 1 THEN
        Y.STAN.3 = Y.STAN.3:RND(10)
    END
    Y.STAN = Y.STAN.1:Y.STAN.2:Y.STAN.3
	
	Y.RND = RND(100)
    IF LEN(Y.RND) EQ 1 THEN
        Y.RND = Y.RND:RND(10)
    END
	Y.CHANNEL = "6010"    ;*TELLER
	
	CALL F.READ(FN.BTPNS.TL.BFAST.INTERFACE.PARAM, "SYSTEM",R.BTPNS.INT.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,READ.PAR.ERR)
	Y.ID.TC = R.BTPNS.INT.PARAM<BF.INT.PAR.ID.TC>
	
	R.NEW(FT.LOCAL.REF)<1,Y.IN.STAN.POS>       = Y.STAN
	R.NEW(FT.LOCAL.REF)<1,Y.IN.TRNS.DT.TM.POS> = DT
	R.NEW(FT.LOCAL.REF)<1,Y.IN.CHANNEL.ID.POS> = Y.CHANNEL
	R.NEW(FT.LOCAL.REF)<1,Y.IN.UNIQUE.ID.POS>  = Y.ID.TC
*	R.NEW(FT.LOCAL.REF)<1,Y.IN.REVERSAL.ID.POS>= "BI.":DT[1,6]:".":"0000":Y.RND:Y.STAN
    R.NEW(FT.LOCAL.REF)<1,Y.IN.REVERSAL.ID.POS>= "BI.":DT[1,6]:".":"0000":Y.TM

    RETURN
*------------------------------------------------------------------------------
*BATCH.SEQ:
*------------------------------------------------------------------------------
*    Y.CUR.SEQ.NO = R.LOCK<1>
*    Y.SEQ.NO.TGL = SUBSTRINGS(Y.CUR.SEQ.NO,1,8)
*    Y.CUR.TGL = TODAY
*
*    IF Y.SEQ.NO.TGL NE Y.CUR.TGL THEN
*        Y.LAST.LOCK = R.LOCK<1>[8]
*        Y.SEQ.NO = Y.CUR.TGL : Y.LAST.LOCK+1
*    END ELSE
*        Y.SEQ.NO = R.LOCK<1>+1
*    END
*
*
*    RETURN

*-----------------------------------------------------------
END
