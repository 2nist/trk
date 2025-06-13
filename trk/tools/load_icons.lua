-- load_icons.lua
function LoadIcons()
  local icon_dir = "lucide_icons/"
  return {
    search = reaper.ImGui_CreateImageFromFile(icon_dir .. "search.png"),
    play = reaper.ImGui_CreateImageFromFile(icon_dir .. "square-play.png"),
    key = reaper.ImGui_CreateImageFromFile(icon_dir .. "key-square.png"),
    check = reaper.ImGui_CreateImageFromFile(icon_dir .. "ticket-check.png"),
    folder = reaper.ImGui_CreateImageFromFile(icon_dir .. "folder-search.png"),
    bolt = reaper.ImGui_CreateImageFromFile(icon_dir .. "bolt.png"),
    chevron_down = reaper.ImGui_CreateImageFromFile(icon_dir .. "chevron-down.png"),
    clipboard_plus = reaper.ImGui_CreateImageFromFile(icon_dir .. "clipboard-plus.png"),
    file_music = reaper.ImGui_CreateImageFromFile(icon_dir .. "file-music.png"),
    x = reaper.ImGui_CreateImageFromFile(icon_dir .. "x.png")
  }
end
