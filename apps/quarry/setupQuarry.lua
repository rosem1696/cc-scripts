-- https://pastebin.com/w7UviVfa
-- pastebin get w7UviVfa setup
-- Download from github

local UrlBase = 'https://raw.githubusercontent.com/rosem1696/cc-scripts/main'

local function download(name, path)
    print(string.format('Downloading %s', name))
    local file = fs.open(name, 'w')
    local contents = http.get(string.format('%s/%s/%s.lua', UrlBase, path, name)).readAll()
    file.write(contents)
    file.close()
    write('done!')
end

local function main()
    download('turtleMover', 'lib/turtle')
    download('turtleInventory', 'lib/turtle')
    download('log', 'lib/misc')

    download('quarry', 'apps/quarry')

    print('Download successful!')
end

main()
