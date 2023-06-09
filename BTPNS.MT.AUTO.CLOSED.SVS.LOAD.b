	SUBROUTINE BTPNS.MT.AUTO.CLOSED.SVS.LOAD
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
    $INSERT I_GTS.COMMON
    $INSERT I_TSA.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_BTPNS.MT.AUTO.CLOSED.SVS.COMMON
    
    FN.AA.ARRANGEMENT    = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT    = ''
    CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
    
    FN.IM.DOCUMENT.IMAGE = "F.IM.DOCUMENT.IMAGE"
    F.IM.DOCUMENT.IMAGE  = ""
    CALL OPF(FN.IM.DOCUMENT.IMAGE,F.IM.DOCUMENT.IMAGE)

    FN.IM.DOCUMENT.UPLOAD = "F.IM.DOCUMENT.UPLOAD"
    F.IM.DOCUMENT.UPLOAD  = ""
    CALL OPF(FN.IM.DOCUMENT.UPLOAD,F.IM.DOCUMENT.UPLOAD)

    FN.ACCOUNT    = 'F.ACCOUNT'
    F.ACCOUNT    = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)
    
    FN.BTPNS.TH.REPORT.SVS.CLOSE = "F.BTPNS.TH.REPORT.SVS.CLOSE"
    F.BTPNS.TH.REPORT.SVS.CLOSE  = ""
    CALL OPF(FN.BTPNS.TH.REPORT.SVS.CLOSE,F.BTPNS.TH.REPORT.SVS.CLOSE)

    FN.BTPNS.TH.QUEUE.CLOSE.SVS = "F.BTPNS.TH.QUEUE.CLOSE.SVS"
    F.BTPNS.TH.QUEUE.CLOSE.SVS  = ""
    CALL OPF(FN.BTPNS.TH.QUEUE.CLOSE.SVS,F.BTPNS.TH.QUEUE.CLOSE.SVS)

    FN.BTPNS.TH.QUEUE.CLOSE.SVS.HIS = "F.BTPNS.TH.QUEUE.CLOSE.SVS$HIS"
    F.BTPNS.TH.QUEUE.CLOSE.SVS.HIS  = ""
    CALL OPF(FN.BTPNS.TH.QUEUE.CLOSE.SVS.HIS,F.BTPNS.TH.QUEUE.CLOSE.SVS.HIS)

    FN.ALT.ACT = 'F.ALTERNATE.ACCOUNT'
    F.ALT.ACT  = ''
    CALL OPF(FN.ALT.ACT, F.ALT.ACT)
    
    RETURN
END