    SUBROUTINE BTPNS.EBR.RESTRICT.CATEG(ENQ.DATA)
*------------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 28 February 2023
* Description        : Routine to restriction categ in inquiry account register 
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
	$INSERT I_F.EB.LOOKUP
	$INSERT I_F.ACCOUNT

	GOSUB INIT
	GOSUB PROCESS
	
	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    FN.EB.LOOKUP = "F.EB.LOOKUP"
	F.EB.LOOKUP  = ""
	CALL OPF(FN.EB.LOOKUP,F.EB.LOOKUP)
	
	FN.ACCOUNT = "F.ACCOUNT"
	F.ACCOUNT  = ""
	CALL OPF(FN.ACCOUNT,F.ACCOUNT)
	
*Parameter to White list Categ for inq acct register
	Y.ID.EBLOOKUP = "PARAM*WHITELIST.CATEG"
	CALL F.READ(FN.EB.LOOKUP,Y.ID.EBLOOKUP,R.EB.LOOKUP,F.EB.LOOKUP,ERR.EB.LOOKUP)
	Y.CATEGWHITELIST = R.EB.LOOKUP<EB.LU.DATA.NAME>
	
	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	FINDSTR "@ID" IN ENQ.DATA<2, 1> SETTING YFM,YVM,YSM THEN
		Y.ID.ACCOUNT = ENQ.DATA<4, YVM>
		CALL F.READ(FN.ACCOUNT,Y.ID.ACCOUNT,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
		Y.CATEGORY = R.ACCOUNT<AC.CATEGORY>
		FINDSTR Y.CATEGORY IN Y.CATEGWHITELIST SETTING YFM,YVM,YSM ELSE 
			ENQ.ERROR = "EB-ACCT.NOT.FOUND"
		END
	END
	
    RETURN
*-----------------------------------------------------------------------------
END
