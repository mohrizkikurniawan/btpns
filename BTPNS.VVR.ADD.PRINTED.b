    SUBROUTINE BTPNS.VVR.ADD.PRINTED
*-----------------------------------------------------------------------------
* Developer Name     : Saidah Manshuroh
* Development Date   : 20220915
* Description        : Routine to validate address option
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description		: 
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.CUSTOMER
	$INSERT I_F.AA.ACCOUNT
    $INSERT I_AA.LOCAL.COMMON
	$INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	FN.CUSTOMER			= "F.CUSTOMER"
	F.CUSTOMER			= ""
	CALL OPF(FN.CUSTOMER, F.CUSTOMER)
	
	FN.AA.ARRANGEMENT	= "F.AA.ARRANGEMENT"
	F.AA.ARRANGEMENT	= ""
	CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
	
	Y.APP<1>			= "AA.ARR.ACCOUNT"
	Y.APP<2>			= "CUSTOMER"
	Y.FLD<1,1>			= "ADD.PRINTED"
	Y.FLD<2,1>			= "DISTRICT.CODE"
	Y.FLD<2,2>			= "ADD.STREET"
	Y.FLD<2,3>			= "ADD.DISTRICT"
	Y.FLD<2,4>			= "ADD.TYPE"
	Y.POS				= ""
	CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD, Y.POS)
	Y.ADD.PRINTED.POS	= Y.POS<1,1>
	Y.DISTRICT.CODE.POS	= Y.POS<2,1>
	Y.ADD.STREET.POS	= Y.POS<2,2>
	Y.ADD.DISTRICT.POS	= Y.POS<2,3>
	Y.ADD.TYPE.POS		= Y.POS<2,4>

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	Y.ADD.PRINTED	= R.NEW(AA.AC.LOCAL.REF)<1, Y.ADD.PRINTED.POS>
	Y.ADD.PRINTED	= FIELD(Y.ADD.PRINTED, " ", 3, 999)
		
    R.ARR.ACT		= c_aalocArrActivityRec
    Y.CUSTOMER		= R.ARR.ACT<AA.ARR.ACT.CUSTOMER,1>
	
	CALL F.READ(FN.CUSTOMER, Y.CUSTOMER, R.CUSTOMER, F.CUSTOMER, Y.ERR.CUSTOMER)
	Y.STREET		= R.CUSTOMER<EB.CUS.STREET>
	Y.DISTRICT.CODE	= R.CUSTOMER<EB.CUS.LOCAL.REF, Y.DISTRICT.CODE.POS>
	Y.ADD.STREET	= R.CUSTOMER<EB.CUS.LOCAL.REF, Y.ADD.STREET.POS>
	Y.ADD.DISTRICT	= R.CUSTOMER<EB.CUS.LOCAL.REF, Y.ADD.DISTRICT.POS>
	Y.ADD.TYPE		= R.CUSTOMER<EB.CUS.LOCAL.REF, Y.ADD.TYPE.POS>
	
	BEGIN CASE
		CASE Y.ADD.PRINTED EQ ""
				AF			= AA.AC.LOCAL.REF
				AV			= Y.ADD.PRINTED.POS
				ETEXT		= "EB-IDI.INPUT.MANDATORY"
				CALL STORE.END.ERROR
				
		CASE Y.ADD.PRINTED EQ "Alamat Sesuai Identitas"
			IF Y.STREET EQ "" OR Y.DISTRICT.CODE EQ "" THEN
				AF			= AA.AC.LOCAL.REF
				AV			= Y.ADD.PRINTED.POS
				ETEXT		= "EB-ADDRESS.MISSING"
				CALL STORE.END.ERROR
			END
			
		CASE Y.ADD.PRINTED EQ "Alamat Sesuai Domisili"
			FIND Y.ADD.PRINTED IN Y.ADD.TYPE SETTING Y.POSF, Y.POSV, Y.POSS THEN
				IF Y.ADD.STREET<1,1,Y.POSS> EQ "" THEN
					AF		= AA.AC.LOCAL.REF
					AV		= Y.ADD.PRINTED.POS
					ETEXT	= "EB-ADDRESS.MISSING"
					CALL STORE.END.ERROR
				END
			END ELSE
				AF			= AA.AC.LOCAL.REF
				AV			= Y.ADD.PRINTED.POS
				ETEXT		= "EB-ADDRESS.MISSING"
				CALL STORE.END.ERROR
			END
			
		CASE Y.ADD.PRINTED EQ "Alamat Surat Menyurat"
			FIND Y.ADD.PRINTED IN Y.ADD.TYPE SETTING Y.POSF, Y.POSV, Y.POSS THEN
				IF Y.ADD.STREET<1,1,Y.POSS> EQ "" THEN
					AF		= AA.AC.LOCAL.REF
					AV		= Y.ADD.PRINTED.POS
					ETEXT	= "EB-ADDRESS.MISSING"
					CALL STORE.END.ERROR
				END
			END ELSE
				AF			= AA.AC.LOCAL.REF
				AV			= Y.ADD.PRINTED.POS
				ETEXT		= "EB-ADDRESS.MISSING"
				CALL STORE.END.ERROR
			END
	END CASE
		
    RETURN
*-----------------------------------------------------------------------------
END
