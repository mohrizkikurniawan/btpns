	SUBROUTINE BTPNS.VIN.VAL.DATA.LL
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
    $INSERT I_F.CUSTOMER
    $INSERT I_F.COMPANY

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB Initialise
	GOSUB Process

	RETURN
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

	fnCustomer  = 'F.CUSTOMER'
    fvCustomer  = ''
    CALL OPF(fnCustomer, fvCustomer)

    fnCompany   = 'F.COMPANY'
    fvCompany   = ''
    CALL OPF(fnCompany, fvCompany)


	RETURN
*-----------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------
	
	vData		= R.NEW(Batch_Data)
	vCif		= vData<1, 1, 2>
    vCompany    = vData<1, 1, 3>

    CALL F.READ(fnCustomer, vCustomer, rCustomer, fvCustomer, '')
    IF rCustomer EQ '' THEN
		AF    	= BAT.DATA
		ETEXT	= "Customer tidak ditemukan"
		CALL STORE.END.ERROR		
		RETURN
    END

    CALL F.READ(fnCompany, vCompany, rCompany, fvCompany, '')
    IF rCompany EQ '' THEN
		AF    	= BAT.DATA
		ETEXT	= "Cabang tidak ditemukan"
		CALL STORE.END.ERROR		
		RETURN
    END

	RETURN
*-----------------------------------------------------------------------------
END

