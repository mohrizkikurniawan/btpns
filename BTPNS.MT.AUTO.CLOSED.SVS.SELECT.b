	SUBROUTINE BTPNS.MT.AUTO.CLOSED.SVS.SELECT
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

    DEBUG
    SEL.CMD  = "SELECT ":FN.BTPNS.TH.QUEUE.CLOSE.SVS
    SEL.LIST = ''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'','','')
    CALL BATCH.BUILD.LIST("",SEL.LIST)
	
    RETURN
END