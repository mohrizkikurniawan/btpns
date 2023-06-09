	SUBROUTINE BTPNS.MT.AUTO.CLOSED.SVS(Y.AA.ID)
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 3 November 2022
* Description        : ROutine multithread for create ofs to reverse IM.DOCUMENT.IMAGE and IM.DOCUMENT.UPLOAD
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description		: 
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_TSA.COMMON
    $INSERT I_BATCH.FILES
    $INSERT I_BTPNS.MT.AUTO.CLOSED.SVS.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.BTPNS.TH.QUEUE.CLOSE.SVS
    $INSERT I_F.BTPNS.TH.REPORT.SVS.CLOSE
    $INSERT I_F.ALTERNATE.ACCOUNT
    $INSERT I_F.IM.DOCUMENT.IMAGE
    GOSUB PROCESS
    
    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    SEL.CMD1  = 'SELECT ': FN.IM.DOCUMENT.IMAGE : ' AND WITH IMAGE.APPLICATION EQ ACCOUNT AA.ARRANGEMENT'
    SEL.CMD1 := ' AND WITH IMAGE.TYPE NE CU.CREDENTIAL'
    SEL.LIST1 =""
    Y.ALT.ACT.ID = Y.AA.ID
    CALL F.READ(FN.ALT.ACT, Y.ALT.ACT.ID, R.ALT.ACT, F.ALT.ACT, ALT.ACT.ERR)
    IF R.ALT.ACT THEN
        Y.IMG.REF.SEL = R.ALT.ACT<AAC.GLOBUS.ACCT.NUMBER>
    END
    
    SEL.CMD1 := ' AND WITH IMAGE.REFERENCE EQ ':Y.IMG.REF.SEL:' ':Y.AA.ID


    CALL EB.READLIST(SEL.CMD1, SEL.LIST1, '', NO.REC, LIST.ERR)

    FOR Y.A = 1 TO NO.REC
    Y.ID.IM.DOCUMENT.IMAGE =SEL.LIST1<Y.A>
    CALL F.READ(FN.IM.DOCUMENT.IMAGE,Y.ID.IM.DOCUMENT.IMAGE,R.IM.DOCUMENT.IMAGE,F.IM.DOCUMENT.IMAGE,ERR.IM.DOCUMENT.IMAGE)
    CALL F.READ(FN.IM.DOCUMENT.UPLOAD,Y.ID.IM.DOCUMENT.IMAGE,R.IM.DOCUMENT.UPLOAD,F.IM.DOCUMENT.UPLOAD,ERR.IM.DOCUMENT.UPLOAD)
    Y.CO.CODE = R.IM.DOCUMENT.IMAGE<IM.DOC.CO.CODE>

    IF R.IM.DOCUMENT.UPLOAD THEN
        GOSUB OFS.DOCUMENT.UPLOAD
        GOSUB OFS.DOCUMENT.IMAGE
        GOSUB WRITE.OUTPUT
        GOSUB DELETE.QUEUE

    END ELSE
        GOSUB OFS.DOCUMENT.UPLOAD
        GOSUB OFS.DOCUMENT.IMAGE
        GOSUB WRITE.OUTPUT
        GOSUB DELETE.QUEUE
        
    END

    NEXT Y.A

    RETURN
*-----------------------------------------------------------------------------
OFS.DOCUMENT.IMAGE:
*-----------------------------------------------------------------------------
    Y.APP.NAME       = "IM.DOCUMENT.IMAGE"
    Y.OFS.FUNCT      = "R"
    Y.PROCESS        = "PROCESS"
    Y.VERSION        = Y.APP.NAME : ",REVERSE"
    Y.GTS.MODE       = "1"
    Y.NO.OF.AUTH     = 0
    Y.TRANSACTION.ID = Y.ID.IM.DOCUMENT.IMAGE
     R.ACL.OFS        = ""
     Y.OFS.SOURCE    = 'DS.PACKAGE'

    CALL LOAD.COMPANY(Y.CO.CODE)
    CALL OFS.BUILD.RECORD(Y.APP.NAME, Y.OFS.FUNCT, Y.PROCESS, Y.VERSION, Y.GTS.MODE, Y.NO.OF.AUTH, Y.TRANSACTION.ID, R.ACL.OFS, Y.OFS.MESSAGE)
    Y.OFS.RESPONSE = ''
    CALL OFS.CALL.BULK.MANAGER(Y.OFS.SOURCE, Y.OFS.MESSAGE, Y.OFS.RESPONSE, Y.TXN.RESULT)
    Y.OFS.RESPONSE.IMAGE = Y.OFS.RESPONSE
    Y.STATUS.IMAGE  = Y.OFS.RESPONSE[',',1,1]['/',3,1]
    IF Y.STATUS.IMAGE EQ '1' THEN
        Y.STATUS.IMAGE  = "Berhasil"
    END ELSE
        Y.MESSAGE.IMAGE = Y.OFS.RESPONSE[',',2,1]
    END

