    SUBROUTINE BTPNS.MT.RECON.BIFAST(Y.ID)
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
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	Y.CONTROL	= CONTROL.LIST<1,1>
	Y.DATA.TYPE	= "CBS"
	Y.TEMP		= ""
	Y.ADD.INFO1	= ""
	Y.ADD.INFO2	= ""
	Y.BODY		= ""
	R.FILE.PART	= ""
	Y.SUCCESS	= 0

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	BEGIN CASE
	CASE Y.CONTROL EQ "BODY.IN"
		GOSUB GET.BODY.IN
	CASE Y.CONTROL EQ "BODY.OUT"
		GOSUB GET.BODY.OUT
	END CASE
	
    RETURN
*-----------------------------------------------------------------------------
GET.BODY.IN:
*-----------------------------------------------------------------------------
	
	CALL F.READ(FN.BTPNS.TH.BIFAST.INCOMING, Y.ID, R.BTPNS.TH.BIFAST.INCOMING, F.BTPNS.TH.BIFAST.INCOMING, Y.ERR.BTPNS.TH.BIFAST.INCOMING)
	Y.DATE.TIME			= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.DATE.TIME>
	Y.TRX.TIME			= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.TRX.TIME>
	Y.RRN				= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.RRN>
	Y.AMOUNT			= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.TRX.AMOUNT>
	Y.RESPONSE.CODE		= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.RESPONSE.CODE>
	Y.ACQUIRER.ID		= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.ACQUIRER.ID>
	Y.MSG.STAN			= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.MSG.STAN>
	Y.PCM				= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.POS.CONDITION.MODE>
	Y.MERCHANT.TYPE		= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.MERCHANT.TYPE>
	Y.ISSUER.ID			= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.ISSUER.ID>
	Y.FROM.ACCOUNT		= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.FROM.ACCOUNT>
	Y.BENEFICIARY.ID	= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.BENEFICIARY.ID>
	Y.TO.ACCOUNT		= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.TO.ACCOUNT>
	Y.TRX.INDICATOR		= R.BTPNS.TH.BIFAST.INCOMING<BIFAST.IN.TRX.INDICATOR>
	
	Y.TRX.DATE			 = "20" : Y.DATE.TIME[1,6]
	IF Y.RESPONSE.CODE EQ "00" THEN
		Y.SUCCESS		 = 1
	END
	
	IF Y.TRX.INDICATOR EQ "2" THEN
		Y.TRX.TYPE		= "1"
	END ELSE
		Y.TRX.TYPE		= "2"
	END
	
	Y.TEMP		 = "REK010"				: "|"
	Y.TEMP		:= Y.DATE.RECON			: "|"
	Y.TEMP		:= Y.BANK.CODE			: "|"
	Y.TEMP		:= Y.TRX.DATE			: "|"
	Y.TEMP		:= Y.TRX.TIME			: "|"
	Y.TEMP		:= Y.RRN				: "|"
	Y.TEMP		:= Y.AMOUNT				: "|"
	Y.TEMP		:= Y.RESPONSE.CODE		: "|"
	Y.TEMP		:= Y.DATA.TYPE			: "|"
	Y.TEMP		:= Y.TRX.TYPE			: "|"
	Y.TEMP		:= Y.ACQUIRER.ID		: "|"
	Y.TEMP		:= Y.MSG.STAN			: "|"
	Y.TEMP		:= Y.PCM				: "|"
	Y.TEMP		:= Y.MERCHANT.TYPE		: "|"
	Y.TEMP		:= Y.ISSUER.ID			: "|"
	Y.TEMP		:= Y.FROM.ACCOUNT		: "|"
	Y.TEMP		:= Y.BENEFICIARY.ID		: "|"
	Y.TEMP		:= Y.TO.ACCOUNT			: "|"
	Y.TEMP		:= Y.ADD.INFO1			: "|"
	Y.TEMP		:= Y.ADD.INFO2
	
	Y.BODY<-1>	 = Y.TEMP
	
	GOSUB WRITE.BODY
	
    RETURN
