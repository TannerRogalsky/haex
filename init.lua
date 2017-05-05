table.insert(arg, 1, ".")

local love = package.loadlib('/Applications/love.app/Contents/Frameworks/love.framework/Versions/A/love', 'luaopen_love')
package.preload.love = love

-- for k,v in pairs(love()) do
--   print(k,v)
-- end
love()
return require('love.boot')()
