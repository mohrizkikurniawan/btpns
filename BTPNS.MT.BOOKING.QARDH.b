*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BOOKING.QARDH(idFile)
*-----------------------------------------------------------------------------
* Developer Name     : Kania Lydia
* Development Date   : 20220816
* Description        : Job untuk memproses Data textfile
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.ATI.TH.LIQ.GENERAL.PARAM
	$INSERT I_F.LIMIT
	$INSERT I_F.CUSTOMER
	$INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.ATI.TH.PRODUCT.PARAMETER
	$INSERT I_F.ATI.TH.STAGING.LIQ.AGENT
	$INSERT I_F.LIMIT
	$INSERT I_F.ACCOUNT
	$INSERT I_BTPNS.MT.BOOKING.QARDH.COMMON
*-----------------------------------------------------------------------------

    GOSUB INIT
	
    CALL F.READ(fnProcess, idFile, recFile, fvProcess, errProc)
	
	cntRec	= DCOUNT(recFile, FM)
	FOR X = 1 TO cntRec
		vRecord	= recFile<X>
		GOSUB Process
	NEXT cntRec	
	
	GOSUB WriteTextfile
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	OfsSource				= 'FINANCING.OFS'
	idBooking				= ''
	idCif					= ''
	rAmtLimPar				= ''
	rExpDateLimPar			= ''
	rAmtLimChildPrk			= ''
	rExpDateLimChildPrk		= ''
	rAmtLimChildPayltr		= ''
	rExpDateLimChildPayltr	= ''
	rPkNumber				= ''
	vFlagParent				= ''
	vFlagPaylater			= ''
	vFlagPrk				= ''
	vNoChange				= ''

	RETURN