RETURN
*-----------------------------------------------------------------------------
OFS.DOCUMENT.UPLOAD:
*-----------------------------------------------------------------------------
    Y.APP.NAME       = "IM.DOCUMENT.UPLOAD"
    Y.OFS.FUNCT      = "R"
    Y.PROCESS        = "PROCESS"
    Y.VERSION        = Y.APP.NAME : ",DMR"
    Y.GTS.MODE       = "1"
    Y.NO.OF.AUTH     = 0
    Y.TRANSACTION.ID = Y.ID.IM.DOCUMENT.IMAGE
    R.ACL.OFS        = ""
    Y.OFS.SOURCE    = 'DS.PACKAGE'

    CALL LOAD.COMPANY(Y.CO.CODE)
    CALL OFS.BUILD.RECORD(Y.APP.NAME, Y.OFS.FUNCT, Y.PROCESS, Y.VERSION, Y.GTS.MODE, Y.NO.OF.AUTH, Y.TRANSACTION.ID, R.ACL.OFS, Y.OFS.MESSAGE)
    Y.OFS.RESPONSE = ''
    CALL OFS.CALL.BULK.MANAGER(Y.OFS.SOURCE, Y.OFS.MESSAGE, Y.OFS.RESPONSE, Y.TXN.RESULT)
    Y.OFS.RESPONSE.UPLOAD = Y.OFS.RESPONSE
    Y.STATUS.UPLOAD  = Y.OFS.RESPONSE[',',1,1]['/',3,1]
    
    IF Y.STATUS.UPLOAD EQ '1' THEN
         Y.STATUS.UPLOAD  = "Berhasil"
    END ELSE
	 Y.STATUS.UPLOAD  = "Gagal"
         Y.MESSAGE.UPLOAD = Y.OFS.RESPONSE[',',2,1]
    END

RETURN
*-----------------------------------------------------------------------------
WRITE.OUTPUT:
*-----------------------------------------------------------------------------
    CALL F.READ(FN.BTPNS.TH.REPORT.SVS.CLOSE,Y.ID.IM.DOCUMENT.IMAGE,R.BTPNS.TH.REPORT.SVS.CLOSE,F.BTPNS.TH.REPORT.SVS.CLOSE,ERR.BTPNS.TH.REPORT.SVS.CLOSE)
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.ACCOUNT.ID>                = Y.AA.ID
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.STATUS.REVERSE.IMAGE>      = Y.STATUS.IMAGE 
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.REVERSE.IMAGE.ERROR>       = Y.MESSAGE.IMAGE
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.STATUS.REVERSE.UPLOAD>     = Y.STATUS.UPLOAD
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.REVERSE.UPLOAD.ERROR>      = Y.MESSAGE.UPLOAD
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.OFS.RESPONSE.IMAGE>        = Y.OFS.RESPONSE.IMAGE
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.OFS.RESPONSE.UPLOAD>       = Y.OFS.RESPONSE.UPLOAD

    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.DATE.TIME>                 = Y.DATE.TIME
    R.BTPNS.TH.REPORT.SVS.CLOSE<CLOSE.SVS.CO.CODE>                   = Y.CO.CODE

    CALL F.WRITE(FN.BTPNS.TH.REPORT.SVS.CLOSE,Y.ID.IM.DOCUMENT.IMAGE,R.BTPNS.TH.REPORT.SVS.CLOSE)
RETURN
*-----------------------------------------------------------------------------
DELETE.QUEUE:
*-----------------------------------------------------------------------------
    Y.AA.ID.HIS = Y.AA.ID:";1"
    CALL F.READ(FN.BTPNS.TH.QUEUE.CLOSE.SVS,Y.AA.ID,R.BTPNS.TH.QUEUE.CLOSE.SVS,F.BTPNS.TH.QUEUE.CLOSE.SVS,ERR.BTPNS.TH.QUEUE.CLOSE.SVS)
    CALL F.WRITE(FN.BTPNS.TH.QUEUE.CLOSE.SVS.HIS,Y.AA.ID.HIS,R.BTPNS.TH.QUEUE.CLOSE.SVS)
    CALL F.DELETE(FN.BTPNS.TH.QUEUE.CLOSE.SVS,Y.AA.ID)

RETURN
*-----------------------------------------------------------------------------
END