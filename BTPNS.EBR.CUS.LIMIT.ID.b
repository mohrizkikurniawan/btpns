*-----------------------------------------------------------------------------------
	SUBROUTINE BTPNS.EBR.CUS.LIMIT.ID(ENQ.DATA)
*-----------------------------------------------------------------------------------
* Author	: Kania Lydia
* Usage		: Routine for build selection limit id by CIF
* Date		: 20220524
* Reference	: 
*-----------------------------------------------------------------------------------
* Modification History:
* YYYYMMDD - Name - Reference
*-----------------------------------------------------------------------------------	
	$INSERT I_COMMON
    $INSERT I_EQUATE   
	$INSERT I_ENQUIRY.COMMON
	$INSERT I_F.CUSTOMER
    $INSERT I_F.ACCOUNT
	$INSERT I_F.LIMIT
	$INSERT I_F.MNEMONIC.ACCOUNT
	$INSERT I_F.ALTERNATE.ACCOUNT
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT 

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	FN.CUSTOMER	= 'F.CUSTOMER'
	F.CUSTOMER	= ''
	CALL OPF(FN.CUSTOMER, F.CUSTOMER)

	FN.ACCOUNT  = 'F.ACCOUNT'
	F.ACCOUNT   = ''
	CALL OPF(FN.ACCOUNT, F.ACCOUNT)
	
	FN.LIMIT  = 'F.LIMIT'
	F.LIMIT   = ''
	CALL OPF(FN.LIMIT, F.LIMIT)
	
	FN.ALT.ACCT = 'F.ALTERNATE.ACCOUNT'
    F.ALT.ACCT  = ''
    CALL OPF(FN.ALT.ACCT, F.ALT.ACCT)
	
	FN.MNEMONIC.ACCOUNT  = 'F.MNEMONIC.ACCOUNT'
	F.MNEMONIC.ACCOUNT   = ''
	CALL OPF(FN.MNEMONIC.ACCOUNT, F.MNEMONIC.ACCOUNT)
	
	
	FIND "@ID" IN ENQ.DATA<2> SETTING Y.AF,Y.AV THEN
        Y.REF.ID = ENQ.DATA<4, Y.AV>
    END
	
	CALL F.READ(FN.CUSTOMER, Y.REF.ID, R.CUSTOMER, F.CUSTOMER, Y.ERR.CUSTOMER)
	CALL F.READ(FN.ACCOUNT, Y.REF.ID, R.ACCOUNT, F.ACCOUNT, Y.ERR.ACCOUNT)
	CALL F.READ(FN.ALT.ACCT, Y.REF.ID, R.ALT.ACCT, F.ALT.ACCT, Y.ERR.ALT.ACCT)
	CALL F.READ(FN.MNEMONIC.ACCOUNT, Y.REF.ID, R.MNEMONIC.ACCOUNT, F.MNEMONIC.ACCOUNT, Y.ERR.MNEMONIC.ACCOUNT)
	
	BEGIN CASE
	CASE R.CUSTOMER NE ""
		SEL.CMD		= "SELECT ":FN.LIMIT: " WITH LIABILITY.NUMBER EQ ":Y.REF.ID
		SEL.LIST	= ''
		CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC, ERR.AA)
		IF SEL.LIST THEN
			GOSUB PROCESS
		END
	CASE R.ACCOUNT NE ""
		CALL F.READ(FN.ACCOUNT, Y.REF.ID, R.ACCOUNT, F.ACCOUNT, Y.ERR.ACCOUNT)
		Y.CUS.ID	= R.ACCOUNT<AC.CUSTOMER>
		
		SEL.CMD		= "SELECT ":FN.LIMIT: " WITH LIABILITY.NUMBER EQ ":Y.CUS.ID
		SEL.LIST	= ''								
		CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC, ERR.AA)
		IF SEL.LIST THEN
			GOSUB PROCESS
		END
	CASE R.ALT.ACCT NE ""
		Y.ACCT.ID	= R.ALT.ACCT<1>
		CALL F.READ(FN.ACCOUNT, Y.ACCT.ID, R.ACCOUNT, F.ACCOUNT, Y.ERR.ACCOUNT)
		Y.CUS.ID	= R.ACCOUNT<AC.CUSTOMER>
		SEL.CMD		= "SELECT ":FN.LIMIT: " WITH LIABILITY.NUMBER EQ ":Y.CUS.ID
		SEL.LIST	= ''								
		CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC, ERR.AA)
		IF SEL.LIST THEN
			GOSUB PROCESS
		END
	CASE R.MNEMONIC.ACCOUNT NE ""
		Y.ACCT.ID	= R.MNEMONIC.ACCOUNT<1>
		CALL F.READ(FN.ACCOUNT, Y.ACCT.ID, R.ACCOUNT, F.ACCOUNT, Y.ERR.ACCOUNT)
		Y.CUS.ID	= R.ACCOUNT<AC.CUSTOMER>
		SEL.CMD		= "SELECT ":FN.LIMIT: " WITH LIABILITY.NUMBER EQ ":Y.CUS.ID
		SEL.LIST	= ''								
		CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC, ERR.AA)
		IF SEL.LIST THEN
			GOSUB PROCESS
		END
	CASE 1
		SEL.LIST	= Y.REF.ID 
	END CASE
	
	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	Y.LIMIT.ID = SEL.LIST
	CONVERT FM TO " " IN Y.LIMIT.ID
	IF Y.LIMIT.ID THEN
        ENQ.DATA<2,Y.AV> = ""
        ENQ.DATA<3,Y.AV> = ""
        ENQ.DATA<4,Y.AV> = ""

        ENQ.DATA<2,Y.AV> = "@ID"
        ENQ.DATA<3,Y.AV> = "EQ"
        ENQ.DATA<4,Y.AV> = Y.LIMIT.ID
    END
		
	RETURN
*-----------------------------------------------------------------------------
END
 