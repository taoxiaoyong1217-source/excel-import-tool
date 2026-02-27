@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║          自动安装 Python 并打包 Excel 导入工具            ║
echo ║                  (增强版 - 支持国内镜像)                  ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: 设置变量
set PYTHON_VERSION=3.11.8
set PYTHON_EMBED_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip
set PYTHON_EMBED_URL_CN=https://registry.npmmirror.com/-/binary/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip
set PYTHON_DIR=%~dp0python_portable
set PYTHON_EXE=%PYTHON_DIR%\python.exe
set GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py
set GET_PIP_URL_CN=https://registry.npmmirror.com/-/binary/python-get-pip/get-pip.py

:: 检查是否已有系统 Python
echo [1/7] 检查系统 Python 环境...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到系统已安装 Python
    python --version
    set USE_SYSTEM_PYTHON=1
    set PYTHON_CMD=python
    goto :install_deps
) else (
    echo ✗ 未检测到系统 Python，将使用便携版
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
echo.

if not exist "%PYTHON_DIR%" mkdir "%PYTHON_DIR%"

:: 尝试从官方源下载
echo 尝试从官方源下载...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%PYTHON_EMBED_URL%' -OutFile '%PYTHON_DIR%\python.zip' -TimeoutSec 60 } catch { exit 1 }}"

if %errorlevel% neq 0 (
    echo ✗ 官方源下载失败，尝试国内镜像...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%PYTHON_EMBED_URL_CN%' -OutFile '%PYTHON_DIR%\python.zip' -TimeoutSec 60 } catch { exit 1 }}"
    
    if !errorlevel! neq 0 (
        echo ✗ 下载失败
        echo.
        echo 请手动下载 Python embeddable 版本：
        echo 官方：%PYTHON_EMBED_URL%
        echo 镜像：%PYTHON_EMBED_URL_CN%
        echo.
        echo 下载后解压到：%PYTHON_DIR%
        pause
        exit /b 1
    )
)

:: 检查下载的文件大小
for %%A in ("%PYTHON_DIR%\python.zip") do set FILE_SIZE=%%~zA
if %FILE_SIZE% LSS 1000000 (
    echo ✗ 下载的文件不完整，请重试
    del "%PYTHON_DIR%\python.zip"
    pause
    exit /b 1
)

echo ✓ 下载完成 (大小: %FILE_SIZE% 字节)
echo.

:: 解压 Python
echo [3/7] 解压 Python...
powershell -Command "& {try { Expand-Archive -Path '%PYTHON_DIR%\python.zip' -DestinationPath '%PYTHON_DIR%' -Force } catch { Write-Host $_.Exception.Message; exit 1 }}"

if %errorlevel% neq 0 (
    echo ✗ 解压失败，文件可能损坏
    del "%PYTHON_DIR%\python.zip"
    pause
    exit /b 1
)

del "%PYTHON_DIR%\python.zip"
echo ✓ 解压完成
echo.

:configure_python
:: 配置 Python embeddable
echo [4/7] 配置 Python 环境...

:: 启用 site-packages（修改 python*._pth 文件）
for %%f in ("%PYTHON_DIR%\python*._pth") do (
    echo 正在配置 %%f
    
    :: 备份原文件
    copy "%%f" "%%f.bak" >nul 2>&1
    
    :: 创建新的配置文件
    (
        echo python311.zip
        echo .
        echo.
        echo # Uncomment to run site.main automatically
        echo import site
    ) > "%%f"
    
    echo ✓ 已启用 site-packages
)
echo.

:: 下载并安装 pip
echo [5/7] 安装 pip...

echo 下载 get-pip.py...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -Uri '%GET_PIP_URL%' -OutFile '%PYTHON_DIR%\get-pip.py' -TimeoutSec 30 } catch { Invoke-WebRequest -Uri '%GET_PIP_URL_CN%' -OutFile '%PYTHON_DIR%\get-pip.py' -TimeoutSec 30 }}"

