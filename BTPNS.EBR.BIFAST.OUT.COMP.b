    SUBROUTINE BTPNS.EBR.BIFAST.OUT.COMP(ENQ.DATA)
*------------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20221019
* Description        : 
*-----------------------------------------------------------------------------
* Modification History:
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON

	GOSUB INIT
	GOSUB PROCESS
	
	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	FN.BTPNS.TH.BIFAST.OUTGOING = "F.BTPNS.TH.BIFAST.OUTGOING"
    F.BTPNS.TH.BIFAST.OUTGOING = ""
    CALL OPF(FN.BTPNS.TH.BIFAST.OUTGOING,F.BTPNS.TH.BIFAST.OUTGOING)
	
	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    
    LOCATE "CO.CODE" IN ENQ.DATA<2,1> SETTING Y.POS THEN
        Y.CO.CODE = ENQ.DATA<4, Y.POS>
    END

    BEGIN CASE
    CASE NOT(Y.CO.CODE) AND ID.COMPANY EQ 'ID0010001'
        Y.STR = ""
    CASE Y.CO.CODE AND ID.COMPANY EQ 'ID0010001'
        Y.CO.CODE = Y.CO.CODE
        Y.STR = " WITH (CO.CODE EQ '":Y.CO.CODE:"' OR COMPANY.BOOK EQ '":Y.CO.CODE:"')"
    CASE NOT(Y.CO.CODE) AND ID.COMPANY NE 'ID0010001'
        Y.CO.CODE = ID.COMPANY
        Y.STR = " WITH (CO.CODE EQ '":Y.CO.CODE:"' OR COMPANY.BOOK EQ '":Y.CO.CODE:"')"
    END CASE
    
*    SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.OUTGOING:" WITH (CO.CODE EQ '":Y.CO.CODE:"' OR COMPANY.BOOK EQ '":Y.CO.CODE:"')"

    LOCATE "@ID" IN ENQ.DATA<2,1> SETTING Y.POS2 THEN
        Y.ID = ENQ.DATA<4, Y.POS2>
        Y.VAR.SEARCH = Y.ID
        Y.OPERAND    = ENQ.DATA<3,Y.POS2>

        CONVERT "..." TO "" IN Y.VAR.SEARCH

        GOSUB CONVERT.OPERAND.CMD

        IF Y.STR THEN
            Y.STR := " AND @ID":Y.ORDER.SRCH
        END ELSE
            Y.STR = " WITH @ID":Y.ORDER.SRCH
        END
    END

    SEL.CMD = "SELECT ":FN.BTPNS.TH.BIFAST.OUTGOING : Y.STR
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,CMD.ERR)

	CONVERT FM TO " " IN SEL.LIST

    ENQ.DATA<2, Y.POS> = "@ID"
    ENQ.DATA<3, Y.POS> = "EQ"
    ENQ.DATA<4, Y.POS> = SEL.LIST
	
    RETURN

*-----------------------------------------------------------------------------
CONVERT.OPERAND.CMD:
*-----------------------------------------------------------------------------
    BEGIN CASE
    CASE Y.OPERAND EQ 'EQ'
        Y.ORDER.SRCH   = ' EQ ':Y.VAR.SEARCH
    CASE Y.OPERAND EQ 'CT'
        Y.ORDER.SRCH   = " LIKE '...":Y.VAR.SEARCH:"...'"
    CASE Y.OPERAND EQ 'LK'
        Y.ORDER.SRCH   = " LIKE '...":Y.VAR.SEARCH:"...'"
    END CASE

    RETURN
*-----------------------------------------------------------------------------
END