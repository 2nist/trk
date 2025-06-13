# Process Groove MIDI Dataset
Write-Host "Processing Groove MIDI Dataset..." -ForegroundColor Green
Write-Host ""

# Navigate to the repository root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptPath

# Check for Python environment
try {
    python -c "import pretty_midi, numpy, matplotlib" 2>$null
} catch {
    Write-Host "Required Python packages not found." -ForegroundColor Yellow
    Write-Host "Installing required packages..." -ForegroundColor Yellow
    pip install pretty_midi numpy matplotlib
}

# Create necessary directories
$directories = @(
    "$repoRoot\data\midi\groove_midi",
    "$repoRoot\data\metadata\groove_midi",
    "$repoRoot\data\jcrd_library\groove_midi"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir"
    }
}

# Extract all files from the dataset and create index
Write-Host "Extracting MIDI files and creating index..." -ForegroundColor Cyan
python "$repoRoot\tools\groove_midi_explorer.py" --extract --create-index --verbose

# Convert to JCRD format (optional)
Write-Host ""
$convert = Read-Host "Do you want to convert files to JCRD format? (Y/N)"
if ($convert -eq "Y" -or $convert -eq "y") {
    Write-Host "Converting to JCRD format..." -ForegroundColor Cyan
    python "$repoRoot\tools\groove_midi_explorer.py" --convert --verbose
}

# Create visualizations (optional)
Write-Host ""
$visualize = Read-Host "Do you want to create pattern visualizations? (Y/N)"
if ($visualize -eq "Y" -or $visualize -eq "y") {
    Write-Host "Creating visualizations..." -ForegroundColor Cyan
    python "$repoRoot\tools\groove_midi_explorer.py" --visualize --verbose
}

# Prepare REAPER files (optional)
Write-Host ""
$prepare = Read-Host "Do you want to create REAPER project files? (Y/N)"
if ($prepare -eq "Y" -or $prepare -eq "y") {
    Write-Host "Preparing REAPER files..." -ForegroundColor Cyan
    python "$repoRoot\tools\groove_midi_explorer.py" --prepare --verbose
}

Write-Host ""
Write-Host "Groove MIDI processing complete!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now use the drum_pattern_browser.lua script in REAPER to browse and use the patterns." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to continue"
