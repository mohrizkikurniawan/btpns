* ----------------------------------------------------------------------------
    SUBROUTINE BTPNS.ENR.LIMIT.LIABILITY(rvEnqData)
* ----------------------------------------------------------------------------
* Author        : Alamsyah Rizki Isroi
* Description   : NoFile routine to build customer limit/facility report
* Date          : 20230216
* Reference     : CBA-178 [Financing_Ops]Menu Enquery Limit Fasilitas Pembiayaan
* ----------------------------------------------------------------------------
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
    
    GOSUB Initialise
    GOSUB Process

    RETURN

* open table and find enquiry filters
Initialise:

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

*
** get detail field value
*
    rvEnqData = ''
    vCustomer = "" ; vCoCode = ""
    vStartDate = '' ; vExpiryDate = ''
    vInternalAmount = "" ; vAvailableMarker = ""
    vStartDateEnd = "" ; vExpiryDateEnd = "" ; vLimitType = ""

    LOCATE "CUSTOMER" IN D.FIELDS<1> SETTING sPos THEN vCustomer = D.RANGE.AND.VALUE<sPos>
    LOCATE "CO.CODE" IN D.FIELDS<1> SETTING sPos THEN vCoCode = D.RANGE.AND.VALUE<sPos>
    LOCATE "START.DATE" IN D.FIELDS<1> SETTING sPos THEN vStartDate = D.RANGE.AND.VALUE<sPos>
    LOCATE "EXPIRY.DATE" IN D.FIELDS<1> SETTING sPos THEN vExpiryDate = D.RANGE.AND.VALUE<sPos>
    LOCATE "INTERNAL.AMOUNT" IN D.FIELDS<1> SETTING sPos THEN vInternalAmount = D.RANGE.AND.VALUE<sPos>
    LOCATE "AVAILABLE.MARKER" IN D.FIELDS<1> SETTING sPos THEN vAvailableMarker = D.RANGE.AND.VALUE<sPos>
    LOCATE "LIMIT.TYPE" IN D.FIELDS<1> SETTING sPos THEN vLimitType = D.RANGE.AND.VALUE<sPos>
    LOCATE "MAINTAIN.DATE" IN D.FIELDS<1> SETTING sPos THEN vMaintainDate = D.RANGE.AND.VALUE<sPos>
    LOCATE "ARRANGEMENT" IN D.FIELDS<1> SETTING sPos THEN vArrangement = D.RANGE.AND.VALUE<sPos>

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

    RETURN

* perform query select and build list
Process:

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
        ENQ.ERROR = "EB-NO.RECORD"
        RETURN
    END

    vCounterPrint = "" ; vCounter = 0
    LOOP
        REMOVE idCustomer FROM QryList SETTING qPos
    WHILE idCustomer : qPos

    IF idCustomer EQ '10025873' OR idCustomer EQ '10025885' OR idCustomer EQ '10037494' OR idCustomer EQ '10079019' THEN
        DEBUG
    END

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

    IF NOT(rvEnqData) THEN ENQ.ERROR = "EB-NO.RECORD"

    RETURN

* Get available amount & outstanding amount
GetAvailableAmount:

    vAvailableAmount = "" ; vOutstandingAmount = ""
    LOCATE idLimit IN vArrLimit<1> SETTING aPos THEN
        vAvailableAmount = vArrAvailableAmount<aPos>
        vOutstandingAmount = vArrOutstandingAmount<aPos>
    END

    RETURN

* Convert limit type (WAKALA ; PARENT ; CHILD)
GetLimitType:

    BEGIN CASE
    CASE vLimitRef EQ "8300"
        vLimitType = "wakala"
    CASE RIGHT(vLimitRef,2) EQ "00"
        vLimitType = "induk"
    CASE RIGHT(vLimitRef,2) NE "00"
        vLimitType = "anak"
    END CASE

    RETURN

* Convert asset class to numeric format
ConvertAssetClass:

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

* get details contract AA Arrangement
GetAaDetailContract:

	idProperty<1> = 'COMMITMENT'
	idProperty<2> = 'PRINCIPALPFT'
	idLinkRef = ""
	CALL AA.PROPERTY.REF(idAaArrangement, idProperty, idLinkRef)

    CALL F.READ(fnAaArrTermAmount, idLinkRef<1>, rvAaArrTermAmount, fvAaArrTermAmount, "")
    CALL F.READ(fnAaArrInterest, idLinkRef<2>, rvAaArrInterest, fvAaArrInterest, "")

    RETURN

* append filtered record to enquiry result
AppendResult:

    vLimitDateTime  = '20' : rvLimit<Limit_DateTime>[1,6]
    vApprovalDate   = rvLimit<Limit_ApprovalDate>

    IF vLimitDateTime EQ vApprovalDate THEN
        vLimitDateTime  = ""
    END

    vLine = ""
    vLine = vCounterPrint
    vLine := "|" : idCustomer
    vLine := "|" : rvCustomer<Customer_CompanyBook>
    vLine := "|" : idLimit
    vLine := "|" : rvLimit<Limit_ApprovalDate>
    vLine := "|" : rvLimit<Limit_OnlineLimitDate>
    vLine := "|" : rvLimit<Limit_ExpiryDate>
    vLine := "|" : rvLimit<Limit_InternalAmount>
    vLine := "|" : rvLimit<Limit_MaximumTotal>
    vLine := "|" : rvLimit<Limit_AvailableMarker> 
    vLine := "|" : vAvailableAmount
    vLine := "|" : idAccount
    vLine := "|" : rvAccount<Account_ArrangementId>
    vLine := "|" : rvAccount<Account_Category>
    vLine := "|" : rvAccount<Account_CoCode>
    vLine := "|" : rvAaArrangement<AaArrangement_ArrStatus>
    vLine := "|" : rvAaArrangement<AaArrangement_ActiveProduct>
    vLine := "|" : rvAaAccountDetails<AaAccountDetails_StartDate>
    vLine := "|" : rvAaAccountDetails<AaAccountDetails_MaturityDate>
    vLine := "|" : rvAaAccountDetails<AaAccountDetails_Suspended>
    vLine := "|" : vAssetClass
    vLine := "|" : rvAaArrTermAmount<AaSimTermAmount_Amount>
    vLine := "|" : rvAaArrTermAmount<AaSimTermAmount_Term>
    vLine := "|" : rvAaArrInterest<AaSimInterest_FixedRate>
    vLine := "|" : rvAaArrInterest<AaSimInterest_InterestMethod>
    vLine := "|" : idCustomerPrint
    vLine := "|" : vLimitType
    vLine := "|" : rvLimit<Limit_RecordParent>
    vLine := "|" : vRevolvingType
    vLine := "|" : vOutstandingAmount
    vLine := "|" : vLimitDateTime

    vCounterPrint = ""
    idCustomer = "" ; rvCustomer = ""
    idLimit = "" ;* rvLimit = ""
    rvAccount = "" ; rvAaArrTermAmount = "" ; rvAaArrInterest = ""
    rvAaAccountDetails = "" ; rvAaArrangement = ""

    rvEnqData<-1> = vLine

    RETURN

END
