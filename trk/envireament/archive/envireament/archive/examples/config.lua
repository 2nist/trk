-- config.lua
-- Configuration for Songbase application
local M = {}

--- Initialize configuration
-- @return table config
function M.init()
  local base = reaper.GetResourcePath() .. "/Scripts/songbase"
  return {
    paths = {
      base = base,
      datasets = base .. "/datasets",
      ui = base .. "/ui",
      data = base .. "/data"
    },
    ui = {
      default_view = "song_browser",
      window_width = 800,
      window_height = 600
    }
  }
end

return M
