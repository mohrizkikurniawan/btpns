    SUBROUTINE BTPNS.CONV.DATE.TIME(Y.DATE.TIME)

    $INSERT I_COMMON
    $INSERT I_EQUATE

    valueDateTime = '20' : Y.DATE.TIME
    formatDate    = OCONV(ICONV(valueDateTime[1,8], "D"), 'D')
    formatTime    = valueDateTime[9,2] : ":" : valueDateTime[11,2]

    Y.DATE.TIME   = formatDate : " " : formatTime


    RETURN
END
