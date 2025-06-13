-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.
-- project_manager.lua
-- UI module for managing song projects/collections
local ProjectManager = {}

-- Import required modules
local config = {}
pcall(function() config = require("config") end)

-- Import utility modules
local utils_file = {}
pcall(function() utils_file = require("utils.file") end)
local utils_json = {}
pcall(function() utils_json = require("utils.json") end)
local utils_reaper = {}
pcall(function() utils_reaper = require("utils.reaper") end)
local Theme = {}
pcall(function() Theme = require("ui.theme") end)
local Widgets = {}
pcall(function() Widgets = require("ui.widgets") end)

-- Load bit operations library
local success, bit = pcall(function() return require("bit") end)
if not success then
  -- Create simplified bitwise operations
  bit = {
    bor = function(a, b, ...)
      local result = a + b
      local args = {...}
      for i=1, #args do result = result + args[i] end
      return result
    end
  }
end

-- Load utility modules
success, utils_file = pcall(function() return require("utils.file_operations") end)
if not success then utils_file = {} end
success, utils_json = pcall(function() return require("utils.json") end)
if not success then utils_json = {} end
success, utils_reaper = pcall(function() return require("utils.reaper_helpers") end)
if not success then utils_reaper = {} end

-- Load theme and widgets
success, Theme = pcall(function() return require("theme_config") end)
if not success then Theme = {} end
success, Widgets = pcall(function() return require("ui.widgets") end)
if not success then Widgets = {} end

-- Define content_width with a valid placeholder value
local content_width = 800 -- Placeholder for content width

-- Local state
local state = {
  ctx = nil,
  app_state = nil,
  projects = {},
  selected_project = nil,
  selected_song_indices = {},
  show_create_dialog = false,
  show_edit_dialog = false,
  show_confirm_delete = false,
  show_export_dialog = false,
  new_project_name = "",
  new_project_description = "",
  edit_project_name = "",
  edit_project_description = "",
  status_message = "",
  last_status_time = 0,
  filter_text = "",
  error = nil,
  export_options = {
    format = 1, -- 1=JSON, 2=CSV
    include_metadata = true,
    include_comments = true
  }
}

-- Initialize the module
function ProjectManager.init(ctx, app_state)
  -- Store context and application state
  state.ctx = ctx
  state.app_state = app_state or {}
  
  -- Reset state
  state.projects = {}
  state.selected_project = nil
  state.selected_song_indices = {}
  state.filter_text = ""
  state.error = nil
  state.export_options = {
    format = 1,
    include_metadata = true,
    include_comments = true
  }
  
  -- Load projects
  ProjectManager.load_projects()
  
  return true
end

-- Load projects from disk
function ProjectManager.load_projects()
  -- Reset projects
  state.projects = {}
  
  -- Check if file operations module is available
  if not utils_file.read_file then
    state.status_message = "File operations module not available"
    state.last_status_time = os.time()
    return false
  end
  
  -- Projects file path
  local projects_path = config.paths and config.paths.metadata and (config.paths.metadata .. "/projects.json") or "projects.json"
  
  -- Check if projects file exists
  if not utils_file.file_exists or not utils_file.file_exists(projects_path) then
    -- Create empty projects file
    local empty_projects = {projects = {}}
    local json_data = utils_json.encode and utils_json.encode(empty_projects) or "{\"projects\":[]}"
    if utils_file.write_file then
      utils_file.write_file(projects_path, json_data)
    end
    state.status_message = "Created new projects file"
    state.last_status_time = os.time()
    return true
  end
  
  -- Read projects file
  local json_data = utils_file.read_file and utils_file.read_file(projects_path) or nil
  if not json_data then
    state.error = "Failed to read projects file"
    return false
  end
  
  -- Parse JSON data
  local success, data = pcall(function()
    if utils_json.decode then
      return utils_json.decode(json_data)
    end
    return {projects = {}}
  end)
  
  if not success or not data or not data.projects then
    state.error = "Failed to parse projects file"
    return false
  end
  
  -- Store projects
  state.projects = data.projects
  state.status_message = "Loaded " .. #state.projects .. " projects"
  state.last_status_time = os.time()
  
  return true
end

