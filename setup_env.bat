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
echo CarFleetSystem Production Environment Setup
echo Fix: NumPy ABI mismatch for PaddleOCR/OpenCV
echo ========================================
echo.

echo [1/9] Remove old venv completely...
if exist venv rmdir /s /q venv

echo [2/9] Create clean venv...
python -m venv venv
if errorlevel 1 goto fail

echo [3/9] Upgrade pip/setuptools/wheel...
venv\Scripts\python.exe -m pip install --upgrade pip setuptools wheel --timeout 120 --retries 10
if errorlevel 1 goto fail

echo [4/9] Remove conflicting packages if any...
venv\Scripts\python.exe -m pip uninstall -y paddleocr paddlex modelscope torch torchvision torchaudio paddlepaddle opencv-python opencv-contrib-python opencv-python-headless numpy Pillow pillow

echo [5/9] Install NumPy 1.x first. Do NOT use NumPy 2.x with PaddleOCR 2.7.3...
venv\Scripts\python.exe -m pip install --no-cache-dir numpy==1.26.4 Pillow==10.4.0 --timeout 120 --retries 10
if errorlevel 1 goto fail

echo [6/9] Install OpenCV contrib without changing NumPy...
venv\Scripts\python.exe -m pip install --no-cache-dir --no-deps opencv-contrib-python==4.6.0.66 --timeout 120 --retries 10
if errorlevel 1 goto fail

echo [7/9] Install web/report packages...
venv\Scripts\python.exe -m pip install --no-cache-dir flask==3.0.3 werkzeug==3.0.3 pandas==2.2.2 openpyxl==3.1.5 alibabacloud_dysmsapi20170525==3.1.2 --timeout 120 --retries 10
if errorlevel 1 goto fail

echo [8/9] Install PaddleOCR packages...
venv\Scripts\python.exe -m pip install --no-cache-dir paddlepaddle==2.6.2 paddleocr==2.7.3 --timeout 180 --retries 10
if errorlevel 1 goto fail

echo [9/9] Final ABI lock: force NumPy 1.26.4 and single OpenCV package...
venv\Scripts\python.exe -m pip uninstall -y opencv-python opencv-python-headless
venv\Scripts\python.exe -m pip install --no-cache-dir --force-reinstall --no-deps numpy==1.26.4 opencv-contrib-python==4.6.0.66 --timeout 120 --retries 10
if errorlevel 1 goto fail

echo.
echo Running environment diagnosis...
venv\Scripts\python.exe check_numpy_abi.py
if errorlevel 1 goto fail
venv\Scripts\python.exe diagnose_env.py
if errorlevel 1 goto fail

echo.
echo Warming up OCR models into English cache path...
venv\Scripts\python.exe warmup_ocr.py
if errorlevel 1 goto fail

echo.
echo ========================================
echo Environment setup finished.
echo Start with run.bat.
echo ========================================
pause
exit /b 0

:fail
echo.
echo ========================================
echo Environment setup failed.
echo Please copy the error above to ChatGPT.
echo If the error mentions NumPy ABI, close run.bat and run fix_numpy_abi.bat.
echo ========================================
pause
exit /b 1
