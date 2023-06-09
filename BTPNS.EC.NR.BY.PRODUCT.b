*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.EC.NR.BY.PRODUCT(Y.APPLIC.ID, Y.APPLIC.REC, Y.STMT.ID, Y.STMT.REC, Y.OUT.TEXT)
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20220727
* Description        : -
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: - 20220804
* Modified by    	: - Moh Rizki Kurniawan
* Description		: - add logic case to check Product Category and Account LCY
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.PRODUCT.GROUP
	DEBUG
	GOSUB INIT
	GOSUB PROCESS
	
	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    FN.AA.ARRANGEMENT = "F.AA.ARRANGEMENT"
    F.AA.ARRANGEMENT  = ""
    CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)

    FN.AA.PRODUCT.GROUP = "F.AA.PRODUCT.GROUP"
    F.AA.PRODUCT.GROUP  = ""
    CALL OPF(FN.AA.PRODUCT.GROUP, F.AA.PRODUCT.GROUP)

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.APPLICATION = 'AA.ARRANGEMENT.ACTIVITY'
    CALL GET.STANDARD.SELECTION.DETS(Y.APPLICATION,REC.SS)
    CALL FIELD.NAMES.TO.NUMBERS("ARRANGEMENT",REC.SS,FIELD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)

    Y.ARRANGEMENT = Y.APPLIC.REC<FIELD.NO>
	
    Y.APPLICATION = 'STMT.ENTRY'
    CALL GET.STANDARD.SELECTION.DETS(Y.APPLICATION,REC.SS)
    CALL FIELD.NAMES.TO.NUMBERS("AMOUNT.LCY",REC.SS,FIELD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
	
	Y.AMOUNT.LCY  = Y.APPLIC.REC<FIELD.NO>
	
	CALL FIELD.NAMES.TO.NUMBERS("PRODUCT.CATEGORY",REC.SS,FIELD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
	Y.PRODUCT.CATEGORY	= Y.APPLIC.REC<FIELD.NO>
	
    CALL F.READ(FN.AA.ARRANGEMENT, Y.ARRANGEMENT, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, READ.COMP.ERR)
	Y.PRODUCT.GROUP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
	
	CALL F.READ(FN.AA.PRODUCT.GROUP, Y.PRODUCT.GROUP, R.AA.PRODUCT.GROUP, F.AA.PRODUCT.GROUP, AA.PRODUCT.GROUP.ERR)
	Y.PRODUCT.GROUP.DESC = R.AA.PRODUCT.GROUP<AaProductGroup_Description>
	
	Y.TEST = Y.PRODUCT.CATEGORY[1,1]
	Y.TEST.2 = LEN(Y.PRODUCT.CATEGORY)
    BEGIN CASE		
		CASE (Y.PRODUCT.CATEGORY[1,1] EQ 1 OR Y.PRODUCT.CATEGORY[1,1] EQ 6) AND (LEN(Y.PRODUCT.CATEGORY) EQ 4) AND Y.AMOUNT.LCY GT 0
			Y.OUT.TEXT = "Pencairan " : Y.PRODUCT.GROUP.DESC
		CASE (Y.PRODUCT.CATEGORY[1,1] EQ 3) AND (LEN(Y.PRODUCT.CATEGORY) EQ 4) AND Y.AMOUNT.LCY LT 0
			Y.OUT.TEXT = "Pencairan " : Y.PRODUCT.GROUP.DESC
		CASE (Y.PRODUCT.CATEGORY[1,1] EQ 1 OR Y.PRODUCT.CATEGORY[1,1] EQ 6) AND (LEN(Y.PRODUCT.CATEGORY) EQ 4) AND Y.AMOUNT.LCY LT 0
			Y.OUT.TEXT = "Pembayaran " : Y.PRODUCT.GROUP.DESC
		CASE (Y.PRODUCT.CATEGORY[1,1] EQ 3) AND (LEN(Y.PRODUCT.CATEGORY) EQ 4) AND Y.AMOUNT.LCY GT 0
			Y.OUT.TEXT = "Pembayaran " : Y.PRODUCT.GROUP.DESC
		CASE OTHERWISE
			Y.OUT.TEXT = "Transaksi " : Y.PRODUCT.GROUP.DESC
    END CASE
	
	RETURN
*-----------------------------------------------------------------------------
END
