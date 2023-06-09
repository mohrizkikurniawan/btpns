   SUBROUTINE BTPNS.TL.BFAST.INTERFACE.PARAM.FIELDS
*-----------------------------------------------------------------------------
* Developer Name     : BTPNS-BSA
* Development Date   : 20220604
* Description        : FIELDS for BTPNS.TL.BFAST.INTERFACE.PARA
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date           	: 20220924
* Modified by    	: Moh Rizki Kurniawan
* Description		: Add MAX.RETRY to Use Check Status in AJ
*-----------------------------------------------------------------------------
	$INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_DataTypes
*-----------------------------------------------------------------------------
	
	ID.CHECKFILE = "" 	; ID.CONCATFILE = ""
    ID.F = 'ID' 		; ID.N ='20' 			; ID.T = "A"
	
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition("XX.LL.DESCRIPTION","35", "A","")
	CALL Table.addFieldDefinition("BI.NOSTRO","25", "A", "")
    CALL Field.setCheckFile("ACCOUNT")
	CALL Table.addFieldDefinition("IA.CATEG.OUT","10", "A", "")
    CALL Field.setCheckFile("CATEGORY")
	CALL Table.addFieldDefinition("IA.CATEG.IN","10", "A", "")
    CALL Field.setCheckFile("CATEGORY")
	CALL Table.addFieldDefinition("XX.ID.SAV.ALLOWED","10", "A", "")
	CALL Field.setCheckFile("IDIH.FUND.PRODUCT.PAR")
	CALL Table.addFieldDefinition("MAX.TXN.AMT","17", "AMT", "")
    CALL Table.addFieldDefinition("MIN.TXN.AMT","17", "AMT", "")
	CALL Table.addFieldDefinition("CHARGE.ID","20", "A", "")
    CALL Field.setCheckFile("FT.COMMISSION.TYPE")
	CALL Table.addFieldDefinition("XX.ID.SAV.RESTRICT","6", "A", "")
	CALL Field.setCheckFile("CATEGORY")
	CALL Table.addFieldDefinition("ID.TC","16", "A", "")
	CALL Field.setCheckFile("IDIH.IN.FT.JOURNAL.PAR")
	CALL Table.addFieldDefinition("XX.EXC.POST.RESTRICT","4", "AMT", "")
	CALL Field.setCheckFile("POSTING.RESTRICT")
	CALL Table.addFieldDefinition("FTTC.OUTGOING","5", "A", "")
	CALL Field.setCheckFile("FT.TXN.TYPE.CONDITION")
	CALL Table.addFieldDefinition("FTTC.INCOMING","5", "A", "")
	CALL Field.setCheckFile("FT.TXN.TYPE.CONDITION")

	CALL Table.addFieldDefinition("XX<COMM.DESC","20", FM:"NASABAH_KARYAWAN_FEE AJ_FEE BI", "")
	CALL Table.addFieldDefinition("XX-COMM.TYPE","20", "A", "")
	CALL Field.setCheckFile("FT.COMMISSION.TYPE")
	CALL Table.addField("XX-RESERVED.12", T24_String, Field_NoInput, "")
	CALL Table.addFieldDefinition("XX>COMM.AMT","18", "AMT", "")
	
    CALL Table.addFieldDefinition("PL.WAIVE.FEE","10", "A", "")
    CALL Field.setCheckFile("CATEGORY")
	
	CALL Table.addFieldDefinition("XX.RESTRICT.CATEG.IN","6", "A", "")
    CALL Field.setCheckFile("CATEGORY")

	CALL Table.addFieldDefinition("MAX.RETRY","5", "A", "")

	
*-----------------------------------------------------------------------------
*    CALL Table.addField("RESERVED.9", T24_String, Field_NoInput, "")
	CALL Table.addField("RESERVED.8", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.7", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.6", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.5", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.4", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.3", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.2", T24_String, Field_NoInput, "")
    CALL Table.addField("RESERVED.1", T24_String, Field_NoInput, "")

*-----------------------------------------------------------------------------
    CALL Table.addField("XX.LOCAL.REF", T24_String, "", 			"")
    CALL Table.addField("XX.OVERRIDE", 	T24_String, Field_NoInput, 	"")
    CALL Table.setAuditPosition         ;* Poputale audit information

	RETURN
*-----------------------------------------------------------------------------
END

