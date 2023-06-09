*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.TL.DEPO.KLIRING
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 05 September 2022
* Description        : table bridge for kliring deposito
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
*-----------------------------------------------------------------------------
    Table.name              = "BTPNS.TL.DEPO.KLIRING"     ;* Full application name including product prefix
    Table.title             = "Depo Kliring"        ;* Screen title
    Table.stereotype        = "L"       		;* H, U, L, W or T
    Table.product           = "ST"      		;* Must be on EB.PRODUCT
    Table.subProduct        = ""        		;* Must be on EB.SUB.PRODUCT
    Table.classification    = "INT"     		;* As per FILE.CONTROL
    Table.systemClearFile   = "N"       		;* As per FILE.CONTROL
    Table.relatedFiles      = ""        		;* As per FILE.CONTROL
    Table.isPostClosingFile = ""        		;* As per FILE.CONTROL
    Table.equatePrefix      = "DEPO.KLIRING" 	;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix          = ""        ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions  = ""        ;* Space delimeted list of blocked functions
    Table.trigger           = ""        ;* Trigger field used for OPERATION style fields

    RETURN
*-----------------------------------------------------------------------------
END
