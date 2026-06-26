@echo off
cd /d %~dp0
set OCR_ASCII_HOME=%~d0\CarFleetSystem_OCR_Cache
set HOME=%OCR_ASCII_HOME%
set USERPROFILE=%OCR_ASCII_HOME%
set PADDLEOCR_HOME=%OCR_ASCII_HOME%\.paddleocr
set PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
set PIP_TRUSTED_HOST=pypi.tuna.tsinghua.edu.cn
set PIP_DISABLE_PIP_VERSION_CHECK=1

chcp 65001 >nul

echo ========================================
echo Fix NumPy ABI mismatch
echo ========================================
echo This fixes errors like:
echo   module compiled against ABI version 0x1000009 but this version of numpy is 0x2000000
echo   numpy.core.multiarray failed to import
echo.
echo Please close run.bat / Flask window before continuing.
echo.
pause

if not exist venv\Scripts\python.exe (
    echo ERROR: venv\Scripts\python.exe not found. Run setup_env.bat first.
    pause
    exit /b 1
)

echo [1/4] Remove NumPy/OpenCV packages...
venv\Scripts\python.exe -m pip uninstall -y numpy opencv-python opencv-python-headless opencv-contrib-python

echo [2/4] Install NumPy 1.26.4...
venv\Scripts\python.exe -m pip install --no-cache-dir --force-reinstall --no-deps numpy==1.26.4 --timeout 120 --retries 10
if errorlevel 1 goto fail

echo [3/4] Install OpenCV contrib 4.6.0.66 without changing NumPy...
venv\Scripts\python.exe -m pip install --no-cache-dir --force-reinstall --no-deps opencv-contrib-python==4.6.0.66 --timeout 120 --retries 10
if errorlevel 1 goto fail

<<<<<<< HEAD
echo [4/5] Repair Paddle google/protobuf dependency...
venv\Scripts\python.exe -m pip install --no-cache-dir --force-reinstall protobuf==3.20.2 --timeout 120 --retries 10
if errorlevel 1 goto fail

echo [5/5] Verify imports...
=======
echo [4/4] Verify imports...
>>>>>>> 55a777a7d7dc7a1e307a6131d3c93efa554ea949
venv\Scripts\python.exe check_numpy_abi.py
if errorlevel 1 goto fail
venv\Scripts\python.exe warmup_ocr.py
if errorlevel 1 goto fail

echo.
echo ========================================
echo Fixed. Now run run.bat again.
echo ========================================
pause
exit /b 0

:fail
echo.
echo ========================================
echo NumPy ABI fix failed. Copy the error above to ChatGPT.
echo ========================================
pause
exit /b 1
