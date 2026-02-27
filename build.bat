@echo off
chcp 65001 >nul
echo ========================================
echo Excel 导入工具 - 自动打包脚本
echo ========================================
echo.

echo [1/4] 检查 Python 环境...
python --version
if errorlevel 1 (
    echo 错误: 未找到 Python，请先安装 Python 3.10+
    pause
    exit /b 1
)
echo.

echo [2/4] 安装依赖包...
pip install -r requirements.txt
if errorlevel 1 (
    echo 错误: 依赖安装失败
    pause
    exit /b 1
)
echo.

echo [3/4] 清理旧的打包文件...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist "Excel导入工具.spec" del /q "Excel导入工具.spec"
echo.

echo [4/4] 开始打包...
pyinstaller build.spec
if errorlevel 1 (
    echo 错误: 打包失败
    pause
    exit /b 1
)
echo.

echo ========================================
echo 打包完成！
echo ========================================
echo.
echo 生成的文件位置: dist\Excel导入工具.exe
echo.
echo 提示: 首次运行时会在 exe 同目录生成 config.json 配置文件
echo.
pause
