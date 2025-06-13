#!/usr/bin/env python3
"""
JCRD Toolbox GUI v2
Tkinter interface to import, enrich, validate, and export .jcrd files
via helper scripts.
"""

import logging

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)s:%(name)s: %(message)s",
)

import os
import sys
import json
import math
import subprocess
import shutil
from pathlib import Path

import pretty_midi

import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext, ttk


class JCRDToolboxGUI:
    def __init__(self, root_window):
        self.root = root_window
        self.root.title("JCRD Toolbox GUI v2")

        # Initialize paths
        self.base_dir = Path(__file__).resolve().parent.parent
        self.scripts_dir = self.base_dir / "scripts"
        self.examples_dir = self.base_dir / "examples"

        # Initialize all required variables and widgets
        self.initialize_variables()

        # Build the interface
        self.build_interface()  # This creates and shows all UI elements

    def initialize_variables(self):
        # Initialize directory and filter variables
        self.catalog_dir = self.base_dir / "jcrddatasets" / "mcgill_jcrd"
        self.filter_var = tk.StringVar(value="*.json")
        # Initialize editing-related variables to avoid attribute errors
        self.edit_button = None
        self.is_editing = False
        self.editing_path = None
        # Initialize other attributes
        self.import_status = tk.StringVar()
        self.preview_content = tk.StringVar()
        self.timing_file_path = tk.StringVar()
        self.timing_data = None  # To store loaded JCRD data for timing tab
        self.target_bpm = tk.StringVar(value="120")
        self.time_sig_num = tk.StringVar(value="4")
        self.time_sig_den = tk.StringVar(value="4")
        self.grid_size = tk.StringVar(value="1")

        # Initialize UI elements that will be created later
        self.notebook = None
        self.import_tab = None
        self.preview_tab = None
        self.timing_tab = None
        self.catalog_tab = None
        self.midi_tab = None
        self.harmony_tab = None
        self.validation_tab = None
        self.export_tab = None

        # Initialize text widgets and status variables
        self.preview_text = None
        self.timing_preview = None
        self.midi_preview = None
        self.result_text = None
        self.file_tree = None

        # Initialize state variables
        self.current_timing_data = None
        self.section_widgets = []

        # Initialize status variables
        self.catalog_status = tk.StringVar(value="Ready")
        self.timing_status = tk.StringVar(value="Ready")
        self.midi_status = tk.StringVar(value="Ready")

        # Initialize file path and mode variables
        self.midi_file_path = tk.StringVar()
        self.midi_import_mode = tk.StringVar()
        self.midi_export_mode = tk.StringVar()

        # Initialize validate button
        self.validate_button = None

    def setup_notebook(self):
        self.notebook = ttk.Notebook(self.root)

        # Create tabs
        self.import_tab = ttk.Frame(self.notebook)
        self.timing_tab = ttk.Frame(self.notebook)

        # Add tabs
        self.notebook.add(self.import_tab, text="Import & Process")
        self.notebook.add(self.timing_tab, text="Timing Tools")

        self.notebook.pack(expand=True, fill="both", padx=10, pady=10)

        # Build UI elements for each tab
        self.build_import_tab()
        self.build_timing_tab()  # Call to build timing tab
        # Removed call to build_preview_tab since preview is handled in catalog tab
        # self._create_midi_tools_tab()
        # self._create_harmony_tools_tab()
        # self._create_validation_tools_tab()
        # self._create_export_tools_tab()
        # self._create_menubar() # Commented out as it's not defined

    def build_menu(self):
        menubar = tk.Menu(self.root)
        filemenu = tk.Menu(menubar, tearoff=0)
        filemenu.add_command(label="Exit", command=self.root.quit)
        menubar.add_cascade(label="File", menu=filemenu)
        helpmenu = tk.Menu(menubar, tearoff=0)
        helpmenu.add_command(
            label="About",
            command=lambda: messagebox.showinfo(
                "About", "JCRD Toolbox GUI v2"
            ),
        )
        menubar.add_cascade(label="Help", menu=helpmenu)
        self.root.config(menu=menubar)

    def run_tool(self, script_name, input_path, success_msg, error_msg):
        cmd = [
            sys.executable,
            f"{self.scripts_dir}/{script_name}.py",
            "--input",
            input_path,
        ]

        # Special handling for scripts that output to 'new_jcrd'
        if script_name.startswith(("validate_", "scan_")):
            output_dir = os.path.join(
                str(Path(__file__).resolve().parent.parent),
                "jcrddatasets",
                "new_jcrd",
            )
            os.makedirs(output_dir, exist_ok=True)

            if script_name == "validate_jcrd":
                cmd.extend(["--output_dir", output_dir])
            elif script_name == "scan_ready_for_export":
                cmd.extend(["--output_ready", output_dir])

        self.import_status.set(f"Running {script_name} on: {input_path}")
        try:
            result = subprocess.run(
                cmd, capture_output=True, text=True, check=True
            )
            self.import_status.set(f"✅ {success_msg}: {input_path}")
            messagebox.showinfo("Success", result.stdout)
        except subprocess.CalledProcessError as e:
            self.import_status.set(f"❌ {error_msg}")
            messagebox.showerror("Error", e.stderr or str(e))

    def build_timing_tab(self):
        frame = ttk.Frame(self.timing_tab, padding=10)
        frame.pack(expand=True, fill="both")

        ttk.Label(
            frame, text="Timing Tools", font=("Arial", 14, "bold")
        ).pack(anchor="w", pady=8)

        file_frame = ttk.LabelFrame(frame, text="JCRD File", padding=10)
        file_frame.pack(fill="x", pady=5)

        self.timing_file_path = tk.StringVar()
        ttk.Label(file_frame, text="Selected File:").pack(side="left", padx=5)

        ttk.Entry(
            file_frame,
            textvariable=self.timing_file_path,
            width=50,
            state="readonly",
        ).pack(side="left", padx=5, fill="x", expand=True)

        def select_file():
            path = filedialog.askopenfilename(
                filetypes=[("JCRD Files", "*.json")]
            )
            if path:
                self.load_timing_data(path)

        ttk.Button(file_frame, text="Browse...", command=select_file).pack(
            side="left", padx=5
        )

        tools_frame = ttk.LabelFrame(frame, text="Timing Tools", padding=10)
        tools_frame.pack(fill="x", pady=5)

        sync_frame = ttk.Frame(tools_frame)
        sync_frame.pack(fill="x", pady=5)

        ttk.Label(sync_frame, text="Sync BPM:").pack(side="left", padx=5)

        self.target_bpm = tk.StringVar(value="120")
        ttk.Entry(sync_frame, textvariable=self.target_bpm, width=10).pack(
            side="left", padx=5
        )

        ttk.Button(
            sync_frame,
            text="Sync All Sections to BPM",
            command=self.sync_all_sections_to_bpm,
        ).pack(side="left", padx=5)

        grid_frame = ttk.Frame(tools_frame)
        grid_frame.pack(fill="x", pady=5)

        ttk.Label(grid_frame, text="Grid Size (bars):").pack(
            side="left", padx=5
        )

        ttk.Entry(grid_frame, textvariable=self.grid_size, width=10).pack(
            side="left", padx=5
        )

        ttk.Button(
            grid_frame,
            text="Snap All Sections to Grid",
            command=self.snap_all_sections_to_grid,
        ).pack(side="left", padx=5)

        time_sig_frame = ttk.Frame(tools_frame)
        time_sig_frame.pack(fill="x", pady=5)

        ttk.Label(time_sig_frame, text="Time Signature:").pack(
            side="left", padx=5
        )

        ttk.Entry(
            time_sig_frame, textvariable=self.time_sig_num, width=3
        ).pack(side="left")
        ttk.Label(time_sig_frame, text="/").pack(side="left")
        ttk.Entry(
            time_sig_frame, textvariable=self.time_sig_den, width=3
        ).pack(side="left", padx=(0, 5))

        ttk.Button(
            time_sig_frame,
            text="Apply Time Signature",
            command=self.apply_time_signature,
        ).pack(side="left", padx=5)

        sections_outer_frame = ttk.LabelFrame(
            frame, text="Sections Details", padding=10
        )
        sections_outer_frame.pack(fill="both", expand=True, pady=5)

        canvas = tk.Canvas(sections_outer_frame)
        scrollbar = ttk.Scrollbar(
            sections_outer_frame, orient="vertical", command=canvas.yview
        )
        self.timing_sections_frame = ttk.Frame(canvas)

        self.timing_sections_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all")),
        )
        canvas_window = canvas.create_window(
            (0, 0), window=self.timing_sections_frame, anchor="nw"
        )
        canvas.configure(yscrollcommand=scrollbar.set)

        def _on_mousewheel(event):
            canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

        canvas.bind_all("<MouseWheel>", _on_mousewheel)

        def _configure_canvas_window(event):
            canvas.itemconfig(canvas_window, width=event.width)

        canvas.bind("<Configure>", _configure_canvas_window)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        preview_frame = ttk.LabelFrame(
            frame, text="JCRD Data Preview (Read-only)", padding=10
        )
        preview_frame.pack(fill="x", expand=False, pady=5)

        self.timing_preview = scrolledtext.ScrolledText(
            preview_frame, height=8, wrap="none", state="disabled"
        )
        self.timing_preview.pack(fill="x", expand=True)

        self.timing_status = tk.StringVar(
            value="Ready"
        )  # For Timing tab status
        ttk.Label(
            frame, textvariable=self.timing_status, foreground="gray"
        ).pack(anchor="w", pady=5)

    def build_midi_tab(self):
        frame = ttk.Frame(self.midi_tab, padding=10)
        frame.pack(expand=True, fill="both")

        ttk.Label(frame, text="MIDI Tools", font=("Arial", 14, "bold")).pack(
            anchor="w", pady=8
        )

        file_frame = ttk.LabelFrame(frame, text="File Selection", padding=10)
        file_frame.pack(fill="x", pady=5)

        self.midi_file_path = tk.StringVar()
        ttk.Label(file_frame, text="Selected File:").pack(side="left", padx=5)

        ttk.Entry(
            file_frame,
            textvariable=self.midi_file_path,
            width=50,
            state="readonly",
        ).pack(side="left", padx=5, fill="x", expand=True)

        def select_file():
            path = filedialog.askopenfilename(
                filetypes=[("MIDI Files", "*.mid"), ("JCRD Files", "*.json")]
            )
            if path:
                self.midi_file_path.set(path)
                self.update_midi_preview()

        ttk.Button(file_frame, text="Browse...", command=select_file).pack(
            side="left", padx=5
        )

        tools_frame = ttk.LabelFrame(frame, text="Tools", padding=10)
        tools_frame.pack(fill="x", pady=5)

        midi_to_jcrd_frame = ttk.Frame(tools_frame)
        midi_to_jcrd_frame.pack(fill="x", pady=5)

        ttk.Label(midi_to_jcrd_frame, text="MIDI to JCRD:").pack(
            side="left", padx=5
        )

        midi_options = ["Auto-detect sections", "Fixed-length sections"]
        self.midi_import_mode = tk.StringVar(value=midi_options[0])
        ttk.OptionMenu(
            midi_to_jcrd_frame,
            self.midi_import_mode,
            midi_options[0],
            *midi_options,
        ).pack(side="left", padx=5)

        ttk.Button(
            midi_to_jcrd_frame,
            text="Convert MIDI to JCRD",
            command=self.convert_midi_to_jcrd,
        ).pack(side="left", padx=5)

        jcrd_to_midi_frame = ttk.Frame(tools_frame)
        jcrd_to_midi_frame.pack(fill="x", pady=5)

        ttk.Label(jcrd_to_midi_frame, text="JCRD to MIDI:").pack(
            side="left", padx=5
        )

        export_options = ["Full song", "Individual sections"]
        self.midi_export_mode = tk.StringVar(value=export_options[0])
        ttk.OptionMenu(
            jcrd_to_midi_frame,
            self.midi_export_mode,
            export_options[0],
            *export_options,
        ).pack(side="left", padx=5)

        ttk.Button(
            jcrd_to_midi_frame,
            text="Export to MIDI",
            command=self.export_to_midi,
        ).pack(side="left", padx=5)

        preview_frame = ttk.LabelFrame(frame, text="Preview", padding=10)
        preview_frame.pack(fill="both", expand=True, pady=5)

        self.midi_preview = tk.Text(
            preview_frame, height=10, width=50, wrap="word", state="disabled"
        )
        self.midi_preview.pack(fill="both", expand=True)

        self.midi_status = tk.StringVar(value="Ready")
        ttk.Label(
            frame, textvariable=self.midi_status, foreground="gray"
        ).pack(anchor="w", pady=5)

    def build_import_tab(self):
        frame = ttk.Frame(self.import_tab, padding=10)
        frame.pack(expand=True, fill="both")
        ttk.Label(
            frame, text="Import Tools", font=("Arial", 14, "bold")
        ).pack(anchor="w", pady=8)
        ext_map = {
            "midi": ("MIDI Files", "*.mid"),
            "mp3": ("MP3 Files", "*.mp3"),
            "json": ("JSON Files", "*.json"),
        }
        for script in sorted(self.scripts_dir.glob("*_to_jcrd.py")):
            name = script.stem
            ft = next(
                (ext_map[k] for k in ext_map if k in name), ext_map["json"]
            )

            def make_cmd(n=name, ft=ft):

                def cmd():
                    path = filedialog.askopenfilename(filetypes=[ft])
                    if path:
                        self.run_tool(
                            n, path, f"Converted {n}", f"Error running {n}"
                        )

                return cmd

            ttk.Button(
                frame, text=name.replace("_", " ").title(), command=make_cmd()
            ).pack(fill="x", pady=4)
        ttk.Label(
            frame, textvariable=self.import_status, foreground="gray"
        ).pack(anchor="w", pady=(10, 0))

    def build_harmony_tab(self):
        frame = ttk.Frame(self.harmony_tab, padding=10)
        frame.pack(expand=True, fill="both")
        ttk.Label(
            frame, text="Harmony Tools", font=("Arial", 14, "bold")
        ).pack(anchor="w", pady=8)
        for script in sorted(self.scripts_dir.glob("add_*.py")):
            name = script.stem

            def make_cmd(n=name):

                def cmd():
                    path = filedialog.askopenfilename(
                        filetypes=[("JCRD Files", "*.json")]
                    )
                    if path:
                        self.run_tool(
                            n, path, f"Added {n}", f"Error running {n}"
                        )

                return cmd

            ttk.Button(
                frame, text=name.replace("_", " ").title(), command=make_cmd()
            ).pack(fill="x", pady=4)

    def build_validation_tab(self):
        frame = ttk.Frame(self.validation_tab, padding=10)
        frame.pack(expand=True, fill="both")
        ttk.Label(
            frame,
            text="Batch Validate .jcrd Files",
            font=("Arial", 14, "bold"),
        ).pack(anchor="w", pady=8)

        output_dir = os.path.join(
            str(Path(__file__).resolve().parent.parent),
            "jcrddatasets",
            "new_jcrd",
        )
        ttk.Label(foreground="darkblue").pack(anchor="w", pady=(0, 10))

        mcgill_dir = os.path.join(
            str(Path(__file__).resolve().parent.parent),
            "jcrddatasets",
            "mcgill_jcrd",
        )
        os.makedirs(mcgill_dir, exist_ok=True)

        ttk.Separator(frame, orient="horizontal").pack(fill="x", pady=10)
        ttk.Label(
            frame,
            text="McGill Dataset Operations:",
            font=("Arial", 11, "bold"),
        ).pack(anchor="w", pady=(5, 5))

        ttk.Label(
            frame,
            text=f"McGill dataset location: {mcgill_dir}",
            foreground="darkblue",
        ).pack(anchor="w", pady=(0, 5))

        def move_to_mcgill():
            source_file = filedialog.askopenfilename(
                filetypes=[("JCRD Files", "*.json")], initialdir=output_dir
            )
            if not source_file:
                return

            filename = os.path.basename(source_file)
            target_file = os.path.join(mcgill_dir, filename)

            if messagebox.askyesno(
                "Confirm",
                f"Move {filename} to McGill dataset?\\\\n\\\\n"
                "This should only be done for validated files that meet "
                "the requirements for the official dataset.",
            ):
                try:
                    shutil.copy2(source_file, target_file)
                    self.import_status.set(
                        f"✅ Added to McGill dataset: {filename}"
                    )
                    messagebox.showinfo(
                        "Success",
                        f"File has been added to McGill dataset at:\\n"
                        f"{target_file}",
                    )
                except Exception as e:
                    self.import_status.set(
                        "❌ Error adding to McGill dataset"
                    )
                    messagebox.showerror("Error", str(e))

        ttk.Button(
            frame, text="Add File to McGill Dataset", command=move_to_mcgill
        ).pack(fill="x", pady=4)

        ttk.Separator(frame, orient="horizontal").pack(fill="x", pady=10)

        ttk.Label(
            frame, text="Validation Tools:", font=("Arial", 11, "bold")
        ).pack(anchor="w", pady=(5, 5))

        validation_scripts = sorted(
            self.scripts_dir.glob("scan_*.py")
        ) + sorted(self.scripts_dir.glob("validate_*.py"))
        for script in validation_scripts:
            name = script.stem

            def make_cmd(n=name):

                def cmd():
                    folder = filedialog.askdirectory()
                    if folder:
                        self.run_tool(
                            n, folder, f"Completed {n}", f"Error running {n}"
                        )

                return cmd

            ttk.Button(
                frame, text=name.replace("_", " ").title(), command=make_cmd()
            ).pack(fill="x", pady=4)

        ttk.Label(
            frame,
            text="Validate Single JCRD File",
            font=("Arial", 11, "bold"),
        ).pack(anchor="w", pady=(10, 5))

        self.validate_button = ttk.Button(
            frame,  # Changed from self.validation_tab to frame
            text="Validate JCRD File",
            command=self.validate_file,  # Uses the new validate_file method
        )
        self.validate_button.pack(anchor="w", pady=(5, 5))

        self.result_text = scrolledtext.ScrolledText(
            frame,
            wrap=tk.WORD,
            height=10,  # Changed from self.validation_tab to frame
        )
        self.result_text.pack(fill="both", expand=True, pady=(5, 5))

    def build_export_tab(self):
        frame = ttk.Frame(self.export_tab, padding=10)
        frame.pack(expand=True, fill="both")
        ttk.Label(
            frame, text="Export Tools", font=("Arial", 14, "bold")
        ).pack(anchor="w", pady=8)
        for script in sorted(self.scripts_dir.glob("export_*.py")):
            name = script.stem

            def make_cmd(n=name):

                def cmd():
                    path = filedialog.askopenfilename(
                        filetypes=[("JCRD Files", "*.json")]
                    )
                    if path:
                        self.run_tool(
                            n, path, f"Exported {n}", f"Error running {n}"
                        )

                return cmd

            ttk.Button(
                frame, text=name.replace("_", " ").title(), command=make_cmd()
            ).pack(fill="x", pady=4)

    def build_interface(self):  # Formerly _setup_ui
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.pack(expand=True, fill=tk.BOTH)

        app_title = ttk.Label(
            main_frame,
            text="JCRD Toolbox",
            font=("Arial", 16, "bold"),
            anchor="center",
        )
        app_title.pack(fill=tk.X, pady=5)

        tab_control = ttk.Notebook(main_frame)

        # Create all tab frames
        self.catalog_tab = ttk.Frame(tab_control)
        self.timing_tab = ttk.Frame(tab_control)
        self.import_tab = ttk.Frame(tab_control)
        self.export_tab = ttk.Frame(tab_control)
        self.harmony_tab = ttk.Frame(tab_control)
        self.validation_tab = ttk.Frame(tab_control)
        self.midi_tab = ttk.Frame(tab_control)

        # Add all tabs to the notebook
        tab_control.add(self.catalog_tab, text="Catalog")
        tab_control.add(self.timing_tab, text="Timing Editor")
        tab_control.add(self.import_tab, text="Import")
        tab_control.add(self.export_tab, text="Export")
        tab_control.add(self.harmony_tab, text="Harmony")
        tab_control.add(self.validation_tab, text="Validation")
        tab_control.add(self.midi_tab, text="MIDI Tools")

        tab_control.pack(expand=True, fill="both", pady=5)

        # Build UI elements for each tab
        self.build_catalog_tab()
        self.build_timing_tab()
        self.build_import_tab()
        self.build_export_tab()
        self.build_harmony_tab()
        self.build_validation_tab()
        self.build_midi_tab()

        # Build menu
        self.build_menu()

    def refresh_file_list(self, event=None):
        if not self.file_tree:  # Guard if called before tree is ready
            return

        for item in self.file_tree.get_children():
            self.file_tree.delete(item)

        dir_path = self.catalog_dir.get()
        filter_text = self.filter_var.get().lower()

        if not dir_path or not os.path.exists(dir_path):
            self.catalog_status.set(
                f"Directory not found or not specified: {dir_path}"
            )
            if self.preview_text:
                self.preview_text.config(state="normal")
                self.preview_text.delete(1.0, "end")
                self.preview_text.config(state="disabled")
            return

        try:
            file_count = 0
            # Sort files for consistent display
            # Sort files case-insensitively
            sorted_files = sorted(
                os.listdir(dir_path), key=lambda s: s.lower()
            )

            for filename in sorted_files:
                if filename.lower().endswith(".json"):  # JCRD files are .json
                    full_path = os.path.join(dir_path, filename)
                    try:
                        with open(full_path, "r", encoding="utf-8") as f:
                            # Try to load minimal info for speed,
                            # or full if needed for filter
                            data = json.load(f)

                        # Prefer metadata fields, fallback to root, then
                        # filename
                        title = data.get("metadata", {}).get(
                            "title", data.get("title", filename)
                        )
                        artist = data.get("metadata", {}).get(
                            "artist", data.get("artist", "Unknown Artist")
                        )

                        if filter_text:
                            if not (
                                filter_text in title.lower()
                                or filter_text in artist.lower()
                                or filter_text in filename.lower()
                            ):
                                continue

                        self.file_tree.insert(
                            "",
                            "end",
                            values=(title, artist),
                            tags=(full_path,),
                        )
                        file_count += 1
                    except json.JSONDecodeError:
                        # Optionally log this or inform user,
                        # but don't stop scan
                        print(
                            f"Warning: Could not parse JSON file: {full_path}"
                        )
                    except Exception as e:
                        # Optionally log this
                        print(
                            f"Warning: Could not process file {full_path}: {e}"
                        )
            self.catalog_status.set(
                f"Found {file_count} JCRD files matching filter."
            )
        except Exception as e:
            self.catalog_status.set(f"Error scanning directory: {e}")
            print(f"Error scanning directory {dir_path}: {e}")
        if self.preview_text:  # Clear preview if list is refreshed
            self.preview_text.config(state="normal")
            self.preview_text.delete(1.0, "end")
            self.preview_text.config(state="disabled")

    def build_catalog_tab(self):
        frame = ttk.Frame(self.catalog_tab, padding=10)
        frame.pack(expand=True, fill="both")

        # Create header
        ttk.Label(
            frame, text="JCRD File Catalog", font=("Arial", 14, "bold")
        ).pack(anchor="w", pady=8)

        # Create directory selection
        dir_frame = ttk.Frame(frame)
        dir_frame.pack(fill="x", pady=5)

        ttk.Label(dir_frame, text="Directory:").pack(side="left", padx=(0, 5))

        # Catalog directory options
        catalog_dirs = {
            "Validated Files": os.path.join(
                str(Path(__file__).resolve().parent.parent),
                "jcrddatasets",
                "new_jcrd",
            ),
            "McGill Dataset": os.path.join(
                str(Path(__file__).resolve().parent.parent),
                "jcrddatasets",
                "mcgill_jcrd",
            ),
            "McGill SALAMI": os.path.join(
                str(Path(__file__).resolve().parent.parent),
                "jcrddatasets",
                "mcgill_jcrd_salami",
            ),
            "Raw Files": os.path.join(
                str(Path(__file__).resolve().parent.parent), "raw"
            ),
        }

        # Create raw directory if it doesn't exist
        os.makedirs(catalog_dirs["Raw Files"], exist_ok=True)

        self.catalog_dir = tk.StringVar(value=catalog_dirs["Validated Files"])
        catalog_dir_combo = ttk.Combobox(
            dir_frame,
            textvariable=self.catalog_dir,
            values=list(catalog_dirs.values()),
            state="readonly",
            width=40,
        )
        catalog_dir_combo.pack(side="left", fill="x", expand=True, padx=5)
        # Bind event
        catalog_dir_combo.bind("<<ComboboxSelected>>", self.refresh_file_list)

        def browse_dir():
            dir_path = filedialog.askdirectory(
                initialdir=self.catalog_dir.get()
            )
            if dir_path:
                # Update the Combobox options if this is a new directory
                current_values = list(catalog_dir_combo.get("values"))
                if dir_path not in current_values:
                    catalog_dir_combo["values"] = current_values + [dir_path]
                self.catalog_dir.set(dir_path)
                self.refresh_file_list()

        ttk.Button(dir_frame, text="Browse...", command=browse_dir).pack(
            side="left", padx=5
        )

        refresh_btn = ttk.Button(
            dir_frame,
            text="Refresh",
            command=self.refresh_file_list,  # Call method
        )
        refresh_btn.pack(side="left")

        # Filter input
        filter_frame = ttk.Frame(frame)
        filter_frame.pack(fill="x", pady=5)
        ttk.Label(filter_frame, text="Filter:").pack(side="left", padx=(0, 5))
        self.filter_var = tk.StringVar()
        filter_entry = ttk.Entry(
            filter_frame, textvariable=self.filter_var, width=40
        )
        filter_entry.pack(side="left", fill="x", expand=True, padx=5)
        # Trigger refresh
        filter_entry.bind("<KeyRelease>", self.refresh_file_list)

        # Create the file list frame with scrollbar
        list_frame = ttk.Frame(frame)
        list_frame.pack(fill="both", expand=True, pady=10)

        # Add scrollbar and listbox
        scrollbar = ttk.Scrollbar(list_frame)
        scrollbar.pack(side="right", fill="y")

        # File list with multiple columns (title, artist)
        columns = ("title", "artist")
        self.file_tree = ttk.Treeview(
            list_frame,
            columns=columns,
            show="headings",
            selectmode="browse",
            height=10,
        )

        # Define column headings
        self.file_tree.heading("title", text="Title")
        self.file_tree.heading("artist", text="Artist")

        # Set column widths
        self.file_tree.column("title", width=250)  # Adjusted width
        self.file_tree.column("artist", width=250)  # Adjusted width

        self.file_tree.pack(side="left", fill="both", expand=True)
        scrollbar.config(command=self.file_tree.yview)
        self.file_tree.config(yscrollcommand=scrollbar.set)

        # Preview frame
        preview_frame = ttk.LabelFrame(frame, text="Preview", padding=10)
        preview_frame.pack(fill="both", expand=False, pady=10)

        self.preview_text = scrolledtext.ScrolledText(  # Use scrolledtext
            preview_frame,
            height=10,
            width=50,  # width is less critical with fill='both'
            wrap="word",
            state="disabled",
        )
        self.preview_text.pack(fill="both", expand=True)

        # Status line
        status_frame = ttk.Frame(frame)
        status_frame.pack(fill="x", pady=5)

        self.catalog_status = tk.StringVar(value="Ready")
        ttk.Label(
            status_frame, textvariable=self.catalog_status, foreground="gray"
        ).pack(anchor="w")

        # Action buttons
        btn_frame = ttk.Frame(frame)
        btn_frame.pack(fill="x", pady=5)

        ttk.Button(
            btn_frame,
            text="Preview Selected",
            command=self.preview_selected_file,
        ).pack(side="left", padx=5)

        # Edit/Save toggle button
        self.edit_button = ttk.Button(
            btn_frame,
            text="Edit Selected",
            command=self.edit_selected_file,
        )
        self.edit_button.pack(side="left", padx=5)

        ttk.Button(
            btn_frame,
            text="Export Selected",
            command=self.export_selected_file,
        ).pack(side="left", padx=5)

        # Bind select event to preview
        self.file_tree.bind("<<TreeviewSelect>>", self.on_file_select)

        # Initial file list population
        self.refresh_file_list()  # Use class method

        # Change directory combobox binding
        catalog_dir_combo.bind(
            "<<ComboboxSelected>>", self.refresh_file_list  # Use class method
        )
        # NOTE: The local 'def refresh_file_list():' that was here previously
        # caused issues with the combobox binding. It's been removed to
        # avoid confusion.

    def on_file_select(self, event):  # event is passed by TreeviewSelect
        if not self.file_tree:
            return
        selected_items = self.file_tree.selection()
        if not selected_items:
            if self.preview_text:
                self.preview_text.config(state="normal")
                self.preview_text.delete(1.0, "end")
                self.preview_text.config(state="disabled")
            self.catalog_status.set("No file selected.")
            return

        selected_item = selected_items[0]  # Get the first selected item

        # Retrieve the full file path stored in the 'tags' tuple
        try:
            file_path_tuple = self.file_tree.item(selected_item, "tags")
            if not file_path_tuple:  # Should not happen if tags are set
                self.catalog_status.set(
                    "Error: File path not found for selection."
                )
                return
            file_path = file_path_tuple[0]
        except tk.TclError:  # If item is somehow gone
            self.catalog_status.set("Error retrieving selected file details.")
            return

        try:
            self.load_preview(file_path)
        except Exception as e:
            self.catalog_status.set(f"Error previewing file: {e}")
            if self.preview_text:
                self.preview_text.config(state="normal")
                self.preview_text.delete(1.0, "end")
                self.preview_text.insert(
                    "end", f"Error previewing file:\n{e}"
                )
                self.preview_text.config(state="disabled")

    def _ms_to_bars(self, ms, bpm, time_sig_num=4):
        if ms is None or bpm is None or bpm == 0 or time_sig_num == 0:
            return 0.0
        try:
            ms = float(ms)
            bpm = float(bpm)
            time_sig_num = int(time_sig_num)

            seconds_per_beat = 60.0 / bpm
            ms_per_beat = seconds_per_beat * 1000.0
            if ms_per_beat == 0:
                return 0.0

            num_beats = ms / ms_per_beat
            num_bars = num_beats / time_sig_num
            return num_bars
        except (ValueError, TypeError, ZeroDivisionError):
            return 0.0

    def _bars_to_ms(self, bars, bpm, time_sig_num=4):
        if bars is None or bpm is None or bpm == 0:
            return 0.0
        try:
            bars = float(bars)
            bpm = float(bpm)
            time_sig_num = int(time_sig_num)

            seconds_per_beat = 60.0 / bpm
            ms_per_beat = seconds_per_beat * 1000.0

            num_beats = bars * time_sig_num
            total_ms = num_beats * ms_per_beat
            return total_ms
        except (ValueError, TypeError, ZeroDivisionError):
            return 0.0

    def _ms_to_bars_display(
        self, ms, bpm, time_sig_num_str=None, time_sig_den_str=None
    ):
        ts_num = 4  # Default
        if time_sig_num_str:
            try:
                ts_num = int(time_sig_num_str)
            except ValueError:
                pass
        elif hasattr(self, "time_sig_num"):  # Check if UI element exists
            try:
                ts_num = int(self.time_sig_num.get())
            except (ValueError, tk.TclError):  # tk.TclError if var not set
                pass

        if ms is None:
            return "?"
        try:
            ms_float = float(ms)
            bpm_float = float(bpm) if bpm is not None else None
        except (ValueError, TypeError):
            return "?"

        bars_val = self._ms_to_bars(ms_float, bpm_float, ts_num)
        return f"{bars_val:.2f} bars"

    def load_preview(self, file_path):
        if not self.preview_text:
            return  # Guard
        logger.debug("load_preview: Start loading preview for %s", file_path)
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                logger.debug("load_preview: Opening file %s", file_path)
                data = json.load(f)
                logger.debug("load_preview: JSON parsed for %s", file_path)

            title = data.get("metadata", {}).get(
                "title", data.get("title", os.path.basename(file_path))
            )
            artist = data.get("metadata", {}).get(
                "artist", data.get("artist", "Unknown Artist")
            )

            # Get BPM from metadata or root
            meta = data.get("metadata", {})
            bpm_val = meta.get("bpm", data.get("bpm", None))
            key_val = data.get("metadata", {}).get(
                "key", data.get("key", "?")
            )
            time_sig_data = data.get("metadata", {}).get(
                "time_signature", data.get("time_signature", "4/4")
            )

            if isinstance(time_sig_data, str) and "/" in time_sig_data:
                current_ts_num_str, current_ts_den_str = str(
                    time_sig_data
                ).split("/")
            else:
                # Default time signature
                current_ts_num_str = "4"
                current_ts_den_str = "4"

            section_info = []
            # Check various common locations for sections
            sections_list = data.get(
                "sections", data.get("analysis", {}).get("sections", [])
            )

            for i, section in enumerate(sections_list):
                # Prefer 'sectionType', then 'sectionLabel', then 'label', then fallback
                s_label = (
                    section.get("sectionType")
                    or section.get("sectionLabel")
                    or section.get("label")
                    or f"Section {i+1}"
                )
                # Check for start_ms/duration_ms as alternatives
                s_start_ms = section.get(
                    "start", section.get("start_ms", None)
                )
                s_duration_ms = section.get(
                    "duration", section.get("duration_ms", None)
                )

                # Get chords if they exist
                chords = section.get("chords", [])
                chord_str = ", ".join(chords) if chords else "No chord data"

                # Calculate bars
                bars_duration = 0
                if s_duration_ms is not None and bpm_val is not None:
                    ms_float = float(s_duration_ms)
                    bpm_float = float(bpm_val)
                    ts_num = (
                        int(current_ts_num_str) if current_ts_num_str else 4
                    )
                    raw_bars = self._ms_to_bars(ms_float, bpm_float, ts_num)
                    bars_duration = self._round_bars_musically(raw_bars)

                # Format: label, bars (on its own line), then chords
                section_info.append(
                    f"  {s_label}\n    {bars_duration} bars\n    {chord_str}"
                )

            preview_content = (
                f"Title: {title}\n"
                f"Artist: {artist}\n"
                f"BPM: {bpm_val if bpm_val is not None else '?'}\n"
                f"Key: {key_val}\n"
                f"Time Signature: {time_sig_data}\n\n"
                f"Sections ({len(sections_list)}):\n"
                + (
                    "\n".join(section_info)
                    if section_info
                    else "  (No section data found)"
                )
            )

            self.preview_text.config(state="normal")
            self.preview_text.delete(1.0, "end")
            self.preview_text.insert("end", preview_content)
            self.preview_text.config(state="disabled")

            self.catalog_status.set(
                f"Previewing: {os.path.basename(file_path)}"
            )
        except json.JSONDecodeError as e:
            logger.error(
                "load_preview: JSONDecodeError for %s: %s", file_path, e
            )
            err_msg = (
                f"Error: '{os.path.basename(file_path)}' "
                f"is not a valid JSON file.\nDetails: {e}"
            )
            self.preview_text.config(state="normal")
            self.preview_text.delete(1.0, "end")
            self.preview_text.insert("end", err_msg)
            self.preview_text.config(state="disabled")
            self.catalog_status.set("Error previewing: Invalid JSON.")
            messagebox.showerror("Preview Error", err_msg)
        except Exception as e:
            logger.exception(
                "load_preview: Exception loading preview for %s", file_path
            )
            filename = os.path.basename(file_path)
            err_msg = f"Error loading preview for {filename}:\n{e}"
            self.preview_text.config(state="normal")
            self.preview_text.delete("1.0", "end")
            self.preview_text.insert("end", err_msg)
            self.preview_text.config(state="disabled")
            self.catalog_status.set("Error previewing file.")
            messagebox.showerror("Preview Error", err_msg)

    def preview_selected_file(self):
        if not self.file_tree:
            return
        selected_items = self.file_tree.selection()
        if not selected_items:
            self.catalog_status.set("No file selected for preview.")
            messagebox.showwarning(
                "Preview", "Please select a file from the list to preview."
            )
            return

        selected_item = selected_items[0]
        try:
            file_path = self.file_tree.item(selected_item, "tags")[0]
        except (IndexError, tk.TclError):  # Should not happen
            self.catalog_status.set(
                "Error: Could not retrieve file path for selected item."
            )
            return

        try:
            self.load_preview(file_path)
        except Exception as e:  # load_preview should handle its own errors
            self.catalog_status.set(f"Failed to initiate preview: {e}")

    def edit_selected_file(self):
        # Inline edit: toggle between edit and save
        if not getattr(self, "is_editing", False):
            # Start editing selected file
            if not self.file_tree:
                return
            items = self.file_tree.selection()
            if not items:
                self.catalog_status.set("No file selected to edit.")
                messagebox.showwarning("Edit", "Select a file to edit.")
                return
            selected = items[0]
            try:
                path = self.file_tree.item(selected, "tags")[0]
            except Exception:
                self.catalog_status.set("Error retrieving file path.")
                return
            try:
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                self.preview_text.config(state="normal")
                self.preview_text.delete(1.0, "end")
                self.preview_text.insert("end", content)
                # Make editable
                self.preview_text.config(state="normal")
                # Switch button to Save
                self.editing_path = path
                self.is_editing = True
                # Update button text to Save if available
                if getattr(self, "edit_button", None):
                    self.edit_button.config(text="Save")
                self.catalog_status.set(f"Editing: {os.path.basename(path)}")
            except Exception as e:
                self.catalog_status.set(f"Error opening for edit: {e}")
                messagebox.showerror("Edit Error", f"Could not open: {e}")
        else:
            # Save edits back to file
            try:
                new_text = self.preview_text.get(1.0, "end")
                with open(self.editing_path, "w", encoding="utf-8") as f:
                    f.write(new_text)
                # Disable editing
                self.preview_text.config(state="disabled")
                self.is_editing = False
                # Reset button text to Edit Selected if available
                if getattr(self, "edit_button", None):
                    self.edit_button.config(text="Edit Selected")
                self.catalog_status.set(
                    f"Saved: {os.path.basename(self.editing_path)}"
                )
                messagebox.showinfo("Save", "File saved successfully.")
                # Refresh preview content
                self.load_preview(self.editing_path)
            except Exception as e:
                self.catalog_status.set(f"Save failed: {e}")
                messagebox.showerror("Save Error", f"Could not save: {e}")

    def export_selected_file(self):
        if not self.file_tree:
            return
        selected_items = self.file_tree.selection()
        if not selected_items:
            self.catalog_status.set("No file selected to export.")
            messagebox.showwarning(
                "Export", "Please select a file from the list to export."
            )
            return

        selected_item = selected_items[0]
        try:
            file_path = self.file_tree.item(selected_item, "tags")[0]
        except (IndexError, tk.TclError):
            self.catalog_status.set(
                "Error: Could not retrieve file path for export."
            )
            messagebox.showerror(
                "Export Error", "Could not retrieve the selected file path."
            )
            return
        # Invoke export helper script
        logger.debug("Starting export for %s", file_path)
        script_path = self.scripts_dir / "export_jcrd_to_midi.py"
        if not script_path.exists():
            msg = f"Export script not found: {script_path}"
            logger.error(msg)
            self.catalog_status.set("Error: Export script missing.")
            messagebox.showerror("Export Error", msg)
            return
        try:
            result = subprocess.run(
                [sys.executable, str(script_path), file_path],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode == 0:
                logger.info("Export successful for %s", file_path)
                self.catalog_status.set(
                    f"Export successful: {os.path.basename(file_path)}"
                )
                messagebox.showinfo(
                    "Export Success",
                    result.stdout or "Export completed successfully.",
                )
            else:
                logger.error(
                    "Export failed for %s: %s", file_path, result.stderr
                )
                self.catalog_status.set(
                    f"Export failed: {os.path.basename(file_path)}"
                )
                messagebox.showerror(
                    "Export Error",
                    f"Error Code: {result.returncode}\nStderr:\n{result.stderr}",
                )
        except Exception as e:
            logger.exception("Exception during export for %s", file_path)
            self.catalog_status.set(f"Export error: {e}")
            messagebox.showerror(
                "Export Exception", f"An exception occurred: {e}"
            )

    def validate_file(self, file_path_to_validate=None):  # Renamed arg
        if file_path_to_validate is None:
            path = filedialog.askopenfilename(
                title="Select JCRD file to validate",
                filetypes=[("JCRD Files", "*.json"), ("All files", "*.*")],
            )
            if not path:
                if hasattr(self, "import_status"):
                    self.import_status.set("Validation cancelled.")
                return
            current_file_to_validate = path
        else:
            current_file_to_validate = file_path_to_validate

        if hasattr(self, "result_text") and self.result_text:
            self.result_text.config(state="normal")
            self.result_text.delete(1.0, tk.END)  # Clear previous results
            self.result_text.config(state="disabled")
        if hasattr(self, "import_status"):
            self.import_status.set(
                f"Validating: {os.path.basename(current_file_to_validate)}"
            )

        try:
            validate_script_path = self.scripts_dir / "validate_jcrd.py"
            if not validate_script_path.exists():
                messagebox.showerror(
                    "Error",
                    f"Validation script not found: {validate_script_path}",
                )
                if hasattr(self, "import_status"):
                    self.import_status.set(
                        "Error: Validation script missing."
                    )
                return

            cmd = [
                sys.executable,  # Use sys.executable for python interpreter
                str(validate_script_path),
                "--input",
                current_file_to_validate,
            ]

            output_dir_validation = (
                self.scripts_dir.parent
                / "jcrddatasets"
                / "validation_reports"
            )
            output_dir_validation.mkdir(parents=True, exist_ok=True)
            cmd.extend(["--output_dir", str(output_dir_validation)])

            # Run process and capture output
            # check=False to handle errors manually
            process = subprocess.run(
                cmd, capture_output=True, text=True, check=False
            )

            result_display_text = ""
            if process.returncode == 0:
                result_display_text = "Validation Successful:\\n"
                result_display_text += (
                    process.stdout.strip()
                    if process.stdout.strip()
                    else "No issues found."
                )
                if hasattr(self, "import_status"):
                    self.import_status.set(
                        f"✅ Validation successful: "
                        f"{os.path.basename(current_file_to_validate)}"
                    )
            else:
                result_display_text = (
                    f"Validation Failed (Code: {process.returncode}):\\n"
                )
                if process.stdout.strip():
                    result_display_text += (
                        "Stdout:\\n" + process.stdout + "\\n"
                    )
                if process.stderr.strip():
                    result_display_text = (
                        f"{result_display_text}\nStderr:\n{process.stderr}"
                    )
                if hasattr(self, "import_status"):
                    self.import_status.set(
                        f"❌ Validation failed: "
                        f"{os.path.basename(current_file_to_validate)}"
                    )

            if hasattr(self, "result_text") and self.result_text:
                self.result_text.config(state="normal")
                self.result_text.insert(tk.END, result_display_text)
                self.result_text.config(state="disabled")
            else:  # Fallback if result_text not available
                messagebox.showinfo("Validation Result", result_display_text)

        except Exception as e:
            error_message = f"Error during validation: {str(e)}"
            if hasattr(self, "result_text") and self.result_text:
                self.result_text.config(state="normal")
                self.result_text.insert(tk.END, error_message)
                self.result_text.config(state="disabled")
            if hasattr(self, "import_status"):
                self.import_status.set("❌ Error during validation.")
            messagebox.showerror("Validation Error", error_message)

    # --- Timing Tab Methods ---
    def get_section_by_id(self, section_identifier):
        if (
            self.current_timing_data
            and "sections" in self.current_timing_data
        ):
            for i, section in enumerate(self.current_timing_data["sections"]):
                # Check against 'id' field or index if 'id' is not present
                # or doesn't match
                if section.get("id") == section_identifier:
                    return section, i
                # Allow fetching by index if section_identifier is an int
                # and no 'id' matched
                if (
                    isinstance(section_identifier, int)
                    and i == section_identifier
                ):
                    # Use index if no ID match found
                    return section, i
            # If loop finishes, try one last time by index if identifier is int
            if isinstance(
                section_identifier, int
            ) and 0 <= section_identifier < len(
                self.current_timing_data["sections"]
            ):
                return (
                    self.current_timing_data["sections"][section_identifier],
                    section_identifier,
                )

        return None, -1

    def load_timing_data(self, file_path_to_load=None):  # Renamed arg
        if file_path_to_load is None:  # Should always be called with a path
            self.timing_status.set(
                "Error: No file path provided to load_timing_data."
            )
            return

        # Set the class attribute for the path
        self.timing_file_path.set(file_path_to_load)

        try:
            with open(file_path_to_load, "r", encoding="utf-8") as f:
                loaded_data = json.load(f)
            self.current_timing_data = loaded_data  # Store the loaded data

            # Ensure essential keys exist for robust operation
            if "metadata" not in self.current_timing_data:
                self.current_timing_data["metadata"] = {}
            has_bpm_meta = "bpm" in self.current_timing_data["metadata"]
            has_bpm_root = "bpm" in self.current_timing_data
            if not (has_bpm_meta or has_bpm_root):
                # Default BPM
                self.current_timing_data["metadata"]["bpm"] = 120.0
                # messagebox.showinfo(
                # "Info",
                # "BPM not found in JCRD, defaulting to 120 BPM for calculations."
                # )

            if (
                "time_signature" not in self.current_timing_data["metadata"]
                and "time_signature" not in self.current_timing_data
            ):
                self.current_timing_data["metadata"]["time_signature"] = "4/4"

            if "sections" not in self.current_timing_data:
                self.current_timing_data["sections"] = []
            for i, section in enumerate(
                self.current_timing_data.get("sections", [])
            ):
                if "id" not in section:
                    section["id"] = f"auto_id_{i}"
                if "start" not in section:
                    section["start"] = 0.0
                if "duration" not in section:
                    section["duration"] = 0.0
                # Ensure they are floats
                try:
                    section["start"] = float(section["start"])
                except (ValueError, TypeError):
                    section["start"] = 0.0
                try:
                    section["duration"] = float(section["duration"])
                except (ValueError, TypeError):
                    section["duration"] = 0.0

            self.clear_section_widgets()
            for i, section_data in enumerate(
                self.current_timing_data.get("sections", [])
            ):
                self.add_section_widget(section_data, i)

            if self.timing_preview:
                self.timing_preview.config(state="normal")
                self.timing_preview.delete(1.0, "end")
                self.timing_preview.insert(
                    "end", json.dumps(self.current_timing_data, indent=2)
                )
                self.timing_preview.config(state="disabled")

            # Update status after loading data
            self.timing_status.set(
                f"Loaded: {os.path.basename(file_path_to_load)}"
            )

        except FileNotFoundError:
            messagebox.showerror(
                "Error", f"File not found: {file_path_to_load}"
            )
            self.current_timing_data = None
            self.timing_status.set("Error: File not found.")
        except json.JSONDecodeError:
            messagebox.showerror(
                "Error", f"Invalid JSON in file: {file_path_to_load}"
            )
            self.current_timing_data = None
            self.timing_status.set("Error: Invalid JSON.")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load timing data: {e}")
            self.current_timing_data = None
            self.timing_status.set(f"Error loading data: {e}")

        # Update UI fields for time signature and BPM from loaded file
        loaded_bpm = self.current_timing_data.get("metadata", {}).get(
            "bpm", self.current_timing_data.get("bpm", 120)
        )
        self.target_bpm.set(str(loaded_bpm))  # Set the target_bpm field

        loaded_ts = self.current_timing_data.get("metadata", {}).get(
            "time_signature",
            self.current_timing_data.get("time_signature", "4/4"),
        )
        if isinstance(loaded_ts, str) and "/" in loaded_ts:
            num, den = loaded_ts.split("/")
            self.time_sig_num.set(num)
            self.time_sig_den.set(den)

    def clear_section_widgets(self):
        if self.timing_sections_frame:  # Check if the frame exists
            for widget in self.timing_sections_frame.winfo_children():
                widget.destroy()
        self.section_widgets = []  # Reset the list

    def add_section_widget(self, section_data, section_index):
        if not self.timing_sections_frame:  # Guard
            print(
                "Error: timing_sections_frame not initialized "
                "for add_section_widget"
            )
            return

        # Use auto_id if 'id' is missing
        section_id = section_data.get("id", f"auto_id_{section_index}")

        s_frame = ttk.Frame(
            self.timing_sections_frame, padding=(5, 2), relief="flat"
        )
        s_frame.pack(fill="x", pady=1, padx=1)

        label_text = section_data.get("label", f"Section {section_index + 1}")
        ttk.Label(
            s_frame,
            text=f"{label_text} (ID: {section_id})",
            width=20,
            anchor="w",
        ).pack(side="left", padx=(0, 5))

        ttk.Label(s_frame, text="Start(ms):").pack(side="left")
        start_var = tk.StringVar(value=str(section_data.get("start", 0.0)))
        start_entry = ttk.Entry(s_frame, textvariable=start_var, width=10)
        start_entry.pack(side="left", padx=(2, 5))

        ttk.Label(s_frame, text="Dur(ms):").pack(side="left")
        duration_var = tk.StringVar(
            value=str(section_data.get("duration", 0.0))
        )
        duration_entry = ttk.Entry(
            s_frame, textvariable=duration_var, width=10
        )
        duration_entry.pack(side="left", padx=(2, 5))

        # Store references
        self.section_widgets.append(
            {
                "id": section_id,
                "frame": s_frame,
                "start_var": start_var,
                "duration_var": duration_var,
                # Keep track of original index if needed
                "original_index": section_index,
            }
        )

        # Optional: Button to apply changes for this specific section
        # ttk.Button(
        # s_frame, text="Apply",
        # command=lambda sid=section_id: self.apply_one_section_changes(sid)
        # ).pack(side='left', padx=5)

    def update_section_display(self, section_identifier):  # id or index
        section_data, section_idx = self.get_section_by_id(section_identifier)
        if section_data is None:
            # print(
            # f"Debug: Section not found for identifier '{section_identifier}'"
            # " in update_section_display"
            # )
            return

        target_widget_group = None
        for wg in self.section_widgets:
            if wg["id"] == section_data.get("id"):  # Match by ID
                target_widget_group = wg
                break
        # Fallback if ID matching failed but we have an index
        # (less reliable if list order changes)
        if (
            not target_widget_group
            and isinstance(section_identifier, int)
            and 0 <= section_idx < len(self.section_widgets)
        ):
            # check if index still makes sense
            if (
                self.section_widgets[section_idx]["original_index"]
                == section_idx
            ):
                target_widget_group = self.section_widgets[section_idx]

        if target_widget_group:
            # Format to 3 decimal places
            target_widget_group["start_var"].set(
                f"{section_data.get('start', 0.0):.3f}"
            )
            target_widget_group["duration_var"].set(
                f"{section_data.get('duration', 0.0):.3f}"
            )
        # else:
        # print(
        #   f"Debug: UI widget not found for section ID "
        #   f"'{section_data.get('id')}' or index {section_idx}"
        # )

        # Update the main JSON preview text area as well
        if self.current_timing_data and self.timing_preview:
            self.timing_preview.config(state="normal")
            self.timing_preview.delete(1.0, "end")
            self.timing_preview.insert(
                "end", json.dumps(self.current_timing_data, indent=2)
            )
            self.timing_preview.config(state="disabled")

    def adjust_section_timing(
        self, section_identifier, start_ms_str=None, duration_ms_str=None
    ):
        # This method is for direct programmatic adjustment.
        # UI changes are handled by other methods.
        section, idx = self.get_section_by_id(section_identifier)
        if not section:
            self.timing_status.set(
                f"Error: Section '{section_identifier}' not found."
            )
            return False

        changed = False
        if start_ms_str is not None:
            try:
                new_start = float(start_ms_str)
                if section.get("start") != new_start:
                    section["start"] = new_start
                    changed = True
            except ValueError:
                self.timing_status.set(
                    f"Error: Invalid start time '{start_ms_str}'."
                )
                return False
        if duration_ms_str is not None:
            try:
                new_duration = float(duration_ms_str)
                if section.get("duration") != new_duration:
                    section["duration"] = new_duration
                    changed = True
            except ValueError:
                self.timing_status.set(
                    f"Error: Invalid duration '{duration_ms_str}'."
                )
                return False

        if changed:
            self.current_timing_data["sections"][idx] = section  # Update list
            # Update specific section UI
            self.update_section_display(section.get("id", idx))
            self.timing_status.set(
                f"Adjusted timing for section "
                f"'{section.get('label', section.get('id', idx))}'."
            )
        return True

    def snap_all_sections_to_grid(self):
        if not self.current_timing_data or not self.current_timing_data.get(
            "sections"
        ):
            messagebox.showwarning(
                "Sync to BPM", "No timing data or sections loaded."
            )
            return

        try:
            grid_size_bars_str = self.grid_size.get()
            grid_size_bars = float(grid_size_bars_str)
            if grid_size_bars <= 0:
                messagebox.showerror(
                    "Error", "Grid size (bars) must be positive."
                )
                return
        except ValueError:
            messagebox.showerror(
                "Error",
                f"Invalid grid size: '{grid_size_bars_str}'. Must be a number.",
            )
            return

        bpm_str = self.target_bpm.get()  # Use UI BPM for consistency
        try:
            bpm = float(bpm_str)
            if bpm <= 0:
                messagebox.showerror(
                    "Error", "BPM must be positive for grid snapping."
                )
                return
        except ValueError:
            messagebox.showerror("Error", f"Invalid BPM value: '{bpm_str}'.")
            return

        ts_num_str = self.time_sig_num.get()
        try:
            time_sig_num = int(ts_num_str)
        except ValueError:
            messagebox.showerror(
                "Error", f"Invalid Time Signature Numerator: '{ts_num_str}'."
            )
            return

        grid_size_ms = self._bars_to_ms(grid_size_bars, bpm, time_sig_num)
        if grid_size_ms <= 0.001:  # Effectively zero or negative
            messagebox.showerror(
                "Error",
                "Calculated grid size in ms is too small or zero. "
                "Check BPM, time signature, and grid settings.",
            )
            return

        for idx, section_data in enumerate(
            self.current_timing_data["sections"]
        ):
            # Get section ID or fall back to index
            section_id = section_data.get("id", idx)

            original_start = float(section_data.get("start", 0.0))
            original_duration = float(section_data.get("duration", 0.0))

            snapped_start = (
                round(original_start / grid_size_ms) * grid_size_ms
            )

            # Snap duration to nearest grid line, ensuring it's positive
            snapped_duration = (
                round(original_duration / grid_size_ms) * grid_size_ms
            )
            # Ensure non-zero duration for positive inputs
            # but was positive
            if original_duration > 0.001 and snapped_duration < 0.001:
                # Or a fraction of it, e.g.
                # grid_size_ms / time_sig_num for one beat
                snapped_duration = grid_size_ms

            section_data["start"] = snapped_start
            # Duration cannot be negative
            section_data["duration"] = max(snapped_duration, 0.0)

            self.update_section_display(section_id)  # Update UI

        self.timing_status.set(
            f"All sections snapped to {grid_size_bars}-bar grid at {bpm} BPM."
        )

    def sync_all_sections_to_bpm(self):
        if not self.current_timing_data or not self.current_timing_data.get(
            "sections"
        ):
            messagebox.showwarning(
                "Sync to BPM", "No timing data or sections loaded."
            )
            return

        try:
            target_bpm_str = self.target_bpm.get()
            target_bpm = float(target_bpm_str)
            if target_bpm <= 0:
                messagebox.showerror("Error", "Target BPM must be positive.")
                return
        except ValueError:
            messagebox.showerror(
                "Error",
                f"Invalid Target BPM: '{target_bpm_str}'. Must be a number.",
            )
            return

        ts_num_str = self.time_sig_num.get()
        try:
            time_sig_num = int(ts_num_str)
        except ValueError:
            messagebox.showerror(
                "Error", f"Invalid Time Signature Numerator: '{ts_num_str}'."
            )
            return

        for idx, section_data in enumerate(
            self.current_timing_data["sections"]
        ):
            section_id = section_data.get("id", idx)
            current_duration_ms = float(section_data.get("duration", 0.0))

            # Convert current duration to bars using the NEW target BPM
            # This is the key: how many bars does it represent at the new
            # tempo?
            duration_bars = self._ms_to_bars(
                current_duration_ms, target_bpm, time_sig_num
            )

            # Round to nearest whole bar (or beat, or other unit as desired)
            # Consider if half-bar or other rounding is desired.
            # For now, whole bars.
            rounded_duration_bars = round(duration_bars)

            # If original duration was positive but rounds to 0 bars,
            # maybe make it 1 bar? Or 1 beat?
            # A beat is (1.0 / time_sig_num) bars.
            if current_duration_ms > 0.001 and rounded_duration_bars < (
                1.0 / time_sig_num
            ):  # Less than one beat
                # One beat minimum
                # rounded_duration_bars = 1.0 / time_sig_num
                # Or if it's very short, let it be, or snap to a
                # minimum sensible duration in ms.
                # For now, if it's positive and rounds to 0,
                # let's make it at least one beat long in bars.
                if duration_bars > 0:  # if it was positive at all
                    rounded_duration_bars = max(
                        rounded_duration_bars, 1.0 / time_sig_num
                    )

            new_duration_ms = self._bars_to_ms(
                rounded_duration_bars, target_bpm, time_sig_num
            )

            # Duration cannot be negative
            section_data["duration"] = max(new_duration_ms, 0.0)
            self.update_section_display(section_id)

        self.timing_status.set(
            f"All section durations synced to bar boundaries at {target_bpm} BPM."
        )
        # Update the main BPM in metadata if desired,
        # or just use target_bpm for calculations
        # self.current_timing_data['metadata']['bpm'] = target_bpm
        # self.update_section_display_all() # If BPM metadata change affects
        # all

    def apply_time_signature(self):
        if not self.current_timing_data:  # Check if data is loaded
            messagebox.showwarning(
                "Apply Time Signature",
                "No timing data loaded. Please load a JCRD file first.",
            )
            return

        try:
            ts_num_str = self.time_sig_num.get()
            ts_den_str = self.time_sig_den.get()
            ts_num = int(ts_num_str)
            ts_den = int(ts_den_str)

            if not (1 <= ts_num <= 32 and ts_den in [1, 2, 4, 8, 16, 32]):
                messagebox.showerror(
                    "Error",
                    "Invalid time signature values. Numerator (1-32), "
                    "Denominator (1,2,4,8,16,32).",
                )
                return
        except ValueError:
            messagebox.showerror(
                "Error", "Time signature components must be integers."
            )
            return

        new_time_signature_str = f"{ts_num}/{ts_den}"

        # Should have been created by load_timing_data
        if "metadata" not in self.current_timing_data:
            self.current_timing_data["metadata"] = {}

        self.current_timing_data["metadata"][
            "time_signature"
        ] = new_time_signature_str
        self.timing_status.set(
            f"Applied Time Signature: {new_time_signature_str}"
        )

        # Time signature change primarily affects bar calculations
        # for display and snapping.
        # Re-render all section displays as their bar representations might
        # change.
        sections = self.current_timing_data.get("sections")
        if sections:
            for i, section_data in enumerate(
                self.current_timing_data["sections"]
            ):
                section_id = section_data.get("id", i)
                self.update_section_display(section_id)

        # Update the main JSON preview
        if self.timing_preview:
            self.timing_preview.config(state="normal")
            self.timing_preview.delete(1.0, "end")
            self.timing_preview.insert(
                "end", json.dumps(self.current_timing_data, indent=2)
            )
            self.timing_preview.config(state="disabled")

    def convert_midi_to_jcrd(self):
        import os
        import json

        if not self.midi_file_path.get():
            self.midi_status.set("No MIDI file selected")
            messagebox.showwarning(
                "Convert", "Please select a MIDI file first."
            )
            return

        try:
            input_path = self.midi_file_path.get()
            mode = self.midi_import_mode.get()

            # Use the correct script
            script_path = self.scripts_dir / "chordify_midi_to_jcrd_1.py"
            if not script_path.exists():
                self.midi_status.set("❌ Script not found")
                messagebox.showerror(
                    "Error", f"Script not found: {script_path}"
                )
                return

            # Determine output path (default: raw/<input>.json)
            base = os.path.splitext(os.path.basename(input_path))[0]
            output_dir = os.path.join(
                str(Path(__file__).resolve().parent.parent), "raw"
            )
            os.makedirs(output_dir, exist_ok=True)
            output_path = os.path.join(output_dir, f"{base}.json")

            # Build command
            cmd = [
                sys.executable,
                str(script_path),
                "--input",
                input_path,
                "--output",
                output_path,
            ]
            if "Fixed-length" in mode:
                cmd.append("--fixed-length")

            self.midi_status.set(
                f"Converting: {os.path.basename(input_path)}"
            )
            print(f"[DEBUG] Running: {' '.join(cmd)}")
            result = subprocess.run(
                cmd, capture_output=True, text=True, check=False
            )

            print(f"[DEBUG] Return code: {result.returncode}")
            print(f"[DEBUG] stdout: {result.stdout}")
            print(f"[DEBUG] stderr: {result.stderr}")

            if result.returncode == 0:
                # Check if output file exists and is valid JSON
                import os
                import json

                if os.path.exists(output_path):
                    try:
                        with open(output_path, "r", encoding="utf-8") as f:
                            json.load(f)
                        self.midi_status.set("✅ Conversion successful")
                        self.update_midi_preview()
                        messagebox.showinfo(
                            "Success",
                            f"MIDI file converted successfully!\nOutput: {output_path}\n\n{result.stdout}",
                        )
                    except Exception as file_exc:
                        self.midi_status.set("❌ Output file invalid")
                        messagebox.showerror(
                            "Error",
                            f"Output file was created but is not valid JSON:\n{output_path}\n\nError: {file_exc}",
                        )
                else:
                    self.midi_status.set("❌ No output file created")
                    messagebox.showerror(
                        "Error",
                        f"Conversion script ran (code 0) but did not create output file:\n{output_path}\n\n{result.stdout}\n{result.stderr}",
                    )
            else:
                self.midi_status.set("❌ Conversion failed")
                messagebox.showerror(
                    "Error",
                    f"Conversion failed (code {result.returncode}):\n{result.stderr}\n\n{result.stdout}",
                )

        except subprocess.CalledProcessError as e:
            self.midi_status.set("❌ Conversion error")
            messagebox.showerror("Error", f"Conversion failed:\n{e.stderr}")
        except Exception as e:
            self.midi_status.set("❌ Conversion error")
            messagebox.showerror(
                "Error", f"Error during conversion:\n{str(e)}"
            )

    def export_to_midi(self):
        if not self.midi_file_path.get():
            self.midi_status.set("No JCRD file selected")
            messagebox.showwarning(
                "Export", "Please select a JCRD file first."
            )
            return

        try:
            input_path = self.midi_file_path.get()
            mode = self.midi_export_mode.get()

            # Construct the command
            cmd = [
                sys.executable,
                str(self.scripts_dir / "jcrd_to_midi.py"),
                "--input",
                input_path,
            ]

            if "Individual sections" in mode:
                cmd.extend(["--split-sections"])

            self.midi_status.set(f"Exporting: {os.path.basename(input_path)}")

            result = subprocess.run(
                cmd, capture_output=True, text=True, check=True
            )

            if result.returncode == 0:
                self.midi_status.set("✅ Export successful")
                messagebox.showinfo("Success", "File exported successfully!")
            else:
                self.midi_status.set("❌ Export failed")
                messagebox.showerror(
                    "Error", f"Export failed:\n{result.stderr}"
                )

        except subprocess.CalledProcessError as e:
            self.midi_status.set("❌ Export error")
            messagebox.showerror("Error", f"Export failed:\n{e.stderr}")
        except Exception as e:
            self.midi_status.set("❌ Export error")
            messagebox.showerror("Error", f"Error during export:\n{str(e)}")

    def update_midi_preview(self):
        if not self.midi_preview:
            return

        file_path = self.midi_file_path.get()
        if not file_path:
            return

        try:
            if file_path.lower().endswith(".mid"):
                # For MIDI files, show basic info using pretty_midi
                pm = pretty_midi.PrettyMIDI(file_path)
                num_instruments = len(pm.instruments)
                total_notes = sum(len(inst.notes) for inst in pm.instruments)
                end_time = pm.get_end_time()
                info = (
                    "MIDI File Information:\n"
                    f"Instruments: {num_instruments}\n"
                    f"Total notes: {total_notes}\n"
                    f"End time (sec): {end_time:.2f}\n"
                )
            else:
                # For JCRD files, show the JSON content
                with open(file_path, "r") as f:
                    data = json.load(f)
                info = json.dumps(data, indent=2)

            self.midi_preview.config(state="normal")
            self.midi_preview.delete(1.0, "end")
            self.midi_preview.insert("end", info)
            self.midi_preview.config(state="disabled")

        except Exception as e:
            self.midi_status.set(f"❌ Error previewing file: {str(e)}")

    def _round_bars_musically(self, bars_val):
        """Round to a musically sensible bar value.

        In most music, sections tend to have lengths that are powers of 2
        (4, 8, 16 bars) or multiples of 4 for pop/rock songs. This function
        rounds to the nearest musically sensible value.
        """
        if bars_val is None or bars_val <= 0:
            return 0

        # For values close to whole numbers (within 0.15), round to whole
        decimal_part = bars_val - int(bars_val)
        if decimal_part < 0.15 or decimal_part > 0.85:
            return round(bars_val)

        # For values close to half bars, prefer the nearest whole even number
        # e.g., 7.4-7.6 likely means 8 bars
        if 0.4 <= decimal_part <= 0.6:
            nearest_whole = round(bars_val)
            # Prefer even numbers as they're more common in music
            if (
                nearest_whole % 2 == 1
                and abs(nearest_whole + 1 - bars_val) <= 0.6
            ):
                return nearest_whole + 1
            elif (
                nearest_whole % 2 == 1
                and abs(nearest_whole - 1 - bars_val) <= 0.6
            ):
                return nearest_whole - 1
            return nearest_whole

        # For values approaching the next whole number but not quite there (0.7-0.85)
        # round up for shorter sections (< 8 bars) as these are likely 4 or 8 bar phrases
        if decimal_part > 0.7 and bars_val < 8:
            return math.ceil(bars_val)

        # Otherwise, use standard rounding - slightly biased to musical numbers if close
        typical_lengths = [4, 8, 12, 16, 24, 32]
        for length in typical_lengths:
            if abs(bars_val - length) < 0.3:
                return length

        return round(bars_val)

if __name__ == "__main__":
    # Launch the GUI when run as a script
    import tkinter as tk

    root = tk.Tk()
    app = JCRDToolboxGUI(root)
    app.build_menu()
    app.setup_notebook()
    root.mainloop()
