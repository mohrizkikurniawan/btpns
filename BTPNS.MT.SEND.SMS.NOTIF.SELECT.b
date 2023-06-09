*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.SEND.SMS.NOTIF.SELECT
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
	$INSERT I_F.BTPNS.TH.QUEUE.SMS.NOTIF
	$INSERT I_BTPNS.MT.SEND.SMS.NOTIF.COMMON

	*vScheduler = OCONV(TIME(),"MTS")
	*IF vScheduler GE '08:00:00' AND vScheduler LE '17:00:00' THEN
		GOSUB PROCESS
	*END
	
	RETURN
*------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------

	vScheduler	= OCONV(TIME(),'MTS')
	vFlagAtm	= ""
	IF vScheduler GE '08:00:00' AND vScheduler LE '17:00:00' THEN
	
		SelCmd	= "SELECT ":fnBtpnsThQueueSms
		CALL EB.READLIST(SelCmd,SelList,'','','')
		vFlagAtm	= 0
		CALL BATCH.BUILD.LIST("",SelList)
	
	END ELSE 
		GOSUB GetChannelList
**		SelCmd	= "SELECT ":fnBtpnsThQueueSms : " WITH @ID LIKE '....6011...' OR @ID LIKE '....6050...'"
		IF ChannelNo THEN 
			CALL EB.READLIST(SelCmd,SelList,'','','')
			vFlagAtm	= 1

			CALL BATCH.BUILD.LIST("",SelList)
		END
	END
	
	RETURN
*------------------------------------------------------------------------------
GetChannelList:

	fnTableChannel = "F.IDIH.CHANNEL.ID"
	fvTableChannel = ""
	CALL OPF(fnTableChannel, fvTableChannel)

	SelCmd = "SELECT ":fnBtpnsThQueueSms :" WITH "

	qryCmd = "SELECT ":fnTableChannel:" WITH B.DEBIT.NOTIF EQ 'Y' OR B.CREDIT.NOTIF EQ 'Y' OR B.DB.NOTIF.INBX EQ 'Y' OR B.CR.NOTIF.INBX EQ 'Y'"
	CALL EB.READLIST(qryCmd, ChannelList, "", ChannelNo, "")
	FOR idx=1 TO ChannelNo
		SelCmd := " @ID LIKE ....":ChannelList<idx>:"-..."
		IF idx NE ChannelNo THEN SelCmd := " OR "
	NEXT idx

	RETURN
*------------------------------------------------------------------------------
END