*-----------------------------------------------------------------------------
GET.BODY.OUT:
*-----------------------------------------------------------------------------
	
	CALL F.READ(FN.BTPNS.TH.BIFAST.OUTGOING, Y.ID, R.BTPNS.TH.BIFAST.OUTGOING, F.BTPNS.TH.BIFAST.OUTGOING, Y.ERR.BTPNS.TH.BIFAST.OUTGOING)
	Y.DATE.TIME		= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.DATE.TIME>
	Y.RRN			= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.RETRIEVAL.REF.NO>
	Y.AMOUNT		= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.AMOUNT>
	Y.SETTLEMENT	= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.SETTLEMENT.STATUS>
	Y.RESPONSE.CODE	= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.RESPONSE.CODE>
	Y.CHNTYPE		= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.CHNTYPE>
	Y.DBTR.ACCID	= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.DBTR.ACCID>
	Y.CDTR.AGTID	= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.CDTR.AGTID>
	Y.CDTR.ACCID	= R.BTPNS.TH.BIFAST.OUTGOING<BF.TOC.CDTR.ACCID>
	
	Y.AMOUNT		= FMT(Y.AMOUNT,"R2")
	Y.TRX.DATE		= "20" : Y.DATE.TIME[1,6]
	
	IF Y.SETTLEMENT EQ "PROCESSED" AND Y.RESPONSE.CODE EQ "" THEN
		Y.RESPONSE.CODE  = "00"
		Y.SUCCESS		 = 1
	END
	
	IF Y.DBTR.ACCID[1,3] EQ "IDR" THEN
		CHANGE "IDR" TO "" IN Y.DBTR.ACCID
	END
	
	CALL F.READ(FN.IDCH.RTGS.BANK.CODE.G2, Y.CDTR.AGTID, R.IDCH.RTGS.BANK.CODE.G2, F.IDCH.RTGS.BANK.CODE.G2, Y.ERR.IDCH.RTGS.BANK.CODE.G2)
	Y.BNK.TYPE			= R.IDCH.RTGS.BANK.CODE.G2<RTGS.BANK.CODE.LOCAL.REF, Y.B.BANK.TYPE.POS>
	Y.SKN.CLR.CODE		= R.IDCH.RTGS.BANK.CODE.G2<RTGS.BANK.CODE.LOCAL.REF, Y.SKN.CLR.CODE.POS>
	Y.ID.BNK  			= Y.SKN.CLR.CODE[1,3]
		
	Y.BENEF.ID			= '9':Y.BNK.TYPE:Y.ID.BNK
	
	CALL F.READ(FN.FUNDS.TRANSFER, Y.ID, R.FUNDS.TRANSFER, F.FUNDS.TRANSFER, Y.ERR.FUNDS.TRANSFER)
	Y.IN.STAN			= R.FUNDS.TRANSFER<FT.LOCAL.REF, Y.IN.STAN.POS>
	Y.B.CDTR.PRXYTYPE	= R.FUNDS.TRANSFER<FT.LOCAL.REF, Y.B.CDTR.PRXYTYPE.POS>
	
	IF Y.B.CDTR.PRXYTYPE EQ "0" THEN
		Y.TRX.TYPE	= "1"
	END ELSE
		Y.TRX.TYPE	= "2"
	END
	
	Y.TEMP		 = "REK010"				: "|"
	Y.TEMP		:= Y.DATE.RECON			: "|"
	Y.TEMP		:= Y.BANK.CODE			: "|"
	Y.TEMP		:= Y.TRX.DATE			: "|"
	Y.TEMP		:= Y.RRN[5,6]			: "|"		;*trxTime
	Y.TEMP		:= Y.RRN				: "|"
	Y.TEMP		:= Y.AMOUNT				: "|"
	Y.TEMP		:= Y.RESPONSE.CODE		: "|"
	Y.TEMP		:= Y.DATA.TYPE			: "|"
	Y.TEMP		:= Y.TRX.TYPE			: "|"
	Y.TEMP		:= "92547"				: "|"		;*acquirerID
	Y.TEMP		:= Y.IN.STAN			: "|"		;*msgSTAN
	Y.TEMP		:= "55"					: "|"		;*posConditionMode
	Y.TEMP		:= Y.CHNTYPE			: "|"		;*merchantTyoe
	Y.TEMP		:= "92547"				: "|"		;*issuerID
	Y.TEMP		:= Y.DBTR.ACCID			: "|"		;*fromAccount
	Y.TEMP		:= Y.BENEF.ID			: "|"
	Y.TEMP		:= Y.CDTR.ACCID			: "|"		;*toAccount
	Y.TEMP		:= Y.ADD.INFO1			: "|"
	Y.TEMP		:= Y.ADD.INFO2
	
	Y.BODY<-1>	 = Y.TEMP
	
	GOSUB WRITE.BODY
	
    RETURN
*-----------------------------------------------------------------------------
WRITE.BODY:
*-----------------------------------------------------------------------------
	
	Y.AGENT.PART = "PART-" : AGENT.NUMBER
	CALL F.READ(FN.FOLDER, Y.AGENT.PART, R.FILE.PART, F.FOLDER, Y.ERR.AGENT.PART)
	
	R.FILE.PART<-1>	= Y.BODY
	WRITE R.FILE.PART TO F.FOLDER, Y.AGENT.PART
	
	
	Y.AGENT.SUM 	= "SUM-" : AGENT.NUMBER
	CALL F.READ(FN.FOLDER, Y.AGENT.SUM, R.FILE.SUM, F.FOLDER, Y.ERR.AGENT.SUM)
	
	IF R.FILE.SUM EQ "" THEN
		R.FILE.SUM<1>		= Y.SUCCESS : "|" : Y.SUCCESS : "|" : Y.AMOUNT
		WRITE R.FILE.SUM TO F.FOLDER, Y.AGENT.SUM
	END ELSE
		Y.PART.DATA			= FIELD(R.FILE.SUM<1>, "|", 1) + Y.SUCCESS
		Y.PART.SUCCESS		= FIELD(R.FILE.SUM<1>, "|", 2) + Y.SUCCESS
		Y.PART.AMOUNT		= FIELD(R.FILE.SUM<1>, "|", 3) + Y.AMOUNT
		R.FILE.SUM<1>		= Y.PART.DATA : "|" :Y.PART.SUCCESS : "|" : Y.PART.AMOUNT
		WRITE R.FILE.SUM TO F.FOLDER, Y.AGENT.SUM
	END
		
	RETURN
	
*-----------------------------------------------------------------------------
END
