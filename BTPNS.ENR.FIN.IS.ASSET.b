*-----------------------------------------------------------------------------------
	SUBROUTINE BTPNS.ENR.FIN.IS.ASSET(Y.OUTPUTLIST)
*-----------------------------------------------------------------------------------
* Author	: Kania Lydia
* Usage		: Enquiry Is Asset
* Date		: 20220512
* Reference	: 
*-----------------------------------------------------------------------------------
* Modification History:
* YYYYMMDD - Name - Reference
*-----------------------------------------------------------------------------------	
	$INSERT I_COMMON
    $INSERT I_EQUATE   
	$INSERT I_ENQUIRY.COMMON
	$INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.CUSTOMER
	$INSERT I_F.MNEMONIC.ACCOUNT
	$INSERT I_F.ALTERNATE.ACCOUNT
	$INSERT I_F.ACCOUNT
	$INSERT I_F.IS.VEHICLE
	$INSERT I_F.IS.EQUIPMENT
	$INSERT I_F.IS.MISCASSET
	$INSERT I_F.IS.REALESTATE
	$INSERT I_F.IS.MOVEQUIPMENT

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB SELECTION

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	FN.CUSTOMER	= 'F.CUSTOMER'
	F.CUSTOMER	= ''
	CALL OPF(FN.CUSTOMER, F.CUSTOMER)
	
	FN.CUSTOMER.ACCOUNT = "F.CUSTOMER.ACCOUNT"
    F.CUSTOMER.ACCOUNT  = ""
    CALL OPF(FN.CUSTOMER.ACCOUNT, F.CUSTOMER.ACCOUNT)
	
	FN.ACCOUNT  = 'F.ACCOUNT'
	F.ACCOUNT   = ''
	CALL OPF(FN.ACCOUNT, F.ACCOUNT)
	
	FN.MNEMONIC.ACCOUNT  = 'F.MNEMONIC.ACCOUNT'
	F.MNEMONIC.ACCOUNT   = ''
	CALL OPF(FN.MNEMONIC.ACCOUNT, F.MNEMONIC.ACCOUNT)
	
	FN.ALT.ACCT = 'F.ALTERNATE.ACCOUNT'
    F.ALT.ACCT  = ''
    CALL OPF(FN.ALT.ACCT, F.ALT.ACCT)
	
	FN.IS.VEHICLE	= 'F.IS.VEHICLE'
	F.IS.VEHICLE	= ''
	CALL OPF(FN.IS.VEHICLE, F.IS.VEHICLE)
	
	FN.IS.EQUIPMENT	= 'F.IS.EQUIPMENT'
	F.IS.EQUIPMENT	= ''
	CALL OPF(FN.IS.EQUIPMENT, F.IS.EQUIPMENT)
	
	FN.IS.MISCASSET	= 'F.IS.MISCASSET'
	F.IS.MISCASSET	= ''
	CALL OPF(FN.IS.MISCASSET, F.IS.MISCASSET)
	
	FN.IS.REALESTATE	= 'F.IS.REALESTATE'
	F.IS.REALESTATE	= ''
	CALL OPF(FN.IS.REALESTATE, F.IS.REALESTATE)
	
	FN.IS.MOVEQUIPMENT	= 'F.IS.MOVEQUIPMENT'
	F.IS.MOVEQUIPMENT	= ''
	CALL OPF(FN.IS.MOVEQUIPMENT, F.IS.MOVEQUIPMENT)
	
	RETURN
