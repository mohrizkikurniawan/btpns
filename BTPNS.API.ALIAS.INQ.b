    SUBROUTINE BTPNS.API.ALIAS.INQ(Y.TYPE,Y.DATA,Y.RESPON,RESP.ERR,Y.PARAM)
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 16 Agustus 2022
* Description        : Call routine for api alias management
*                    : Format Y.DATA with delimeter pipeline "|"
*           Posisi 1 : Legal type -> 01-KTP/02-PASPORT -> For alias Inquiry
*           Posisi 2 : Legal ID   -> NIK / No Passport -> For alias Inquiry
*           Posisi 3 : lookup Type -> PXRS,CHCK,NMEQ ->For Alias Resolution
*           Posisi 4 : proxy Type-> 01-Phone No,02-Email,03-IPT ID ->For Alias Resolution
*           Posisi 5 : proxy Value -> No Telp , Email ,IPT ID ->For Alias Resolution
*           Posisi 6 : Channel Type -> 6845 - IB , 6846 - MB ,6847 - Counter , 6849 0 Other
*           Posisi 7 : From Account 
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date           :
* Modified by      :
* Description      :
* No Log         :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
*Declare Date Time
	BEGIN CASE
	CASE Y.TYPE EQ "BAliasRegInqRQ"
	   Y.TRX.TYPE       = "620"
       Y.LEGAL.TYPE     = FIELD(Y.DATA,"|",1)
       Y.LEGAL.ID       = FIELD(Y.DATA,"|",2)
       Y.CHANNEL.TYPE   = FIELD(Y.DATA,"|",6)
       Y.ACCOUNT.TYPE   = FIELD(Y.DATA,"|",7)
       IF Y.ACCOUNT.TYPE = '' THEN
           Y.ACCOUNT.TYPE= "999999999"
       END
       GOSUB DEFAULT.VALUE
       GOSUB CALL.API.INQUIRY
	CASE Y.TYPE EQ "BAliasRsltRQ"
	   Y.TRX.TYPE    = "610"
       Y.LOOKUP.TYPE = FIELD(Y.DATA,"|",3)
       Y.PROXY.TYPE  = FIELD(Y.DATA,"|",4)
       Y.PROXY.VALUE = FIELD(Y.DATA,"|",5)
       Y.CHANNEL.TYPE= FIELD(Y.DATA,"|",6)
       Y.ACCOUNT.TYPE   = FIELD(Y.DATA,"|",7)
       IF Y.ACCOUNT.TYPE = '' THEN
           Y.ACCOUNT.TYPE= "999999999"
       END


       GOSUB DEFAULT.VALUE
	   GOSUB CALL.API.RESOLUTION
    CASE 1 
       RESP.ERR = "Type Request Invalid"
	END CASE
	
    RETURN
*-----------------------------------------------------------------------------
CALL.API.INQUIRY:
*-----------------------------------------------------------------------------


    Y.PARAM = ''
    XX = ':'
    ZZ = ','
    Y.OPEN   = '{'
    Y.CLOSE = '}'
    Y.PARAM = Y.OPEN
    Y.PARAM :='"partnerReferenceNo"':XX:DQUOTE(Y.RRN)
    Y.PARAM :=',"creationDateTime"':XX:DQUOTE(Y.CREATE.DT.TM)
    Y.PARAM :=',"onboardingPartner"':XX:DQUOTE(Y.ONBOARD.PARTNER)    
    Y.PARAM :=',"receivingPartner"':XX:DQUOTE(Y.REC.PARTNER)
    Y.PARAM :=',"channelType"':XX:DQUOTE(Y.CHANNEL.TYPE)
    Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.ACCOUNT.TYPE)
    Y.PARAM :=',"additionalInfo"':XX:Y.OPEN
    Y.PARAM :='"idType"':XX:DQUOTE(Y.LEGAL.TYPE)
    Y.PARAM :=',"id"':XX:DQUOTE(Y.LEGAL.ID)
    Y.PARAM := Y.CLOSE
    Y.PARAM := Y.CLOSE
    
    CRT '[BFASTPROXYINQ-REQ] - ':Y.PARAM
    RESP.ERR = ''
    CALL BTPNSR.BIFAST.INTERFACE(Y.TYPE,Y.PARAM,Y.RESPON,RESP.ERR)

