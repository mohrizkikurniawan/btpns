*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.SEND.SMS.NOTIF(idSmsQueue)
*-----------------------------------------------------------------------------
* Developer Name     : Kania Farhaning Lydia
* Development Date   : 4 Oktober 2022
* Description        : Routine To send SMS notification for Open and Close product Account and Deposito. Autodebit (success/fail) TTR/Savplan. Rollover Deposito.
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
	
	$INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.DATES
	$INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.ACTION.CONTEXT
	$INSERT I_F.BTPNSH.ACK.LOG.SMS
	$INSERT I_F.ATI.TH.LOG.INBOX
	$INSERT I_F.COMPANY
	$INSERT I_F.AA.PRODUCT
	$INSERT I_F.AA.ARRANGEMENT
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_F.BTPNS.TH.QUEUE.SMS.NOTIF
	$INSERT I_F.BTPNSH.SMS.MESSAGE.TEXT
	$INSERT I_BTPNS.MT.SEND.SMS.NOTIF.COMMON
	
	vScheduler = OCONV(TIME(),"MTS")
	IF (vScheduler GE '08:00:00' AND vScheduler LE '17:00:00') OR vFlagAtm EQ 1 THEN
		GOSUB INIT
		
		IF vFprdSmsFlag EQ 'Y' THEN
			IF vSmsFlag EQ 'Y' AND vSmsNo NE "" AND vMessage NE '' THEN
				GOSUB PROCESS.SMS
			END
			
			IF vMbibFlag EQ 'Y' AND vMessage NE '' THEN
				GOSUB PROCESS.INBOX
			END
		END
		
		idSmsQueueHis = idSmsQueue:"-":TODAY:";1"
		CALL F.READ(fnBtpnsThQueueSms,idSmsQueue,recidSmsQueue,fvBtpnsThQueueSms,errQueue)
		CALL F.READ(fnBtpnsThQueueSmsHis,idSmsQueueHis,recidSmsQueueHis,fvBtpnsThQueueSmsHis,errHisQueue)
		recidSmsQueueHis = recidSmsQueue
		WRITE recidSmsQueueHis TO fvBtpnsThQueueSmsHis,idSmsQueueHis
		DELETE fvBtpnsThQueueSms,idSmsQueue
	END
	
	RETURN
	
*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------

	CALL F.READ(fnBtpnsThQueueSms,idSmsQueue,rSmsQueue,fvBtpnsThQueueSms,errSms)
	idContract		= rSmsQueue<SMS.NOTIF.ID.SMS>			
    idSmsText		= rSmsQueue<SMS.NOTIF.ID.TEXT.SMS>	
    vSmsCode		= rSmsQueue<SMS.NOTIF.DESC.SMS>		
    vSmsDet			= rSmsQueue<SMS.NOTIF.SMS.FLAG>	
	vSmsFlag		= FIELD(vSmsDet,'|',1)	
	vSmsNo			= FIELD(vSmsDet,'|',2)
    vMbibFlag		= rSmsQueue<SMS.NOTIF.INBOX.FLAG>
*	vMbibFlag		= FIELD(vMbibDet,'|',1)	
*	vMbibNo			= FIELD(vMbibDet,'|',2)
    vFprdSmsFlag	= rSmsQueue<SMS.NOTIF.PRODUCT.FLAG>		
    vAmount			= rSmsQueue<SMS.NOTIF.AMOUNT>			
    vAcctCr			= rSmsQueue<SMS.NOTIF.ACCOUNT.CR>	
    vAcctDb			= rSmsQueue<SMS.NOTIF.ACCOUNT.DB>	
    xTime			= rSmsQueue<SMS.NOTIF.TIME>			
    vProcDate		= rSmsQueue<SMS.NOTIF.DATE>			
    vProdDesc		= rSmsQueue<SMS.NOTIF.PRODUCT.DESC>		
    vCoName			= rSmsQueue<SMS.NOTIF.COMPANY>		
    vAroStatusDesc	= rSmsQueue<SMS.NOTIF.ARO.STATUS>
	vMessage		= rSmsQueue<SMS.NOTIF.LOCAL.REF,vFinaLMssgPos>
	vCustomer		= rSmsQueue<SMS.NOTIF.LOCAL.REF,vCustomerIdPos>
	vAroStatus		= FIELD(vAroStatusDesc,'|',1)
	vTerm			= FIELD(vAroStatusDesc,'|',2)
	cntUnique		= 0
	XX				= '|'
	PrefixId		= idSmsQueue[1,3]
	
	CHANGE '.' TO ':' IN xTime
	xTime		= xTime:':00'
	
	vToday		= TODAY
	vDay		= FIELD(vProcDate,'/',1)
	vMounth		= FIELD(vProcDate,'/',2)
	vYear		= vToday[1,2]:FIELD(vProcDate,'/',3)
	vProcDate	= vYear:vMounth:vDay
	
	X = OCONV(DATE(),"D-")
    yTime = OCONV(TIME(),"MTS")
    DT = X[9,2]:X[1,2]:X[4,2]:yTime[1,2]:yTime[4,2]:yTime[7,2]
    dateTime = X[9,2]:X[1,2]:X[4,2]:yTime[1,2]:yTime[4,2]
	
	idFolder	= idContract:dateTime
	
	IF PrefixId EQ 'TRX' THEN
		vCustomer		= FIELD(idSmsQueue,'-',2)
	END ELSE
		idArrangement	= FIELD(idSmsQueue,'-',1)
		idMasterAa		= FIELD(idSmsQueue,'-',2)
		
		CALL F.READ(fnArrangementActivity, idMasterAa, rAaMaster, fvArrangementActivity, errAaMaster)
		vInputter   	= rAaMaster<AA.ARR.ACT.INPUTTER>
		vArrCode		= rAaMaster<AA.ARR.ACT.CO.CODE>
		vArrDateTime	= rAaMaster<AA.ARR.ACT.DATE.TIME>
		idProduct		= rAaMaster<AA.ARR.ACT.PRODUCT>
		vOrgSyDate		= rAaMaster<AA.ARR.ACT.ORG.SYSTEM.DATE>
	END
	
	RETURN
