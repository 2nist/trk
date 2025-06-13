-- utils/file_operations.lua
-- File operations utility for Songbase
local M = {}

--- Check if a file exists
-- @param path string
-- @return boolean
function M.file_exists(path)
  local f = io.open(path, "rb")
  if f then f:close() return true end
  return false
end

--- Check if a directory exists
-- @param path string
-- @return boolean
function M.directory_exists(path)
  local ok, _, code = os.rename(path, path)
  if ok then return true end
  if code == 13 then -- permission denied but exists
    return true
  end
  return false
end

--- Read the entire contents of a file
-- @param path string
-- @return string|nil
function M.read_file(path)
  local f, err = io.open(path, "rb")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

--- Write contents to a file
-- @param path string
-- @param content string
-- @return boolean
function M.write_file(path, content)
  local f, err = io.open(path, "wb")
  if not f then return false end
  f:write(content)
  f:close()
  return true
end

--- Create a directory (including parents)
-- @param path string
-- @return boolean
function M.create_directory(path)
  local sep = package.config:sub(1,1)
  local cmd
  if sep == "\\" then
    cmd = string.format('mkdir "%s"', path)
  else
    cmd = string.format('mkdir -p "%s"', path)
  end
  local res = os.execute(cmd)
  return res == true or res == 0
end

--- Join path segments using OS separator
-- @param ... string segments
-- @return string
function M.join_path(...)
  local sep = package.config:sub(1,1) == "\\" and "\\" or "/"
  return table.concat({ ... }, sep)
end

--- Get the filename component from a path
-- @param path string
-- @return string
function M.get_filename(path)
  return path:match("([^/\\]+)$") or path
end

return M
