*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.ST.LIMIT.LIABILITY
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20230331
* Description        : Routine to extract enq limit liabilty
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: -
* Modified by    	: -
* Description		: -
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.LIMIT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.COMPANY
    $INSERT I_F.LIMIT.REFERENCE
    $INSERT I_F.CATEGORY
    $INSERT I_F.AA.PRODUCT

*-----------------------------------------------------------------------------
    
	GOSUB Initialise
	GOSUB Process
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

    fnLimitLiability = "F.LIMIT.LIABILITY" ; fvLimitLiability = ""
    CALL OPF(fnLimitLiability, fvLimitLiability)

    fnLimit = "F.LIMIT" ; fvLimit = ""
    CALL OPF(fnLimit, fvLimit)

    fnAccount = "F.ACCOUNT" ; fvAccount = ""
    CALL OPF(fnAccount, fvAccount)

    fnCustomer = "F.CUSTOMER" ; fvCustomer = ""
    CALL OPF(fnCustomer, fvCustomer)

    fnAaArrangement = "F.AA.ARRANGEMENT" ; fvAaArrangement = ""
    CALL OPF(fnAaArrangement, fvAaArrangement)

    fnAaAccountDetails = "F.AA.ACCOUNT.DETAILS" ; fvAaAccountDetails = ""
    CALL OPF(fnAaAccountDetails, fvAaAccountDetails)

    fnAaArrTermAmount = "F.AA.ARR.TERM.AMOUNT" ; fvAaArrTermAmount = ""
    CALL OPF(fnAaArrTermAmount, fvAaArrTermAmount)

    fnAaArrInterest = "F.AA.ARR.INTEREST" ; fvAaArrInterest = ""
    CALL OPF(fnAaArrInterest, fvAaArrInterest)

    fnCompany   = "F.COMPANY"
    fvCompany   = ""
    CALL OPF(fnCompany, fvCompany)

    fnLimitReference    = "F.LIMIT.REFERENCE"
    fvLimitReference    = ""
    CALL OPF(fnLimitReference, fvLimitReference)

    fnCategory  = "F.CATEGORY"
    fvCategory  = ""
    CALL OPF(fnCategory, fvCategory)

    fnAaProduct = "F.AA.PRODUCT"
    fvAaProduct = ""
    CALL OPF(fnAaProduct, fvAaProduct)

    rvEnqData = ''
    vCustomer = "" ; vCoCode = ""
    vStartDate = '' ; vExpiryDate = ''
    vInternalAmount = "" ; vAvailableMarker = ""
    vStartDateEnd = "" ; vExpiryDateEnd = "" ; vLimitType = ""

    batchDetails 	= BATCH.DETAILS<3,1>
    nameDoc         = TODAY : "_" : batchDetails<1,1,1> : ".csv"
    vCustomer       = batchDetails<1,1,2>
    vCoCode         = batchDetails<1,1,3>
    vLimitType      = batchDetails<1,1,4>
    vAvailableMarker= batchDetails<1,1,5>
    vStartDate      = batchDetails<1,1,6>
    vExpiryDate     = batchDetails<1,1,7>
    vMaintainDate   = batchDetails<1,1,8>
    vArrangement    = batchDetails<1,1,9>


    IF vArrangement NE '' THEN
        CALL F.READ(fnAaArrInterest, vArrangement, rvArr, fvAaArrangement, '')
        vCoCode = rvArr<AaArrangement_CoCode>
    END

    IF COUNT(vStartDate, @SM) OR COUNT(vStartDate, @VM) THEN
        vStartDate = CHANGE(CHANGE(CHANGE(vStartDate," ", @FM), @SM, @FM), @VM, @FM)
        vStartDateEnd = vStartDate<2>
        vStartDate = vStartDate<1>
    END

    IF COUNT(vExpiryDate, @SM) OR COUNT(vExpiryDate, @VM) THEN
        vExpiryDate = CHANGE(CHANGE(CHANGE(vExpiryDate," ", @FM), @SM, @FM), @VM, @FM)
        vExpiryDateEnd = vExpiryDate<2>
        vExpiryDate = vExpiryDate<1>
    END

    fnOutput    = "../UD/APPSHARED.BP/ESTATEMENT/LIMIT.LIABILITY"
    fOutput     = ""

    OPEN fnOutput TO fOutput ELSE
        createFolder    = "CREATE.FILE ":fnOutput:" TYPE=UD"
        EXECUTE createFolder
        OPEN fnOutput TO fOutput ELSE
        END
    END

    dataExcelAll       = ''
    dataExcelAll<-1>       = "No,Cif,Nama Nasabah,Cabang CIF,Nama Cabang CIF,Tipe Limit,Deskripsi Limit,Limit Induk,Limit ID,Limit Approval Date,Limit Online Date,Limit Expiry Date,Limit Maintain Date,Limit Internal Amount,Limit Maximum Amount,Available Marker,Limit Available Amount,Account ID,Arrangement ID,Category,Product,Cabang Account,Nama Cabang,Arr Status,AA Product Code,AA Product,AA Start Date,AA Maturity Date,Suspended,Asset Class,Disburse Amount,Tenor,Rate Margin,Jenis Margin"


	RETURN
	
