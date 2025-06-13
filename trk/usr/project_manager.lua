-- project_manager.lua-- UI module for managing song projects/collectionslocal ProjectManager = {}-- Import required moduleslocal config = {}pcall(function() config = require("config") end)-- Import utility moduleslocal utils_file = {}pcall(function() utils_file = require("utils.file") end)local utils_json = {}pcall(function() utils_json = require("utils.json") end)local utils_reaper = {}pcall(function() utils_reaper = require("utils.reaper") end)local Theme = {}pcall(function() Theme = require("ui.theme") end)local Widgets = {}pcall(function() Widgets = require("ui.widgets") end)-- Try to load bit operations librarylocal bitlocal successsuccess, bit = pcall(function() return require("bit") end)if not success then  -- Create simplified bitwise operations  bit = {    bor = function(a, b, ...)      local result = a + b      local args = {...}      for i=1, #args do result = result + args[i] end      return result    end  }end-- Local statelocal state = {  ctx = nil,  app_state = nil,  projects = {},  selected_project = nil,  selected_song_indices = {},  show_create_dialog = false,  show_edit_dialog = false,  show_confirm_delete = false,  show_export_dialog = false,  new_project_name = "",  new_project_description = "",  edit_project_name = "",  edit_project_description = "",  status_message = "",  last_status_time = 0,  filter_text = "",  error = nil,  export_options = {    format = 1, -- 1=JSON, 2=CSV    include_metadata = true,    include_comments = true  }}-- Initialize the modulefunction ProjectManager.init(ctx, app_state)  -- Store context and application state  state.ctx = ctx  state.app_state = app_state or {}    -- Reset state  state.projects = {}  state.selected_project = nil  state.selected_song_indices = {}  state.filter_text = ""  state.error = nil  state.export_options = {    format = 1,    include_metadata = true,    include_comments = true  }    -- Load projects  ProjectManager.load_projects()    return trueend-- Load projects from diskfunction ProjectManager.load_projects()  -- Reset projects  state.projects = {}    -- Check if file operations module is available  if not utils_file.read_file then    state.status_message = "File operations module not available"    state.last_status_time = os.time()    return false  end    -- Projects file path  local projects_path = config.paths and config.paths.data and (config.paths.data .. "/projects.json") or "projects.json"    -- Try to read projects file  local content = utils_file.read_file(projects_path)  if not content then    -- Projects file doesn't exist or couldn't be read    state.status_message = "No projects file found. Creating new one."    state.last_status_time = os.time()    return false  end    -- Try to parse JSON  local success, projects = pcall(function() return utils_json.decode(content) end)  if not success or not projects then    -- JSON parsing failed    state.status_message = "Failed to parse projects file"    state.last_status_time = os.time()    return false  end    -- Store projects  state.projects = projects    -- Check if there are any projects  if #state.projects > 0 then    -- Select first project    state.selected_project = 1  else    state.selected_project = nil  end    state.status_message = "Projects loaded"  state.last_status_time = os.time()  return trueend-- Save projects to diskfunction ProjectManager.save_projects()  -- Check if file operations module is available  if not utils_file.write_file then    state.status_message = "File operations module not available"    state.last_status_time = os.time()    return false  end    -- Projects file path  local projects_path = config.paths and config.paths.data and (config.paths.data .. "/projects.json") or "projects.json"    -- Try to encode projects as JSON  local success, content = pcall(function() return utils_json.encode(state.projects) end)  if not success or not content then    -- JSON encoding failed    state.status_message = "Failed to encode projects"    state.last_status_time = os.time()    return false  end    -- Try to write projects file  success = utils_file.write_file(projects_path, content)  if not success then    -- File write failed    state.status_message = "Failed to write projects file"    state.last_status_time = os.time()    return false  end    state.status_message = "Projects saved"  state.last_status_time = os.time()  return trueend-- Create a new projectfunction ProjectManager.create_project()  -- Check if name is empty  if state.new_project_name == "" then    state.status_message = "Project name cannot be empty"    state.last_status_time = os.time()    return false  end    -- Check if project with same name already exists  for i, project in ipairs(state.projects) do    if project.name == state.new_project_name then      state.status_message = "Project with this name already exists"      state.last_status_time = os.time()      return false    end  end    -- Create new project  local new_project = {    name = state.new_project_name,    description = state.new_project_description,    songs = {}  }    -- Add project to list  table.insert(state.projects, new_project)    -- Select the new project  state.selected_project = #state.projects    -- Clear dialog fields  state.new_project_name = ""  state.new_project_description = ""    -- Hide dialog  state.show_create_dialog = false    -- Save projects  ProjectManager.save_projects()    state.status_message = "Project created"  state.last_status_time = os.time()  return trueend-- Update project detailsfunction ProjectManager.update_project()  -- Check if a project is selected  if not state.selected_project or state.selected_project < 1 or state.selected_project > #state.projects then    state.status_message = "No project selected"    state.last_status_time = os.time()    return false  end    -- Check if name is empty  if state.edit_project_name == "" then    state.status_message = "Project name cannot be empty"    state.last_status_time = os.time()    return false  end    -- Check if project with same name already exists (excluding current project)  for i, project in ipairs(state.projects) do    if i ~= state.selected_project and project.name == state.edit_project_name then      state.status_message = "Project with this name already exists"      state.last_status_time = os.time()      return false    end  end    -- Update project  state.projects[state.selected_project].name = state.edit_project_name  state.projects[state.selected_project].description = state.edit_project_description    -- Hide dialog  state.show_edit_dialog = false    -- Save projects  ProjectManager.save_projects()    state.status_message = "Project updated"  state.last_status_time = os.time()  return trueend-- Delete projectfunction ProjectManager.delete_project()  -- Check if a project is selected  if not state.selected_project or state.selected_project < 1 or state.selected_project > #state.projects then    state.status_message = "No project selected"    state.last_status_time = os.time()    return false  end    -- Remove project  table.remove(state.projects, state.selected_project)    -- Update selected project  if #state.projects > 0 then    state.selected_project = math.min(state.selected_project, #state.projects)  else    state.selected_project = nil  end    -- Clear selected song indices  state.selected_song_indices = {}    -- Hide dialog  state.show_confirm_delete = false    -- Save projects  ProjectManager.save_projects()    state.status_message = "Project deleted"  state.last_status_time = os.time()  return trueend-- Add songs to projectfunction ProjectManager.add_songs(songs)  -- Check if a project is selected  if not state.selected_project or state.selected_project < 1 or state.selected_project > #state.projects then    state.status_message = "No project selected"    state.last_status_time = os.time()    return false  end    -- Check if songs is a table  if type(songs) ~= "table" then    state.status_message = "Invalid songs data"    state.last_status_time = os.time()    return false  end    -- Add songs to project  local project = state.projects[state.selected_project]  local count = 0    for _, song in ipairs(songs) do    -- Check if song is already in project    local exists = false    for _, existing in ipairs(project.songs) do      if existing.path == song.path then        exists = true        break      end    end        -- Add song if it doesn't exist    if not exists then      table.insert(project.songs, song)      count = count + 1    end  end    -- Save projects  ProjectManager.save_projects()    state.status_message = count .. " song(s) added to project"  state.last_status_time = os.time()  return trueend-- Remove songs from projectfunction ProjectManager.remove_songs()  -- Check if a project is selected  if not state.selected_project or state.selected_project < 1 or state.selected_project > #state.projects then    state.status_message = "No project selected"    state.last_status_time = os.time()    return false  end    -- Check if any songs are selected  if #state.selected_song_indices == 0 then    state.status_message = "No songs selected"    state.last_status_time = os.time()    return false  end    -- Sort selected indices in descending order  table.sort(state.selected_song_indices, function(a, b) return a > b end)    -- Remove songs  local project = state.projects[state.selected_project]  local count = 0    for _, index in ipairs(state.selected_song_indices) do    if index >= 1 and index <= #project.songs then      table.remove(project.songs, index)      count = count + 1    end  end    -- Clear selected song indices  state.selected_song_indices = {}    -- Save projects  ProjectManager.save_projects()    state.status_message = count .. " song(s) removed from project"  state.last_status_time = os.time()  return trueend-- Export projectfunction ProjectManager.export_project()  -- Check if a project is selected  if not state.selected_project or state.selected_project < 1 or state.selected_project > #state.projects then    state.status_message = "No project selected"    state.last_status_time = os.time()    return false  end    -- Check if file operations module is available  if not utils_file.write_file then    state.status_message = "File operations module not available"    state.last_status_time = os.time()    return false  end    -- Get project  local project = state.projects[state.selected_project]    -- Generate filename  local filename = project.name:gsub("[^%w]", "_")  local extension = state.export_options.format == 1 and ".json" or ".csv"  local export_path = (config.paths and config.paths.exports or "") .. "/" .. filename .. extension    -- Export data  local content    if state.export_options.format == 1 then    -- Export as JSON    local export_data = {      name = project.name,      description = project.description,      songs = {}    }        for _, song in ipairs(project.songs) do      local song_data = {        title = song.title,        artist = song.artist,        path = song.path      }            -- Include additional metadata if requested      if state.export_options.include_metadata then        song_data.album = song.album        song_data.key = song.key        song_data.tempo = song.tempo        song_data.time_signature = song.time_signature        song_data.tags = song.tags      end            -- Include comments if requested      if state.export_options.include_comments and song.comments then        song_data.comments = song.comments      end            table.insert(export_data.songs, song_data)    end        -- Encode as JSON    local success    success, content = pcall(function() return utils_json.encode(export_data) end)    if not success or not content then      state.status_message = "Failed to encode export data"      state.last_status_time = os.time()      return false    end  else    -- Export as CSV    content = "Title,Artist,Path"        if state.export_options.include_metadata then      content = content .. ",Album,Key,Tempo,Time Signature,Tags"    end        if state.export_options.include_comments then      content = content .. ",Comments"    end        content = content .. "\n"        for _, song in ipairs(project.songs) do      content = content .. utils_csv_escape(song.title or "") .. ","      content = content .. utils_csv_escape(song.artist or "") .. ","      content = content .. utils_csv_escape(song.path or "")            -- Include additional metadata if requested      if state.export_options.include_metadata then        content = content .. "," .. utils_csv_escape(song.album or "")        content = content .. "," .. utils_csv_escape(song.key or "")        content = content .. "," .. utils_csv_escape(song.tempo and tostring(song.tempo) or "")        content = content .. "," .. utils_csv_escape(song.time_signature or "")        content = content .. "," .. utils_csv_escape(table.concat(song.tags or {}, "; "))      end            -- Include comments if requested      if state.export_options.include_comments then        content = content .. "," .. utils_csv_escape(song.comments or "")      end            content = content .. "\n"    end  end    -- Write export file  local success = utils_file.write_file(export_path, content)  if not success then    state.status_message = "Failed to write export file"    state.last_status_time = os.time()    return false  end    -- Hide dialog  state.show_export_dialog = false    state.status_message = "Project exported to " .. export_path  state.last_status_time = os.time()  return trueend-- Helper function to escape CSV valuesfunction utils_csv_escape(value)  if not value then return "" end  value = tostring(value)  if value:find('[,"\n]') then    -- Escape quotes by doubling them    value = value:gsub('"', '""')    -- Wrap in quotes    value = '"' .. value .. '"'  end  return valueend-- Draw the project manager UIfunction ProjectManager.draw()  -- Get theme colors  local colors = Theme.colors or {}    -- Calculate time since last status message  local status_age = os.time() - state.last_status_time    -- Draw project list panel  reaper.ImGui_BeginChild(state.ctx, "project_list", 200, 0, true)    -- Draw project list header  if reaper.ImGui_Button(state.ctx, "New Project", -1, 0) then    -- Show create dialog    state.show_create_dialog = true    state.new_project_name = ""    state.new_project_description = ""  end    -- Draw project list  for i, project in ipairs(state.projects) do    local is_selected = state.selected_project == i        if reaper.ImGui_Selectable(state.ctx, project.name, is_selected) then      state.selected_project = i      state.selected_song_indices = {}    end  end    reaper.ImGui_EndChild(state.ctx)    reaper.ImGui_SameLine(state.ctx)    -- Draw project details panel  reaper.ImGui_BeginChild(state.ctx, "project_details", 0, 0, true)    if state.selected_project and state.projects[state.selected_project] then    local project = state.projects[state.selected_project]        -- Project header    reaper.ImGui_Text(state.ctx, "Project: " .. project.name)    if project.description and project.description ~= "" then      reaper.ImGui_TextWrapped(state.ctx, project.description)    end    reaper.ImGui_Separator(state.ctx)        -- Project actions    if reaper.ImGui_Button(state.ctx, "Edit Project") then      -- Show edit dialog      state.show_edit_dialog = true      state.edit_project_name = project.name      state.edit_project_description = project.description or ""    end        reaper.ImGui_SameLine(state.ctx)        if reaper.ImGui_Button(state.ctx, "Delete Project") then      -- Show confirm dialog      state.show_confirm_delete = true    end        reaper.ImGui_SameLine(state.ctx)        if reaper.ImGui_Button(state.ctx, "Export Project") then      -- Show export dialog      state.show_export_dialog = true    end        reaper.ImGui_Separator(state.ctx)        -- Song filter
    reaper.ImGui_Text(state.ctx, "Filter:")
    reaper.ImGui_SameLine(state.ctx)
    _, state.filter_text = reaper.ImGui_InputText(state.ctx, "##filter", state.filter_text)
    
    -- Song list header
    reaper.ImGui_Text(state.ctx, "Songs: " .. #project.songs)
    
    -- Create song list flags
    local flags = bit.bor(
      reaper.ImGui_TableFlags_Resizable(),
      reaper.ImGui_TableFlags_ScrollY(),
      reaper.ImGui_TableFlags_RowBg(),
      reaper.ImGui_TableFlags_BordersOuter(),
      reaper.ImGui_TableFlags_BordersV()
    )
    
    -- Song list
    if reaper.ImGui_BeginTable(state.ctx, "songs_table", 4, flags) then
      reaper.ImGui_TableSetupColumn(state.ctx, "Title")
      reaper.ImGui_TableSetupColumn(state.ctx, "Artist")
      reaper.ImGui_TableSetupColumn(state.ctx, "Key")
      reaper.ImGui_TableSetupColumn(state.ctx, "Tempo")
      reaper.ImGui_TableHeadersRow(state.ctx)
      
      for i, song in ipairs(project.songs) do
        -- Apply filter if needed
        local show = true
        if state.filter_text ~= "" then
          local filter_lower = state.filter_text:lower()
          local title_lower = (song.title or ""):lower()
          local artist_lower = (song.artist or ""):lower()
          
          show = title_lower:find(filter_lower, 1, true) or
                artist_lower:find(filter_lower, 1, true)
        end
        
        if show then
          -- Check if song is selected
          local is_selected = false
          for _, index in ipairs(state.selected_song_indices) do
            if index == i then
              is_selected = true
              break
            end
          end
          
          -- Draw selectable row
          reaper.ImGui_TableNextRow(state.ctx)
          reaper.ImGui_TableSelectRow(state.ctx, i, is_selected)
          
          -- Draw row items
          reaper.ImGui_TableNextColumn(state.ctx)
          if reaper.ImGui_Selectable(state.ctx, song.title or "Unknown", is_selected, reaper.ImGui_SelectableFlags_SpanAllColumns() + reaper.ImGui_SelectableFlags_AllowItemOverlap()) then
            -- Toggle selection
            if reaper.ImGui_GetIO(state.ctx).KeyCtrl then
              -- Add/remove from selection
              local found = false
              for j, index in ipairs(state.selected_song_indices) do
                if index == i then
                  table.remove(state.selected_song_indices, j)
                  found = true
                  break
                end
              end
              if not found then
                table.insert(state.selected_song_indices, i)
              end
            else
              -- Replace selection
              state.selected_song_indices = {i}
            end
          end
          
          reaper.ImGui_TableNextColumn(state.ctx)
          reaper.ImGui_Text(state.ctx, song.artist or "")
          
          reaper.ImGui_TableNextColumn(state.ctx)
          reaper.ImGui_Text(state.ctx, song.key or "")
          
          reaper.ImGui_TableNextColumn(state.ctx)
          reaper.ImGui_Text(state.ctx, song.tempo and tostring(song.tempo) or "")
        end
      end
      
      reaper.ImGui_EndTable(state.ctx)
    end
    
    -- Song actions
    if #state.selected_song_indices > 0 then
      if reaper.ImGui_Button(state.ctx, "Remove Selected") then
        ProjectManager.remove_songs()
      end
      
      reaper.ImGui_SameLine(state.ctx)
      
      if reaper.ImGui_Button(state.ctx, "Open in Editor") and #state.selected_song_indices == 1 then
        local song_index = state.selected_song_indices[1]
        if song_index >= 1 and song_index <= #project.songs then
          local song = project.songs[song_index]
          -- Call app state callback if available
          if state.app_state.on_open_song then
            state.app_state.on_open_song(song)
          end
        end
      end
    end
  else
    reaper.ImGui_Text(state.ctx, "No project selected")
  end
  
  -- Display status message if recent
  if status_age < 3 then
    reaper.ImGui_Separator(state.ctx)
    reaper.ImGui_TextColored(state.ctx, colors.status_text or 0xFF00FFFF, state.status_message)
  end
  
  -- Display error if present
  if state.error then
    reaper.ImGui_Separator(state.ctx)
    reaper.ImGui_TextColored(state.ctx, colors.error_text or 0xFF0000FF, "Error: " .. state.error)
  end
  
  reaper.ImGui_EndChild(state.ctx)
  
  -- Draw modal dialogs
  ProjectManager.draw_dialogs()
end

-- Draw modal dialogs
function ProjectManager.draw_dialogs()
  -- Create project dialog
  if state.show_create_dialog then
    reaper.ImGui_OpenPopup(state.ctx, "Create Project")
  end
  
  if reaper.ImGui_BeginPopupModal(state.ctx, "Create Project", true, reaper.ImGui_WindowFlags_AlwaysAutoResize()) then
    reaper.ImGui_Text(state.ctx, "Project Details")
    reaper.ImGui_Separator(state.ctx)
    
    reaper.ImGui_Text(state.ctx, "Name:")
    _, state.new_project_name = reaper.ImGui_InputText(state.ctx, "##name", state.new_project_name)
    
    reaper.ImGui_Text(state.ctx, "Description:")
    _, state.new_project_description = reaper.ImGui_InputTextMultiline(state.ctx, "##description", state.new_project_description, 300, 100)
    
    reaper.ImGui_Separator(state.ctx)
    
    if reaper.ImGui_Button(state.ctx, "Create", 120, 0) then
      ProjectManager.create_project()
    end
    
    reaper.ImGui_SameLine(state.ctx)
    
    if reaper.ImGui_Button(state.ctx, "Cancel", 120, 0) then
      state.show_create_dialog = false
    end
    
    reaper.ImGui_EndPopup(state.ctx)
  end
  
  -- Edit project dialog
  if state.show_edit_dialog then
    reaper.ImGui_OpenPopup(state.ctx, "Edit Project")
  end
  
  if reaper.ImGui_BeginPopupModal(state.ctx, "Edit Project", true, reaper.ImGui_WindowFlags_AlwaysAutoResize()) then
    reaper.ImGui_Text(state.ctx, "Project Details")
    reaper.ImGui_Separator(state.ctx)
    
    reaper.ImGui_Text(state.ctx, "Name:")
    _, state.edit_project_name = reaper.ImGui_InputText(state.ctx, "##edit_name", state.edit_project_name)
    
    reaper.ImGui_Text(state.ctx, "Description:")
    _, state.edit_project_description = reaper.ImGui_InputTextMultiline(state.ctx, "##edit_description", state.edit_project_description, 300, 100)
    
    reaper.ImGui_Separator(state.ctx)
    
    if reaper.ImGui_Button(state.ctx, "Save", 120, 0) then
      ProjectManager.update_project()
    end
    
    reaper.ImGui_SameLine(state.ctx)
    
    if reaper.ImGui_Button(state.ctx, "Cancel", 120, 0) then
      state.show_edit_dialog = false
    end
    
    reaper.ImGui_EndPopup(state.ctx)
  end
  
  -- Confirm delete dialog
  if state.show_confirm_delete then
    reaper.ImGui_OpenPopup(state.ctx, "Confirm Delete")
  end
  
  if reaper.ImGui_BeginPopupModal(state.ctx, "Confirm Delete", true, reaper.ImGui_WindowFlags_AlwaysAutoResize()) then
    reaper.ImGui_Text(state.ctx, "Are you sure you want to delete this project?")
    reaper.ImGui_Text(state.ctx, "This action cannot be undone.")
    
    reaper.ImGui_Separator(state.ctx)
    
    if reaper.ImGui_Button(state.ctx, "Delete", 120, 0) then
      ProjectManager.delete_project()
    end
    
    reaper.ImGui_SameLine(state.ctx)
    
    if reaper.ImGui_Button(state.ctx, "Cancel", 120, 0) then
      state.show_confirm_delete = false
    end
    
    reaper.ImGui_EndPopup(state.ctx)
  end
  
  -- Export dialog
  if state.show_export_dialog then
    reaper.ImGui_OpenPopup(state.ctx, "Export Project")
  end
  
  if reaper.ImGui_BeginPopupModal(state.ctx, "Export Project", true, reaper.ImGui_WindowFlags_AlwaysAutoResize()) then
    reaper.ImGui_Text(state.ctx, "Export Options")
    reaper.ImGui_Separator(state.ctx)
    
    -- Format selection
    reaper.ImGui_Text(state.ctx, "Format:")
    if reaper.ImGui_RadioButton(state.ctx, "JSON", state.export_options.format == 1) then
      state.export_options.format = 1
    end
    reaper.ImGui_SameLine(state.ctx)
    if reaper.ImGui_RadioButton(state.ctx, "CSV", state.export_options.format == 2) then
      state.export_options.format = 2
    end
    
    -- Include options
    _, state.export_options.include_metadata = reaper.ImGui_Checkbox(state.ctx, "Include metadata (album, key, tempo, etc.)", state.export_options.include_metadata)
    _, state.export_options.include_comments = reaper.ImGui_Checkbox(state.ctx, "Include comments", state.export_options.include_comments)
    
    reaper.ImGui_Separator(state.ctx)
    
    if reaper.ImGui_Button(state.ctx, "Export", 120, 0) then
      ProjectManager.export_project()
    end
    
    reaper.ImGui_SameLine(state.ctx)
    
    if reaper.ImGui_Button(state.ctx, "Cancel", 120, 0) then
      state.show_export_dialog = false
    end
    
    reaper.ImGui_EndPopup(state.ctx)
  end
end

return ProjectManager
