*-----------------------------------------------------------------------------
	SUBROUTINE BTPNS.TH.BIFAST.STO.DEPO.FIELDS
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220621
* Description        : Table to store BIFAST Incoming Transaction
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* 20220621		Alamsyah Rizki Isroi		Initial
*-----------------------------------------------------------------------------
	$INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_DataTypes

	** To make this table can be input on COB (Non Stop Operation)
	C$NS.OPERATION = "ALL"

	ID.CHECKFILE = "" ; ID.CONCATFILE=""
	ID.F= '@ID' ; ID.N='65'; ID.T="ANY"

    fieldName = 'ARRANGEMENT' ; fieldType = '' ; fieldLength = '35' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	CALL Field.setCheckFile("AA.ARRANGEMENT")
	
    fieldName = 'DATE' ; fieldType = 'D' ; fieldLength = '11' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
    fieldName = 'XX<DIST.ENTRY' ; fieldType = 'A' ; fieldLength = '35' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	CALL Field.setCheckFile("STMT.ENTRY")
	
    fieldName = 'XX-DIST.REFERENCE' ; fieldType = 'A' ; fieldLength = '35' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
    fieldName = 'XX-DIST.PMA' ; fieldType = 'A' ; fieldLength = '35' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	CALL Field.setCheckFile("IDIH.PMS.ACTION")
	
    fieldName = 'XX-DIST.AMOUNT' ; fieldType = 'AMT' ; fieldLength = '35' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
    fieldName = 'XX-DIST.ACCOUNT' ; fieldType = 'POSANT' ; fieldLength = '35' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
    fieldName = 'XX-AMOUNT.TYPE' ; fieldType = '' ; fieldLength = '25' ; neighbour = ''
	fieldType<2> = '_PRINCIPAL_PROFIT_PRINCIPAL.PROFIT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    CALL Table.addField("XX-RESERVED.24",  T24_String, Field_NoInput,"")
    CALL Table.addField("XX-RESERVED.23",  T24_String, Field_NoInput,"")
    CALL Table.addField("XX-RESERVED.22",  T24_String, Field_NoInput,"")
    CALL Table.addField("XX>RESERVED.21",  T24_String, Field_NoInput,"")
	
    fieldName = 'FT.REFERENCE' ; fieldType = 'A' ; fieldLength = '35' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
    fieldName = 'STATUS' ; fieldType = '' ; fieldLength = '25' ; neighbour = ''
	fieldType<2> = '_ERROR_DELETED_PROCESS_PROCESSED'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	CALL Table.addFieldDefinition("XX.ERROR.MESSAGE", 		"99", "ANY", "") ;* Add a new field
    CALL Table.addFieldDefinition("COM.CODE", 		"35", "ANY", "") ;* Add a new field
    CALL Table.addFieldDefinition("CHARGES.AMT", 		"35", "ANY", "") ;* Add a new field
    CALL Table.addFieldDefinition("XX.CHARGES.TYPE", 		"35", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("CUS.CR.NAME", 		"30", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("CUS.REFERENCE", 		"16", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("TAG.TM", 			"35", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("TAG.TC", 			"35", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("TAG.PI", 			"35", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("TAG.DI", 			"35", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("TAG.CI", 			"35", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("TAG.RN", 			"35", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("TAG.IF", 			"99", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("EXPIRATION.DATE", 	"99", "ANY", "") ;* Add a new field
*	CALL Table.addFieldDefinition("TRACK.2.DATA", 		"99", "ANY", "") ;* Add a new field

*-----------------------------------------------------------------------------
* reserved fields
* ----------------------------------------------------------------------------
*    CALL Table.addField("RESERVED.20",  T24_String, Field_NoInput,"")
*    CALL Table.addField("RESERVED.19",  T24_String, Field_NoInput,"")
*    CALL Table.addField("RESERVED.18",  T24_String, Field_NoInput,"")
*    CALL Table.addField("RESERVED.17",  T24_String, Field_NoInput,"")
*    CALL Table.addField("RESERVED.16",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.15",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.14",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.13",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.12",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.11",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.10",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.9",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.8",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.7",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.6",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.5",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.4",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.3",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.2",  T24_String, Field_NoInput,"")
    CALL Table.addField("RESERVED.1",  T24_String, Field_NoInput,"")
*-----------------------------------------------------------------------------
	CALL Table.addLocalReferenceField("")
*-----------------------------------------------------------------------------
	CALL Table.addOverrideField
    CALL Table.setAuditPosition         ;* Poputale audit information
*-----------------------------------------------------------------------------
    RETURN
*-----------------------------------------------------------------------------
END 
