    SUBROUTINE BTPNS.MT.DEPO.KLIRING(Y.AA.ID)
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 05 Sept 2022
* Description        : Flag account depo existing to BTPNS.TL.DEPO.KLIRING
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.SETTLEMENT
	$INSERT I_F.BTPNS.TL.DEPO.KLIRING
	$USING EB.Updates
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

	COMMON/DEPO.KLIRING.COM/FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT,FN.BTPNS.TL.DEPO.KLIRING,F.BTPNS.TL.DEPO.KLIRING,Y.SKN.RTGS.POS
	
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
	
    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ERR.AAR)
    Y.CO.CODE           = R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
	
    Y.PROPERTY.ID.SET = "SETTLEMENT"
    Y.PROPERTY.CLASS.SET = ""
    Y.EFFECTIVE.DATE.SET = TODAY
    CALL AA.GET.PROPERTY.RECORD("",Y.AA.ID,Y.PROPERTY.ID.SET,Y.EFFECTIVE.DATE.SET,Y.PROPERTY.CLASS.SET,"",R.AA.SETTLEMENT,RET.ERROR.SET)
    Y.SKN.RTGS          = R.AA.SETTLEMENT<AA.SET.LOCAL.REF,Y.SKN.RTGS.POS>
	
	CALL F.READ(FN.BTPNS.TL.DEPO.KLIRING, Y.ARR.ID, R.BTPNS.TL.DEPO.KLIRING, F.BTPNS.TL.DEPO.KLIRING, BTPNS.TL.DEPO.KLIRING.ERR)
	  	
	R.BTPNS.TL.DEPO.KLIRING<BtpnsTlDepoKliring_ProductLine> = 'DEPOSITS'
	R.BTPNS.TL.DEPO.KLIRING<BtpnsTlDepoKliring_TypeTransfer>= Y.SKN.RTGS
	R.BTPNS.TL.DEPO.KLIRING<BtpnsTlDepoKliring_IdCompany>	= Y.CO.CODE	
	
	CALL F.WRITE(FN.BTPNS.TL.DEPO.KLIRING, Y.AA.ID, R.BTPNS.TL.DEPO.KLIRING)
	
    RETURN

*-----------------------------------------------------------------------------
END