*-----------------------------------------------------------------------------
SELECTION:
*-----------------------------------------------------------------------------

    Y.FIELD = ENQ.SELECTION<2,0>
    FIND "Y.CIF.ID" IN Y.FIELD SETTING POS.FM, POS1 THEN
        Y.FIELD1		= ENQ.SELECTION<2,POS1>
        Y.OPERATION1	= ENQ.SELECTION<3,POS1>
        Y.CIF.ID		= ENQ.SELECTION<4,POS1>
    END
	
	FIND "Y.REFERENCE" IN Y.FIELD SETTING POS.FM, POS1 THEN
        Y.FIELD2		= ENQ.SELECTION<2,POS1>
        Y.OPERATION3	= ENQ.SELECTION<3,POS1>
        Y.REF.ID		= ENQ.SELECTION<4,POS1>
    END
	
	BEGIN CASE
	CASE Y.CIF.ID NE "" AND Y.REF.ID NE ""
		ENQ.ERROR = "Hanya boleh mengisi salah satu dari referensi"
        RETURN
	CASE Y.CIF.ID EQ "" AND Y.REF.ID EQ ""
		ENQ.ERROR = "Referensi tidak boleh kosong"
        RETURN
	CASE Y.CIF.ID NE ""
		CALL F.READ(FN.CUSTOMER, Y.CIF.ID, R.CUSTOMER, F.CUSTOMER, Y.ERR.CUSTOMER)
		Y.CUS.ID	= Y.CIF.ID
		IF R.CUSTOMER NE "" THEN
			GOSUB PROCESS.REC
		END
	CASE Y.REF.ID NE ""
		CALL F.READ(FN.ACCOUNT, Y.REF.ID, R.ACCT, F.ACCOUNT, Y.ERR.ACCOUNT)
		CALL F.READ(FN.ALT.ACCT, Y.REF.ID, R.ALT.ACCT, F.ALT.ACCT, Y.ERR.ALT.ACCT)
		CALL F.READ(FN.MNEMONIC.ACCOUNT, Y.REF.ID, R.MNEMONIC.ACCOUNT, F.MNEMONIC.ACCOUNT, Y.ERR.MNEMONIC.ACCOUNT)
		
		BEGIN CASE
		CASE R.ACCT NE ""
			Y.ACCT.ID	= Y.REF.ID
			GOSUB PROCESS.CUS
		CASE R.ALT.ACCT NE ""
			Y.ACCT.ID	= R.ALT.ACCT<1>
			GOSUB PROCESS.CUS
		CASE R.MNEMONIC.ACCOUNT NE ""
			Y.ACCT.ID	= R.MNEMONIC.ACCOUNT<1>
			GOSUB PROCESS.CUS
		END CASE 
		
		
	END CASE
	
	RETURN
*-----------------------------------------------------------------------------	
PROCESS.CUS:
*-----------------------------------------------------------------------------
	CALL F.READ(FN.ACCOUNT, Y.ACCT.ID, R.ACCOUNT, F.ACCOUNT, Y.ERR.ACCOUNT)
	Y.CUS.ID	= R.ACCOUNT<AC.CUSTOMER>
	
	CALL F.READ(FN.CUSTOMER, Y.CUS.ID, R.CUSTOMER, F.CUSTOMER, Y.ERR.CUSTOMER)
	IF R.CUSTOMER NE "" THEN
		GOSUB PROCESS.REC
	END
	
	RETURN
