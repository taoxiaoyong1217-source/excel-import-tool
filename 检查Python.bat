@echo off
chcp 65001 >nul
echo ========================================
echo Python 环境检查工具
echo ========================================
echo.

echo [检查 1] 检查 Python 是否安装...
python --version 2>nul
if errorlevel 1 (
    echo ✗ 未找到 Python
    echo.
    echo 请先安装 Python 3.10 或更高版本
    echo 详见：安装Python指南.txt
    echo.
    pause
    exit /b 1
) else (
    echo ✓ Python 已安装
)
echo.

echo [检查 2] 检查 pip 是否可用...
pip --version 2>nul
if errorlevel 1 (
    echo ✗ pip 不可用
    echo.
    pause
    exit /b 1
) else (
    echo ✓ pip 可用
)
echo.

echo [检查 3] 检查 Python 版本...
python -c "import sys; exit(0 if sys.version_info >= (3, 10) else 1)" 2>nul
if errorlevel 1 (
    echo ✗ Python 版本过低，需要 3.10 或更高
    echo.
    pause
    exit /b 1
) else (
    echo ✓ Python 版本符合要求
)
echo.

echo ========================================
echo 环境检查通过！
echo ========================================
echo.
echo 你可以开始打包了：
echo 1. 双击 build.bat 开始打包
echo 2. 或双击 test_run.bat 先测试运行
echo.
pause
