*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.AA.VAL.FIN.SCHEDULE.TYPE
*-----------------------------------------------------------------------------
**-----              G E N E R A L   I N F O R M A T I O N             -----**
*-----------------------------------------------------------------------------
* Company Name        : BTPNS
* Developer Name      : Alamsyah Rizki Isroi
* Reference Number    : JIRA-XXX
* Subroutine Type     : T24 Subroutine
* Attached to         : Activity API
*                       Activity Class = LENDING-NEW-ARRANGEMENT
*                       Property = SCHEDULE
*                       Action = UPDATE
*                       Validation Routine = BTPNS.AA.VAL.FIN.SCHEDULE.TYPE
* Used in             : Not Applicable
* Incoming Parameters : -
* Outgoing Parameters : -
*-----------------------------------------------------------------------------
**-----          S U B R O U T I N E   D E S C R I P T I O N           -----**
*-----------------------------------------------------------------------------
* 1. read L.SCH.TYPE then determine the Schedule Format
*-----------------------------------------------------------------------------
**-----             M O D I F I C A T I O N   H I S T O R Y            -----**
*-----------------------------------------------------------------------------
* 20220310 - BTPNS - Alamsyah Rizki Isroi
*            Initial Version
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
	$INSERT I_GTS.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.PAYMENT.SCHEDULE
	
	GOSUB INITIALISE
    GOSUB GET.ACTIVITY.DETAILS	
    GOSUB PRE.ACTION.PROCESS
	
    RETURN
*-----------------------------------------------------------------------------
INITIALISE:
***********
	
	arrApp<1> = "AA.PRD.DES.PAYMENT.SCHEDULE"
	arrFld<1,1> = "L.SCH.TYPE"
	arrPos	  = ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	fSchTypePos = arrPos<1,1>	
    
    RETURN
*-----------------------------------------------------------------------------
GET.ACTIVITY.DETAILS:
*********************

    AAA.STATUS = c_aalocActivityStatus
    vDateEffectiveORI = c_aalocActivityEffDate
    rvAaArrRec = c_aalocArrangementRec
    AA.CUST.NO = rvAaArrRec<AA.ARR.CUSTOMER>
	ARR.PDT.ID = c_aalocArrProductId
	ARR.ID.REF = c_aalocArrId
	rvAaArrActivity = c_aalocArrActivityRec
	
    RETURN
*-----------------------------------------------------------------------------
PRE.ACTION.PROCESS:
*******************
    BEGIN CASE
        CASE AAA.STATUS[1,6] = 'UNAUTH'
            GOSUB PROCESS.INPUT.ACTION      ;* Update processing...
        CASE AAA.STATUS = 'DELETE'
            GOSUB PROCESS.DELETE.ACTION     ;* Deletion processing...
        CASE AAA.STATUS = 'AUTH'
            GOSUB PROCESS.AUTHORISE.ACTION  ;* Authorisation processing...
        CASE AAA.STATUS = 'REVERSE'
            GOSUB PROCESS.REVERSE.ACTION    ;* Reversal processing...
        CASE OTHERWISE  ;* For other cases...
    END CASE

    RETURN
*-----------------------------------------------------------------------------
PROCESS.INPUT.ACTION:
*********************

	IF fSchTypePos AND R.NEW(AaSimPaymentSchedule_LocalRef)<1,fSchTypePos> EQ "" THEN RETURN

	vSchType = R.NEW(AaSimPaymentSchedule_LocalRef)<1,fSchTypePos>
	
	BEGIN CASE
	CASE vSchType EQ "ANNUITY"
		GOSUB BuildScheduleAnnuity
	CASE vSchType EQ "FLAT"
		TEXT = "Please Set Manual Schedule for ":vSchType
		CALL REM
	CASE vSchType EQ "IRREGULAR"
		TEXT = "Please Set Manual Schedule for ":vSchType
		CALL REM
	CASE vSchType EQ "BULLET"
		GOSUB BuildScheduleBullet
	END CASE
	
    RETURN
*-------------------------------------------------------------------------------
PROCESS.DELETE.ACTION:
**********************
* Reserved for future developments

    RETURN
*-----------------------------------------------------------------------------
PROCESS.AUTHORISE.ACTION:
*************************
* Reserved for future developments

    RETURN
*-----------------------------------------------------------------------------
PROCESS.REVERSE.ACTION:
***********************
* Reserved for future developments

    RETURN
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
BuildScheduleAnnuity:
***********************
* Build Annuity SCHEDULE

	IF R.NEW(AaSimPaymentSchedule_PaymentType)<1,3> NE "" THEN
		R.NEW(AaSimPaymentSchedule_PaymentType) 	= ""
		R.NEW(AaSimPaymentSchedule_PaymentMethod) 	= ""
		R.NEW(AaSimPaymentSchedule_PaymentFreq) 	= ""
		R.NEW(AaSimPaymentSchedule_Property) 		= ""
		R.NEW(AaSimPaymentSchedule_DueFreq) 		= ""
		R.NEW(AaSimPaymentSchedule_StartDate) 		= ""
		R.NEW(AaSimPaymentSchedule_BillType) 		= ""
	END
** DISBURSEMENT Amount
	R.NEW(AaSimPaymentSchedule_PaymentType)<1,1> = "DISBURSEMENT.%"
	R.NEW(AaSimPaymentSchedule_PaymentMethod)<1,1> = "PAY"
	R.NEW(AaSimPaymentSchedule_Property)<1,1,1> = "ACCOUNT"
	R.NEW(AaSimPaymentSchedule_Percentage)<1,1,1> = "100"
	R.NEW(AaSimPaymentSchedule_StartDate)<1,1,1> = "R_START"
	R.NEW(AaSimPaymentSchedule_BillType)<1,1,1> = "DISBURSEMENT"
