@echo off
chcp 65001 >nul
echo ========================================
echo 测试运行 Excel 导入工具
echo ========================================
echo.

echo 检查 Python 环境...
python --version
if errorlevel 1 (
    echo 错误: 未找到 Python
    pause
    exit /b 1
)
echo.

echo 检查依赖...
pip show customtkinter >nul 2>&1
if errorlevel 1 (
    echo 正在安装依赖...
    pip install -r requirements.txt
)
echo.

echo 启动程序...
python main.py
