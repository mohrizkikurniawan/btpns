	SUBROUTINE BTPNS.MT.GENERATE.REPORT.NISBAH(Y.AA.ID)
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 13 September 2022
* Description        : ROutine multithread for generate report changes nisbah in deposits
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description    : 
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_TSA.COMMON
    $INSERT I_BATCH.FILES
	$INSERT I_BTPNS.MT.GENERATE.REPORT.NISBAH.COMMON
	$INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
	$INSERT	I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.BTPNS.TH.POOL.NISBAH.DEP
	
	GOSUB PROCESS
	
	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.AA.ID  = FIELD(Y.AA.ID, "-", 1)
	CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ERR.AA.ARRANGEMENT)
	Y.PRODUCT.LINE     = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.LINE>
	Y.LINKED.APPL.ID    = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
	Y.CO.CODE    	= R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
	
	CALL F.READ(FN.EB.CONTRACT.BALANCES, Y.LINKED.APPL.ID, R.EB.CONTRACT.BALANCES, F.EB.CONTRACT.BALANCES, ERR.EB.CONTRACT.BALANCES)
    Y.AMOUNT         	= R.EB.CONTRACT.BALANCES<ECB.WORKING.BALANCE>
	
	CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.ACCOUNT.DETAILS.ERR)
	Y.RENEWAL.DATE  	= R.AA.ACCOUNT.DETAILS<AA.AD.RENEWAL.DATE>
	
	CALL F.READ(FN.ACCOUNT,Y.LINKED.APPL.ID,REC.ACCOUNT,F.ACCOUNT,ERR.AC)
	Y.ACCOUNT.OFFICER   = REC.ACCOUNT<AC.ACCOUNT.OFFICER>
	
	CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID, "TERM.AMOUNT", "COMMITMENT", "", Y.PROPERTY.IDS, R.AA.TERM.AMOUNT, READ.ERR)
    R.AA.TERM.AMOUNT = RAISE(R.AA.TERM.AMOUNT)
	
	Y.MATURITY.DATE    	= R.AA.TERM.AMOUNT<AA.AMT.MATURITY.DATE>
	Y.L.MAT.MODE    = R.AA.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.L.MAT.MODE.POS>
	Y.L.ORG.MAT.DATE    = R.AA.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.L.ORG.MAT.DATE.POS>
	
	IF Y.PRODUCT.LINE EQ 'DEPOSITS' THEN

    SEL.CMD  = "SELECT ":FN.AA.ARR.ACCOUNT:" WITH @ID LIKE ":Y.AA.ID:"... AND ( ACTIVITY EQ 'DEPOSITS-NEW-ARRANGEMENT' 'DEPOSITS-TAKEOVER-ARRANGEMENT' 'DEPOSITS-CHANGE.CUR.NISBAH-ACCOUNT' 'DEPOSITS-CHANGE.FUT.NISBAH-ACCOUNT' )"
    SEL.LIST = ''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',SEL.CNT,ERR.ACCT)

    FOR I = 1 TO SEL.CNT
    	Y.AA.ACCT.ID = SEL.LIST<I>
    	
    	GOSUB PROCESS.AA
    	
    	Y.BEFORE.NISBA = Y.L.FINAL.NISBA
    NEXT I
	END

    RETURN
