    SUBROUTINE BTPNS.VVR.BIFAST.COMMISSION
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
    $INSERT I_F.FT.COMMISSION.TYPE

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    
	fnFtCommissionType = "F.FT.COMMISSION.TYPE"
	fvftCommissionType = ""
	CALL OPF(fnFtCommissionType, fvftCommissionType)

    RETURN	

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    
    vCommissionType = COMI	
    vCommissionTypeLast = R.NEW.LAST(FT.COMMISSION.TYPE)
	vCommissionTypeCnt = DCOUNT(vCommissionType, @VM)

	FOR I = 1 TO vCommissionTypeCnt
        test = vCommissionType<1, I>
        IF vCommissionType<1, I> NE '' THEN
            R.NEW(FT.COMMISSION.TYPE)<1, -1> = vCommissionType<1, I> 

		    CALL F.READ(fnFtCommissionType, vCommissionType<1, I>, rvFtCommissionType, fvFtCommissionType, "")
		    vFlatAmt	= rvFtCommissionType<FtCommissionType_FlatAmt>
		    vFlatAmt    = vFlatAmt<1, 1>
		    IF vFlatAmt NE '' AND vFlatAmt NE '0' THEN
		    	vCharge	= vFlatAmt
                R.NEW(FT.COMMISSION.AMT)<1, -1>  = vCharge
		    END ELSE
		    	vCharge	= FIELD(chargeAmt<1, I>, "IDR", 2)
                R.NEW(FT.COMMISSION.AMT)<1, -1>  = vCharge
		    END	  
        END
	NEXT I


    RETURN	

*-----------------------------------------------------------------------------
END