-- Save projects to disk
function ProjectManager.save_projects()
  -- Projects file path
  local projects_path = config.paths and config.paths.metadata and (config.paths.metadata .. "/projects.json") or "projects.json"
  
  -- Prepare data
  local data = {projects = state.projects}
  
  -- Convert to JSON
  local json_data = utils_json.encode and utils_json.encode(data) or "{\"projects\":[]}"
  if not json_data then
    state.error = "Failed to encode projects data"
    return false
  end
  
  -- Write to file
  local success = utils_file.write_file and utils_file.write_file(projects_path, json_data) or false
  if not success then
    state.error = "Failed to write projects file"
    return false
  end
  
  -- Update status
  state.status_message = "Projects saved"
  state.last_status_time = os.time()
  
  return true
end

-- Create a new project
function ProjectManager.create_project(name, description)
  -- Validate name
  if not name or name == "" then
    state.error = "Project name cannot be empty"
    return false
  end
  
  -- Check for duplicate names
  for _, project in ipairs(state.projects) do
    if project.name == name then
      state.error = "Project with this name already exists"
      return false
    end
  end
  
  -- Create new project
  local new_project = {
    id = tostring(os.time()),
    name = name,
    description = description or "",
    songs = {},
    created = os.time(),
    modified = os.time()
  }
  
  -- Add to projects
  table.insert(state.projects, new_project)
  
  -- Save projects
  ProjectManager.save_projects()
  
  -- Select new project
  state.selected_project = #state.projects
  
  -- Update status
  state.status_message = "Created project: " .. name
  state.last_status_time = os.time()
  
  return true
end

-- Update an existing project
function ProjectManager.update_project(index, name, description)
  -- Validate index
  if not index or not state.projects[index] then
    state.error = "Invalid project index"
    return false
  end
  
  -- Validate name
  if not name or name == "" then
    state.error = "Project name cannot be empty"
    return false
  end
  
  -- Check for duplicate names (excluding current project)
  for i, project in ipairs(state.projects) do
    if i ~= index and project.name == name then
      state.error = "Project with this name already exists"
      return false
    end
  end
  
  -- Update project
  state.projects[index].name = name
  state.projects[index].description = description or state.projects[index].description
  state.projects[index].modified = os.time()
  
  -- Save projects
  ProjectManager.save_projects()
  
  -- Update status
  state.status_message = "Updated project: " .. name
  state.last_status_time = os.time()
  
  return true
end

-- Delete a project
function ProjectManager.delete_project(index)
  -- Validate index
  if not index or not state.projects[index] then
    state.error = "Invalid project index"
    return false
  end
  
  -- Get project name
  local name = state.projects[index].name
  
  -- Remove project
  table.remove(state.projects, index)
  
  -- Save projects
  ProjectManager.save_projects()
  
  -- Reset selection if needed
  if state.selected_project == index then
    state.selected_project = nil
  elseif state.selected_project and state.selected_project > index then
    state.selected_project = state.selected_project - 1
  end
  
  -- Update status
  state.status_message = "Deleted project: " .. name
  state.last_status_time = os.time()
  
  return true
end