** PRINCIPAL + INTEREST Amount
	R.NEW(AaSimPaymentSchedule_PaymentType)<1,2> = "CONSTANT"
	R.NEW(AaSimPaymentSchedule_PaymentMethod)<1,2> = "DUE"
	IF R.NEW(AaSimPaymentSchedule_PaymentFreq)<1,2> EQ "" THEN R.NEW(AaSimPaymentSchedule_PaymentFreq)<1,2> = "e0Y e1M e0W e0D e0F"
	R.NEW(AaSimPaymentSchedule_Property)<1,2,1> = "ACCOUNT"
	R.NEW(AaSimPaymentSchedule_Property)<1,2,2> = "PRINCIPALPFT"
	IF R.NEW(AaSimPaymentSchedule_DueFreq)<1,2,1> EQ "" THEN R.NEW(AaSimPaymentSchedule_DueFreq)<1,2,1> = "e0Y e1M e0W e0D e0F"
	IF R.NEW(AaSimPaymentSchedule_DueFreq)<1,2,2> EQ "" THEN R.NEW(AaSimPaymentSchedule_DueFreq)<1,2,2> = "e0Y e1M e0W e0D e0F"
	R.NEW(AaSimPaymentSchedule_StartDate)<1,2> = ""
	R.NEW(AaSimPaymentSchedule_BillType)<1,2> = "INSTALLMENT"


    RETURN
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
BuildScheduleBullet:
***********************
* Build Bullet SCHEDULE

	IF R.NEW(AaSimPaymentSchedule_PaymentType)<1,3> NE "INTEREST" THEN
		R.NEW(AaSimPaymentSchedule_PaymentType) 	= ""
		R.NEW(AaSimPaymentSchedule_PaymentMethod) 	= ""
		R.NEW(AaSimPaymentSchedule_PaymentFreq) 	= ""
		R.NEW(AaSimPaymentSchedule_Property)		= ""
		R.NEW(AaSimPaymentSchedule_DueFreq) 		= ""
		R.NEW(AaSimPaymentSchedule_BillType) 		= ""
		R.NEW(AaSimPaymentSchedule_PaymentFreq)<1,2> = "e0Y e1M e0W e0D e0F"
		R.NEW(AaSimPaymentSchedule_DueFreq)<1,2> = "e0Y e1M e0W e0D e0F"
		R.NEW(AaSimPaymentSchedule_PaymentFreq)<1,3> = "e0Y e1M e0W e0D e0F"
		R.NEW(AaSimPaymentSchedule_DueFreq)<1,3> = "e0Y e1M e0W e0D e0F"
		R.NEW(AaSimPaymentSchedule_StartDate)<1,3,1> = "R_MATURITY"
	END
** DISBURSEMENT Amount
	R.NEW(AaSimPaymentSchedule_PaymentType)<1,1> = "DISBURSEMENT.%"
	R.NEW(AaSimPaymentSchedule_PaymentMethod)<1,1> = "PAY"
	R.NEW(AaSimPaymentSchedule_Property)<1,1,1> = "ACCOUNT"
	R.NEW(AaSimPaymentSchedule_Percentage)<1,1,1> = "100"
	R.NEW(AaSimPaymentSchedule_StartDate)<1,1,1> = "R_START"
	R.NEW(AaSimPaymentSchedule_BillType)<1,1,1> = "DISBURSEMENT"
** PRINCIPAL Amount
	R.NEW(AaSimPaymentSchedule_PaymentType)<1,2> = "LINEAR"
	R.NEW(AaSimPaymentSchedule_PaymentMethod)<1,2> = "DUE"
	IF R.NEW(AaSimPaymentSchedule_PaymentFreq)<1,2> EQ "" THEN R.NEW(AaSimPaymentSchedule_PaymentFreq)<1,2> = "e0Y e1M e0W e0D e0F"
	R.NEW(AaSimPaymentSchedule_Property)<1,2,1> = "ACCOUNT"
	IF R.NEW(AaSimPaymentSchedule_DueFreq)<1,2> EQ "" THEN R.NEW(AaSimPaymentSchedule_DueFreq)<1,2> = "e0Y e1M e0W e0D e0F"
	R.NEW(AaSimPaymentSchedule_StartDate)<1,2,1> = "R_MATURITY"
	R.NEW(AaSimPaymentSchedule_BillType)<1,2,1> = "INSTALLMENT"
** INTEREST Amount
	R.NEW(AaSimPaymentSchedule_PaymentType)<1,3> = "INTEREST"
	R.NEW(AaSimPaymentSchedule_PaymentMethod)<1,3> = "DUE"
	IF R.NEW(AaSimPaymentSchedule_PaymentFreq)<1,3> EQ "" THEN R.NEW(AaSimPaymentSchedule_PaymentFreq)<1,3> = "e0Y e1M e0W e0D e0F"
	R.NEW(AaSimPaymentSchedule_Property)<1,3,1> = "PRINCIPALPFT"
	IF R.NEW(AaSimPaymentSchedule_DueFreq)<1,3> EQ "" THEN R.NEW(AaSimPaymentSchedule_DueFreq)<1,3> = "e0Y e1M e0W e0D e0F"
*	R.NEW(AaSimPaymentSchedule_StartDate)<1,3,1> = ""
	R.NEW(AaSimPaymentSchedule_BillType)<1,3,1> = "INSTALLMENT"

    RETURN
*-----------------------------------------------------------------------------
END
