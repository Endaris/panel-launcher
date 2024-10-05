local https = require("https")

--[[
Expected server directory structure:

downloads/
  love
    Linux
      1.AppImage
    OS X
      1.app
    Windows
      1.zip
  updater
    1.love
  updates
    stable
      panel-yyyy-MM-dd_hh-mm-ss.zip
    beta
      panel-beta-yyyy-MM-dd_hh-mm-ss.zip
  launcher
    panel-attack.AppImage
    panel-attack.app
    panel-attack.zip

]]


local network = {
  ongoingDownloads = {}
}

local function getUrl(directory, OS)
  local url = "http://panelattack.com/downloads/" .. directory
  if OS then
    url = url .. "/" .. OS
  end
  return url
end

function network.getAvailableVersion(directory, OS, suffix)
  local version = 0
  local url = getUrl(directory, OS)

  local status, body, headers = https.request(url, {method = "GET", headers = { ["user-agent"] = love.filesystem.getIdentity()}})

  if body and status == 200 then
    local patternMatch = 'href="%d+' .. suffix .. '"'
    for w in body:gmatch(patternMatch) do
      local versionString = w:gsub(suffix .. '"', ""):gsub('href="', "")
      version = math.max(version, tonumber(versionString) or 0)
    end
    return version
  else
    -- couldn't retrieve the desired data
    return nil
  end
end

function network.download(directory, OS, version, suffix)
  local thread = love.thread.newThread("downloadThread.lua")
  local url = getUrl(directory, OS) .. "/" .. version .. suffix
  local destination = "downloads/" .. directory .. "/" .. version .. suffix
  thread:start(url, destination)
  network.ongoingDownloads[#network.ongoingDownloads+1] = {
    url = url,
    path = destination,
    directory = directory,
    version = version,
    suffix = suffix,
  }
end

function network.setDownloadSuccessCallback(func)
  network.successCallback = func
end

-- returns true if there are still network processes ongoing
function network.update()
  for i = #network.ongoingDownloads, 1, -1 do
    local download = network.ongoingDownloads[i]
    local result = love.thread.getChannel(download.url):pop()
    if result then
      network.ongoingDownloads[i] = nil
      if result.success and network.successCallback then
        network.successCallback(download.path, download.directory, download.version, download.suffix)
      end
    end
  end

  return #network.ongoingDownloads ~= 0
end

return network