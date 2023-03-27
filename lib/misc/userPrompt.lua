local userPrompt = {}

function userPrompt.getNumber(description, default, min, max)
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
        if input == '' and default then
            return default
        end

        print('')

        local inputNum = tonumber(input)
        if not inputNum then
            printError('Input is not a number')
        elseif (max and max < inputNum) or (min and min > inputNum) then
            printError('Input is not within range')
        else
            return inputNum
        end

        print('')
    end
end

function userPrompt.getYesNo(description, default)
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

        print('')

        local input = io.read('l')
        if input == '' and default ~= nil then
            return default
        elseif input == 'y' or input == 'Y' then
            return true
        elseif input == 'n' or input == 'N' then
            return false
        else
            printError('Input is invalid')
        end

        print('')
    end
end

return userPrompt