*------------------------------------------------------------------------------
PROCESS.SMS:
*------------------------------------------------------------------------------
	
	flagPrintSms	= 'Y'
    vChannel		= 'TMN01'
    
    CRT '[SMS:REQUEST-MESSAGE] - ':vSmsNo
	
	cntUnique		= cntUnique + 1
    fmtUnique		= FMT(cntUnique, "R%3")
    idTransaction	= idContract:fmtUnique
	idCorSms		= idTransaction
	
    rParam = '{"transactionid":"':idTransaction:'",'
    rParam := '"to": "':vSmsNo:'",'
    rParam := '"cc": "",'
    rParam := '"bcc": "",'
    rParam := '"message": "':vMessage:'",'
    rParam := '"subject": "",'
    rParam := '"type": "0001",'
    rParam := '"attachment": []}'
	
    CRT rParam
	
    CALL ATI.SMS.REQ.RESP(rParam,posResponse)
        
    idOutFile = idFolder:'.SMS'
	fnOutDirctSms	= '../UD/APPSHARED.BP/SMS.BP'
	
	OPENSEQ fnOutDirctSms, idOutFile TO fvOutDirctSms THEN
    END ELSE
        CREATE fvOutDirctSms ELSE
            CRT 'FILE CREATION ERROR'
            STOP
        END
    END
	
    rOutRec = idFolder:XX:vChannel:XX:vSmsCode:XX:vSmsNo:XX:vMessage
    WRITESEQ rOutRec APPEND TO fvOutDirctSms ELSE
        CRT 'FILE WRITE ERROR'
        STOP
    END
    
    GOSUB GET.RESPONSE

	RETURN
*------------------------------------------------------------------------------
PROCESS.INBOX:
*------------------------------------------------------------------------------

	flagPrintSms	= ''
	flagPrintInbox	= 'Y'

	
    vChannel = 'TMN01'
    
    CRT '[SMS:REQUEST-MESSAGE] - ':vCustomer
	
	cntUnique		= cntUnique + 1
    fmtUnique		= FMT(cntUnique, "R%3")
    idTransaction	= idContract:fmtUnique
	idCorInbox		= idTransaction
	
    rParam = '{"transactionid":"':idTransaction:'",'
    rParam := '"to": "':vCustomer:'",'
    rParam := '"cc": "",'
    rParam := '"bcc": "",'
    rParam := '"message": "':vMessage:'",'
    rParam := '"subject": "",'
    rParam := '"type": "0003",'
    rParam := '"attachment": []}'
	
    CRT rParam
	
    CALL ATI.SMS.REQ.RESP(rParam,posResponse)
        
    idOutFileInbox = idFolder:'.INBOX'
	fnOutDirctMbib	= '../UD/APPSHARED.BP/INBOX.BP'
	
	OPENSEQ fnOutDirctMbib, idOutFileInbox TO fvOutDirctMbib THEN
    END ELSE
        CREATE fvOutDirctMbib ELSE
            CRT 'FILE CREATION ERROR'
            STOP
        END
    END
	
    rOutRec = idFolder:XX:vChannel:XX:vSmsCode:XX:vCustomer:XX:vMessage
    WRITESEQ rOutRec APPEND TO fvOutDirctMbib ELSE
        CRT 'FILE WRITE ERROR'
        STOP
    END
    
    GOSUB GET.RESPONSE

	RETURN
