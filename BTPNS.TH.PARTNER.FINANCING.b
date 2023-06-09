*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.TH.PARTNER.FINANCING
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221021
* Description        : Table to list partner in financing
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
*-----------------------------------------------------------------------------
    Table.name              = "BTPNS.TH.PARTNER.FINANCING"             ;* Full application name including product prefix
    Table.title             = "List Partner Financing"	               ;* Screen title
    Table.stereotype        = "H"                         	 		   ;* H, U, L, W or T
    Table.product           = "EB"                        	           ;* Must be on EB.PRODUCT
    Table.subProduct        = ""                              		   ;* Must be on EB.SUB.PRODUCT
    Table.classification    = "FIN"                     	  		   ;* As per FILE.CONTROL
    Table.systemClearFile   = "N"                         	  		   ;* As per FILE.CONTROL
    Table.relatedFiles      = ""                          	  		   ;* As per FILE.CONTROL
    Table.isPostClosingFile = ""                              		   ;* As per FILE.CONTROL
    Table.equatePrefix      = "PTN.FIN"                                ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix          = ""                                       ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions  = ""                                       ;* Space delimeted list of blocked functions
    Table.trigger           = ""                                       ;* Trigger field used for OPERATION style fields

    RETURN
*-----------------------------------------------------------------------------
END
