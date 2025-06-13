-- Luacheck configuration for TRK project
-- Documentation: https://luacheck.readthedocs.io/en/stable/config.html

-- Global options
std = "min"  -- Minimal standard library (Lua 5.1 compatible)
max_line_length = 120
max_cyclomatic_complexity = 15

-- Global variables that should be allowed
globals = {
  -- REAPER API globals
  "reaper",
  "gfx",
  "midi",
  
  -- ImGui globals  
  "ImGui",
  
  -- Common script globals
  "script_path",
  "script_name",
  
  -- Test globals
  "describe",
  "it",
  "before_each",
  "after_each",
  "assert",
  "spy",
  "stub",
  "mock"
}

-- Files/directories to exclude
exclude_files = {
  -- External libraries and generated files
  "database/**",
  "myenv/**",
  "**/Lokasenna_**",
  
  -- Large data files that shouldn't be linted
  "**/*dataset*/**",
  "**/*Dataset*/**",
  
  -- Demo files with complex syntax
  "envireament/examples/demo.lua",
  
  -- Archive directories
  "archive/**"
}

-- Directory-specific rules
files = {
  -- Source code should be stricter
  ["src/**"] = {
    max_line_length = 100,
    max_cyclomatic_complexity = 10
  },
  
  -- Test files can be more lenient
  ["test*/**"] = {
    max_line_length = 120,
    globals = {
      "describe", "it", "before_each", "after_each",
      "assert", "spy", "stub", "mock", "setup", "teardown"
    }
  },
  
  -- Virtual environment files need REAPER mocks
  ["envireament/**"] = {
    globals = {
      "reaper", "gfx", "ImGui", "ctx",
      -- Mock-specific globals
      "mock_reaper", "virtual_imgui"
    }
  },
  
  -- Individual script globals
  ["main.lua"] = {
    globals = {"main", "init", "run", "cleanup"}
  },
  
  -- Module-specific globals
  ["bss/**"] = {
    globals = {"bass", "drum", "sequence", "pattern"}
  },
  
  ["crd/**"] = {
    globals = {"chord", "progression", "analyze", "detect"}
  },
  
  ["drm/**"] = {
    globals = {"groove", "pattern", "midi", "quantize"}
  },
  
  ["mel/**"] = {
    globals = {"melody", "transform", "generate", "fx"}
  },
  
  ["lyr/**"] = {
    globals = {"lyric", "editor", "sync", "timeline"}
  },
  
  ["ske/**"] = {
    globals = {"sketch", "prototype", "rapid", "test"}
  }
}

-- Ignore specific warnings
ignore = {
  "212",  -- Unused argument (common in callback functions)
  "213",  -- Unused loop variable (common in iteration)
  "431",  -- Shadowing upvalue (sometimes unavoidable)
  "432"   -- Shadowing upvalue argument (sometimes unavoidable)
}

-- Only warn about unused variables, not arguments
unused_args = false
