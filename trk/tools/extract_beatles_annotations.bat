@echo off
echo Beatles Annotation Extractor
echo ===========================
echo.

REM Get the path to the archive file
set /p archive_path="Enter the full path to The Beatles Annotations.tar.gz file: "

REM Run the Python script
python "%~dp0\extract_beatles_annotations.py" "%archive_path%"

echo.
pause
