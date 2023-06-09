    SUBROUTINE BTPNS.MT.RECON.BIFAST.LOAD
*-----------------------------------------------------------------------------
* Developer Name     : Saidah Manshuroh
* Development Date   : 20220929
* Description        : Routine for generate teksfile recon BiFast
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
    $INSERT I_BATCH.FILES
	$INSERT I_TSA.COMMON
	$INSERT I_F.BTPNS.TH.BIFAST.INCOMING
	$INSERT I_F.BTPNS.TH.BIFAST.OUTGOING
	$INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.IDCH.RTGS.BANK.CODE.G2
	$INSERT I_BTPNS.MT.RECON.BIFAST.COMMON
	$INSERT I_F.ATI.TH.SFTP.PARAM
	$INSERT I_F.LOCKING
	$INCLUDE JBC.h

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

	FN.BTPNS.TH.BIFAST.INCOMING	= "F.BTPNS.TH.BIFAST.INCOMING"
	F.BTPNS.TH.BIFAST.INCOMING	= ""
	CALL OPF(FN.BTPNS.TH.BIFAST.INCOMING, F.BTPNS.TH.BIFAST.INCOMING)
	
	FN.BTPNS.TH.BIFAST.OUTGOING	= "F.BTPNS.TH.BIFAST.OUTGOING"
	F.BTPNS.TH.BIFAST.OUTGOING	= ""
	CALL OPF(FN.BTPNS.TH.BIFAST.OUTGOING, F.BTPNS.TH.BIFAST.OUTGOING)
	
	FN.FUNDS.TRANSFER			= "F.FUNDS.TRANSFER"
	F.FUNDS.TRANSFER			= ""
	CALL OPF(FN.FUNDS.TRANSFER, F.FUNDS.TRANSFER)
	
	FN.IDCH.RTGS.BANK.CODE.G2	= "F.IDCH.RTGS.BANK.CODE.G2"
    F.IDCH.RTGS.BANK.CODE.G2	= ""
    CALL OPF(FN.IDCH.RTGS.BANK.CODE.G2, F.IDCH.RTGS.BANK.CODE.G2)
	
    FN.ATI.TH.SFTP.PARAM 		= "F.ATI.TH.SFTP.PARAM"
    F.ATI.TH.SFTP.PARAM  		= ""
    CALL OPF(FN.ATI.TH.SFTP.PARAM, F.ATI.TH.SFTP.PARAM)

	FN.LOCKING					= "F.LOCKING"
	F.LOCKING					= ""
	CALL OPF(FN.LOCKING, F.LOCKING)
	
	Y.APP<1>					= "FUNDS.TRANSFER"
	Y.APP<2>					= "IDCH.RTGS.BANK.CODE.G2"
	Y.FLD<1,1>					= "IN.STAN"
	Y.FLD<1,2>					= "B.CDTR.PRXYTYPE"
	Y.FLD<2,1>					= "SKN.CLR.CODE"
	Y.FLD<2,2>					= "B.BANK.TYPE"
	CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD, Y.POS)
	Y.IN.STAN.POS				= Y.POS<1,1>
	Y.B.CDTR.PRXYTYPE.POS		= Y.POS<1,2>
	Y.SKN.CLR.CODE.POS			= Y.POS<2,1>
	Y.B.BANK.TYPE.POS			= Y.POS<2,2>
	
    Y.BATCH.NAME	= BATCH.INFO<1>
	IF Y.BATCH.NAME EQ "BNK/BTPNS.MT.RECON.BIFAST.SCHD" THEN
	
		Y.DATE		= OCONV(DATE(), "D4-")
		Y.YYYY		= Y.DATE[7,4]
		Y.MM		= Y.DATE[1,2]
		Y.DD		= Y.DATE[4,2]
		Y.SELDATE	= Y.YYYY : Y.MM : Y.DD
		CALL CDT("", Y.SELDATE, "-1C")
		
	END ELSE
		Y.SELDATE	= BATCH.DETAILS<3,1>
	END
	
	SEL.DATE.GE		= Y.SELDATE[3,6] : "0000"
	SEL.DATE.LE		= Y.SELDATE[3,6] : "2359"
	
	Y.TIME			= TIMEDATE()
	Y.TIME.HMS		= Y.TIME[1,8]
	CHANGE ":" TO "" IN Y.TIME.HMS
	
	CALL CDT("", Y.SELDATE, "+1C")
	Y.DATE.RECON	= Y.SELDATE
	Y.DATE.CREATED	= Y.SELDATE : Y.TIME.HMS
	
	FN.FOLDER		= "../UD/APPSHARED.BP/BIFAST.RECON"
	OPEN FN.FOLDER TO F.FOLDER ELSE
		SQL.CMD = "CREATE.FILE 'APPSHARED.BP/BIFAST.RECON' TYPE=UD"
		EXECUTE SQL.CMD
		OPEN FN.FOLDER TO F.FOLDER ELSE
		END
	END
	
	Y.BANK.CODE		= "92547"	;*Kode Bank / institusi BTPNS
	Y.SERVICE.CODE	= "CBS"		;*Kode Layanan
	Y.TOT.DATA		= 0
	Y.TOT.SUCCESS	= 0
	Y.TOT.AMOUNT	= 0
	Y.ADD.INFO1		= ""
	Y.ADD.INFO2		= ""
	Y.BODY			= ""
	Y.HEADER		= ""
	Y.FOOTER		= ""
	Y.TEMP			= ""
	
	Y.FILE.REK		= "DATA" : Y.BANK.CODE :"_": Y.SERVICE.CODE :"_": Y.DATE.RECON : ".REK"
	
    RETURN

*-----------------------------------------------------------------------------
END
