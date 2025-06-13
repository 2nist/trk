-- assertions.lua
-- Assertion utilities for use with the Virtual REAPER Environment test suite

local Assertions = {}

-- Basic assertion function
function Assertions.assert(condition, message)
  if not condition then
    error(message or "Assertion failed", 2)
  end
  return true
end

-- Assert equality with detailed error message
function Assertions.assertEquals(expected, actual, message)
  if expected ~= actual then
    local error_message = message or "Expected equality failed"
    error(string.format("%s\nExpected: %s\nActual: %s", 
      error_message, 
      tostring(expected), 
      tostring(actual)), 
    2)
  end
  return true
end

-- Assert that value is true
function Assertions.assertTrue(value, message)
  if value ~= true then
    local err_msg = "Expected true, got " .. tostring(value)
    error(message or err_msg, 2)
  end
  return true
end

-- Assert that value is false
function Assertions.assertFalse(value, message)
  if value ~= false then
    local err_msg = "Expected false, got " .. tostring(value)
    error(message or err_msg, 2)
  end
  return true
end

-- Assert that value is nil
function Assertions.assertNil(value, message)
  if value ~= nil then
    local err_msg = "Expected nil, got " .. tostring(value)
    error(message or err_msg, 2)
  end
  return true
end

-- Assert that value is not nil
function Assertions.assertNotNil(value, message)
  if value == nil then
    error(message or "Expected non-nil value", 2)
  end
  return true
end

-- Assert that value is a specific type
function Assertions.assertType(value, expected_type, message)
  if type(value) ~= expected_type then
    error(message or string.format("Expected type %s, got %s", expected_type, type(value)), 2)
  end
  return true
end

-- Assert that a function raises an error
function Assertions.assertError(func, expected_error_pattern, message)
  local status, error_message = pcall(func)
  if status then
    error(message or "Expected function to raise an error, but it succeeded", 2)
  end
  
  if expected_error_pattern then
    if not string.match(tostring(error_message), expected_error_pattern) then
      error(string.format("%s\nExpected error matching: %s\nActual error: %s", 
        message or "Error message did not match expected pattern",
        expected_error_pattern,
        tostring(error_message)), 
      2)
    end
  end
  
  return true
end

-- Assert that a value is in a specified range
function Assertions.assertInRange(value, min, max, message)
  if value < min or value > max then
    error(string.format("%s\nExpected value in range [%s, %s], got %s", 
      message or "Value out of expected range",
      tostring(min),
      tostring(max),
      tostring(value)), 
    2)
  end
  return true
end

-- Assert that a table contains a specific key
function Assertions.assertTableHasKey(tbl, key, message)
  if tbl[key] == nil then
    local err_msg = "Table does not contain expected key: " .. tostring(key)
    error(message or err_msg, 2)
  end
  return true
end

-- Assert that a table contains a specific value
function Assertions.assertTableContains(tbl, value, message)
  for _, v in pairs(tbl) do
    if v == value then
      return true
    end
  end
  local err_msg = "Table does not contain expected value: " .. tostring(value)
  error(message or err_msg, 2)
end

-- Assert that a string matches a pattern
function Assertions.assertMatch(str, pattern, message)
  if not string.match(str, pattern) then
    error(string.format("%s\nExpected string to match pattern: %s\nActual string: %s", 
      message or "String does not match expected pattern",
      pattern,
      str), 
    2)
  end
  return true
end

-- Assert deep equality of tables
function Assertions.assertDeepEquals(expected, actual, message)
  -- Check types
  if type(expected) ~= type(actual) then
    error(string.format("%s\nExpected type %s, got %s", 
      message or "Type mismatch in deep comparison",
      type(expected),
      type(actual)), 
    2)
  end
  
  -- If not tables, do simple comparison
  if type(expected) ~= "table" then
    return Assertions.assertEquals(expected, actual, message)
  end
  
  -- Check that all keys in expected are in actual with same values
  for k, v in pairs(expected) do
    if type(v) == "table" then
      Assertions.assertDeepEquals(v, actual[k], 
        (message or "Table mismatch") .. " at key [" .. tostring(k) .. "]")
    else
      if v ~= actual[k] then
        error(string.format("%s at key [%s]\nExpected: %s\nActual: %s", 
          message or "Table values differ",
          tostring(k),
          tostring(v),
          tostring(actual[k])), 
        2)
      end
    end
  end
  
  -- Check that actual doesn't have extra keys
  for k, _ in pairs(actual) do
    if expected[k] == nil then
      error(string.format("%s\nUnexpected key in actual table: %s", 
        message or "Tables have different keys",
        tostring(k)), 
      2)
    end
  end
  
  return true
end

return Assertions
