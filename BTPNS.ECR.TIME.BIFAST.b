*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.ECR.TIME.BIFAST
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20230315
* Description        : Conversion routine for detail time refer to portal bifast
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
*-----------------------------------------------------------------------------
	$INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
	$INSERT I_F.BTPNS.TH.BIFAST.INCOMING

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB INIT
	GOSUB PROCESS
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	

	fnBtpnsThBifastIncoming		= "F.BTPNS.TH.BIFAST.INCOMING"
	fvBtpnsThBifastIncoming		= ""
	CALL OPF(fnBtpnsThBifastIncoming ,fvBtpnsThBifastIncoming)


	statusAmPm	= ''

	RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	CALL F.READ(fnBtpnsThBifastIncoming, O.DATA, rvBtpnsThBifastIncomingTrf, fvBtpnsThBifastIncoming, '')
	rrn 		= rvBtpnsThBifastIncomingTrf<BtpnsThBifastIncoming_Rrn>

	selCmd	= "SELECT " : fnBtpnsThBifastIncoming : " WITH RRN EQ " : rrn : " AND API.TYPE EQ B.STLM.TRF.RQ"
	CALL EB.READLIST(selCmd, selList, "", selCnt, selErr)

	CALL F.READ(fnBtpnsThBifastIncoming, selList<1>, rvBtpnsThBifastIncomingSettle, fvBtpnsThBifastIncoming, '')

	IF rvBtpnsThBifastIncomingSettle NE '' THEN
		secWib		= rvBtpnsThBifastIncomingSettle<BtpnsThBifastIncoming_TransDateTime>[9,2]
		minWib		= rvBtpnsThBifastIncomingSettle<BtpnsThBifastIncoming_TransDateTime>[7,2]
		hourWib		= rvBtpnsThBifastIncomingSettle<BtpnsThBifastIncoming_TrxTime>[1,2]
		dateTime	= rvBtpnsThBifastIncomingSettle<BtpnsThBifastIncoming_DateTime>[1,6]
	END ELSE
		secWib		= rvBtpnsThBifastIncomingTrf<BtpnsThBifastIncoming_TransDateTime>[9,2]
		minWib		= rvBtpnsThBifastIncomingTrf<BtpnsThBifastIncoming_TransDateTime>[7,2]
		hourWib		= rvBtpnsThBifastIncomingTrf<BtpnsThBifastIncoming_TrxTime>[1,2]
		dateTime	= rvBtpnsThBifastIncomingTrf<BtpnsThBifastIncoming_DateTime>[1,6]
	END

	IF hourWib GT 12 THEN
		hourWib	= hourWib - 12
		statusAmPm = 'PM'
	END ELSE
		statusAmPm = 'AM'
	END

	IF hourWib = 12 AND minWib NE '00' AND secWib NE '00' THEN
		statusAmPm	= 'PM'
	END
	
	O.DATA = OCONV(ICONV(dateTime,'D4'),'D'): " " : hourWib : ":" : minWib : ":" : secWib : " " : statusAmPm
	
	RETURN
*-----------------------------------------------------------------------------
END
