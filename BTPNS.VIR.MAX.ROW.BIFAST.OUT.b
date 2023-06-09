	SUBROUTINE BTPNS.VIR.MAX.ROW.BIFAST.OUT
*-----------------------------------------------------------------------------
* Developer Name     : Khoirul Rokhim
* Development Date   : 04 Agt 2022
* Description        : Check Maximal Row Upload BIFAST Outgoing
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : Moh Rizki Kurniawan
* Modified by        : 18 Agustus 2022
* Description        : add logic to check filename
*-----------------------------------------------------------------------------

	$INSERT I_COMMON
	$INSERT I_EQUATE
	$INSERT I_BATCH.FILES
	$INSERT I_TSA.COMMON
	$INSERT I_F.EB.FILE.UPLOAD
	$INSERT I_F.EB.FILE.UPLOAD.TYPE
	$INSERT I_F.EB.FILE.UPLOAD.PARAM
	$INSERT I_F.EB.ERROR

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB INIT
	GOSUB PROCESS

	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	FN.EB.FILE.UPLOAD = 'F.EB.FILE.UPLOAD'
	F.EB.FILE.UPLOAD  = ''
	CALL OPF(FN.EB.FILE.UPLOAD, F.EB.FILE.UPLOAD)

	FN.EB.FILE.UPLOAD.TYPE = 'F.EB.FILE.UPLOAD.TYPE'
	F.EB.FILE.UPLOAD.TYPE  = ''
	CALL OPF(FN.EB.FILE.UPLOAD.TYPE, F.EB.FILE.UPLOAD.TYPE)

	FN.EB.FILE.UPLOAD.PARAM = 'F.EB.FILE.UPLOAD.PARAM'
	F.EB.FILE.UPLOAD.PARAM  = ''
	CALL OPF(FN.EB.FILE.UPLOAD.PARAM, F.EB.FILE.UPLOAD.PARAM)
	
	FN.EB.ERROR				= 'F.EB.ERROR'
	F.EB.ERROR				= ''
	CALL OPF(FN.EB.ERROR, F.EB.ERROR)
	
	Y.UPLOAD.TYPE		= R.NEW(EB.UF.UPLOAD.TYPE)

    CALL F.READ(FN.EB.FILE.UPLOAD.PARAM, "SYSTEM", R.EB.FILE.UPLOAD.PARAM, F.EB.FILE.UPLOAD.PARAM, EB.FILE.UPLOAD.PARAM.ERR)


	Y.POS		= ''
	Y.APP		= 'EB.FILE.UPLOAD.TYPE'
	Y.FIELD		= 'B.MAX.ROW'

	CALL MULTI.GET.LOC.REF(Y.APP, Y.FIELD, Y.POS)

	Y.B.MAX.ROW.POS	= Y.POS<1,1>

	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	Y.SYSTEM.FILE.NAME	= R.NEW(EB.UF.SYSTEM.FILE.NAME)
	Y.FILE.NAME			= R.NEW(EB.UF.FILE.NAME)

	CALL F.READ(FN.EB.FILE.UPLOAD.TYPE, Y.UPLOAD.TYPE, R.EB.FILE.UPLOAD.TYPE, F.EB.FILE.UPLOAD.TYPE, EB.FILE.UPLOAD.TYPE.ERR)
	Y.B.MAX.ROW		= R.EB.FILE.UPLOAD.TYPE<EB.UT.LOCAL.REF, Y.B.MAX.ROW.POS>
	
	Y.DATE.FILE.NAME	= FIELD(Y.FILE.NAME, "-", 1)
	IF Y.DATE.FILE.NAME NE TODAY THEN
		AF    	= EB.UF.FILE.NAME
		ETEXT	= "EB-BIFAST.DATE.DIFFERENT"
		CALL STORE.END.ERROR			
	END
	
	SEL.CMD := "SELECT " : FN.EB.FILE.UPLOAD : " WITH UPLOAD.TYPE EQ " : Y.UPLOAD.TYPE : " AND FILE.NAME EQ " : Y.FILE.NAME
	CALL EB.READLIST(SEL.CMD, SEL.LIST, "", SEL.CNT, SEL.ERR)
	IF SEL.LIST NE '' THEN
		AF    	= EB.UF.FILE.NAME
		ETEXT	= "EB-BIFAST.NAME.DUPLIKAT"
		CALL STORE.END.ERROR		
	END
	
	FN.DIR.FILE = R.EB.FILE.UPLOAD.PARAM<EB.UP.TC.UPLOAD.PATH> : "\" : R.EB.FILE.UPLOAD.TYPE<EB.UT.UPLOAD.DIR>
	
	OPEN FN.DIR.FILE TO F.DIR.FILE ELSE
        Y.ERROR.MESSAGE = "CANNOT OPEN TXT FILE FOLDER"
        RETURN
    END	
	
	CALL F.READ(FN.DIR.FILE, Y.SYSTEM.FILE.NAME, R.DIR.FILE, F.DIR.FILE, DIR.FILE.ERR)
    Y.CNT.DATA	= DCOUNT(R.DIR.FILE, FM)
	
	Y.ID	= 'EB-BIFAST.MAX.ROW'
	
	CALL F.READ(FN.EB.ERROR, Y.ID, R.ERROR, F.EB.ERROR, ERROR.ERR)
	Y.DESC.ERROR	= R.ERROR<EB.ERR.ERROR.MSG>

	IF Y.CNT.DATA GT Y.B.MAX.ROW THEN
		AF    	= EB.UF.FILE.NAME
		ETEXT	= Y.DESC.ERROR : " " : Y.B.MAX.ROW
		CALL STORE.END.ERROR
	END
	
*	Y.FILE.NAME.CHECK	= FIELD(Y.FILE.NAME, ".", 1)
*	Y.FILE.NAME.CHECK	= FIELD(Y.FILE.NAME.CHECK, "-", 2)
*	Y.FILE.NAME.CHECKCNT= LEN(Y.FILE.NAME.CHECK)
*	Y.PARAM				= Y.FILE.NAME.CHECKCNT - 4
*	Y.FILE.NAME.CHECK	= Y.FILE.NAME.CHECK[1, Y.PARAM]

	Y.FILE.NAME.CHECK	= FIELD(Y.FILE.NAME, ".", 1)
	Y.FILE.NAME.CHECK	= FIELD(Y.FILE.NAME.CHECK, "-", 2)
	
	IF NOT(ISUPPER(Y.FILE.NAME.CHECK)) THEN
		AF    	= EB.UF.FILE.NAME
		ETEXT	= "EB-BIFAST.CHAR.UPPER"
		CALL STORE.END.ERROR	
	END
	
	FINDSTR SPACE(1) IN Y.FILE.NAME SETTING Y.POSF, Y.POSV, Y.POSS THEN
		AF    	= EB.UF.FILE.NAME
		ETEXT	= "EB-BIFAST.NOT.SPACE"
		CALL STORE.END.ERROR	 	
	END
	
	Y.FILE.NAME.CHECK	= Y.FILE.NAME
	CONVERT ' ' TO "#" IN Y.FILE.NAME.CHECK
	
	FINDSTR '#' IN Y.FILE.NAME.CHECK SETTING Y.POSF, Y.POSV, Y.POSS THEN
		AF    	= EB.UF.FILE.NAME
		ETEXT	= "EB-BIFAST.NOT.SPACE"
		CALL STORE.END.ERROR	 	
	END



	RETURN
*-----------------------------------------------------------------------------
END




