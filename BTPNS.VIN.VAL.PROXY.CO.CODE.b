    SUBROUTINE BTPNS.VIN.VAL.PROXY.CO.CODE
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 20 Agustus 2022
* Description        : Routine to proxy activity must in company account cannot interbranch
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           :
* Modified by    :
* Description    :
* No Log         :
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.BTPNS.TH.BIFAST.PROXY.MGMT
    $INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.POSTING.RESTRICT
    $INSERT I_F.SECTOR
    $INSERT I_F.CATEGORY
    $INSERT I_F.EB.ERROR
    
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    FN.ACC = 'F.ACCOUNT'
    F.ACC = ''
    CALL OPF(FN.ACC,F.ACC)

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

   Y.ACC.ID   = R.NEW(BF.PM.ACCOUNT.NO)

   CALL F.READ(FN.ACC, Y.ACC.ID, R.ACC, F.ACC, ACC.ERR)
   Y.COMPANY.CODE = R.ACC<AC.CO.CODE>
   IF Y.COMPANY.CODE NE ID.COMPANY THEN
        ETEXT = "EB-DIFF.CO.CODE"
        CALL STORE.END.ERROR
   END

   RETURN
*-----------------------------------------------------------------------------
END


    

    