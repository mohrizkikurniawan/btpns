*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.E.GET.PYADIT(Y.DATA)
*-----------------------------------------------------------------------------
* Create by   : BTPNS-GES
* Create Date : 18 Apr 2022
* Description : Routine for get value PYADIT
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.RE.STAT.RANGE

	GOSUB INIT
	GOSUB PROCESS
	
	RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	FN.RANGE = 'F.RE.STAT.RANGE' ; F.RANGE = ''
	CALL OPF(FN.RANGE,F.RANGE)
	
	FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT' ; F.AA.ARRANGEMENT = ''
	CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
	
	Y.VALUE.ASSET = 0
	Y.SUM.VALUE.ASSET = 0
	
	RETURN
	
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	CALL F.READ(FN.AA.ARRANGEMENT,Y.DATA,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARRANGEMENT.ERR)
	Y.AA.ACCT.CNT=DCOUNT(R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL>,@VM)
	FOR I = 1 TO Y.AA.ACCT.CNT
		Y.AA.ACCT = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL,I>
		IF Y.AA.ACCT = 'ACCOUNT' THEN
			Y.ID.CONTRACT = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID,I>
			EXIT
		END
	NEXT I
	
	Y.TYPE.ASSET = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
	
	BEGIN CASE 
	CASE Y.TYPE.ASSET EQ 'BTPNS.PRK.FINANCE'
		Y.RANGE.ID = 'SCHEDULERFEE'
	CASE Y.TYPE.ASSET EQ 'BTPNS.IS.MUL.STR.FIN'
		Y.RANGE.ID = 'PRINCIPALPFT'
	CASE Y.TYPE.ASSET EQ 'BTPNS.MUS.FINANCE'
		Y.RANGE.ID = 'PRINCIPALPFT'
	END CASE
	
	CALL F.READ(FN.RANGE,Y.RANGE.ID,R.RANGE,F.RANGE,RANGE.ERR)
	Y.CNT.RANGE = DCOUNT(R.RANGE<RE.RNG.START.RANGE>,@VM)
	
	FOR X = 1 TO Y.CNT.RANGE
		Y.TYPE.ASSET = R.RANGE<RE.RNG.START.RANGE,X>
		IF Y.TYPE.ASSET[1,2] EQ 'SS' THEN CONTINUE
		IF Y.TYPE.ASSET[1,3] EQ 'DBT' THEN CONTINUE
		IF Y.TYPE.ASSET[1,3] EQ 'LOS' THEN CONTINUE
		CALL EB.GET.ECB.TYPE.VAL(Y.ID.CONTRACT, Y.TYPE.ASSET, Y.VALUE.ASSET)
		Y.SUM.VALUE.ASSET+=Y.VALUE.ASSET
	NEXT X
	
	Y.DATA = Y.SUM.VALUE.ASSET
	
    RETURN
*-----------------------------------------------------------------------------
END
