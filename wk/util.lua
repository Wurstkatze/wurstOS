-- API for utility stuff

function colorPrint(text, textColor, backgroundColor)
    if textColor then
        term.setTextColor(textColor)
    end
    if backgroundColor then
        term.setBackgroundColor(backgroundColor)
    end
    print(text)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end

function clear()
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end
