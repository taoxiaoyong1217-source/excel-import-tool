@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║     一键安装 Python 并打包（使用 winget/choco）           ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: 检查是否已有 Python
echo [检查] 检测 Python 环境...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到 Python
    python --version
    echo.
    goto :build
)

echo ✗ 未检测到 Python
echo.

:: 尝试使用 winget 安装
echo [方案1] 尝试使用 winget 安装 Python...
winget --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到 winget
    echo 正在安装 Python 3.11...
    winget install Python.Python.3.11 --silent --accept-package-agreements --accept-source-agreements
    
    if !errorlevel! equ 0 (
        echo ✓ Python 安装完成
        echo.
        echo 请关闭此窗口，重新运行此脚本
        pause
        exit /b 0
    ) else (
        echo ✗ winget 安装失败
    )
) else (
    echo ✗ 未检测到 winget
)
echo.

:: 尝试使用 chocolatey 安装
echo [方案2] 尝试使用 chocolatey 安装 Python...
choco --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到 chocolatey
    echo 正在安装 Python...
    choco install python311 -y
    
    if !errorlevel! equ 0 (
        echo ✓ Python 安装完成
        echo.
        echo 请关闭此窗口，重新运行此脚本
        pause
        exit /b 0
    ) else (
        echo ✗ chocolatey 安装失败
    )
) else (
    echo ✗ 未检测到 chocolatey
)
echo.

:: 提示手动安装
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║              无法自动安装 Python                           ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 请选择以下方案之一：
echo.
echo [方案A] 手动安装 Python（推荐）
echo   1. 访问：https://www.python.org/downloads/
echo   2. 下载 Python 3.11 或 3.10
echo   3. 安装时勾选 "Add Python to PATH"
echo   4. 安装完成后重新运行此脚本
echo.
echo [方案B] 使用便携版（自动下载）
echo   运行：自动安装并打包-增强版.bat
echo.
echo [方案C] 使用 Microsoft Store
echo   1. 打开 Microsoft Store
echo   2. 搜索 "Python 3.11"
echo   3. 点击安装
echo   4. 安装完成后重新运行此脚本
echo.
pause
exit /b 1

:build
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║                  开始打包项目                              ║
echo ║                                                            ║
╚════════════════════════════════════════════════════════════╝
echo.

echo [1/3] 升级 pip...
python -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
echo.

echo [2/3] 安装依赖...
python -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if %errorlevel% neq 0 (
    echo ✗ 依赖安装失败
    pause
    exit /b 1
)
echo.

echo [3/3] 打包 EXE...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist

python -m PyInstaller build.spec --clean
if %errorlevel% neq 0 (
    echo ✗ 打包失败
    pause
    exit /b 1
)

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║                    打包完成！                              ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 文件位置：dist\Excel导入工具.exe
echo.

if exist "dist\Excel导入工具.exe" (
    for %%A in ("dist\Excel导入工具.exe") do (
        set /a SIZE_MB=%%~zA/1048576
        echo 文件大小：!SIZE_MB! MB
    )
    
    set /p OPEN="是否打开 dist 目录？(Y/N): "
    if /i "!OPEN!"=="Y" explorer dist
)

pause
