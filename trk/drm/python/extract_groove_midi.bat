@echo off
echo Processing Groove MIDI Dataset...
echo.

REM Navigate to the repository root
cd /d %~dp0\..\

REM Check for Python environment
python -c "import pretty_midi, numpy, matplotlib" 2>nul
if %errorlevel% neq 0 (
    echo Required Python packages not found.
    echo Installing required packages...
    pip install pretty_midi numpy matplotlib
)

REM Create necessary directories
mkdir data\midi\groove_midi 2>nul
mkdir data\metadata\groove_midi 2>nul
mkdir data\jcrd_library\groove_midi 2>nul

REM Extract all files from the dataset and create index
echo Extracting MIDI files and creating index...
python tools\groove_midi_explorer.py --extract --create-index --verbose

REM Convert to JCRD format (optional)
echo.
set /p convert="Do you want to convert files to JCRD format? (Y/N): "
if /i "%convert%"=="Y" (
    echo Converting to JCRD format...
    python tools\groove_midi_explorer.py --convert --verbose
)

REM Create visualizations (optional)
echo.
set /p visualize="Do you want to create pattern visualizations? (Y/N): "
if /i "%visualize%"=="Y" (
    echo Creating visualizations...
    python tools\groove_midi_explorer.py --visualize --verbose
)

REM Prepare REAPER files (optional)
echo.
set /p prepare="Do you want to create REAPER project files? (Y/N): "
if /i "%prepare%"=="Y" (
    echo Preparing REAPER files...
    python tools\groove_midi_explorer.py --prepare --verbose
)

echo.
echo Groove MIDI processing complete!
echo.
echo You can now use the drum_pattern_browser.lua script in REAPER to browse and use the patterns.
echo.
pause