*-----------------------------------------------------------------------------	
PROCESS.REC:
*-----------------------------------------------------------------------------
	SEL.CMD.1	= ""
	SEL.CMD.1	= "SELECT ":FN.IS.VEHICLE: " WITH CUSTOMER EQ ":Y.CUS.ID
	SEL.LIST.1	= ''								
	CALL EB.READLIST(SEL.CMD.1, SEL.LIST.1, '', NO.REC.1, ERR.AA.1)
	IF SEL.LIST.1 NE "" THEN
		FOR X = 1 TO NO.REC.1
			Y.VEHICLE.ID	= SEL.LIST.1<X>
			GOSUB VEHICLE
			GOSUB WRITE.DATA
		NEXT X
	END
	
	SEL.CMD.2	= ""
	SEL.CMD.2	= "SELECT ":FN.IS.EQUIPMENT: " WITH CUSTOMER EQ ":Y.CUS.ID
	SEL.LIST.2	= ''								
	CALL EB.READLIST(SEL.CMD.2, SEL.LIST.2, '', NO.REC.2, ERR.AA.2)
	IF SEL.LIST.2 NE "" THEN
		FOR X = 1 TO NO.REC.2
			Y.EQUIPMENT.ID	= SEL.LIST.2
			GOSUB EQUIPMENT
			GOSUB WRITE.DATA
		NEXT X
	END
	
	SEL.CMD.3	= ""
	SEL.CMD.3	= "SELECT ":FN.IS.MISCASSET: " WITH CUSTOMER EQ ":Y.CUS.ID
	SEL.LIST.3	= ''								
	CALL EB.READLIST(SEL.CMD.3, SEL.LIST.3, '', NO.REC.3, ERR.AA.3)
	IF SEL.LIST.3 NE "" THEN
		FOR X = 1 TO NO.REC.3
			Y.MISCASSET.ID 	= SEL.LIST.3<X>
			GOSUB MISCASSET
			GOSUB WRITE.DATA
		NEXT X
	END
	
	SEL.CMD.4	= ""
	SEL.CMD.4	= "SELECT ":FN.IS.REALESTATE: " WITH CUSTOMER EQ ":Y.CUS.ID
	SEL.LIST.4	= ''								
	CALL EB.READLIST(SEL.CMD.4, SEL.LIST.4, '', NO.REC.4, ERR.AA.4)
	IF SEL.LIST.4 NE "" THEN
		FOR X = 1 TO NO.REC.4
			Y.REALESTATE.ID = SEL.LIST.4<X>
			GOSUB REALESTATE
			GOSUB WRITE.DATA
		NEXT X
	END
	
	SEL.CMD.5	= ""
	SEL.CMD.5	= "SELECT ":FN.IS.MOVEQUIPMENT: " WITH CUSTOMER EQ ":Y.CUS.ID
	SEL.LIST.5	= ''								
	CALL EB.READLIST(SEL.CMD.5, SEL.LIST.5, '', NO.REC.5, ERR.AA.5)
	IF SEL.LIST.5 NE "" THEN
		FOR X = 1 TO NO.REC.5
			Y.MOVEQUIPMENT.ID	= SEL.LIST.5<X>
			GOSUB MOVEQUIPMENT
			GOSUB WRITE.DATA
		NEXT X
	END
	
	RETURN
*-----------------------------------------------------------------------------
VEHICLE:
*-----------------------------------------------------------------------------
	CALL F.READ(FN.IS.VEHICLE,Y.VEHICLE.ID,R.IS.VEHICLE,F.IS.VEHICLE,ERR.IS.VEHICLE)
	Y.ASSET.ID				= Y.VEHICLE.ID
	Y.ASSET.SHORT.TITTLE	= R.IS.VEHICLE<IS.VEH.ASSET.SHORT.TITLE>
	Y.CUSTOMER				= R.IS.VEHICLE<IS.VEH.CUSTOMER>
	Y.CURRENCY				= R.IS.VEHICLE<IS.VEH.CURRENCY>
	Y.UNIT.PRICE			= R.IS.VEHICLE<IS.VEH.UNIT.PRICE>
	Y.ASSET.DESC			= R.IS.VEHICLE<IS.VEH.ASSET.DESC>
	
	RETURN
*-----------------------------------------------------------------------------
EQUIPMENT:
*-----------------------------------------------------------------------------
	CALL F.READ(FN.IS.EQUIPMENT,Y.EQUIPMENT.ID,R.IS.EQUIPMENT,F.IS.EQUIPMENT,ERR.IS.EQUIPMENT)
	Y.ASSET.ID				= Y.EQUIPMENT.ID
	Y.ASSET.SHORT.TITTLE	= R.IS.EQUIPMENT<IS.EQU.ASSET.SHORT.TITLE>
	Y.CUSTOMER				= R.IS.EQUIPMENT<IS.EQU.CUSTOMER>
	Y.CURRENCY				= R.IS.EQUIPMENT<IS.EQU.CURRENCY>
	Y.UNIT.PRICE			= R.IS.EQUIPMENT<IS.EQU.UNIT.PRICE>
	Y.ASSET.DESC			= R.IS.EQUIPMENT<IS.EQU.ASSET.DESC>
	
	RETURN
