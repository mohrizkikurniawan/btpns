*-----------------------------------------------------------------------------
	SUBROUTINE BTPNS.TH.BIFAST.INCOMING.FIELDS
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

    C$NS.OPERATION = "ALL"

	ID.CHECKFILE = "" ; ID.CONCATFILE=""
	ID.F= '@ID' ; ID.N='65'; ID.T="ANY"
	
    fieldName = 'API.TYPE' ; fieldType = '' ; fieldLength = '25' ; neighbour = ''
	fieldType<2> = '_B.INQ.TRF.RQ_B.INQ.TRF.RS_B.TRF.RQ_B.TRF.RS_B.STLM.TRF.RQ_B.STLM.TRF.RS_B.CHECK.STATUS.RQ_B.CHECK.STATUS.RS'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
    fieldName = 'SETTLEMENT.STATUS' ; fieldType = '' ; fieldLength = '25' ; neighbour = ''
	fieldType<2> = '_PROCESSING_PROCESSED_DECLINED_DECLINING'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'RETRY.COUNTER' ; fieldType = '' ; fieldLength = '4' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'MSG.TYPE' ; fieldType = '' ; fieldLength = '4' ; neighbour = ''
	fieldType<2> = '_0200_0201_0202_0210_0212'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TRX.PAN' ; fieldType = 'ANY' ; fieldLength = '19' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TRX.CODE' ; fieldType = 'ANY' ; fieldLength = '6' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TRX.AMOUNT' ; fieldType = 'AMT' ; fieldLength = '25' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TRANS.DATE.TIME' ; fieldType = 'ANY' ; fieldLength = '10' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'MSG.STAN' ; fieldType = 'ANY' ; fieldLength = '6' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TRX.TIME' ; fieldType = 'ANY' ; fieldLength = '6' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TRX.DATE' ; fieldType = 'ANY' ; fieldLength = '4' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'SETTLEMENT.DATE' ; fieldType = 'ANY' ; fieldLength = '4' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'MERCHANT.TYPE' ; fieldType = 'ANY' ; fieldLength = '4' ; neighbour = ''
*	fieldType<2> = '_6845_6846_6847_6849'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	CALL Field.setCheckFile("BTPNS.TL.BFAST.CHANNEL.TYPE")

    fieldName = 'POS.ENTRY.MODE' ; fieldType = 'ANY' ; fieldLength = '3' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'POS.CONDITION.MODE' ; fieldType = 'ANY' ; fieldLength = '3' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'ACQUIRER.ID' ; fieldType = 'ANY' ; fieldLength = '11' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'FORWARDING.ID' ; fieldType = 'ANY' ; fieldLength = '11' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'RRN' ; fieldType = 'ANY' ; fieldLength = '12' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'RESPONSE.CODE' ; fieldType = 'ANY' ; fieldLength = '4' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TERMINAL.ID' ; fieldType = 'ANY' ; fieldLength = '8' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'MERCHANT.ID' ; fieldType = 'ANY' ; fieldLength = '15' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'MERCHANT.NAME.LOC' ; fieldType = 'ANY' ; fieldLength = '40' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'ADD.DATA.PRIVATE' ; fieldType = 'ANY' ; fieldLength = '255' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TRX.CURRENCY.CODE' ; fieldType = 'ANY' ; fieldLength = '3' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'ENCRYPTED.DATA' ; fieldType = 'ANY' ; fieldLength = '16' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'ADD.DATA.NATIONAL' ; fieldType = 'ANY' ; fieldLength = '255' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'ISSUER.ID' ; fieldType = 'ANY' ; fieldLength = '11' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'FROM.ACCOUNT' ; fieldType = 'ANY' ; fieldLength = '34' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TO.ACCOUNT' ; fieldType = 'POSANT' ; fieldLength = '34' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'TRX.INDICATOR' ; fieldType = 'ANY' ; fieldLength = '1' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'BENEFICIARY.ID' ; fieldType = 'ANY' ; fieldLength = '11' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'FT.SETTLEMENT' ; fieldType = 'ANY' ; fieldLength = '25' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
*RESERVED.20
    fieldName = 'ERROR.MESSAGE' ; fieldType = 'ANY' ; fieldLength = '255' ; neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	CALL Table.addFieldDefinition("CUS.DB.NAME", 		"30", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("CUS.CR.NAME", 		"30", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("CUS.REFERENCE", 		"16", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("TAG.TM", 			"35", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("TAG.TC", 			"35", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("TAG.PI", 			"35", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("TAG.DI", 			"35", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("TAG.CI", 			"35", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("TAG.RN", 			"35", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("TAG.IF", 			"99", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("EXPIRATION.DATE", 	"99", "ANY", "") ;* Add a new field
	CALL Table.addFieldDefinition("TRACK.2.DATA", 		"99", "ANY", "") ;* Add a new field

*-----------------------------------------------------------------------------
* reserved fields
* ----------------------------------------------------------------------------
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
