*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.ENR.DOWNLOAD.FILE(valOutput)
*-----------------------------------------------------------------------------
* Developer Name : Moh Rizki Kurniaiwan
* Description    : Nofile routine for download file
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Developer Name     :
* Development Date   :  
* Description        : 
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
	$INSERT I_F.BTPNS.TL.BIFAST.UPLOAD.NAU
	$INSERT I_F.FUNDS.TRANSFER
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    
	GOSUB Initialise

    RETURN

*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------
   
    selFields = ''
    selFields<-1> = "TYPE":@VM:"TYPE"
    selFields<-1> = "FOLDER":@VM:"FOLDER"
    selFields<-1> = "FILE.ID":@VM:"FILE.ID"
    selFields<-1> = "SORT.MODIFIED":@VM:"SORT.MODIFIED"
    selFields<-1> = "DEFINE.FOLDER":@VM:"DEFINE.FOLDER"

    valOutput = '' ; Y.ERROR = ''
    vType = "" ; vFolder = "" ; vFile = "" ; vSort = ""
    selFieldsCnt = DCOUNT(selFields,@FM)

    FOR index = 1 TO selFieldsCnt
        selFld = selFields<index,1>
        selFmt = selFields<index,2>

        LOCATE selFld IN D.FIELDS<1> SETTING LOC.POS ELSE CONTINUE

        operPos = D.LOGICAL.OPERANDS<LOC.POS>
        selectOperator = OPERAND.LIST<operPos>
        rangeValue = D.RANGE.AND.VALUE<LOC.POS>

        BEGIN CASE
        CASE selFld EQ 'TYPE'
            vType = DOWNCASE(rangeValue)
        CASE selFld EQ 'FOLDER'
            vFolder = rangeValue
        CASE selFld EQ 'FILE.ID'
            vFile = rangeValue
        CASE selFld EQ 'SORT.MODIFIED'
            vSort = rangeValue
        CASE selFld EQ "DEFINE.FOLDER"
            vLinkFolder = rangeValue
        END CASE
    NEXT index

    
    IF NOT(vFolder) THEN
        ENQ.ERROR = "FOLDER is mandatory selection criteria"
    END ELSE        
        GETENV('T24_HOME', t24Home)
        CONVERT "\" TO "/" IN t24Home
        fnFolder         = t24Home : "/APPSHARED.BP/" : vLinkFolder : "/" : vFolder

        OPEN fnFolder TO fvFolder THEN
            CLOSE fvFolder
            queryCmd    = "SELECT " : fnFolder
            queryList   = ""
            noList      = ""
            CALL EB.READLIST(queryCmd, queryList, '', noList, '')
            IF noList LT 1 THEN
                ENQ.ERROR    = vFolder : " is empty"
            END ELSE
                GOSUB PutData
            END
        END ELSE
            ENQ.ERROR   = "Directory/folder " : vFolder : " is not exist"
        END
    END

	RETURN	
	
*-----------------------------------------------------------------------------
PutData:
*-----------------------------------------------------------------------------
 
    
    IF NOT(selSortModified) THEN queryList  = SORT(queryList)
    IF RIGHT(vFolder,1) NE "/" THEN
        vFolderName  = fnFolder : "/"
    END ELSE
        vFolderName  = fnFolder
    END

    FOR index = noList TO 1 STEP -1
        vline   = ""
        catItem = ""
        vItemName   = queryList<index>
        catItem = vItemName
        vItem = vFolderName:vItemName
*        checkItem = OCONV( DIR(vItem), 'MCP' )
        checkItem   = DIR(vItem)
        checkItem = CHANGE(checkItem, "^",@FM)
        sizeItem = checkItem<1>
        dateItem = checkItem<2>
        timeItem = checkItem<3>
        dirItem = checkItem<4>
        dateItem = CHANGE(OCONV(dateItem, 'D4/' ),"/","")
        dateItem = dateItem[5,4]:dateItem[3,2]:dateItem[1,2]
        timeItem = OCONV(timeItem, 'MTS')
        timeItemSort = CHANGE(timeItem,":","")
        typeItem = FIELD(vItemName, ".", DCOUNT(vItemName, "."))
        IF dirItem THEN
            catItem = ""
            dirItem = "Directory"
        END ELSE
            dirItem = "File"
        END

        downloadPath    = vLinkFolder : "/" : vFolder : "/" : vItemName
        showPath        = "../UD/APPSHARED.BP/" : vLinkFolder : "/" : vFolder : ">" : vItemName

        IF vType AND vType NE typeItem THEN CONTINUE
        IF vFile AND COUNT(UPCASE(vItemName),UPCASE(vFile)) LT 1 THEN CONTINUE

        vSorter = dateItem:timeItemSort:typeItem:vItemName:vFolder

        vLine = vSorter
        vLine := "|" : typeItem
        vLine := "|" : vItemName
        vLine := "|" : vFolder
        vLine := "|" : sizeItem
        vLine := "|" : dateItem
        vLine := "|" : timeItem
        vLine := "|" : dirItem
        vLine := "|" : catItem
        vLine := "|" : downloadPath
        vLine := "|" : showPath

        FINDSTR vFile IN vItemName SETTING vPosF, vPosV, vPosS THEN
            valOutput<-1> = vLine
        END
            
    NEXT index

    IF vSort THEN
        ENQ.DATA.SORTED = SORT(valOutput)
        valOutput = ""
        FOR index=DCOUNT(ENQ.DATA.SORTED,@FM) TO 1 STEP -1
            valOutput<-1> = ENQ.DATA.SORTED<index>
        NEXT index
    END
	
    RETURN
*-----------------------------------------------------------------------------
END