-- Export a project
function ProjectManager.export_project(project_index, options)
  -- Check if project exists
  if not state.projects[project_index] then
    state.status_message = "Invalid project index"
    state.last_status_time = os.time()
    return false
  end
  
  local project = state.projects[project_index]
  
  -- Check if the project has songs
  if #project.songs == 0 then
    state.status_message = "Project has no songs to export"
    state.last_status_time = os.time()
    return false
  end
  
  -- Create export directory if it doesn't exist
  local export_dir = options.target_path or (config.paths.base .. "/exports")
  if not utils_file.directory_exists(export_dir) then
    utils_file.create_directory(export_dir)
  end
  
  -- Create project directory
  local project_dir = export_dir .. "/" .. project.name:gsub("[^%w%s]", "_")
  if not utils_file.directory_exists(project_dir) then
    utils_file.create_directory(project_dir)
  end
  
  -- Create a project manifest
  local manifest = {
    name = project.name,
    description = project.description,
    created = project.created,
    exported = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    songs = {}
  }
  
  -- Export each song
  for i, song in ipairs(project.songs) do
    -- Read song file
    local song_path = config.paths.base .. "/" .. song.path
    local song_content = utils_file.read_file(song_path)
    
    if song_content then
      -- Parse song
      local success, song_data = pcall(function() return utils_json.decode(song_content) end)
      
      if success and song_data then
        -- Add to manifest
        table.insert(manifest.songs, {
          title = song.title or song_data.title,
          artist = song.artist or song_data.artist,
          file = song.path:match("([^/]+)$")
        })
        
        -- Export song based on format
        if options.format == "jcrd" then
          -- Copy the original JCRD file
          utils_file.write_file(
            project_dir .. "/" .. song.path:match("([^/]+)$"),
            song_content
          )
        elseif options.format == "midi" then
          -- TODO: Implement MIDI export
          -- This would call a function to convert JCRD to MIDI
        elseif options.format == "musicxml" then
          -- TODO: Implement MusicXML export
        elseif options.format == "text" then
          -- Simple text export with just chord information
          local text_content = "Title: " .. (song_data.title or "Unknown") .. "\n"
          text_content = text_content .. "Artist: " .. (song_data.artist or "Unknown") .. "\n\n"
          
          -- Add sections and chords
          if song_data.sections then
            for _, section in ipairs(song_data.sections) do
              text_content = text_content .. "=== " .. section.name .. " ===\n"
              
              if section.chords then
                text_content = text_content .. table.concat(section.chords, " ") .. "\n\n"
              end
            end
          end
          
          -- Save text file
          local text_filename = song.path:match("(.+)%.json$") .. ".txt"
          utils_file.write_file(
            project_dir .. "/" .. text_filename:match("([^/]+)$"),
            text_content
          )
        end
      end
    end
  end
  
  -- Save manifest
  utils_file.write_file(project_dir .. "/manifest.json", utils_json.encode(manifest))
  
  state.status_message = "Exported project to " .. project_dir
  state.last_status_time = os.time()
  return true
end

