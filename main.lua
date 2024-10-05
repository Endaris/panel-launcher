require("lldebugger").start()
local launcher = require("launcher")

local currentCursor = love.mouse.getCursor()
function love.load(arg)
  local waitCursor = love.mouse.getSystemCursor("wait")
  love.mouse.setCursor(waitCursor)

  launcher.initialize()
end

function love.update()
  if not launcher.update() then
    love.mouse.setCursor(currentCursor)
    launcher.launch()
    love.event.quit()
  end
end