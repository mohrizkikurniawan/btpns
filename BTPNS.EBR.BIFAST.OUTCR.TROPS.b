*-----------------------------------------------------------------------------
* <Rating>-100</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.EBR.BIFAST.OUTCR.TROPS(ENQ.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220704
* Description        : BIFAST ENQ selection for all data
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
	$INSERT I_COMMON
    $INSERT I_EQUATE   
	$INSERT I_ENQUIRY.COMMON
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT 
	GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	FN.BTPNS.TH.BIFAST.OUTGOING = "F.BTPNS.TH.BIFAST.OUTGOING"
	F.BTPNS.TH.BIFAST.OUTGOING  = ""
	CALL OPF(FN.BTPNS.TH.BIFAST.OUTGOING, F.BTPNS.TH.BIFAST.OUTGOING)
	
	RETURN
	
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	Y.FIELD.SELECTION = ENQ.DATA<2>
	FIND "CO.CODE" IN Y.FIELD.SELECTION SETTING Y.POSF,Y.POSV THEN
        Y.CO.CODE = ENQ.DATA<4, Y.POSV>
    END
	
	IF Y.CO.CODE EQ 'ID0010001' OR Y.CO.CODE EQ '' THEN
		SEL.CMD  = "SELECT ":FN.BTPNS.TH.BIFAST.OUTGOING
		SEL.LIST = ""
		CALL EB.READLIST(SEL.CMD,SEL.LIST,'','','')
		CONVERT FM TO " " IN SEL.LIST
		
		ENQ.DATA<2,Y.POSV> = "@ID"
        ENQ.DATA<3,Y.POSV> = "EQ"
        ENQ.DATA<4,Y.POSV> = SEL.LIST
	END
	
	RETURN
*-----------------------------------------------------------------------------
END