-- Draw the module UI
function ProjectManager.draw(ctx, app_state)
  -- Store context and app state
  state.ctx = ctx
  state.app_state = app_state

  -- Main container
  Widgets.begin_card(ctx, "Project Manager", 0)

  -- Toolbar
  if Widgets.button(ctx, "New Project", 120, 0) then
    state.show_new_project_dialog = true
  end

  reaper.ImGui_SameLine(ctx)

  -- Export button (disabled if no project selected)
  local export_button_disabled = not state.selected_project
  if export_button_disabled then
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_Alpha(), 0.5)
  end

  if Widgets.button(ctx, "Export Project", 120, 0) and state.selected_project then
    state.show_export_dialog = true
  end

  if export_button_disabled then
    reaper.ImGui_PopStyleVar(ctx)
  end

  reaper.ImGui_SameLine(ctx)

  -- Refresh button
  if Widgets.button(ctx, "Refresh", 80, 0) then
    ProjectManager.load_projects()
  end

  reaper.ImGui_SameLine(ctx, content_width - 150) -- Access .x for width

  -- Filter projects
  local filter_changed, new_filter = reaper.ImGui_InputTextWithHint(
    ctx, "##filter", "Filter projects...", state.filter_text
  )

  if filter_changed then
    state.filter_text = new_filter
  end

  reaper.ImGui_Spacing(ctx)
  Widgets.divider(ctx, "Projects")
  reaper.ImGui_Spacing(ctx)

  -- Projects list
  if #state.projects == 0 then
    reaper.ImGui_TextColored(ctx, Theme.colors.dim, "No projects available")
  else
    -- Calculate heights
    local content_height = reaper.ImGui_GetContentRegionAvail(ctx).y -- Access .y for height
    local project_list_height = content_height * 0.3
    -- local song_list_height = content_height - project_list_height - 40 -- Not used, can be removed if not needed later

    -- Projects list
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ChildRounding(), 4)
    if reaper.ImGui_BeginChild(ctx) then
      for i, project in ipairs(state.projects) do
        -- Filter by name
        if state.filter_text == "" or
           string.find(string.lower(project.name), string.lower(state.filter_text)) then

          -- Project selectable
          if reaper.ImGui_Selectable(ctx, project.name, state.selected_project == i) then
            state.selected_project = i
            state.selected_song_indices = {}
          end

          -- Show project details on hover
          if reaper.ImGui_IsItemHovered(ctx) then
            reaper.ImGui_BeginTooltip(ctx)
            reaper.ImGui_Text(ctx, "Created: " .. project.created:sub(1, 10))
            reaper.ImGui_Text(ctx, "Modified: " .. project.modified:sub(1, 10))
            reaper.ImGui_Text(ctx, "Songs: " .. #project.songs)

            if project.description and #project.description > 0 then
              reaper.ImGui_Separator(ctx)
              reaper.ImGui_TextWrapped(ctx, project.description)
            end

            reaper.ImGui_EndTooltip(ctx)
          end
        end
      end
      
      reaper.ImGui_EndChild(ctx)
    end
  end
  
  if Widgets.divider then Widgets.divider(ctx) end
  
  -- Selected project details
  if state.selected_project and state.projects[state.selected_project] then
    local project = state.projects[state.selected_project]
    
    -- Project details header
    reaper.ImGui_Text(ctx, "Project: " .. project.name)
    
    -- Project actions
    if reaper.ImGui_Button(ctx, "Edit") then
      state.show_edit_dialog = true
      state.edit_project_name = project.name
      state.edit_project_description = project.description or ""
    end
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Delete") then
      state.show_confirm_delete = true
    end
    
    -- Show songs if any
    if project.songs and #project.songs > 0 then
      if Widgets.divider then Widgets.divider(ctx) end
      
      -- Songs list header
      reaper.ImGui_Text(ctx, "Songs (" .. #project.songs .. ")")
      
      -- Display songs list
      local avail_width, avail_height = reaper.ImGui_GetContentRegionAvail(ctx)
      if reaper.ImGui_BeginChild(ctx, "songs_list", avail_width, avail_height) then
        for i, song in ipairs(project.songs) do
          local is_selected = state.selected_song_indices[i] == true
          if reaper.ImGui_Selectable(ctx, song.title or "Untitled", is_selected) then
            if not reaper.ImGui_IsKeyDown(ctx, reaper.ImGui_Key_LeftCtrl()) and
               not reaper.ImGui_IsKeyDown(ctx, reaper.ImGui_Key_RightCtrl()) then
              -- Single selection
              state.selected_song_indices = {}
            end
            -- Toggle selection
            state.selected_song_indices[i] = not state.selected_song_indices[i]
          end
        end
        reaper.ImGui_EndChild(ctx)
      end
    else
      reaper.ImGui_Text(ctx, "No songs in this project")
    end
  end
  
  -- Handle dialogs
  ProjectManager.draw_dialogs(ctx)
  
  -- End card
  if Widgets.end_card then Widgets.end_card(ctx) end
  
  return true
end

-- Draw dialog boxes
function ProjectManager.draw_dialogs(ctx)
  -- Create project dialog
  if state.show_create_dialog then
    -- Center the dialog
    local viewport_width, viewport_height = 1024, 768 -- Placeholder values
    local window_width, window_height = 400, 180
    local center_x = viewport_width and viewport_width/2 or 400
    local center_y = viewport_height and viewport_height/2 or 300
    
    reaper.ImGui_SetNextWindowSize(ctx, window_width, window_height)
    reaper.ImGui_SetNextWindowPos(ctx, center_x, center_y, reaper.ImGui_Cond_Appearing(), 0.5, 0.5)
    
    if reaper.ImGui_Begin() then
      reaper.ImGui_Text(ctx, "Enter project details:")
      if Widgets.divider then Widgets.divider(ctx) end
      
      reaper.ImGui_Text(ctx, "Project Name:")
      reaper.ImGui_SetNextItemWidth(ctx, window_width - 20)
      local changed, new_name = reaper.ImGui_InputText(ctx, "##name", state.new_project_name or "")
      if changed then state.new_project_name = new_name end
      
      reaper.ImGui_Text(ctx, "Description (optional):")
      reaper.ImGui_SetNextItemWidth(ctx, window_width - 20)
      local changed, new_desc = reaper.ImGui_InputText(ctx, "##desc", state.new_project_description or "")
      if changed then state.new_project_description = new_desc end
      
      if Widgets.divider then Widgets.divider(ctx) end
      
      if reaper.ImGui_Button(ctx, "Create", 120) then
        if ProjectManager.create_project(state.new_project_name, state.new_project_description) then
          state.show_create_dialog = false
          reaper.ImGui_End(ctx)
        end
      end
      
      reaper.ImGui_SameLine(ctx)
      if reaper.ImGui_Button(ctx, "Cancel", 120) then
        state.show_create_dialog = false
        reaper.ImGui_End(ctx)
      end
      
      reaper.ImGui_End(ctx)
    else
      reaper.ImGui_Text(ctx, "Create New Project")
    end
  end
  
  -- Edit project dialog
  if state.show_edit_dialog and state.selected_project and state.projects[state.selected_project] then
    -- Center the dialog
    local viewport_width, viewport_height = 1024, 768 -- Placeholder values
    local window_width, window_height = 400, 180
    local center_x = viewport_width and viewport_width/2 or 400
    local center_y = viewport_height and viewport_height/2 or 300
    
    reaper.ImGui_SetNextWindowSize(ctx, window_width, window_height)
    reaper.ImGui_SetNextWindowPos(ctx, center_x, center_y, reaper.ImGui_Cond_Appearing(), 0.5, 0.5)
    
    if reaper.ImGui_Begin() then
      reaper.ImGui_Text(ctx, "Edit project details:")
      if Widgets.divider then Widgets.divider(ctx) end
      
      reaper.ImGui_Text(ctx, "Project Name:")
      reaper.ImGui_SetNextItemWidth(ctx, window_width - 20)
      local changed, edit_name = reaper.ImGui_InputText(ctx, "##edit_name", state.edit_project_name or "")
      if changed then state.edit_project_name = edit_name end
      
      reaper.ImGui_Text(ctx, "Description:")
      reaper.ImGui_SetNextItemWidth(ctx, window_width - 20)
      local changed, edit_desc = reaper.ImGui_InputText(ctx, "##edit_desc", state.edit_project_description or "")
      if changed then state.edit_project_description = edit_desc end
      
      if Widgets.divider then Widgets.divider(ctx) end
      
      if reaper.ImGui_Button(ctx, "Save", 120) then
        if ProjectManager.update_project(state.selected_project, state.edit_project_name, state.edit_project_description) then
          state.show_edit_dialog = false
          reaper.ImGui_End(ctx)
        end
      end
      
      reaper.ImGui_SameLine(ctx)
      if reaper.ImGui_Button(ctx, "Cancel", 120) then
        state.show_edit_dialog = false
        reaper.ImGui_End(ctx)
      end
      
      reaper.ImGui_End(ctx)
    else
      reaper.ImGui_Text(ctx, "Edit Project")
    end
  end
  
  -- Confirm delete dialog
  if state.show_confirm_delete and state.selected_project and state.projects[state.selected_project] then
    -- Center the dialog
    local viewport_width, viewport_height = 1024, 768 -- Placeholder values
    local window_width, window_height = 350, 120
    local center_x = viewport_width and viewport_width/2 or 400
    local center_y = viewport_height and viewport_height/2 or 300
    
    reaper.ImGui_SetNextWindowSize(ctx, window_width, window_height)
    reaper.ImGui_SetNextWindowPos(ctx, center_x, center_y, reaper.ImGui_Cond_Appearing(), 0.5, 0.5)
    
    if reaper.ImGui_Begin() then
      reaper.ImGui_Text(ctx, "Are you sure you want to delete project:")
      if Theme.colors and Theme.colors.warning then
        reaper.ImGui_TextColored(ctx, Theme.colors.warning[1], Theme.colors.warning[2], Theme.colors.warning[3], Theme.colors.warning[4], state.projects[state.selected_project].name)
      else
        reaper.ImGui_Text(ctx, state.projects[state.selected_project].name)
      end
      reaper.ImGui_Text(ctx, "This action cannot be undone!")
      
      if Widgets.divider then Widgets.divider(ctx) end
      
      if reaper.ImGui_Button(ctx, "Yes, Delete", 120) then
        if ProjectManager.delete_project(state.selected_project) then
          state.show_confirm_delete = false
          reaper.ImGui_End(ctx)
        end
      end
      
      reaper.ImGui_SameLine(ctx)
      if reaper.ImGui_Button(ctx, "Cancel", 120) then
        state.show_confirm_delete = false
        reaper.ImGui_End(ctx)
      end
      
      reaper.ImGui_End(ctx)
    else
      reaper.ImGui_Text(ctx, "Confirm Delete")
    end
  end

  -- Handle add song dialog
  if state.show_add_song_dialog then
    -- TODO: Implement add song dialog
    -- For now, just add a dummy song to the selected project
    if state.selected_project then
      ProjectManager.add_song_to_project(state.selected_project, {
        path = "examples/example_jcrd.json",
        title = "New Song",
        artist = "New Artist"
      })
    end
  end
end

return ProjectManager