RETURN
*-----------------------------------------------------------------------------
CALL.API.RESOLUTION:
*-----------------------------------------------------------------------------

    Y.PARAM = ''
    XX = ':'
    ZZ = ','
    Y.OPEN   = '{'
    Y.CLOSE = '}'
    Y.PARAM = Y.OPEN
    Y.PARAM :='"partnerReferenceNo"':XX:DQUOTE(Y.RRN)
    Y.PARAM :=',"creationDateTime"':XX:DQUOTE(Y.CREATE.DT.TM)
    Y.PARAM :=',"onboardingPartner"':XX:DQUOTE(Y.ONBOARD.PARTNER)    
    Y.PARAM :=',"receivingPartner"':XX:DQUOTE(Y.REC.PARTNER)
    Y.PARAM :=',"channelType"':XX:DQUOTE(Y.CHANNEL.TYPE)
    Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.ACCOUNT.TYPE)
    Y.PARAM :=',"additionalInfo"':XX:Y.OPEN
    Y.PARAM :='"lookupType"':XX:DQUOTE(Y.LOOKUP.TYPE)
    Y.PARAM :=',"requestID"':XX:DQUOTE(Y.REQUEST.ID)
	Y.PARAM :=',"proxyType"':XX:DQUOTE(Y.PROXY.TYPE)
    Y.PARAM :=',"proxyValue"':XX:DQUOTE(Y.PROXY.VALUE)
    Y.PARAM := Y.CLOSE
    Y.PARAM := Y.CLOSE
    
    CRT '[BFASTPROXYRESOLUTION-REQ] - ':Y.PARAM
    RESP.ERR = ''
    CALL BTPNSR.BIFAST.INTERFACE(Y.TYPE,Y.PARAM,Y.RESPON,RESP.ERR)

RETURN
*-----------------------------------------------------------------------------
DEFAULT.VALUE:
*-----------------------------------------------------------------------------
    
    Y.DATE         = TODAY
    Y.ID         = ID.NEW
    
*construct date
    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
    Y.CURRENT.TIME = TIMESTAMP()
    Y.DAYS = OCONV(DATE(),"DWA")
    Y.DAYS = Y.DAYS[1,1]:LOWCASE(Y.DAYS[2,2])
    Y.DD.MMM.YY = OCONV(DATE(), "D2")
    Y.DD.MMM.YY =  Y.DD.MMM.YY[1,3]:Y.DD.MMM.YY[4,1]:LOWCASE(Y.DD.MMM.YY[5,2])
    Y.YY = X[9,2]
    Y.MM = X[1,2]
    Y.DD = X[4,2]
    Y.TH = Y.TIME[1,2]
    Y.TM = Y.TIME[4,2]
    Y.TS = Y.TIME[7,2]
    Y.CREATE.DT.TM = Y.DAYS:", ":Y.DD.MMM.YY:" ":X[7,4]:" ":Y.TH:":":Y.TM:":":Y.TS

*Construct Sequence
    FOR Y.E = 1 TO 8
       Y.RND = RND(9)
       Y.SEQ := Y.RND
    NEXT Y.E

    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME       = UPCASE(X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2])
	Y.REC.PARTNER     = "360000"
	Y.ONBOARD.PARTNER = "92547"
	Y.DATE            = X[7,4]:Y.MM:Y.DD
	Y.RRN             = Y.DATE:'000':Y.ONBOARD.PARTNER:Y.TRX.TYPE:Y.SEQ
	Y.REQUEST.ID      = Y.DATE:'000':Y.ONBOARD.PARTNER:"O":Y.SEQ

RETURN
*-----------------------------------------------------------------------------
END