*-----------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------
	
	idBooking				= FIELD(vRecord,'|',1)
	idCif					= FIELD(vRecord,'|',2)
	rAmtLimPar				= FIELD(vRecord,'|',3)
	rExpDateLimPar			= FIELD(vRecord,'|',4)
	rAmtLimChildPrk			= FIELD(vRecord,'|',5)
	rExpDateLimChildPrk		= FIELD(vRecord,'|',6)
	rAmtLimChildPayltr		= FIELD(vRecord,'|',7)
	rExpDateLimChildPayltr	= FIELD(vRecord,'|',8)
	rPkNumber				= FIELD(vRecord,'|',9)
		
	CALL F.READ(fnAtiThStagingLiqAgent, idBooking, recStagLiq, fvAtiThStagingLiqAgent, errStaging)
	idLimPar	= recStagLiq<SLA.PARENT.ID>	
	amtLimPar	= recStagLiq<SLA.PARENT.AMOUNT>
	idLimPay	= recStagLiq<SLA.CHILD.PAYLATER.ID>
	amtLimPay	= recStagLiq<SLA.CHILD.PAYLATER.AMOUNT>
	idLimPrk	= recStagLiq<SLA.CHILD.PRK.ID>
	amtLimPrk	= recStagLiq<SLA.CHILD.PRK.AMOUNT>
    idCustomer	= recStagLiq<SLA.CUSTOMER.NO>
    recPkNum	= recStagLiq<SLA.PK.NUMBER>
	idArr		= recStagLiq<SLA.RESULT>
	vSlaTerm	= recStagLiq<SLA.TERM>
	vUpdateFlag	= recStagLiq<SLA.LOCAL.REF,vUpdateFlagPos>
	vCoBook		= recStagLiq<SLA.CO.BOOK>
	
	CALL F.READ(fnArrangement,idArr,recArr,fvArrangement,errArr)
	vStartDate	= recArr<AA.ARR.START.DATE>
	
	vTenorFreq	= vSlaTerm[1]
	vTenor		= vSlaTerm[1, (LEN(vSlaTerm)-1)]
	
	CALL EB.NO.OF.MONTHS(vStartDate, rExpDateLimChildPayltr, vTenorUpdate)
    vTenorNew	= vTenorUpdate : vTenorFreq
	
	CALL F.READ(fnLimit, idLimPar, recLiPar, fvLimit, errLimitPar)
	vLiParExpDate	= recLiPar<LI.EXPIRY.DATE>
	vAmtLiPar		= recLiPar<LI.INTERNAL.AMOUNT>
	
	CALL F.READ(fnLimit, idLimPay, recLiPay, fvLimit, errLimitPay)
	vLiPayExpDate	= recLiPay<LI.EXPIRY.DATE>
	vAmtLiPay		= recLiPay<LI.INTERNAL.AMOUNT>
	
	CALL F.READ(fnLimit, idLimPrk, recLiPrk, fvLimit, errLimitPrk)
	vLiPrkExpDate	= recLiPrk<LI.EXPIRY.DATE>
	vAmtLiPrk		= recLiPrk<LI.INTERNAL.AMOUNT>
	
	BEGIN CASE
	CASE recStagLiq EQ ''
		vRespError	= 'MISSING BOOKING - RECORD'
		GOSUB ResponseError
	CASE idCif NE idCustomer
		vRespError 	= 'CIF CANNOT BE DIFFERENT'
		GOSUB ResponseError
	CASE recLiPar EQ ''
		vRespError = 'LIMIT PARENT ID ':recLiPar:' NOT FOUND'
		GOSUB ResponseError
	CASE recLiPrk EQ ''
		vRespError = 'LIMIT CHILD PRK ID ':recLiPrk:' NOT FOUND'
		GOSUB ResponseError
	CASE recLiPay EQ ''
		vRespError = 'LIMIT CHILD PAYLATER ID ':recLiPay:' NOT FOUND'
		GOSUB ResponseError
	CASE rExpDateLimPar LT vLiParExpDate
		vRespError = 'NEW EXPIRY.DATE ON LIMIT PARENT MUST BE GT LAST EXPIRY.DATE [':vLiParExpDate:']'
		GOSUB ResponseError
	CASE rExpDateLimChildPrk LT vLiPrkExpDate
		vRespError = 'NEW EXPIRY.DATE ON LIMIT PRK MUST BE GT LAST EXPIRY.DATE [':vLiPrkExpDate:']'
		GOSUB ResponseError
	CASE rExpDateLimChildPayltr LT vLiPayExpDate
		vRespError = 'NEW EXPIRY.DATE ON LIMIT PAYLATER MUST BE GT LAST EXPIRY.DATE [':vLiPayExpDate:']'
		GOSUB ResponseError
	CASE rExpDateLimChildPrk LT TODAY OR rExpDateLimChildPrk LT vStartDate
		vRespError = 'EXPIRY.DATE CANNOT BE LESS THAN EFFECTIVE.DATE'
		GOSUB ResponseError
	CASE rAmtLimChildPrk LT vAmtLiPrk
		vRespError = 'AMOUNT LIMIT PRK CANNOT BE LESS ACTUAL LIMIT AMOUNT'
		GOSUB ResponseError
	CASE 1
		GOSUB UpdateFlaging
		GOSUB CekUpdate
	END CASE
	
	RETURN
*-----------------------------------------------------------------------------
CekUpdate:
*-----------------------------------------------------------------------------	
	
	FlagProcessPar	= 0
	FlagProcessPay	= 0
	IF vAmtLiPar NE rAmtLimPar OR rExpDateLimPar NE vLiParExpDate THEN
		GOSUB UpdateLiParent
		IF FlagProcessPar EQ '1' THEN
			vFlagParent	= 1
		END
	END
	
	IF vAmtLiPay NE rAmtLimChildPayltr OR rExpDateLimChildPayltr NE vLiPayExpDate THEN
		IF FlagProcessPar EQ '1' OR FlagProcessPar EQ '0' THEN
			GOSUB UpdateLiPaylater
			IF FlagProcessPay EQ '1' THEN
				vFlagPaylater	= 1
			END
		END ELSE
			GOSUB ResponseError
			RETURN
		END
	END
	
	IF amtLimPrk NE rAmtLimChildPrk OR rExpDateLimChildPrk NE vLiPrkExpDate THEN
		IF FlagProcessPay EQ '1' OR FlagProcessPay EQ '0' THEN
			GOSUB UpdateLiPrk
			IF amtLimPrk NE rAmtLimChildPrk AND FlagProcessPrk EQ 1 THEN
				vAmount	= rAmtLimChildPrk - amtLimPrk
				GOSUB UpdatePrkActAmt
				IF FlagProcArrAmt NE '1' THEN
					GOSUB ResponseError
					RETURN
				END
			END
			IF vLiPrkExpDate NE rExpDateLimChildPrk THEN
				GOSUB UpdatePrkActExDate
				IF FlagProcArrDate NE '1' THEN
					GOSUB ResponseError
					RETURN
				END
			END
			IF FlagProcessPrk EQ '1' AND (FlagProcessPrk NE '-1' OR FlagProcessPrk NE '-1') THEN
				vFlagPrk	= 1
			END
		END ELSE
			GOSUB ResponseError
			RETURN
		END
	END
	
	BEGIN CASE
	CASE (vFlagParent EQ 1) OR (vFlagPaylater EQ 1) OR (vFlagPrk EQ 1)
		GOSUB LiveWrite
		GOSUB ResponseSuccess
	CASE (vFlagParent EQ '') AND (vFlagPaylater EQ '') AND (vFlagPrk EQ '') AND FlagProcessPar EQ 0 AND FlagProcessPay EQ 0
		vNoChange	= 1
		GOSUB ResponseSuccess
	CASE 1
		GOSUB ResponseError
	END CASE
		
	RETURN