*-----------------------------------------------------------------------------
MISCASSET:
*-----------------------------------------------------------------------------
	CALL F.READ(FN.IS.MISCASSET,Y.MISCASSET.ID,R.IS.MISCASSET,F.IS.MISCASSET,ERR.IS.MISCASSET)
	Y.ASSET.ID				= Y.MISCASSET.ID
	Y.ASSET.SHORT.TITTLE	= R.IS.MISCASSET<IS.MIS12.ASSET.SHORT.TITLE>
	Y.CUSTOMER				= R.IS.MISCASSET<IS.MIS12.CUSTOMER>
	Y.CURRENCY				= R.IS.MISCASSET<IS.MIS12.CURRENCY>
	Y.UNIT.PRICE			= R.IS.MISCASSET<IS.MIS12.UNIT.PRICE>
	Y.ASSET.DESC			= R.IS.MISCASSET<IS.MIS12.ASSET.DESC>
	
	RETURN
*-----------------------------------------------------------------------------
REALESTATE:
*-----------------------------------------------------------------------------
	CALL F.READ(FN.IS.REALESTATE,Y.REALESTATE.ID,R.IS.REALESTATE,F.IS.REALESTATE,ERR.IS.REALESTATE)
	Y.ASSET.ID				= Y.REALESTATE.ID
	Y.ASSET.SHORT.TITTLE	= R.IS.REALESTATE<IS.REAL.ASSET.SHORT.TITLE>
	Y.CUSTOMER				= R.IS.REALESTATE<IS.REAL.CUSTOMER>
	Y.CURRENCY				= R.IS.REALESTATE<IS.REAL.CURRENCY>
	Y.UNIT.PRICE			= R.IS.REALESTATE<IS.REAL.UNIT.PRICE>
	Y.ASSET.DESC			= R.IS.REALESTATE<IS.REAL.ASSET.DESC>
	
	RETURN
*-----------------------------------------------------------------------------
MOVEQUIPMENT:
*-----------------------------------------------------------------------------
	CALL F.READ(FN.IS.MOVEQUIPMENT,Y.MOVEQUIPMENT.ID,R.IS.MOVEQUIPMENT,F.IS.MOVEQUIPMENT,ERR.IS.MOVEQUIPMENT)
	Y.ASSET.ID				= Y.MOVEQUIPMENT.ID
	Y.ASSET.SHORT.TITTLE	= R.IS.MOVEQUIPMENT<IS.MVE.ASSET.SHORT.TITLE>
	Y.CUSTOMER				= R.IS.MOVEQUIPMENT<IS.MVE.CUSTOMER>
	Y.CURRENCY				= R.IS.MOVEQUIPMENT<IS.MVE.CURRENCY>
	Y.UNIT.PRICE			= R.IS.MOVEQUIPMENT<IS.MVE.UNIT.PRICE>
	Y.ASSET.DESC			= R.IS.MOVEQUIPMENT<IS.MVE.ASSET.DESC>
	
	RETURN
*-----------------------------------------------------------------------------
WRITE.DATA:
*-----------------------------------------------------------------------------
	Y.OUTPUT =  Y.ASSET.ID					; *1 ID Asset
    Y.OUTPUT := "|" : Y.ASSET.SHORT.TITTLE	; *2 Jenis Asset 
    Y.OUTPUT := "|" : Y.CUSTOMER			; *3 CIF
    Y.OUTPUT := "|" : Y.CURRENCY			; *4 Currency
    Y.OUTPUT := "|" : Y.UNIT.PRICE			; *5 Nilai asset
    Y.OUTPUT := "|" : Y.ASSET.DESC			; *6 Description
	
	Y.OUTPUTLIST<-1> = Y.OUTPUT
	
	Y.ASSET.ID				= ""
	Y.ASSET.SHORT.TITTLE	= ""
	Y.CUSTOMER				= ""
	Y.CURRENCY				= ""
	Y.UNIT.PRICE			= ""
	Y.ASSET.DESC			= ""
	
	RETURN
*-----------------------------------------------------------------------------
END
	