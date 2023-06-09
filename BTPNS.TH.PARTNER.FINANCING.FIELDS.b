   SUBROUTINE BTPNS.TH.PARTNER.FINANCING.FIELDS
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221021
* Description        : Table to list partner in financing
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
	$INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_DataTypes
*-----------------------------------------------------------------------------
	
	ID.CHECKFILE = "" 	; ID.CONCATFILE = ""
    ID.F = '@ID' 		; ID.N ='20' 			; ID.T = "A"
	
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition("DESCRIPTION", 		    "75",	 "A", "")
    CALL Table.addFieldDefinition("PRODUCT.CODE", 			"30",	 "A", "")
    CALL Field.setCheckFile("AA.PRODUCT")
	
*-----------------------------------------------------------------------------
    CALL Table.addField("RESERVED.10", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.9", T24_String, Field_NoInput, "")
	CALL Table.addField("RESERVED.8", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.7", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.6", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.5", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.4", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.3", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.2", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.1", T24_String, Field_NoInput, "")

*-----------------------------------------------------------------------------
    CALL Table.addField("XX.LOCAL.REF", T24_String, "","")
    CALL Table.addField("XX.OVERRIDE", 	T24_String, Field_NoInput, 	"")
    CALL Table.setAuditPosition         ;* Poputale audit information

	RETURN
*-----------------------------------------------------------------------------
END