*-----------------------------------------------------------------------------
UpdateLiParent:
*-----------------------------------------------------------------------------
	AppName			= 'LIMIT'
    OfsFunction		= 'I'
    vProcess		= 'PROCESS'
    OfsVersion		= AppName : ',BTPNS.LI.CHILD.OFS'
    GtsMode			= ''
    NoOfAuth		= ''
    LimitId			= idLimPar
    OfsResponse		= ''
    recParOfs		= ''
    FlagProcessPar	= ''
	
	IF vAmtLiPar NE rAmtLimPar THEN
		recParOfs<LI.INTERNAL.AMOUNT>	= rAmtLimPar
		recParOfs<LI.MAXIMUM.TOTAL>		= rAmtLimPar
	END
	IF rExpDateLimPar NE vLiParExpDate THEN
		recParOfs<LI.EXPIRY.DATE>		= rExpDateLimPar
	END
	
	ID.COMPANY	= vCoBook
    CALL OFS.BUILD.RECORD(AppName, OfsFunction, vProcess, OfsVersion, GtsMode, NoOfAuth, LimitId, recParOfs, OfsMessage)
	
    ReqCommited	= ''
    CALL OFS.CALL.BULK.MANAGER(OfsSource,OfsMessage,OfsResponse,ReqCommited)
	
	OfsResponseHdr	= FIELD(OfsResponse,',',1)
    FlagProcessPar	= FIELD(OfsResponseHdr,'/',3)	
	vRespError		= 'UPDATE LIMIT PARENT - ':FIELD(OfsResponse,OfsResponseHdr:',',2)
	
    RETURN
*-----------------------------------------------------------------------------
UpdateLiPaylater:
*-----------------------------------------------------------------------------

	AppName			= 'LIMIT'
    OfsFunction		= 'I'
    vProcess		= 'PROCESS'
    OfsVersion		= AppName : ',BTPNS.LI.CHILD.OFS'
    GtsMode			= ''
    NoOfAuth		= ''
    LimitId			= idLimPay
    OfsResponse		= ''
    recPayOfs		= ''
    FlagProcessPay	= ''
	
	IF amtLimPay NE rAmtLimChildPayltr THEN
		recPayOfs<LI.INTERNAL.AMOUNT>	= rAmtLimChildPayltr
		recPayOfs<LI.MAXIMUM.TOTAL>		= rAmtLimChildPayltr
	END
	IF vLiPayExpDate NE rExpDateLimChildPayltr THEN
		recPayOfs<LI.EXPIRY.DATE>		= rExpDateLimChildPayltr
	END
	
	ID.COMPANY	= vCoBook
    CALL OFS.BUILD.RECORD(AppName, OfsFunction, vProcess, OfsVersion, GtsMode, NoOfAuth, LimitId, recPayOfs, OfsMessage)
	
    ReqCommited	= ''
    CALL OFS.CALL.BULK.MANAGER(OfsSource,OfsMessage,OfsResponse,ReqCommited)
	
	OfsResponseHdr	= FIELD(OfsResponse,',',1)
    FlagProcessPay	= FIELD(OfsResponseHdr,'/',3)	
	vRespError		= 'UPDATE LIMIT PAYLATER - ':FIELD(OfsResponse,OfsResponseHdr:',',2)
	
    RETURN
