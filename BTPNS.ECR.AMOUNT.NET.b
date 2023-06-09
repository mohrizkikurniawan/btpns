*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.ECR.AMOUNT.NET
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20220912
* Description        : Conversion routine for amount net deposito
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
	$INSERT I_F.IDIH.PMS.CALC.PARAMETER
	$INSERT I_F.BTPNS.TH.BIFAST.STO.DEPO

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB INIT
	GOSUB PROCESS
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	FN.IDIH.PMS.CALC.PARAMETER	= 'F.IDIH.PMS.CALC.PARAMETER'
	F.IDIH.PMS.CALC.PARAMETER	= ''
	CALL OPF(FN.IDIH.PMS.CALC.PARAMETER, F.IDIH.PMS.CALC.PARAMETER)
	
	FN.BTPNS.TH.BIFAST.STO.DEPO	= 'F.BTPNS.TH.BIFAST.STO.DEPO'
	F.BTPNS.TH.BIFAST.STO.DEPO = ''
	CALL OPF(FN.BTPNS.TH.BIFAST.STO.DEPO, F.BTPNS.TH.BIFAST.STO.DEPO)
	
	RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	Y.ID.STO	= O.DATA
	Y.ID.FT		= FIELD(OD.DATA, ".", 3)
	
	CALL F.READ(FN.IDIH.PMS.CALC.PARAMETER, "SYSTEM", R.IDIH.PMS.CALC.PARAMETER, F.IDIH.PMS.CALC.PARAMETER, IDIH.PMS.CALC.PARAMETER.ERR)
	Y.PERCENTAX	= R.IDIH.PMS.CALC.PARAMETER<IdihPmsCalcParameter_TaxRate>
	
	CALL F.READ(FN.BTPNS.TH.BIFAST.STO.DEPO, Y.ID.STO, R.BTPNS.TH.BIFAST.STO.DEPO, F.BTPNS.TH.BIFAST.STO.DEPO, BTPNS.TH.BIFAST.STO.DEPO.ERR)
	Y.AMOUNT	= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_DistAmount>
	Y.AMT.TYPE	= R.BTPNS.TH.BIFAST.STO.DEPO<BtpnsThBifastStoDepo_AmountType>
	
	IF Y.AMT.TYPE EQ 'PRINCIPAL' THEN
		O.DATA = Y.AMOUNT
	END ELSE
		O.DATA = DROUND((Y.AMOUNT * ((100 - Y.PERCENTAX)/100)),0)	
	END
	

	
	RETURN
*-----------------------------------------------------------------------------
END
