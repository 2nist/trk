# TRK — EnviREAment UI Toolkit for REAPER

**TRK** is a ReaImGui-based toolkit and development environment for building and validating custom REAPER panels and plugins within the **EnviREAment** project. It provides:

* **Virtual REAPER environment** (`enhanced_virtual_reaper.lua`) to mock the ReaImGui API for headless validation.
* **Demo harness** (`demo.lua`) serving as the canonical ImGui usage example.
* **Dev Control Center** panel (`trk/envireament/panels/dev_control_center.lua`) with a multi-pane UI framework.
* **Dataset browser**, **theme helpers**, **widgets**, and **theme config** modules for rapid UI prototyping.
* **Validation script** (`validate_envireament_demo.lua`) to lint, syntax-check, and verify ImGui calls against the mock environment.
* **CI pipeline** via GitHub Actions to run Luacheck and UI validation across Lua versions.

---

## 📂 Repository Structure

```
trk/                          # Core Lua modules and panels
  envireament/
    panels/
      dev_control_center.lua
      ui_dataset_browser_v2.lua
    theme_helper.lua
    widgets.lua
    theme_config.lua
enhanced_virtual_reaper.lua   # Mock REAPER+ImGui environment
demo.lua                      # Canonical ImGui demo script
validate_envireament_demo.lua  # Preprocess & validate ImGui scripts
.github/
  workflows/
    ci.yml                     # CI pipeline (lint & validation)
README.md                     # Project overview and instructions
.luacheckrc                   # Luacheck configuration
```

---

## 🚀 Prerequisites

1. **REAPER** with the [ReaImGui](https://github.com/cfillion/reaimgui) extension (for live panel testing).
2. **Lua** 5.1, 5.2, 5.3 or **LuaJIT** (development & CI).
3. **LuaRocks** (to install dependencies):

   ```sh
   luarocks install luacheck
   luarocks install bit32  # or rely on the builtin bit32 in Lua 5.2+
   ```
4. **Git** and GitHub account (for cloning and CI).

---

## 🛠 Installation & Setup

```bash
# Clone the repository
git clone git@github.com:2nist/trk.git
cd trk

# (Optional) install linting + bitwise module
luarocks install luacheck
luarocks install bit32
```

---

## ▶️ Usage

### 1. Run the canonical demo

```sh
lua demo.lua
```

This uses the real ImGui API in REAPER or the mock environment if running headless.

### 2. Validate panels and scripts

```sh
lua validate_envireament_demo.lua demo.lua
lua validate_envireament_demo.lua trk/envireament/panels/dev_control_center.lua
```

This preprocesses bitwise ops (with `bit32` shim), then checks for missing ImGui calls.

### 3. Load panel in REAPER

* Copy `trk/envireament/panels/dev_control_center.lua` into your REAPER scripts folder.
* In REAPER, run the script to launch the Dev Control Center UI.

---

## 🧑‍💻 Development Workflow

* **Add new ImGui calls**: Extend `enhanced_virtual_reaper.lua` with stubs for any newly introduced `reaper.ImGui_*` functions or constants.
* **Write panel code** in `trk/envireament/panels/`, following demo.lua patterns (use `ctx` for all calls).
* **Lint** with Luacheck:

  ```sh
  luacheck trk
  ```
* **Validate UI** using the validation script before committing.

---

## 📊 Continuous Integration

A GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push/PR to `main`, matrixing across Lua 5.1/5.2/5.3:

* **Luacheck** for style and potential errors.
* **Syntax check** of all Lua files.
* **ImGui validation** against the mock environment for demo and each panel.

---

## 🤝 Contributing

1. Fork the repo and create a feature branch.
2. Install dependencies and run `luacheck` + `validate_envireament_demo.lua` locally.
3. Commit tests and code, push to your fork, then open a Pull Request.
4. CI will run and report any issues.

Please include tests for any new ImGui API usage in `demo.lua` or in a new demo snippet.

---

## 📜 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.
