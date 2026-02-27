@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║          手动安装 Python 并打包                            ║
echo ║                                                            ║
╚════════════════════════════════════════════════════════════╝
echo.

:: 设置变量
set PYTHON_INSTALLER=%~dp0python_installer.exe
set PYTHON_INSTALL_DIR=%~dp0python_local

:: 检查是否已有系统 Python
echo [1/5] 检查 Python 环境...
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
    echo [2/5] 检测到本地 Python，跳过安装...
    set PYTHON_CMD=%PYTHON_INSTALL_DIR%\python.exe
    goto :install_deps
)

:: 检查安装程序是否存在
echo [2/5] 检查 Python 安装程序...
if not exist "%PYTHON_INSTALLER%" (
    echo ✗ 未找到 python_installer.exe
    echo.
    echo 请按照以下步骤操作：
    echo.
    echo 1. 手动下载 Python 3.11 安装程序
    echo    推荐下载地址：
    echo    • 官方：https://www.python.org/downloads/
    echo    • 华为云：https://repo.huaweicloud.com/python/3.11.8/python-3.11.8-amd64.exe
    echo    • 淘宝：https://registry.npmmirror.com/-/binary/python/3.11.8/python-3.11.8-amd64.exe
    echo.
    echo 2. 将下载的文件重命名为：python_installer.exe
    echo.
    echo 3. 放在项目根目录（与此脚本同一目录）
    echo.
    echo 4. 重新运行此脚本
    echo.
    echo 详细说明请查看：手动下载Python方案.txt
    echo.
    pause
    exit /b 1
)

:: 检查文件大小
for %%A in ("%PYTHON_INSTALLER%") do set FILE_SIZE=%%~zA
if %FILE_SIZE% LSS 10000000 (
    echo ✗ 安装程序文件太小，可能下载不完整
    echo 文件大小：%FILE_SIZE% 字节
    echo 正常大小应该在 25-30 MB 左右
    echo.
    echo 请重新下载完整的安装程序
    pause
    exit /b 1
)

echo ✓ 找到 Python 安装程序
echo 文件大小：%FILE_SIZE% 字节
echo.

:: 安装 Python
echo [3/5] 安装 Python 到本地目录...
echo 安装位置：%PYTHON_INSTALL_DIR%
echo 这可能需要 1-2 分钟，请耐心等待...
echo.

"%PYTHON_INSTALLER%" /quiet InstallAllUsers=0 PrependPath=0 Include_test=0 TargetDir="%PYTHON_INSTALL_DIR%"

if %errorlevel% neq 0 (
    echo ✗ 安装失败
    echo.
    echo 可能的原因：
    echo 1. 需要管理员权限
    echo 2. 安装程序损坏
    echo 3. 磁盘空间不足
    echo.
    pause
    exit /b 1
)

:: 等待安装完成
echo 等待安装完成...
timeout /t 10 /nobreak >nul

:: 验证安装
if not exist "%PYTHON_INSTALL_DIR%\python.exe" (
    echo ✗ Python 安装失败，未找到 python.exe
    echo.
    echo 请检查：
    echo 1. 是否有足够的磁盘空间
    echo 2. 是否有写入权限
    echo 3. 安装程序是否完整
    echo.
    pause
    exit /b 1
)

echo ✓ Python 安装完成
set PYTHON_CMD=%PYTHON_INSTALL_DIR%\python.exe

:: 验证 Python 版本
"%PYTHON_CMD%" --version
echo.

:install_deps
:: 安装依赖
echo [4/5] 安装项目依赖...
echo 使用国内镜像加速...
echo.

if %USE_SYSTEM_PYTHON% equ 1 (
    echo 升级 pip...
    python -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
    echo.
    echo 安装依赖包...
    python -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
) else (
    echo 升级 pip...
    "%PYTHON_CMD%" -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
    echo.
    echo 安装依赖包...
    "%PYTHON_CMD%" -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
)

if %errorlevel% neq 0 (
    echo ✗ 依赖安装失败，尝试官方源...
    echo.
    
    if %USE_SYSTEM_PYTHON% equ 1 (
        python -m pip install -r requirements.txt
    ) else (
        "%PYTHON_CMD%" -m pip install -r requirements.txt
    )
    
    if !errorlevel! neq 0 (
        echo ✗ 依赖安装失败
        echo.
        echo 请检查：
        echo 1. 网络连接是否正常
        echo 2. requirements.txt 是否存在
        echo.
        pause
        exit /b 1
    )
)

echo.
echo ✓ 依赖安装完成
echo.

:: 验证依赖
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
echo [5/5] 开始打包 EXE...
echo 这可能需要 1-3 分钟...
echo.

if %USE_SYSTEM_PYTHON% equ 1 (
    python -m PyInstaller build.spec --clean
) else (
    "%PYTHON_CMD%" -m PyInstaller build.spec --clean
)

if %errorlevel% neq 0 (
    echo ✗ 打包失败
    echo.
    echo 请检查上面的错误信息
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
    echo 后续操作：
    echo 1. 复制 dist\Excel导入工具.exe 到安全位置
    echo 2. 测试 exe 是否正常运行
    echo 3. 运行 清理Python环境.bat 清理临时文件
    echo 4. 分发 exe 给用户
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