*-----------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------

    QryList = "" ; QryNo = ""
    BEGIN CASE
    CASE vCustomer NE ""
        QryList = vCustomer ; QryNo = 1
    CASE vCoCode NE ""
        QryCmd = "SELECT ":fnCustomer:" WITH COMPANY.BOOK EQ ":vCoCode
        CALL EB.READLIST(QryCmd, QryList, "", QryNo, "")
    CASE OTHERWISE
        QryCmd = "SELECT ":fnLimitLiability
        CALL EB.READLIST(QryCmd, QryList, "", QryNo, "")
    END CASE

    IF NOT(QryList) THEN
        dataExcelAll = "EB-NO.RECORD"
        RETURN
    END

    vCounterPrint = "" ; vCounter = 0
    LOOP
        REMOVE idCustomer FROM QryList SETTING qPos
    WHILE idCustomer : qPos

        rvLimitLiability = "" ; rvLimit = "" ; rvAaAccountDetails = "" ; rvAaArrangement = "" ; rvCustomer = ""
        idLimit = "" ; idAaArrangement = "" ; idAccount = ""
        idCustomerPrint = idCustomer

        CALL F.READ(fnCustomer, idCustomer, rvCustomer, fvCustomer, "")
        CALL F.READ(fnLimitLiability, idCustomer, rvLimitLiability, fvLimitLiability, "")
        IF NOT(rvLimitLiability) THEN CONTINUE
        vCounter += 1
        vCounterPrint = vCounter
        FOR idx=1 TO DCOUNT(rvLimitLiability, @FM)
            idLimit = rvLimitLiability<idx>
            rvLimit = "" ; rvAccount = "" ; 
            CALL F.READ(fnLimit, idLimit, rvLimit, fvLimit, "")
            IF NOT(rvLimit) THEN CONTINUE
            vLimitRef = FIELD(idLimit, ".",2,1) * 1

            IF (RIGHT(vLimitRef,2) NE "00") THEN CONTINUE
            CALL ATI.LI.CMMT.FEE(idLimit, vAvailableAmountParent, vOutstandingAmountParent, vArrLimitChild, vArrAvailableAmountChild, vArrOutstandingAmountChild, vExpiryDateParent)
            vArrLimit = idLimit :@FM: vArrLimitChild
            vArrAvailableAmount = vAvailableAmountParent :@FM: vArrAvailableAmountChild
            vArrOutstandingAmount = vOutstandingAmountParent :@FM: vArrOutstandingAmountChild

            FOR idz=1 TO DCOUNT(vArrLimit, @FM)
                idLimit = vArrLimit<idz>
                CALL F.READ(fnLimit, idLimit, rvLimit, fvLimit, "")
                IF NOT(rvLimit) THEN CONTINUE

