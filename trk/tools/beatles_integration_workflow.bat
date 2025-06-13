@echo off
echo Beatles Dataset Integration Workflow
echo =================================
echo.
echo This script will guide you through the process of integrating the Beatles dataset into Songbase.
echo.
echo Steps:
echo 1. Extract the Beatles annotations from the tar.gz archive
echo 2. Convert the annotations to JCRD format
echo 3. Validate the converted JCRD files
echo 4. Update the Beatles index file
echo.
echo Prerequisites:
echo - Python 3.6+ installed
echo - The Beatles Annotations.tar.gz file
echo.
echo Press any key to start...
pause > nul

cls
echo STEP 1: Extract Beatles Annotations
echo ------------------------------------
echo.
call "%~dp0extract_beatles_annotations.bat"
echo.
echo Extraction complete. Press any key to continue...
pause > nul

cls
echo STEP 2: Convert Annotations to JCRD Format
echo -------------------------------------------
echo.
python "%~dp0convert_beatles_annotations.py"
echo.
echo Conversion complete. Press any key to continue...
pause > nul

cls
echo STEP 3: Validate JCRD Files
echo ----------------------------
echo.
python "%~dp0validate_beatles_jcrd.py"
echo.
echo Validation complete. Press any key to continue...
pause > nul

cls
echo STEP 4: Update Beatles Index File
echo ---------------------------------
echo.
echo Creating index file for the Beatles dataset...
python "%~dp0create_beatles_index.py"
echo.
echo Index creation complete.
echo.
echo Beatles dataset integration workflow complete!
echo.
echo You can now use the Beatles dataset in Songbase.
echo The JCRD files are located in:
echo data\jcrd_library\beatles_full
echo.
pause