*-----------------------------------------------------------------------------
PROCESS.AA:
*-----------------------------------------------------------------------------
	CALL F.READ(FN.AA.ARR.ACCOUNT,Y.AA.ACCT.ID,R.AA.ARR.ACCOUNT,F.AA.ARR.ACCOUNT,ERR.AA.ARR.ACCOUNT)
	Y.CATEGORY       	= R.AA.ARR.ACCOUNT<AA.AC.CATEGORY>
	Y.USER.ID   	  	= R.AA.ARR.ACCOUNT<AA.AC.INPUTTER>
	Y.AUTHORISER.ID   	= R.AA.ARR.ACCOUNT<AA.AC.AUTHORISER>
    Y.DATE.TIME1        = R.AA.ARR.ACCOUNT<AA.AC.DATE.TIME>
    Y.TIME.RECORD       = Y.DATE.TIME1[7,2]:":":Y.DATE.TIME1[9,2]
	Y.CO.CODE       	= R.AA.ARR.ACCOUNT<AA.AC.CO.CODE>
	Y.ID.COMP.3    	= FIELD(Y.AA.ACCT.ID, "-", 3)
	Y.EFFECTIVE.DATE  	= FIELD(Y.ID.COMP.3, ".",1)
	Y.COMP.SEQ    	= FIELD(Y.ID.COMP.3, ".",2)                
	Y.L.FINAL.NISBA	  	= R.AA.ARR.ACCOUNT<AA.AC.LOCAL.REF,Y.L.FINAL.NISBA.POS>
	Y.L.BILYET.NUM	  	= R.AA.ARR.ACCOUNT<AA.AC.LOCAL.REF,Y.L.BILYET.NUM.POS>
	Y.ATI.JOINT.NAME  	= R.AA.ARR.ACCOUNT<AA.AC.LOCAL.REF,Y.ATI.JOINT.NAME.POS>
	
	CALL F.READ(FN.AA.ACTIVITY.HISTORY,Y.AA.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,ERR.AA.ACTIVITY.HISTORY)	;*20200320	SAI
	
	FIND Y.EFFECTIVE.DATE IN R.AA.ACTIVITY.HISTORY SETTING Y.POS.FM, Y.POS.VM, Y.POS.SM THEN    
         Y.SYSTEM.DATE.HIS    = R.AA.ACTIVITY.HISTORY<AA.AH.SYSTEM.DATE, Y.POS.VM>
         Y.SM        	= DCOUNT(Y.SYSTEM.DATE.HIS,SM) + 1 - Y.COMP.SEQ
         Y.DATE.CHG        = R.AA.ACTIVITY.HISTORY<AA.AH.SYSTEM.DATE,Y.POS.VM,Y.SM>
	END
        
	Y.FLAG = 0
	
	IF Y.FLAG EQ 0 AND Y.BEFORE.NISBA AND Y.BEFORE.NISBA NE Y.L.FINAL.NISBA THEN
            GOSUB WRITE.OUTPUT
	END
    
	RETURN
*-----------------------------------------------------------------------------
WRITE.OUTPUT:
*-----------------------------------------------------------------------------

    Y.ID.STAGING=Y.AA.ID:"*":Y.DATE.CHG:"*":Y.EFFECTIVE.DATE:"*":Y.COMP.SEQ
    CALL F.READ(FN.BTPNS.TH.POOL.NISBAH.DEP,Y.ID.STAGING,R.BTPNS.TH.POOL.NISBAH.DEP,F.BTPNS.TH.POOL.NISBAH.DEP,ERR.BTPNS.TH.POOL.NISBAH.DEP)
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.AA.ID>           = Y.AA.ID 
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.CATEGORY>        = Y.CATEGORY
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.CHANGE.DATE>     = Y.DATE.CHG
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.L.BILYET.NUM>    = Y.L.BILYET.NUM
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.ATI.JOINT.NAME>  = Y.ATI.JOINT.NAME
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.NISBAH.BEFORE>   = Y.BEFORE.NISBA
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.NISBAH.AFTER>    = Y.L.FINAL.NISBA
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.EFFECTIVE.DATE>  = Y.EFFECTIVE.DATE
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.PRINCIPAL>       = Y.AMOUNT
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.USER.INPUT>      = Y.USER.ID
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.USER.AUTHORISER> = Y.AUTHORISER.ID
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.ACCOUNT.OFFICER> = Y.ACCOUNT.OFFICER
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.CO.CODE>         = Y.CO.CODE
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.TIME.AUTHOR>     = Y.TIME.RECORD
    
    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]
    R.BTPNS.TH.POOL.NISBAH.DEP<POOL.NIS.DATE.TIME>         = Y.DATE.TIME

    CALL F.WRITE(FN.BTPNS.TH.POOL.NISBAH.DEP,Y.ID.STAGING,R.BTPNS.TH.POOL.NISBAH.DEP)
    
    RETURN
*-----------------------------------------------------------------------------
END