* specified filter in Limit record level must be declared here
*           start Date and expiry date are enclose bracket
                IF vStartDate AND vStartDate LT rvLimit<Limit_OnlineLimitDate> THEN CONTINUE
                IF vStartDateEnd AND vStartDateEnd GT rvLimit<Limit_OnlineLimitDate> THEN CONTINUE
                IF vExpiryDate AND vExpiryDate LT rvLimit<Limit_ExpiryDate> THEN CONTINUE
                IF vExpiryDateEnd AND vExpiryDateEnd GT rvLimit<Limit_ExpiryDate> THEN CONTINUE
                IF vInternalAmount AND vInternalAmount GT rvLimit<Limit_InternalAmount> THEN CONTINUE
                IF vAvailableMarker AND vAvailableMarker NE rvLimit<Limit_AvailableMarker> THEN CONTINUE
                IF vLimitType AND vLimitType[1,6] EQ "wakala" AND vLimitRef NE "8300" THEN CONTINUE
                IF vLimitType AND vLimitType EQ "induk" AND ((RIGHT(vLimitRef,2) NE "00") OR vLimitRef EQ "8300") THEN CONTINUE
                IF vLimitType AND vLimitType EQ "anak" AND RIGHT(vLimitRef,2) EQ "00" THEN CONTINUE
                IF NOT(vLimitType) THEN GOSUB GetLimitType
                GOSUB GetAvailableAmount

                IF rvLimit<Limit_ReducingLimit> EQ "Y" THEN
                    vRevolvingType = "NON REVOLVING"
                END ELSE
                    vRevolvingType = "REVOLVING"
                END

                arrAccount = CHANGE(rvLimit<Limit_Account>, @VM, @FM)
                FOR idy=1 TO DCOUNT(arrAccount, @FM)
                    idAccount = arrAccount<idy> ; rvAccount = ""
                    CALL F.READ(fnAccount, idAccount, rvAccount, fvAccount, "")
                    IF NOT(rvAccount) THEN CONTINUE
                    idAaArrangement = rvAccount<Account_ArrangementId>
                    IF vArrangement NE '' THEN
                        IF idAaArrangement NE vArrangement THEN
                            vFlagArrangement    = 'Y'
                        END
                    END
                    IF vFlagArrangement EQ 'Y' THEN CONTINUE
                    CALL F.READ(fnAaArrangement, idAaArrangement, rvAaArrangement, fvAaArrangement, "")
                    CALL F.READ(fnAaAccountDetails, idAaArrangement, rvAaAccountDetails, fvAaAccountDetails, "")
                    CALL BTPNS.GET.ASSET.CLASS(idAaArrangement, vAssetClass)
                    GOSUB ConvertAssetClass
                    GOSUB GetAaDetailContract
                    GOSUB AppendResult
                NEXT idy
                IF NOT(idAccount) THEN GOSUB AppendResult
            NEXT idz
        NEXT idx

    REPEAT

    IF NOT(rvEnqData) THEN 
        dataExcelAll = "EB-NO.RECORD"
    END ELSE
        WRITE dataExcelAll ON fOutput, nameDoc
	    CALL JOURNAL.UPDATE("")
    END

    RETURN
*-----------------------------------------------------------------------------
GetAvailableAmount:
*-----------------------------------------------------------------------------
    
    vAvailableAmount = "" ; vOutstandingAmount = ""
    LOCATE idLimit IN vArrLimit<1> SETTING aPos THEN
        vAvailableAmount = vArrAvailableAmount<aPos>
        vOutstandingAmount = vArrOutstandingAmount<aPos>
    END

    RETURN
*-----------------------------------------------------------------------------
GetLimitType:
*-----------------------------------------------------------------------------

    BEGIN CASE
    CASE vLimitRef EQ "8300"
        vLimitType = "wakala"
    CASE RIGHT(vLimitRef,2) EQ "00"
        vLimitType = "induk"
    CASE RIGHT(vLimitRef,2) NE "00"
        vLimitType = "anak"
    END CASE   

    RETURN
