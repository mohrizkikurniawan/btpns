    SUBROUTINE BTPNS.EBR.BIFAST.BIC(ENQ.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221115
* Description        : Build routine for selection enq incoming (kode bic)
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
	$INSERT I_F.IDCH.RTGS.BANK.CODE.G2

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    
    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	fnIdchRtgsBankCodeG2    = "F.IDCH.RTGS.BANK.CODE.G2"
    fvIdchRtgsBankCodeG2    = ""
    CALL OPF(fnIdchRtgsBankCodeG2, fvIdchRtgsBankCodeG2)

	arrApp<1> 	= "IDCH.RTGS.BANK.CODE.G2"
	arrFld<1,1>	= "SKN.CLR.CODE"
	arrPos		= ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	sknClrCodePos	 	 = arrPos<1,1>

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    FIND "ISSUER.ID" IN ENQ.DATA<2> SETTING POSF, POSV, POSS THEN
        bicCode = ENQ.DATA<4,POSV>
        IF bicCode NE '' THEN
            CALL F.READ(fnIdchRtgsBankCodeG2, bicCode, rvIdchRtgsBankCodeG2, fvIdchRtgsBankCodeG2, "")
            sknClrCode  = rvIdchRtgsBankCodeG2<IdchRtgsBankCodeG2_LocalRef, sknClrCodePos>[1,3]
    
			ENQ.DATA<2,POSV>	= "ISSUER.ID"
            ENQ.DATA<3,POSV>	= "CT"
			ENQ.DATA<4,POSV>	= sknClrCode         
        END
    END
	
	RETURN
*-----------------------------------------------------------------------------
END

