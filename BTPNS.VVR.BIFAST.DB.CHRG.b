    SUBROUTINE BTPNS.VVR.BIFAST.DB.CHRG
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221201
* Description        : Routine to default charge.acct from db ac
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* 
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    

    RETURN	

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    vCommissionCode = COMI
	vAccount		= R.NEW(FT.DEBIT.ACCT.NO)
	vCommissionType	= R.NEW(FT.COMMISSION.TYPE)
	vCommissionAmt	= R.NEW(FT.COMMISSION.AMT)	
	vCommissionTypeCnt = DCOUNT(vCommissionType, @VM)

    IF vCommissionCode EQ "WAIVE" OR "" THEN
        R.NEW(FT.CHARGES.ACCT.NO) = ""
        R.NEW(FT.COMMISSION.TYPE) = ""
        R.NEW(FT.COMMISSION.AMT) = ""
		IF vCommissionTypeCnt GE 2 THEN
			FOR I = 2 TO vCommissionTypeCnt
				DEL R.NEW(FT.COMMISSION.TYPE)<1, I>
				DEL R.NEW(FT.COMMISSION.AMT)<1, I>
			NEXT I
		END
    END ELSE
        R.NEW(FT.CHARGES.ACCT.NO) = vAccount
    END


    RETURN	

*-----------------------------------------------------------------------------
END