*------------------------------------------------------------------------------
GET.RESPONSE:
*------------------------------------------------------------------------------

	vStatusCode = FIELDS(FIELDS(posResponse,':',2),'"',2)
    vResult = vStatusCode:' [success]'
    vResponseDesc = FIELDS(FIELDS(posResponse,':',3),'"',2)
    vResult :='*': vResponseDesc:' [description]'
	vStatus = vStatusCode :'-': vResponseDesc

    IF flagPrintSms EQ "Y" THEN
        CRT '[SMS:RESPONSE-MESSAGE]'
        CRT vResult
        GOSUB WRITE.TABLE.SMS.TEXT
    END

    IF flagPrintInbox EQ "Y" THEN
        CRT '[INBOX:RESPONSE-MESSAGE]'
        CRT vResult
        GOSUB WRITE.TABLE.INBOX.TEXT
    END

	RETURN
*------------------------------------------------------------------------------
WRITE.TABLE.SMS.TEXT:
*------------------------------------------------------------------------------
	
	Y.DATE.SERVER 		= OCONV(DATE(), 'D4/')
    Y.DATE.SERVER.CONV 	= Y.DATE.SERVER[4]:Y.DATE.SERVER[1,2]:Y.DATE.SERVER[4,2]
    CALL F.READ(FN.LOGS,Y.FIELD.NAME,R.LOGS,F.LOGS,LOGS.ERR)
	yTime = OCONV(TIME(),"MTS")
	
	X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    vTime = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
	
    CALL F.READ(fnLogSms,idSmsQueue,rLogSms,fvLogSms,errLogSms)
	rLogSms<ALS.REFERENCE.NO>				= idContract
	rLogSms<ALS.CUSTOMER.NO>				= vCustomer
    rLogSms<ALS.SMS.TEXT>					= vMessage
    rLogSms<ALS.STATUS>						= vStatus
    rLogSms<ALS.SMS.NO>						= vSmsNo
    rLogSms<ALS.DATE.SENT>					= TODAY
    rLogSms<ALS.TIME.SENT>					= yTime
    rLogSms<ALS.AMOUNT>						= vAmount
	rLogSms<ALS.CORRELATION.ID>				= idTransaction
	
	IF PrefixId EQ 'TRX' THEN
		rLogSms<ALS.TRX.DATE>				= TODAY
		rLogSms<ALS.DATE.TIME>				= vTime
		rLogSms<ALS.LOCAL.REF,vDescTrxPos>	= vProdDesc
		rLogSms<ALS.INPUTTER>				= OPERATOR
		rLogSms<ALS.AUTHORISER>				= OPERATOR
		rLogSms<ALS.CO.CODE>				= ID.COMPANY
	END ELSE
		rLogSms<ALS.TRX.DATE>				= vProcDate
		rLogSms<ALS.DATE.TIME>				= vTime
		rLogSms<ALS.INPUTTER>				= OPERATOR
		rLogSms<ALS.AUTHORISER>				= OPERATOR
		rLogSms<ALS.CO.CODE>				= ID.COMPANY
		rLogSms<ALS.LOCAL.REF,vDescTrxPos>	= vSmsCode
	END

    WRITE rLogSms TO fvLogSms,idSmsQueue
	
	RETURN
*------------------------------------------------------------------------------
WRITE.TABLE.INBOX.TEXT:
*------------------------------------------------------------------------------
	yTime = OCONV(TIME(),"MTS")
	
    CALL F.READ(fnLogInbox,idSmsQueue,rLogInbox,fvLogInbox,errLogInbox)

	rLogInbox<LOG.INB.REFERENCE.NO>		= idContract
	rLogInbox<LOG.INB.TRX.DATE>			= vOrgSyDate
	rLogInbox<LOG.INB.DATE.TIME>		= vArrDateTime
	rLogInbox<LOG.INB.INPUTTER>    		= vInputter
	rLogInbox<LOG.INB.AUTHORISER>  		= vInputter
	rLogInbox<LOG.INB.CO.CODE>      	= vArrCode
	rLogInbox<LOG.INB.AMOUNT>       	= vAmount
    rLogInbox<LOG.INB.CUSTOMER.NO>  	= vCustomer
    rLogInbox<LOG.INB.MSG.TEXT>     	= vMessage
    rLogInbox<LOG.INB.STATUS>       	= vStatus
    rLogInbox<LOG.INB.MSG.TO>       	= vCustomer
    rLogInbox<LOG.INB.DATE.SENT>    	= TODAY
    rLogInbox<LOG.INB.TIME.SENT>    	= yTime  
	rLogInbox<LOG.INB.DATE.TIME>		= vTime
	rLogInbox<LOG.INB.INPUTTER>			= OPERATOR
	rLogInbox<LOG.INB.AUTHORISER>		= OPERATOR
	rLogInbox<LOG.INB.CO.CODE>			= ID.COMPANY
	rLogInbox<LOG.INB.CORRELATION.ID>	= idTransaction
	
    WRITE rLogInbox TO fvLogInbox,idSmsQueue

	RETURN
*------------------------------------------------------------------------------
END

