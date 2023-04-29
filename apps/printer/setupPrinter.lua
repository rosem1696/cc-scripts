-- https://pastebin.com/0gNcU8jq
-- pastebin get 0gNcU8jq setup
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
    download('boundingBox', 'lib/misc')

    -- turtle
    download('turtleConst', 'lib/turtle')
    download('turtleMover', 'lib/turtle')
    download('turtleInventory', 'lib/turtle')

    -- inventory
    download('inventory', 'lib/inventory')

    -- printer
    download('blockFilter', 'lib/printer')
    download('pattern', 'lib/printer')
    download('project', 'lib/printer')

    -- app
    download('scan', 'apps/printer')
    download('updateInk', 'apps/printer')
    download('betterUpdateInk', 'apps/printer')
    download('makeProject', 'apps/printer')
    download('projectMaterials', 'apps/printer')
    download('printer', 'apps/printer')

    print('Download finished!')
end

main()
