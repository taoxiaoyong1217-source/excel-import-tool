@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║     自动下载完整版 Python 并打包（推荐方案）              ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: 设置变量
set PYTHON_VERSION=3.11.8
set PYTHON_INSTALLER_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe
set PYTHON_INSTALLER=%~dp0python_installer.exe
set PYTHON_INSTALL_DIR=%~dp0python_local

:: 检查是否已有系统 Python
echo [1/6] 检查 Python 环境...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到系统 Python
    python --version
    set USE_SYSTEM_PYTHON=1
    set PYTHON_CMD=python
    goto :install_deps
) else (
    echo ✗ 未检测到系统 Python
    set USE_SYSTEM_PYTHON=0
)
echo.

:: 检查是否已有本地 Python
if exist "%PYTHON_INSTALL_DIR%\python.exe" (
    echo [2/6] 检测到本地 Python，跳过下载...
    set PYTHON_CMD=%PYTHON_INSTALL_DIR%\python.exe
    goto :install_deps
)

:: 下载 Python 安装程序
echo [2/6] 下载 Python %PYTHON_VERSION% 安装程序...
echo 下载地址: %PYTHON_INSTALLER_URL%
echo 这可能需要几分钟，请耐心等待...
echo.

powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%PYTHON_INSTALLER_URL%' -OutFile '%PYTHON_INSTALLER%' -TimeoutSec 300 } catch { Write-Host '下载失败:' $_.Exception.Message; exit 1 }}"

if %errorlevel% neq 0 (
    echo ✗ 下载失败
    echo.
    echo 请尝试以下方案：
    echo 1. 检查网络连接
    echo 2. 手动下载：%PYTHON_INSTALLER_URL%
    echo 3. 下载后放在项目目录，命名为 python_installer.exe
    echo 4. 重新运行此脚本
    pause
    exit /b 1
)

:: 检查下载的文件
for %%A in ("%PYTHON_INSTALLER%") do set FILE_SIZE=%%~zA
if %FILE_SIZE% LSS 10000000 (
    echo ✗ 下载的文件不完整
    del "%PYTHON_INSTALLER%"
    pause
    exit /b 1
)

echo ✓ 下载完成 (大小: %FILE_SIZE% 字节)
echo.

:: 安装 Python
echo [3/6] 安装 Python 到本地目录...
echo 安装位置: %PYTHON_INSTALL_DIR%
echo 这可能需要 1-2 分钟...
echo.

"%PYTHON_INSTALLER%" /quiet InstallAllUsers=0 PrependPath=0 Include_test=0 TargetDir="%PYTHON_INSTALL_DIR%"

if %errorlevel% neq 0 (
    echo ✗ 安装失败
    pause
    exit /b 1
)

:: 等待安装完成
timeout /t 5 /nobreak >nul

:: 验证安装
if not exist "%PYTHON_INSTALL_DIR%\python.exe" (
    echo ✗ Python 安装失败，未找到 python.exe
    pause
    exit /b 1
)

echo ✓ Python 安装完成
set PYTHON_CMD=%PYTHON_INSTALL_DIR%\python.exe

:: 删除安装程序
if exist "%PYTHON_INSTALLER%" del "%PYTHON_INSTALLER%"
echo.

:install_deps
:: 安装依赖
echo [4/6] 安装项目依赖...
echo 使用国内镜像加速...
echo.

if %USE_SYSTEM_PYTHON% equ 1 (
    python -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
    python -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
) else (
    "%PYTHON_CMD%" -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
    "%PYTHON_CMD%" -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
)

if %errorlevel% neq 0 (
    echo ✗ 依赖安装失败，尝试官方源...
    
    if %USE_SYSTEM_PYTHON% equ 1 (
        python -m pip install -r requirements.txt
    ) else (
        "%PYTHON_CMD%" -m pip install -r requirements.txt
    )
    
    if !errorlevel! neq 0 (
        echo ✗ 依赖安装失败
        pause
        exit /b 1
    )
)

echo.
echo ✓ 依赖安装完成
echo.

:: 清理旧文件
echo [5/6] 清理旧的打包文件...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
echo.

:: 打包
echo [6/6] 开始打包 EXE...
echo 这可能需要 1-3 分钟...
echo.

if %USE_SYSTEM_PYTHON% equ 1 (
    python -m PyInstaller build.spec --clean
) else (
    "%PYTHON_CMD%" -m PyInstaller build.spec --clean
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
echo 生成的文件：
echo %~dp0dist\Excel导入工具.exe
echo.

if exist "dist\Excel导入工具.exe" (
    for %%A in ("dist\Excel导入工具.exe") do (
        set /a SIZE_MB=%%~zA/1048576
        echo 文件大小：!SIZE_MB! MB
    )
    echo.
    echo ✓ EXE 文件已生成
    echo.
    echo 提示：
    echo • 这个 exe 文件可以在任何 Windows 电脑运行
    echo • 无需安装 Python 或任何依赖
    echo • 双击即可使用
    echo.
    echo 清理环境：
    echo • 如需清理本地 Python，运行 清理Python环境.bat
    echo • 或手动删除 python_local 目录
    echo.
    
    set /p OPEN_DIR="是否打开 dist 目录？(Y/N): "
    if /i "!OPEN_DIR!"=="Y" (
        explorer "%~dp0dist"
    )
) else (
    echo ✗ 未找到生成的 EXE 文件
)

echo.
pause
