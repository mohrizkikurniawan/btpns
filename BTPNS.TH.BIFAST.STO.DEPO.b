*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.TH.BIFAST.STO.DEPO
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220621
* Description        : Table to store BIFAST Standing Order DEPOSITS
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* 20220621		Alamsyah Rizki Isroi		Initial
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
*-----------------------------------------------------------------------------
    Table.name              = "BTPNS.TH.BIFAST.STO.DEPO"          ;* Full application name including product prefix
    Table.title             = "BIFAST STO DEPOSITS"	   ;* Screen title
    Table.stereotype        = "H"                         	 		   ;* H, U, L, W or T
    Table.product           = "EB"                        	           ;* Must be on EB.PRODUCT
    Table.subProduct        = ""                              		   ;* Must be on EB.SUB.PRODUCT
    Table.classification    = "FIN"                     	  		   ;* As per FILE.CONTROL
    Table.systemClearFile   = "N"                         	  		   ;* As per FILE.CONTROL
    Table.relatedFiles      = ""                          	  		   ;* As per FILE.CONTROL
    Table.isPostClosingFile = ""                              		   ;* As per FILE.CONTROL
    Table.equatePrefix      = "BIFAST.STO"                              ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix          = ""                                       ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions  = ""                                       ;* Space delimeted list of blocked functions
    Table.trigger           = ""                                       ;* Trigger field used for OPERATION style fields

    RETURN
*-----------------------------------------------------------------------------
END
