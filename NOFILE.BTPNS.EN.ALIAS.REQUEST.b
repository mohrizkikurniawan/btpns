   SUBROUTINE NOFILE.BTPNS.EN.ALIAS.REQUEST(Y.OUTPUT)
*-----------------------------------------------------------------------------
* Developer Name    : Hamka Ardyansah
* Development Date  : 16 Agustus 2022
* Description       : Nofile for get data alias inquiry in bifast system
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date       :
* Modified by    :
* Description    :
* No Log        :
*-----------------------------------------------------------------------------
   $INSERT I_COMMON
   $INSERT I_EQUATE
   $INSERT I_F.BTPNS.TH.BIFAST.PROXY.MGMT
   $INSERT I_F.ACCOUNT
   $INSERT I_F.CUSTOMER
   $INSERT I_F.SECTOR
   $INSERT I_F.BTPNS.TL.BFAST.OPR.TYPE
   $INSERT I_F.BTPNS.TL.BFAST.ACCT.TYPE
   $INSERT I_F.BTPNS.TL.BFAST.CUST.TYPE
   $INSERT I_F.BTPNS.TL.BFAST.PROXY.TYPE
   $INSERT I_ENQUIRY.COMMON

   GOSUB INIT
   GOSUB PROCESS
   
   RETURN
   
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

   Y.FIELD = ENQ.SELECTION<2,0>
   FIND 'LEGAL.ID.NO' IN Y.FIELD SETTING POS.FM, POS1 THEN
      Y.FIELD1    = ENQ.SELECTION<2,POS1>
      Y.OPERATION1 = ENQ.SELECTION<3,POS1>
      Y.LEGAL.ID.NO     = ENQ.SELECTION<4,POS1>
   END
   
RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    GOSUB GET.ALIAS.INQUIRY

RETURN
*-----------------------------------------------------------------------------
GET.ALIAS.INQUIRY:
*-----------------------------------------------------------------------------

   Y.LEGAL.TYPE      = "01"
   Y.LEGAL.ID.NO     = Y.LEGAL.ID.NO
   Y.TYPE = "BAliasRegInqRQ"
   Y.DATA = "01|":Y.LEGAL.ID.NO:"||||6847"
   Y.OUPUT =""
   CALL BTPNS.API.ALIAS.INQ(Y.TYPE,Y.DATA,Y.RESPON,RESP.ERR,Y.REQUEST.JSON)
   Y.DATA.TEMP   = FIELDS(Y.RESPON,']',1)
   Y.DATA.TEMP   = FIELDS(Y.DATA.TEMP,'[',2)
   Y.CNT = DCOUNT(Y.DATA.TEMP,"},{")
   FOR Y.Z = 1 TO Y.CNT
       Y.DATA = FIELDS(Y.DATA.TEMP,"},",Y.Z)
       Y.RESPONSE.TEMP = EREPLACE(EREPLACE(Y.DATA,'":"','|'),'","','|')
       Y.RESPONSE      = CHANGE(CHANGE(Y.RESPONSE.TEMP,'"',''),'}','')
       Y.BANK          = FIELDS(FIELDS(Y.RESPONSE,'bankID',2),'|',2)
       Y.ACC           = FIELDS(FIELDS(Y.RESPONSE,'accountID',2),'|',2)
       Y.PRX.TYPE      = FIELDS(FIELDS(Y.RESPONSE,'proxyType',2),'|',2)
       Y.PRX           = FIELDS(FIELDS(Y.RESPONSE,'proxyValue',2),'|',2)
       Y.NAME          = FIELDS(FIELDS(Y.RESPONSE,'name',2),'|',2)
       Y.STATUS        = FIELDS(FIELDS(Y.RESPONSE,'proxyStatus',2),'|',2)
       Y.REG.ID        = FIELDS(FIELDS(Y.RESPONSE,'registrationIdentifier',2),'|',2)
       Y.OUTPUT<-1>    = Y.BANK:"|":Y.ACC:"|":Y.PRX.TYPE:"|":Y.PRX:"|":Y.NAME:"|":Y.STATUS:"|":Y.REG.ID
   NEXT Y.Z


RETURN
*-----------------------------------------------------------------------------
END