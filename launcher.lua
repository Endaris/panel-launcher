local versions = require("version")
local launcher = { OS = love.system.getOS()}
local network = require("network")
require("love-zip")

-- copies a file from the given source to the given destination
local function copyFile(source, destination)
  local success
  local content, err = love.filesystem.read(source)
  success, err = love.filesystem.write(destination, content)
  return success, err
end

local function copyDirectory(source, destination)
  for i, file in ipairs(love.filesystem.getDirectoryItems(source)) do
    copyFile(source .. "/" .. file, destination .. "/" .. file)
  end
end

local function clearDirectory(directory)
  for i, file in ipairs(love.filesystem.getDirectoryItems(directory)) do
    love.filesystem.remove(directory .. "/" .. file)
  end
end

local function createDirectory(directory)
  if not love.filesystem.getInfo(directory, "directory") then
    love.filesystem.createDirectory(directory)
  end
end

function launcher.createDirectories()
  createDirectory("launcher")
  createDirectory("launcher/love")
  createDirectory("launcher/updater")

  createDirectory("downloads")
  createDirectory("downloads/love")
  createDirectory("downloads/updater")


  if not love.filesystem.exists("launcher/love/love" .. launcher.getLoveSuffix()) then
    launcher.onDownloaded("embeds/love/love" .. launcher.getLoveSuffix(), "love", 1, launcher.getLoveSuffix())
  end

  if not love.filesystem.exists("launcher/updater/updater.love") then
    clearDirectory("launcher/updater")
    launcher.onDownloaded("embeds/updater/updater.love", "updater", 1, ".love")
  end

end

function launcher.getLoveSuffix()
  if launcher.OS == "Linux" then
    return ".AppImage"
  elseif launcher.OS == "OS X" then
    return ".zip"
  elseif launcher.OS == "Windows" then
    return ".zip"
  end
end

function launcher.initialize()
  launcher.createDirectories()
  network.setDownloadSuccessCallback(launcher.onDownloaded)
  local loveVersion = network.getAvailableVersion("love", launcher.OS, launcher.getLoveSuffix())
  if (loveVersion or 0) > versions.love then
    network.download("love", launcher.OS, loveVersion, launcher.getLoveSuffix())
  end

  local updaterVersion = network.getAvailableVersion("updater", nil, ".love")
  if (updaterVersion or 0) > versions.updater then
    network.download("updater", nil, updaterVersion, ".love")
  end
end

function launcher.writeVersions()
  local s = "local versions = { love = " .. versions.love ..
                             ", updater = " .. versions.updater ..
                              "} return versions"
  love.filesystem.write("version.lua", s)
end

function launcher.onDownloaded(path, directory, version, suffix)
  clearDirectory("launcher/" .. directory)

  if directory == "love" then
    if launcher.OS == "Windows" then
      love.zip:decompress(path, "launcher/" .. directory)
    elseif launcher.OS == "OS X" then
      love.zip:decompress(path, "launcher/" .. directory)
    elseif launcher.OS == "Linux" then
      copyFile(path, "launcher/" .. directory .. "/" .. directory .. suffix)
    end
  elseif directory == "updater" then
    copyFile(path, "launcher/" .. directory .. "/" .. directory .. suffix)
  end
  love.filesystem.remove(path)
  versions[directory] = version
  launcher.writeVersions()
end

-- returns true if the launcher is still updating
function launcher.update()
  return network.update()
end

function launcher.launch()
  local saveDir = love.filesystem.getSaveDirectory()
  local updater
  local loveApp

  if launcher.OS == "Linux" then
    loveApp = "'" .. saveDir .. "/launcher/love/love.AppImage'"
    updater = "'" .. saveDir .. "/launcher/updater/updater.love'"
    os.execute("chmod +x " .. loveApp)
    os.execute(loveApp .. ' ' .. updater)
  elseif launcher.OS == "OS X" then
    loveApp = "'" .. saveDir .. "/launcher/love/love.app'"
    updater = "'" .. saveDir .. "/launcher/updater/updater.love'"
    --os.execute("chmod +x " .. loveApp)
    os.execute("open " .. loveApp .. ' --args ' .. updater)
  elseif launcher.OS == "Windows" then
    loveApp = "'" .. saveDir .. "\\launcher\\love\\love.exe'"
    updater = "'" ..saveDir .. "\\launcher\\updater\\updater.love'"
    os.execute('start cmd /c call ' .. loveApp .. ' ' .. updater)
  end
end

return launcher