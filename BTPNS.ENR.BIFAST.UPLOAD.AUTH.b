*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.ENR.BIFAST.UPLOAD.AUTH(Y.OUTPUT)
*-----------------------------------------------------------------------------
* Developer Name : 20220815
* Description    : Nofile routine for authorize ft auth from bfast upload
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Developer Name     :
* Development Date   :  
* Description        : 
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
	$INSERT I_F.BTPNS.TL.BIFAST.UPLOAD.NAU
	$INSERT I_F.FUNDS.TRANSFER
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB INIT
    GOSUB PUT.DATA

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	FN.BTPNS.TL.BIFAST.UPLOAD.NAU	= 'F.BTPNS.TL.BIFAST.UPLOAD.NAU'
	F.BTPNS.TL.BIFAST.UPLOAD.NAU	= ''
	CALL OPF(FN.BTPNS.TL.BIFAST.UPLOAD.NAU, F.BTPNS.TL.BIFAST.UPLOAD.NAU)
	
    FN.FUNDS.TRANSFER.NAU = "F.FUNDS.TRANSFER$NAU"
    F.FUNDS.TRANSFER.NAU  = ""
    CALL OPF(FN.FUNDS.TRANSFER.NAU, F.FUNDS.TRANSFER.NAU)
	
    Y.APP 		= "FUNDS.TRANSFER"
    Y.FIELDS  	= "B.CDTR.AGTID" : @VM : "B.CDTR.ACCID" : @VM: "B.CDTR.NM" : @VM : "B.DBTR.NM" : @VM : "B.CHNTYPE" : @VM : "B.TXNTYPE"
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FIELDS,Y.POS)

	Y.B.CDTR.AGTID.POS		= Y.POS<1,1>
	Y.B.CDTR.ACCID.POS		= Y.POS<1,2>
	Y.B.CDTR.NM.POS			= Y.POS<1,3>
	Y.B.DBTR.NM.POS			= Y.POS<1,4>
	Y.B.CHNTYPE.POS			= Y.POS<1,5>
	Y.B.TXNTYPE.POS			= Y.POS<1,6>

    Y.INPUT = ENQ.SELECTION<2>
	
	*SEL.1 ------------------------------------------------------
    FIND "UPLOAD.ID" IN Y.INPUT SETTING Y.POSF, Y.POSV, Y.POSS THEN
		Y.OPR.UPLOAD.ID = ENQ.SELECTION<3,Y.POSV>
        Y.SEL.UPLOAD.ID = ENQ.SELECTION<4,Y.POSV>
	END
	
	RETURN	
	
*-----------------------------------------------------------------------------
PUT.DATA:
*-----------------------------------------------------------------------------
 
    SEL.CMD = "SELECT ":FN.BTPNS.TL.BIFAST.UPLOAD.NAU:" WITH @ID LIKE ..." : Y.SEL.UPLOAD.ID : "..."
	
    SEL.LIST =''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.REC,ERR.MM)
	
	
    FOR I = 1 TO NO.REC
        Y.UPLOAD.ID		= FIELD(SEL.LIST<I>, ".", 1)
		Y.FT.ID			= FIELD(SEL.LIST<I>, ".", 2)
		
		CALL F.READ(FN.FUNDS.TRANSFER.NAU, Y.FT.ID, R.FUNDS.TRANSFER.NAU, F.FUNDS.TRANSFER.NAU, FT.ERR)
		IF R.FUNDS.TRANSFER.NAU NE '' THEN
			Y.PROCESSING.DATE	= R.FUNDS.TRANSFER.NAU<FundsTransfer_ProcessingDate>
			Y.B.CDTR.AGTID		= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.B.CDTR.AGTID.POS>
			Y.B.CDTR.ACCID		= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.B.CDTR.ACCID.POS>
			Y.B.CDTR.NM			= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.B.CDTR.NM.POS>
			Y.DEBIT.AMOUNT		= R.FUNDS.TRANSFER.NAU<FundsTransfer_DebitAmount>
			Y.DEBIT.ACCT.NO		= R.FUNDS.TRANSFER.NAU<FundsTransfer_DebitAcctNo>
			Y.B.DBTR.NM			= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.B.DBTR.NM.POS>
			Y.B.CHNTYPE			= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.B.CHNTYPE.POS>
			Y.B.TXNTYPE			= R.FUNDS.TRANSFER.NAU<FundsTransfer_LocalRef, Y.B.TXNTYPE.POS>
		
			Y.OUT.TEMP	= Y.PROCESSING.DATE
			Y.OUT.TEMP := "|" : Y.UPLOAD.ID			
			Y.OUT.TEMP := "|" : Y.FT.ID	
			Y.OUT.TEMP := "|" : Y.B.CDTR.AGTID
			Y.OUT.TEMP := "|" : Y.B.CDTR.AGTID
			Y.OUT.TEMP := "|" : Y.B.CDTR.ACCID
			Y.OUT.TEMP := "|" : Y.B.CDTR.NM
			Y.OUT.TEMP := "|" : Y.DEBIT.AMOUNT
			Y.OUT.TEMP := "|" : Y.DEBIT.ACCT.NO
			Y.OUT.TEMP := "|" : Y.B.DBTR.NM
			Y.OUT.TEMP := "|" : Y.B.CHNTYPE
			Y.OUT.TEMP := "|" : Y.B.TXNTYPE
		

			Y.OUTPUT<-1> = Y.OUT.TEMP
		END
    NEXT I	
	
    RETURN
*-----------------------------------------------------------------------------
END