    SUBROUTINE BTPNS.POST.UPD.COLL.PERC
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia 
* Development Date   : 202310202
* Description        : Routine to validate Coll Percentage and Execution Value
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : 
* Modified by        : 
* Description        : 
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.ACTION.CONTEXT
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.COLLATERAL

    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
    FN.COLLATERAL = "F.COLLATERAL"
    F.COLLATERAL  = ""
    CALL OPF(FN.COLLATERAL, F.COLLATERAL)
	
	FN.ARRANGEMENT = "F.AA.ARRANGEMENT"
    F.ARRANGEMENT  = ""
    CALL OPF(FN.ARRANGEMENT, F.ARRANGEMENT)

    Y.APP       = "AA.PRD.DES.ACCOUNT" :FM: "COLLATERAL"
    Y.FLD.NAME  = "ATI.COLL.CODE" :VM: "ATI.PERC.ALLOC" :VM: "AGN.FLAG"
    Y.FLD.NAME := FM: "LD.REF.NO" :VM: "LD.COLL.PRCTG"
    Y.POS       = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)
    Y.COLL.CODE.POS  = Y.POS<1, 1>
    Y.PERC.ALLOC.POS = Y.POS<1, 2>
    Y.AGN.FLAG.POS   = Y.POS<1, 3>

    Y.LD.REF.NO.POS     = Y.POS<2, 1>
    Y.LD.COLL.PRCTG.POS = Y.POS<2, 2>

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	vActivityStatus	= c_arrActivityStatus
	Y.ARR.ID		= AA$ARR.ID

	Y.COLL.CODE.OLD	= R.OLD(AA.AC.LOCAL.REF)<1, Y.COLL.CODE.POS>
    Y.AGN.FLAG		= R.NEW(AA.AC.LOCAL.REF)<1, Y.AGN.FLAG.POS>
	Y.COLL.CODE		= R.NEW(AA.AC.LOCAL.REF)<1, Y.COLL.CODE.POS>
    Y.PERC.ALLOC	= R.NEW(AA.AC.LOCAL.REF)<1, Y.PERC.ALLOC.POS>
    Y.CNT.COLL   	= DCOUNT(Y.COLL.CODE, SM)

	BEGIN CASE
    CASE vActivityStatus EQ "AUTH"
        GOSUB PROCESS.AUTH
    CASE 1
        RETURN
    END CASE
   
    RETURN

*-----------------------------------------------------------------------------
UpdateDeteleAaFromCollateral:
*-----------------------------------------------------------------------------
	
    CALL F.READ(FN.COLLATERAL, idCollCodeOldToDeleteNow, R.COLLATERAL, F.COLLATERAL, COLLATERAL.ERR)
	FIND Y.ARR.ID IN R.COLLATERAL<COLL.LOCAL.REF, Y.LD.REF.NO.POS> SETTING Y.POSF, Y.POSV, Y.POSS THEN
		DEL R.COLLATERAL<COLL.LOCAL.REF, Y.LD.REF.NO.POS, Y.POSS>
		DEL R.COLLATERAL<COLL.LOCAL.REF, Y.LD.COLL.PRCTG.POS, Y.POSS>
        CALL ID.LIVE.WRITE(FN.COLLATERAL, idCollCodeOldToDeleteNow, R.COLLATERAL)
	END

    RETURN

*-----------------------------------------------------------------------------
PROCESS.AUTH:
*-----------------------------------------------------------------------------
	
    Y.COLL.CODE.OLD	= CHANGE(CHANGE(CHANGE(Y.COLL.CODE.OLD ," ", @FM), @SM, @FM), @VM, @FM)
    Y.COLL.CODE		= CHANGE(CHANGE(CHANGE(Y.COLL.CODE ," ", @FM), @SM, @FM), @VM, @FM)
	Y.PERC.ALLOC	= CHANGE(CHANGE(CHANGE(Y.PERC.ALLOC ," ", @FM), @SM, @FM), @VM, @FM)

    FOR idx=1 TO DCOUNT(Y.COLL.CODE.OLD,@FM)
        idCollCodeOld = Y.COLL.CODE.OLD<idx>
        LOCATE idCollCodeOld IN Y.COLL.CODE<1> SETTING iPos ELSE
            idCollCodeOldToDelete<-1> = idCollCodeOld
        END
    NEXT idx

    FOR idx=1 TO DCOUNT(idCollCodeOldToDelete,@FM)
        idCollCodeOldToDeleteNow = idCollCodeOldToDelete<idx>
        GOSUB UpdateDeteleAaFromCollateral
    NEXT idx

	FOR Y.LOOP = 1 TO DCOUNT( Y.COLL.CODE,@FM)
        Y.CUR.COLL = Y.COLL.CODE<Y.LOOP>
        CALL F.READ(FN.COLLATERAL, Y.CUR.COLL, R.COLLATERAL, F.COLLATERAL, COLLATERAL.ERR)
        R.COLLATERAL.OLD = R.COLLATERAL
				
		FIND Y.ARR.ID IN R.COLLATERAL<COLL.LOCAL.REF, Y.LD.REF.NO.POS> SETTING Y.POSF, Y.POSV, Y.POSS THEN
			IF R.COLLATERAL<COLL.LOCAL.REF, Y.LD.COLL.PRCTG.POS, Y.POSS> NE Y.PERC.ALLOC<Y.LOOP> THEN
                R.COLLATERAL<COLL.LOCAL.REF, Y.LD.COLL.PRCTG.POS, Y.POSS> = Y.PERC.ALLOC<Y.LOOP>
            END
		END ELSE
			R.COLLATERAL<COLL.LOCAL.REF, Y.LD.REF.NO.POS, -1>		= Y.ARR.ID
			R.COLLATERAL<COLL.LOCAL.REF, Y.LD.COLL.PRCTG.POS, -1>	= Y.PERC.ALLOC<Y.LOOP>
        END

        IF R.COLLATERAL.OLD NE R.COLLATERAL THEN CALL ID.LIVE.WRITE(FN.COLLATERAL, Y.CUR.COLL, R.COLLATERAL)
    NEXT Y.LOOP
	
	RETURN

*-----------------------------------------------------------------------------
END
