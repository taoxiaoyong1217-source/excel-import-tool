@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║          自动安装 Python 并打包 Excel 导入工具            ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: 设置变量
set PYTHON_VERSION=3.11.8
set PYTHON_EMBED_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip
set PYTHON_DIR=%~dp0python_portable
set PYTHON_EXE=%PYTHON_DIR%\python.exe
set GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py

:: 检查是否已有系统 Python
echo [1/7] 检查系统 Python 环境...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到系统已安装 Python
    set USE_SYSTEM_PYTHON=1
    set PYTHON_CMD=python
    goto :install_deps
) else (
    echo ✗ 未检测到系统 Python
    set USE_SYSTEM_PYTHON=0
    set PYTHON_CMD=%PYTHON_EXE%
)
echo.

:: 检查是否已有便携版 Python
if exist "%PYTHON_EXE%" (
    echo [2/7] 检测到便携版 Python，跳过下载...
    goto :configure_python
)

:: 下载 Python embeddable
echo [2/7] 下载 Python %PYTHON_VERSION% 便携版...
echo 下载地址: %PYTHON_EMBED_URL%
echo 目标目录: %PYTHON_DIR%
echo.

if not exist "%PYTHON_DIR%" mkdir "%PYTHON_DIR%"

:: 使用 PowerShell 下载
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%PYTHON_EMBED_URL%' -OutFile '%PYTHON_DIR%\python.zip'}"

if %errorlevel% neq 0 (
    echo ✗ 下载失败，请检查网络连接
    echo.
    echo 你可以手动下载：
    echo %PYTHON_EMBED_URL%
    echo 然后解压到：%PYTHON_DIR%
    pause
    exit /b 1
)

echo ✓ 下载完成
echo.

:: 解压 Python
echo [3/7] 解压 Python...
powershell -Command "& {Expand-Archive -Path '%PYTHON_DIR%\python.zip' -DestinationPath '%PYTHON_DIR%' -Force}"

if %errorlevel% neq 0 (
    echo ✗ 解压失败
    pause
    exit /b 1
)

del "%PYTHON_DIR%\python.zip"
echo ✓ 解压完成
echo.

:configure_python
:: 配置 Python embeddable
echo [4/7] 配置 Python 环境...

:: 启用 site-packages（修改 python311._pth 文件）
for %%f in ("%PYTHON_DIR%\python*._pth") do (
    echo import site>> "%%f"
    echo ✓ 已启用 site-packages
)
echo.

:: 下载并安装 pip
echo [5/7] 安装 pip...
if not exist "%PYTHON_DIR%\Scripts\pip.exe" (
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GET_PIP_URL%' -OutFile '%PYTHON_DIR%\get-pip.py'}"
    
    "%PYTHON_CMD%" "%PYTHON_DIR%\get-pip.py" --no-warn-script-location
    
    if %errorlevel% neq 0 (
        echo ✗ pip 安装失败
        pause
        exit /b 1
    )
    
    del "%PYTHON_DIR%\get-pip.py"
    echo ✓ pip 安装完成
) else (
    echo ✓ pip 已安装
)
echo.

:install_deps
:: 安装依赖
echo [6/7] 安装项目依赖...
echo 这可能需要几分钟，请耐心等待...
echo.

if %USE_SYSTEM_PYTHON% equ 1 (
    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt
) else (
    "%PYTHON_CMD%" -m pip install --upgrade pip --no-warn-script-location
    "%PYTHON_CMD%" -m pip install -r requirements.txt --no-warn-script-location
)

if %errorlevel% neq 0 (
    echo ✗ 依赖安装失败
    pause
    exit /b 1
)

echo.
echo ✓ 依赖安装完成
echo.

:: 清理旧文件
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist

:: 打包
echo [7/7] 开始打包 EXE...
echo 这可能需要 1-3 分钟...
echo.

if %USE_SYSTEM_PYTHON% equ 1 (
    python -m PyInstaller build.spec
) else (
    "%PYTHON_CMD%" -m PyInstaller build.spec
)

if %errorlevel% neq 0 (
    echo ✗ 打包失败
    pause
    exit /b 1
)

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║                    打包成功完成！                          ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 生成的文件位置：
echo %~dp0dist\Excel导入工具.exe
echo.
echo 文件大小：
for %%A in ("dist\Excel导入工具.exe") do echo %%~zA 字节 (约 %%~zA / 1048576 MB)
echo.
echo 提示：
echo • 这个 exe 文件可以在任何 Windows 电脑运行
echo • 无需安装 Python 或任何依赖
echo • 双击即可使用
echo.

:: 询问是否打开目录
set /p OPEN_DIR="是否打开 dist 目录？(Y/N): "
if /i "%OPEN_DIR%"=="Y" (
    explorer "%~dp0dist"
)

pause