*-----------------------------------------------------------------------------
ConvertAssetClass:
*-----------------------------------------------------------------------------

    BEGIN CASE
    CASE vAssetClass EQ "CUR" OR vAssetClass EQ "DUE"
        vAssetClass = "1"
    CASE vAssetClass EQ "DEL"
        vAssetClass = "2"
    CASE vAssetClass EQ "SS"
        vAssetClass = "3"
    CASE vAssetClass EQ "DBT"
        vAssetClass = "4"
    CASE vAssetClass EQ "LOS"
        vAssetClass = "5"
    CASE OTHERWISE
        vAssetClass = "1"
    END CASE    

    RETURN
*-----------------------------------------------------------------------------
GetAaDetailContract:
*-----------------------------------------------------------------------------

	idProperty<1> = 'COMMITMENT'
	idProperty<2> = 'PRINCIPALPFT'
	idLinkRef = ""
	CALL AA.PROPERTY.REF(idAaArrangement, idProperty, idLinkRef)

    CALL F.READ(fnAaArrTermAmount, idLinkRef<1>, rvAaArrTermAmount, fvAaArrTermAmount, "")
    CALL F.READ(fnAaArrInterest, idLinkRef<2>, rvAaArrInterest, fvAaArrInterest, "")    

    RETURN
*-----------------------------------------------------------------------------
AppendResult:
*-----------------------------------------------------------------------------

    CALL F.READ(fnCompany, rvCustomer<Customer_CompanyBook>, rvComp, fvCompany, '')
    CALL F.READ(fnLimitReference, rvLimit<Limit_LimitProduct>, rvLimitReference, fvLimitReference, '')
    CALL F.READ(fnCategory, rvAccount<Account_Category>, rvCategory, fvCategory, '')
    CALL F.READ(fnCompany, rvAccount<Account_CoCode>, rvCompacco, fvCompany, '')
    CALL F.READ(fnAaProduct, rvAaArrangement<AaArrangement_ActiveProduct>, rvAaProduct, fvAaProduct, '')

    vLimitDateTime  = '20' : rvLimit<Limit_DateTime>[1,6]
    vApprovalDate   = rvLimit<Limit_ApprovalDate>

    IF vLimitDateTime EQ vApprovalDate THEN
        vLimitDateTime  = ""
    END

    dataExcelAll<-1> = vCounterPrint:",":idCustomer:",":rvCustomer<Customer_Name1>:",":rvCustomer<Customer_CompanyBook>:",":rvComp<Company_CompanyName>:",":vRevolvingType:",":rvLimitReference<LimitReference_Description>:",":rvLimit<Limit_RecordParent>:",":idLimit:",":rvLimit<Limit_ApprovalDate>:",":rvLimit<Limit_OnlineLimitDate>:",":rvLimit<Limit_ExpiryDate>:",":vLimitDateTime:",":rvLimit<Limit_InternalAmount>:",":rvLimit<Limit_MaximumTotal>:",":rvLimit<Limit_AvailableMarker>:",":vAvailableAmount:",":idAccount:",":rvAccount<Account_ArrangementId>:",":rvAccount<Account_Category>:",":rvCategory<Category_Description>:",":rvAccount<Account_CoCode>:",":rvCompacco<Company_CompanyName>:",":rvAaArrangement<AaArrangement_ArrStatus>:",":rvAaArrangement<AaArrangement_ActiveProduct>:",":rvAaProduct<AaProduct_Description>:",":rvAaAccountDetails<AaAccountDetails_StartDate>:",":rvAaAccountDetails<AaAccountDetails_MaturityDate>:",":rvAaAccountDetails<AaAccountDetails_Suspended>:",":vAssetClass:",":rvAaArrTermAmount<AaSimTermAmount_Amount>:",":rvAaArrTermAmount<AaSimTermAmount_Term>:",":rvAaArrInterest<AaSimInterest_FixedRate>:",":rvAaArrInterest<AaSimInterest_InterestMethod>

    RETURN
END 
