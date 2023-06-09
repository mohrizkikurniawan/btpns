*-----------------------------------------------------------------------------
* <Rating>-100</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.VIN.BIFAST.PROXY.ID.REGIS
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami Dan BSA
* Development Date   : 20220731
* Description        : BIFAST Proxy ID Validations For Register
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.BTPNS.TH.BIFAST.PROXY.MGMT
	
	GOSUB INIT
	GOSUB PROCESS

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
 	FN.PROXY.MGMT = 'F.BTPNS.TH.BIFAST.PROXY.MGMT'
	F.PROXY.MGMT = ''
	CALL OPF(FN.PROXY.MGMT,F.PROXY.MGMT)

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
    Y.PROXY.TYPE = R.NEW(BF.PM.PROXY.TYPE)
    Y.PROXY.ID   = R.NEW(BF.PM.PROXY.ID)
    BEGIN CASE

    CASE Y.PROXY.TYPE EQ "1" AND Y.PROXY.ID          ;*Mobile Phone Number
        IF NOT(ISDIGIT(Y.PROXY.ID)) THEN
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
        END
        Y.PROXY.ID = TRIM(Y.PROXY.ID)
		IF Y.PROXY.ID[1,2] <> '62' THEN
		   AF = BF.PM.PROXY.ID
		   AV = Y.PROXY.ID
		   ETEXT = "Mobile No Harus di awali dengan kode 62"
		   CALL STORE.END.ERROR
		END
		
    CASE Y.PROXY.TYPE EQ "2" AND Y.PROXY.ID          ;*Email Address
        Y.EMAIL.ADDR = Y.PROXY.ID

        Y.EMAIL1 = FIELD(Y.EMAIL.ADDR,"@",1)          ;* get the part before @
        Y.EMAIL2 = FIELD(Y.EMAIL.ADDR,"@",2)          ;* get the part after @
        Y.INDEX1 = INDEX(Y.EMAIL.ADDR,"@",1)          ;* get the position of the first occurence of @
        Y.INDEX2 = INDEX(Y.EMAIL.ADDR,"@",2)          ;* get the position of the second occurence of @
        Y.DOTINDEX1= INDEX(Y.EMAIL1,".",1)  ;* position of dot in the first part
        Y.DOTINDEX2= INDEX(Y.EMAIL2,".",1)  ;* position of dot in the second part

        * '@' Validations
        * There should be atleast one occurence of '@' character and it should not be the first character in the
        * email address and not more than one '@' character in the email address.
        IF NOT(Y.INDEX1) OR Y.INDEX1 = 1 OR Y.INDEX2  THEN
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
			RETURN
        END


        * '.' Validations
        *  In either part of the email address separated by '@' ,the '.' can neither be the first
        *  character nor the last character.There should  not be consecutive occurence of '.' in the email address.
        *  Atleast there should be a single dot in the second part of email address.

        IF Y.DOTINDEX1=1 OR Y.DOTINDEX1=LEN(Y.EMAIL1) THEN        ;* dot present in the first character or last character of the first part of email address
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
			RETURN
        END

        IF NOT(Y.DOTINDEX2) OR Y.DOTINDEX2=1 OR Y.DOTINDEX2=LEN(Y.EMAIL2) THEN          ;* dot present in the first character or last character of the second part of email address
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
			RETURN
        END

        IF INDEX(Y.EMAIL.ADDR,'..',1) OR INDEX(Y.EMAIL.ADDR,' ',1) THEN   ;*two dots consecutively present or space present in the email address
			AF = BF.PM.PROXY.ID
			AV = Y.PROXY.ID
			ETEXT = "EB-INVALID.FORMAT"
			CALL STORE.END.ERROR
			RETURN
        END
    END CASE
	
	RETURN
*-----------------------------------------------------------------------------
END