*-----------------------------------------------------------------------------
UpdateLiPrk:
*-----------------------------------------------------------------------------
	
	AppName			= 'LIMIT'
    OfsFunction		= 'I'
    vProcess		= 'PROCESS'
    OfsVersion		= AppName : ',BTPNS.LI.CHILD.OFS'
    GtsMode			= ''
    NoOfAuth		= ''
    LimitId			= idLimPrk
    OfsResponse		= ''
    recPrkOfs		= ''
    FlagProcessPrk	= ''
	
	IF amtLimPrk NE rAmtLimChildPrk THEN
		recPrkOfs<LI.INTERNAL.AMOUNT>	= rAmtLimChildPrk
		recPrkOfs<LI.MAXIMUM.TOTAL>		= rAmtLimChildPrk 
	END
	IF vLiPrkExpDate NE rExpDateLimChildPrk THEN
		recPrkOfs<LI.EXPIRY.DATE>		= rExpDateLimChildPrk
	END
	
	ID.COMPANY	= vCoBook
    CALL OFS.BUILD.RECORD(AppName, OfsFunction, vProcess, OfsVersion, GtsMode, NoOfAuth, LimitId, recPrkOfs, OfsMessage)
	
    ReqCommited	= ''
    CALL OFS.CALL.BULK.MANAGER(OfsSource,OfsMessage,OfsResponse,ReqCommited)
	
	OfsResponseHdr	= FIELD(OfsResponse,',',1)
    FlagProcessPrk	= FIELD(OfsResponseHdr,'/',3)	
	vRespError		= 'UPDATE LIMIT PRK - ':FIELD(OfsResponse,OfsResponseHdr:',',2)
	
	
    RETURN
*-----------------------------------------------------------------------------
UpdatePrkActExDate:
*-----------------------------------------------------------------------------
	
	AppName			= 'AA.ARRANGEMENT.ACTIVITY'
    OfsFunction		= 'I'
    vProcess		= 'PROCESS'
    OfsVersion		= AppName : ',BTPNS.INDV.OFS'
    GtsMode			= ''
    NoOfAuth		= ''
    TransactionId	= ''
    OfsResponse		= ''
    recArrOfsDate	= ''
    FlagProcArrDate	= ''
	
	recArrOfsDate<AA.ARR.ACT.ARRANGEMENT>		= idArr
	recArrOfsDate<AA.ARR.ACT.ACTIVITY>			= 'LENDING-CHANGE.TERM-COMMITMENT'
	recArrOfsDate<AA.ARR.ACT.PROPERTY,1>		= 'COMMITMENT'
	recArrOfsDate<AA.ARR.ACT.FIELD.NAME,1,1>	= 'TERM'
	recArrOfsDate<AA.ARR.ACT.FIELD.VALUE,1,1>	= vTenorNew
	recArrOfsDate<AA.ARR.ACT.FIELD.NAME,1,2>	= 'MATURITY.DATE'
	recArrOfsDate<AA.ARR.ACT.FIELD.VALUE,1,2>	= rExpDateLimChildPrk
	
	ID.COMPANY	= vCoBook
    CALL OFS.BUILD.RECORD(AppName, OfsFunction, vProcess, OfsVersion, GtsMode, NoOfAuth, TransactionId, recArrOfsDate, OfsMessage)
	
    ReqCommited	= ''
    CALL OFS.CALL.BULK.MANAGER(OfsSource,OfsMessage,OfsResponse,ReqCommited)
	
	OfsResponseHdr	= FIELD(OfsResponse,',',1)
    FlagProcArrDate	= FIELD(OfsResponseHdr,'/',3)
	vRespError		= FIELD(OfsResponseHdr,'/',4)
	vRespError		= FIELD(vRespError, '</', 1)
	vRespError		= 'UPDATE EXPIRY.DATE AA LOAN - ':idArr:' - ':vRespError
	
	
	RETURN
