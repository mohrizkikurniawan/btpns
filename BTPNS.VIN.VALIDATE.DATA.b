	SUBROUTINE BTPNS.VIN.VALIDATE.DATA
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20230201
* Description        : Validate Input GL dan tanggal pada extract statement
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : 
* Modified by        : 
* Description        : 
*-----------------------------------------------------------------------------

	$INSERT I_COMMON
	$INSERT I_EQUATE
	$INSERT I_BATCH.FILES
	$INSERT I_TSA.COMMON
	$INSERT I_F.BATCH

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB Initialise
	GOSUB Process

	RETURN
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

	fnAccount	= "F.ACCOUNT"
	fvAccount	= ""
	CALL OPF(fnAccount, fvAccount)

	RETURN
*-----------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------
	
	vData		= R.NEW(Batch_Data)
	vDate		= vData<1, 1, 1>

	vAccountCnt     = DCOUNT(vData, @SM)
    FOR idx = 2 TO vAccountCnt
		vGl      = vData<1, 1, idx>
		IF vGl NE '' THEN
			CALL F.READ(fnAccount, vGl, rAccount, fvAccount, '')

			IF rAccount EQ '' THEN
				AF    	= BAT.DATA
				ETEXT	= "Account pada line ke-" : idx-1 : " tidak ditemukan"
				CALL STORE.END.ERROR		
				RETURN
			END
		END
    NEXT idx

	IF vDate GT TODAY THEN
		AF    	= BAT.DATA
		ETEXT	= "Tanggal melebihi hari ini"
		CALL STORE.END.ERROR
		RETURN		
	END

	vDateCnt	= LEN(vDate)
	IF vDateCnt NE 8 THEN
		AF    	= BAT.DATA
		ETEXT	= "Format tanggal tidak sesuai"
		CALL STORE.END.ERROR
		RETURN		
	END

	vYear		= vDate[1,4]
	IF vYear LT 2000 THEN
		AF    	= BAT.DATA
		ETEXT	= "Format tahun tidak seuai"
		CALL STORE.END.ERROR
		RETURN		
	END	

	vMonth		= vDate[5,2]
	IF vMonth GT 12 THEN
		AF    	= BAT.DATA
		ETEXT	= "Format bulan tidak sesuai"
		CALL STORE.END.ERROR
		RETURN		
	END		

	vDay		= vDate[7,2]
	IF vDay GT 31 THEN
		AF    	= BAT.DATA
		ETEXT	= "Format tanggal tidak sesuai"
		CALL STORE.END.ERROR
		RETURN		
	END		


	RETURN
*-----------------------------------------------------------------------------
END




