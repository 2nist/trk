@echo off
REM Extract a .tar.gz file using Python
REM Usage: extract_tar_gz.bat file.tar.gz [destination_directory]

if "%1"=="" (
    echo Error: Please provide the path to a .tar.gz file.
    echo Usage: extract_tar_gz.bat file.tar.gz [destination_directory]
    exit /b 1
)

set ARCHIVE_PATH=%1
set EXTRACT_DIR=%2

if "%EXTRACT_DIR%"=="" (
    python %~dp0\extract_tar_gz.py "%ARCHIVE_PATH%"
) else (
    python %~dp0\extract_tar_gz.py "%ARCHIVE_PATH%" -d "%EXTRACT_DIR%"
)

if %ERRORLEVEL% NEQ 0 (
    echo Extraction failed.
    exit /b %ERRORLEVEL%
)

echo Extraction completed successfully.
exit /b 0