*-----------------------------------------------------------------------------
UpdatePrkActAmt:
*-----------------------------------------------------------------------------
	
	AppName			= 'AA.ARRANGEMENT.ACTIVITY'
    OfsFunction		= 'I'
    vProcess		= 'PROCESS'
    OfsVersion		= AppName : ',BTPNS.INDV.OFS'
    GtsMode			= ''
    NoOfAuth		= ''
    TransactionId	= ''
    OfsResponse		= ''
    recArrOfsAmt	= ''
    FlagProcArrAmt	= ''
	
	recArrOfsAmt<AA.ARR.ACT.ARRANGEMENT>		= idArr
	recArrOfsAmt<AA.ARR.ACT.ACTIVITY>			= 'LENDING-INCREASE-COMMITMENT'
	recArrOfsAmt<AA.ARR.ACT.EFFECTIVE.DATE>		= TODAY
	recArrOfsAmt<AA.ARR.ACT.PROPERTY,1>			= 'COMMITMENT'
	recArrOfsAmt<AA.ARR.ACT.FIELD.NAME,1,1>		= 'CHANGE.AMOUNT'
	recArrOfsAmt<AA.ARR.ACT.FIELD.VALUE,1,1>	= vAmount
	
	ID.COMPANY	= vCoBook
    CALL OFS.BUILD.RECORD(AppName, OfsFunction, vProcess, OfsVersion, GtsMode, NoOfAuth, TransactionId, recArrOfsAmt, OfsMessage)
	
    ReqCommited	= ''
    CALL OFS.CALL.BULK.MANAGER(OfsSource,OfsMessage,OfsResponse,ReqCommited)
	
	OfsResponseHdr	= FIELD(OfsResponse,',',1)
    FlagProcArrAmt	= FIELD(OfsResponseHdr,'/',3)	
	vRespError		= FIELD(OfsResponseHdr,'/',4)
	vRespError		= FIELD(vRespError, '</', 1)
	vRespError		= 'UPDATE AMOUNT AA LOAN - ':idArr:' - ':vRespError
	
	
	RETURN
*-----------------------------------------------------------------------------
UpdateFlaging:
*-----------------------------------------------------------------------------

	recStagLiqUpd<SLA.LOCAL.REF, vUpdateFlagPos>			= 'Y'
	CALL ATI.LIVE.WRITE(fnAtiThStagingLiqAgent, idBooking, recStagLiqUpd)

*-----------------------------------------------------------------------------
LiveWrite:
*-----------------------------------------------------------------------------

	recStagLiq<SLA.PARENT.AMOUNT>			= rAmtLimPar
	recStagLiq<SLA.CHILD.PAYLATER.AMOUNT>	= rAmtLimChildPayltr
	recStagLiq<SLA.CHILD.PRK.AMOUNT>		= rAmtLimChildPrk
	IF rPkNumber NE recPkNum THEN
		recStagLiq<SLA.PK.NUMBER>			= rPkNumber
	END
	CALL ATI.LIVE.WRITE(fnAtiThStagingLiqAgent, idBooking, recStagLiq)
	
	
    RETURN
*-----------------------------------------------------------------------------
ResponseError:
*-----------------------------------------------------------------------------

	recFinalMessage<-1>	= vRecord:'|ERROR|':vRespError	
	
    RETURN
*-----------------------------------------------------------------------------
ResponseSuccess:
*-----------------------------------------------------------------------------
	IF vNoChange EQ 1 THEN
		recFinalMessage<-1>	= vRecord:'|SUCCESS|NO RECORD CHANGE'
	END ELSE
		recFinalMessage<-1>	= vRecord:'|SUCCESS'
	END

    RETURN
	
*-----------------------------------------------------------------------------
WriteTextfile:
*-----------------------------------------------------------------------------
	
	idProc		= idFile:'.res'
	yFileDup	= idFile:'.DISB.INDV.FINACING'
	yFileBkp	= idFile:'.bkp'
	
*---WRITE NEW PROCESS FILE---
	WRITE recFinalMessage TO fvResult, idProc
	
*---WRITE FILE NAME TO TABLE DUPLICATE---	
	WRITE idFile TO fvBtpnsTtDup,yFileDup 
	
*---WRITE BACKUP FILE---	
	WRITE recFile TO fvBakup,yFileBkp

*---DELETE FILE---
	DELETE fvProcess, idFile
	
	RETURN

*-----------------------------------------------------------------------------
END	
	