if %errorlevel% neq 0 (
    echo ✗ 下载 get-pip.py 失败
    pause
    exit /b 1
)

echo 安装 pip...
"%PYTHON_CMD%" "%PYTHON_DIR%\get-pip.py" --no-warn-script-location

if %errorlevel% neq 0 (
    echo ✗ pip 安装失败
    echo.
    echo 尝试使用 ensurepip...
    "%PYTHON_CMD%" -m ensurepip --default-pip
    
    if !errorlevel! neq 0 (
        echo ✗ pip 安装失败，请检查 Python 环境
        pause
        exit /b 1
    )
)

if exist "%PYTHON_DIR%\get-pip.py" del "%PYTHON_DIR%\get-pip.py"

:: 验证 pip 安装
"%PYTHON_CMD%" -m pip --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ pip 安装完成
    "%PYTHON_CMD%" -m pip --version
) else (
    echo ✗ pip 验证失败
    pause
    exit /b 1
)
echo.

:install_deps
:: 安装依赖
echo [6/7] 安装项目依赖...
echo 使用国内镜像加速下载...
echo.

:: 先升级 pip
echo 升级 pip...
if %USE_SYSTEM_PYTHON% equ 1 (
    python -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
) else (
    "%PYTHON_CMD%" -m pip install --upgrade pip --no-warn-script-location -i https://pypi.tuna.tsinghua.edu.cn/simple
)
echo.

:: 安装依赖
echo 安装项目依赖包...
if %USE_SYSTEM_PYTHON% equ 1 (
    python -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir
) else (
    "%PYTHON_CMD%" -m pip install -r requirements.txt --no-warn-script-location -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir
)

if %errorlevel% neq 0 (
    echo ✗ 国内镜像安装失败，尝试使用官方源...
    echo.
    
    if %USE_SYSTEM_PYTHON% equ 1 (
        python -m pip install -r requirements.txt --no-cache-dir
    ) else (
        "%PYTHON_CMD%" -m pip install -r requirements.txt --no-warn-script-location --no-cache-dir
    )
    
    if !errorlevel! neq 0 (
        echo ✗ 依赖安装失败
        echo.
        echo 请检查：
        echo 1. 网络连接是否正常
        echo 2. requirements.txt 文件是否存在
        echo 3. Python 环境是否正确配置
        pause
        exit /b 1
    )
)

echo.
echo ✓ 依赖安装完成
echo.

:: 验证关键依赖
echo 验证依赖安装...
if %USE_SYSTEM_PYTHON% equ 1 (
    python -c "import customtkinter; import requests; import openpyxl; import PyInstaller; print('✓ 所有依赖已正确安装')"
) else (
    "%PYTHON_CMD%" -c "import customtkinter; import requests; import openpyxl; import PyInstaller; print('✓ 所有依赖已正确安装')"
)

if %errorlevel% neq 0 (
    echo ✗ 依赖验证失败
    pause
    exit /b 1
)
echo.

:: 清理旧文件
echo 清理旧的打包文件...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
echo.

:: 打包
echo [7/7] 开始打包 EXE...
echo 这可能需要 1-3 分钟，请耐心等待...
echo.

if %USE_SYSTEM_PYTHON% equ 1 (
    python -m PyInstaller build.spec --clean
) else (
    "%PYTHON_CMD%" -m PyInstaller build.spec --clean
)

if %errorlevel% neq 0 (
    echo ✗ 打包失败
    echo.
    echo 请检查错误信息
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
    
    :: 询问是否打开目录
    set /p OPEN_DIR="是否打开 dist 目录？(Y/N): "
    if /i "!OPEN_DIR!"=="Y" (
        explorer "%~dp0dist"
    )
) else (
    echo ✗ 未找到生成的 EXE 文件
    echo 请检查 build 目录中的错误日志
)

echo.
pause
