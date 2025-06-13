#!/usr/bin/env python3
"""
JCRD Toolbox GUI v2
Tkinter interface to import, enrich, validate, and export .jcrd files via helper scripts.
"""

import os
from pathlib import Path
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import subprocess
import json
import importlib.util
import sys


class JCRDToolboxGUI:
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
        script_path = f"{self.scripts_dir}/{script_name}.py"
        if not os.path.exists(script_path):
            error = f"Script not found: {script_path}"
            self.update_status(f"❌ {error}")
            messagebox.showerror("Error", error)
            return

        # Determine the appropriate arguments for the script
        if script_name in ["add_key_estimation", "add_roman_numerals"]:
            # These scripts expect --directory, but when called from the catalog
            # we're passing a specific file, so we need to pass its parent directory
            parent_dir = os.path.dirname(input_path)
            cmd = ["python3", script_path, "--directory", parent_dir]
        else:
            # Default: use --input for most scripts
            cmd = ["python3", script_path, "--input", input_path]

        self.update_status(f"Running {script_name} on: {input_path}")
        print(f"Executing command: {' '.join(cmd)}")
        try:
            result = subprocess.run(
                cmd, capture_output=True, text=True, check=True
            )
            self.update_status(f"✅ {success_msg}: {input_path}")
            messagebox.showinfo("Success", result.stdout)
        except subprocess.CalledProcessError as e:
            error_details = e.stderr or str(e)
            self.update_status(f"❌ {error_msg}")
            messagebox.showerror("Error", error_details)

    def build_timing_tab(self):
        frame = ttk.Frame(self.timing_tab, padding=10)
        frame.pack(expand=True, fill="both")
        ttk.Label(
            frame,
            text="Timing Tools (coming soon)",
            font=("Arial", 14, "bold"),
        ).pack(pady=20)

    def build_midi_tab(self):
        frame = ttk.Frame(self.midi_tab, padding=10)
        frame.pack(expand=True, fill="both")
        ttk.Label(
            frame, text="MIDI Tools (coming soon)", font=("Arial", 14, "bold")
        ).pack(pady=20)

    def build_catalog_tab(self):
        frame = ttk.Frame(self.catalog_tab, padding=10)
        frame.pack(expand=True, fill="both")

        # Dataset selection
        ttk.Label(
            frame, text="JCRD Catalog Browser", font=("Arial", 14, "bold")
        ).pack(anchor="w", pady=8)

        ttk.Label(control_frame, text="Dataset:").pack(side="left", padx=5)

        dataset_dropdown = ttk.Combobox(
            control_frame,
            textvariable=self.dataset_var,
            values=list(self.catalog_dirs.keys()),
            state="readonly",
            width=20,
        )
        dataset_dropdown.pack(side="left", padx=5)
        dataset_dropdown.bind("<<ComboboxSelected>>", self.load_catalog)

        ttk.Label(control_frame, text="Filter:").pack(
            side="left", padx=(15, 5)
        )

        filter_entry = ttk.Entry(
            control_frame, textvariable=self.filter_var, width=20
        )
        filter_entry.pack(side="left", padx=5)
        filter_entry.bind("<Return>", self.load_catalog)

        # Refresh button
        refresh_btn = ttk.Button(
            control_frame, text="Refresh", command=self.load_catalog
        )
        refresh_btn.pack(side="left", padx=15)

        # Create listbox with scrollbar
        list_frame = ttk.Frame(frame)
        list_frame.pack(fill="both", expand=True, pady=5)

        scrollbar = ttk.Scrollbar(list_frame)
        scrollbar.pack(side="right", fill="y")

        self.file_listbox = tk.Listbox(
            list_frame,
            width=60,
            height=15,
            yscrollcommand=scrollbar.set,
            font=("Courier", 11),
            bg="#f8f8f8",
            fg="#000000",
            selectbackground="#4a6da7",
            selectforeground="#ffffff",
        )
        self.file_listbox.pack(side="left", fill="both", expand=True)
        scrollbar.config(command=self.file_listbox.yview)

        # Double-click to preview
        self.file_listbox.bind(
            "<Double-1>", lambda e: self.preview_selected_file()
        )

        # Information and preview area
        info_frame = ttk.Frame(frame)
        info_frame.pack(fill="x", pady=5)

        ttk.Button(
            info_frame,
            text="Preview Selected",
            command=self.preview_selected_file,
        ).pack(side="left", padx=5)

        ttk.Button(
            info_frame,
            text="Add Key",
            command=lambda: self.process_selected_file("add_key_estimation"),
        ).pack(side="left", padx=5)

        ttk.Button(
            info_frame,
            text="Add Roman Numerals",
            command=lambda: self.process_selected_file("add_roman_numerals"),
        ).pack(side="left", padx=5)

        # Status display
        self.catalog_status = tk.StringVar(value="Ready to browse")
        ttk.Label(
            frame,
            textvariable=self.catalog_status,
            foreground="#004080",
            font=("Arial", 10),
        ).pack(anchor="w", pady=(10, 0))

        # Initial load
        self.load_catalog()

    def load_catalog(self, event=None):
        """Load files from the selected catalog directory with optional filtering"""
        self.file_listbox.delete(0, tk.END)

        dataset = self.dataset_var.get()
        directory = self.catalog_dirs.get(dataset, "")
        filter_text = self.filter_var.get().lower()

        print(f"Loading catalog for dataset: {dataset}")
        print(f"Directory path: {directory}")

        if not os.path.isdir(directory):
            os.makedirs(directory, exist_ok=True)
            self.catalog_status.set(f"Created directory: {directory}")
            print(f"Created missing directory: {directory}")
            return

        try:
            files = []
            for file in sorted(Path(directory).glob("*.json")):
                print(f"Found file: {file}")
                if filter_text and filter_text not in file.name.lower():
                    print(f"Skipping file due to filter: {file}")
                    continue
                files.append(file)

            for i, file in enumerate(files):
                self.file_listbox.insert(tk.END, file.name)

                # Try to add metadata if possible
                try:
                    with open(file, "r") as f:
                        data = json.load(f)
                        title = data.get("title", "")
                        artist = data.get("artist", "")
                        if title and artist:
                            self.file_listbox.itemconfig(
                                i,
                                bg="#e6eeff" if i % 2 == 0 else "#ffffff",
                                fg="#000000",
                            )
                except Exception as e:
                    print(f"Error reading metadata from {file}: {e}")
                    # Skip metadata if file can't be read
                    pass

            self.catalog_status.set(
                f"Loaded {len(files)} files from {dataset}"
                + (f" (filtered by '{filter_text}')" if filter_text else "")
            )
            print(f"Loaded {len(files)} files from {dataset}")

        except Exception as e:
            self.catalog_status.set(f"Error loading catalog: {str(e)}")
            print(f"Error loading catalog: {e}")

    def preview_selected_file(self):
        """Preview the selected JCRD file from the catalog"""
        selection = self.file_listbox.curselection()
        if not selection:
            messagebox.showinfo(
                "No Selection", "Please select a file to preview"
            )
            return

        file_name = self.file_listbox.get(selection[0])
        dataset = self.dataset_var.get()
        directory = self.catalog_dirs.get(dataset, "")
        file_path = os.path.join(directory, file_name)

        try:
            with open(file_path, "r") as f:
                data = json.load(f)

            title = data.get("title", "(no title)")
            artist = data.get("artist", "(no artist)")
            bpm = data.get("bpm", "?")
            key = data.get("key", "?")
            section_info = []

            for i, section in enumerate(data.get("sections", [])):
                chords = ", ".join(section.get("chords", []))
                section_info.append(f"Section {i+1}: {chords}")

            preview = (
                f"Title: {title}\n"
                f"Artist: {artist}\n"
                f"BPM: {bpm}\n"
                f"Key: {key}\n\n"
                f"Sections:\n" + "\n".join(section_info)
            )

            messagebox.showinfo(f"Preview: {file_name}", preview)

        except Exception as e:
            self.catalog_status.set("Preview error occurred.")
            messagebox.showerror("Preview Error", str(e))

    def process_selected_file(self, script_name):
        """Process the selected file with the specified script"""
        selection = self.file_listbox.curselection()
        if not selection:
            messagebox.showinfo(
                "No Selection", "Please select a file to process"
            )
            return

        # Check for required modules for specific scripts
        if script_name in ["add_key_estimation", "add_roman_numerals"]:
            if not self.is_module_installed("music21"):
                self.update_status(
                    "Music21 module required for this operation"
                )
                if not self.install_module("music21"):
                    return

        file_name = self.file_listbox.get(selection[0])
        dataset = self.dataset_var.get()
        directory = self.catalog_dirs.get(dataset, "")
        file_path = os.path.join(directory, file_name)

        # Run the script on the file
        self.run_tool(
            script_name,
            file_path,
            f"Processed with {script_name}",
            f"Error processing with {script_name}",
        )

        # Refresh display after processing
        self.load_catalog()

    def is_module_installed(self, module_name):
        """Check if a Python module is installed"""
        try:
            importlib.util.find_spec(module_name)
            return True
        except ImportError:
            return False

    def install_module(self, module_name):
        """Attempt to install a Python module"""
        msg = (
            f"The {module_name} module is required for this operation.\n"
            "Would you like to install it now?"
        )
        if messagebox.askyesno("Install Dependency", msg):
            try:
                self.update_status(f"Installing {module_name}...")
                subprocess.check_call(
                    [sys.executable, "-m", "pip", "install", module_name]
                )
                self.update_status(f"{module_name} installed successfully.")
                return True
            except subprocess.CalledProcessError:
                error_msg = (
                    f"Failed to install {module_name}. "
                    "Please install it manually."
                )
                messagebox.showerror("Installation Error", error_msg)
                self.update_status(f"Failed to install {module_name}.")
                return False
        else:
            self.update_status("Installation cancelled.")
            return False

    def update_status(self, message):
        """Update status message in both tabs"""
        if hasattr(self, "import_status"):
            self.import_status.set(message)
        if hasattr(self, "catalog_status"):
            self.catalog_status.set(message)
        self.root.update()

    def __init__(self, root):
        self.root = root
        self.root.title("🎼 JCRD Toolbox GUI v2")
        # window geometry and grid layout
        self.root.geometry("700x500")
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_columnconfigure(0, weight=1)
        # locate scripts directory for dynamic discovery
        self.scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
        self.import_status = tk.StringVar(value="Ready")
        # Dataset directories for the catalog
        self.catalog_dirs = {
            "McGill JCRD": os.path.join(
                str(Path(__file__).resolve().parent.parent),
                "jcrddatasets",
                "mcgill_jcrd",
            ),
            "McGill JCRD SALAMI": os.path.join(
                str(Path(__file__).resolve().parent.parent),
                "jcrddatasets",
                "mcgill_jcrd_salami",
            ),
            "Raw Files": os.path.join(
                str(Path(__file__).resolve().parent.parent), "raw"
            ),
            "Validated Files": os.path.join(
                str(Path(__file__).resolve().parent.parent),
                "jcrddatasets",
                "new_jcrd",
            ),
        }
        # Initialize dataset variable for catalog dropdown
        self.dataset_var = tk.StringVar(
            value=next(iter(self.catalog_dirs.keys()))
        )
        self.build_menu()
        self.build_interface()

    def build_interface(self):
        # Header label
        banner = tk.Label(
            self.root,
            text="JCRD Toolbox v2\nImport, enrich, validate, and export .jcrd files",
            font=("Arial", 11),
            justify="center",
            fg="darkblue",
        )
        banner.grid(row=0, column=0, pady=4)

        tab_control = ttk.Notebook(self.root)
        # place notebook via grid
        tab_control.grid(row=1, column=0, sticky="nsew")

        # Define tabs
        self.catalog_tab = ttk.Frame(tab_control)
        self.import_tab = ttk.Frame(tab_control)
        self.harmony_tab = ttk.Frame(tab_control)
        self.timing_tab = ttk.Frame(tab_control)
        self.midi_tab = ttk.Frame(tab_control)
        self.validation_tab = ttk.Frame(tab_control)
        self.export_tab = ttk.Frame(tab_control)

        tab_control.add(self.catalog_tab, text="Catalog")
        tab_control.add(self.import_tab, text="Import")
        tab_control.add(self.harmony_tab, text="Harmony")
        tab_control.add(self.timing_tab, text="Timing")
        tab_control.add(self.midi_tab, text="MIDI")
        tab_control.add(self.validation_tab, text="Validation")
        tab_control.add(self.export_tab, text="Export")

        # build content tabs
        self.build_catalog_tab()
        self.build_import_tab()
        self.build_harmony_tab()
        self.build_timing_tab()
        self.build_midi_tab()
        self.build_validation_tab()
        self.build_export_tab()

    def build_import_tab(self):
        # dynamically list all import scripts
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
        for script in sorted(self.scripts_dir.glob("scan_*.py")) + sorted(
            self.scripts_dir.glob("validate_*.py")
        ):
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

    def build_export_tab(self):
        frame = ttk.Frame(self.export_tab, padding=10)
        frame.pack(expand=True, fill="both")
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

    def preview_jcrd(self):
        path = filedialog.askopenfilename(
            filetypes=[("JCRD Files", "*.json")]
        )
        if path:
            try:
                with open(path, "r") as f:
                    data = json.load(f)
                title = data.get("title", "(no title)")
                artist = data.get("artist", "(no artist)")
                bpm = data.get("bpm", "?")
                key = data.get("key", "?")
                section_info = []
                for i, section in enumerate(data.get("sections", [])):
                    chords = ", ".join(section.get("chords", []))
                    section_info.append(f"Section {i+1}: {chords}")
                preview = (
                    f"Title: {title}\n"
                    f"Artist: {artist}\n"
                    f"BPM: {bpm}\n"
                    f"Key: {key}\n\n"
                    f"Sections:\n" + "\n".join(section_info)
                )
                messagebox.showinfo("Chord Sheet Preview", preview)
            except Exception as e:
                self.import_status.set("❌ Preview error occurred.")
                messagebox.showerror("Preview Error", str(e))

    def import_json(self):
        path = filedialog.askopenfilename(
            filetypes=[("JSON Files", "*.json")]
        )
        if path:
            self.import_status.set(
                f"JSON loaded: {os.path.basename(path)} (added to catalog or raw)"
            )
