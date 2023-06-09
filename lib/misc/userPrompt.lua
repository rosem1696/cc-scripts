local userPrompt = {}

function userPrompt.getNumber(description, default, min, max)
    term.clear()
    while true do
        print(description)

        if max and min then
            print(string.format('Limit: %d <= n <= %d', min, max))
        elseif max then
            print(string.format('Limit: n <= %d', max))
        elseif min then
            print(string.format('Limit: n >= %d', min))
        end

        print('')

        if default then
            write(string.format('Enter number <default = %d>: ', default))
        else
            write('Enter number: ')
        end

        local input = io.read('l')
        term.clear()

        if input == '' and default then
            return default
        end

        local inputNum = tonumber(input)
        if not inputNum then
            printError('Input is not a number\n')
        elseif (max and max < inputNum) or (min and min > inputNum) then
            printError('Input is not within range\n')
        else
            return inputNum
        end
    end
end

function userPrompt.getYesNo(description, default)
    term.clear()
    while (true) do
        print(description)
        print('')

        local defaultString = ''
        if default ~= nil then
            if default then defaultString = 'y' else defaultString = 'n' end
            write(string.format('Enter y/n <default = %s>: ', defaultString))
        else
            write('Enter y/n: ')
        end

        local input = io.read('l')
        term.clear()

        if input == '' and default ~= nil then
            return default
        elseif input == 'y' or input == 'Y' then
            return true
        elseif input == 'n' or input == 'N' then
            return false
        else
            printError('Input is invalid\n')
        end
    end
end

function userPrompt.getString(description, default)
    term.clear()
    while (true) do
        print(description)
        print('')
        if default then
            write(string.format('Enter text<default = %s>\n: ', default))
        else
            write('Enter text\n: ')
        end

        local input = io.read('l')
        term.clear()

        if input == '' and default ~= nil then
            return default
        elseif input ~= '' then
            return input
        else
            printError('Input is invalid\n')
        end
    end
end

function userPrompt.getSelection(description, list, defaultIndex)
    term.clear()
    while (true) do
        print(description)
        print('')
        for i, item in pairs(list) do
            print(string.format('%d - %s', i, item))
        end

        if defaultIndex then
            print(string.format('<default = %s>', list[defaultIndex]))
        end
        write('Select: ')

        local input = io.read('l')
        term.clear()

        if input == '' and defaultIndex ~= nil then
            return list[defaultIndex]
        end

        local index = tonumber(input)

        if not index or index < 1 or index > #list then
            printError('Invalid selection\n')
        else
            return list[index]
        end
    end
end

function userPrompt.pressEnter()
    print('')
    print('Press Enter to Continue')
    print('')

    local n = io.read('l')
    term.clear()
end

return userPrompt
