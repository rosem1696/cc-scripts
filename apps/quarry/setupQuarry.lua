-- https://pastebin.com/w7UviVfa
-- pastebin get w7UviVfa setup
-- Download from github

local UrlBase = 'https://raw.githubusercontent.com/rosem1696/cc-scripts/main'

local function download(name, path)
    write(string.format('Downloading %s - ', name))
    local file = fs.open(name, 'w')
    local contents = http.get(string.format('%s/%s/%s.lua', UrlBase, path, name)).readAll()
    file.write(contents)
    file.close()
    print('done!')
end

local function main()
    -- misc
    download('log', 'lib/misc')
    download('userPrompt', 'lib/misc')
    -- turtle
    download('turtleConst', 'lib/turtle')
    download('turtleMover', 'lib/turtle')
    download('turtleInventory', 'lib/turtle')
    --inventory
    download('inventory', 'lib/inventory')


    download('quarry', 'apps/quarry')

    print('Download finished!')
end

main()
