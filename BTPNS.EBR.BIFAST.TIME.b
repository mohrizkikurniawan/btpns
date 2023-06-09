    SUBROUTINE BTPNS.EBR.BIFAST.TIME(ENQ.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221115
* Description        : Build routine for selection enq incoming (morning/afternoon)
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
	$INSERT I_F.IDCH.RTGS.BANK.CODE.G2

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    
    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------


    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
   
    FIND "B.REAL.DATE" IN ENQ.DATA<2> SETTING POSF, POSV, POSS THEN
        timeTransSel = ENQ.DATA<3,POSV>
        timeTransVal = ENQ.DATA<4,POSV>
    END

    flagCheck   = 0
    selTimeCnt  = DCOUNT(timeTransVal, " ")

    BEGIN CASE
	CASE timeTransSel EQ "EQ" AND selTimeCnt EQ 1
        flagCheck   = 1
        selTimeCnt = LEN(timeTransVal)
        IF selTimeCnt EQ 8 THEN
            startTime = timeTransVal[3,8] : "0000"
            endTime   = timeTransVal[3,8] : "2359"
            selTime   = startTime : " " : endTime
 		    ENQ.DATA<2,POSV>	= "DATE.TIME"
            ENQ.DATA<3,POSV>	= "RG"
		    ENQ.DATA<4,POSV>	= selTime     
        END ELSE
            GOSUB ErrorProcess
        END   
		RETURN
	CASE timeTransSel EQ "RG" AND selTimeCnt EQ 2
        flagCheck   = 1
        startTime = FIELD(timeTransVal, " ", 1)[3,8] : "0000"
        startTimeCnt = LEN(FIELD(timeTransVal, " ", 1))
        endTime   = FIELD(timeTransVal, " ", 2)[3,8] : "2359"
        endTimeCnt  = LEN(FIELD(timeTransVal, " ", 2))
        selTimeCnt = LEN(timeTransVal)
*        IF startTimeCnt EQ 8 AND endTimeCnt EQ 8 THEN
        IF selTimeCnt EQ 17 THEN
            selTime   = startTime : " " : endTime
            ENQ.DATA<2,POSV>	= "DATE.TIME"
            ENQ.DATA<3,POSV>	= timeTransSel
		    ENQ.DATA<4,POSV>	= selTime 
        END ELSE
            GOSUB ErrorProcess
        END
		RETURN
	END CASE   

    IF flagCheck EQ 0 THEN GOSUB ErrorProcess                                     
	
	RETURN
*-----------------------------------------------------------------------------
ErrorProcess:
*-----------------------------------------------------------------------------
                                       
	    ENQ.DATA<2,POSV>	= "DATE.TIME"
        ENQ.DATA<3,POSV>	= "EQ"
		ENQ.DATA<4,POSV>	= "99999999"
	RETURN
*-----------------------------------------------------------------------------
END

