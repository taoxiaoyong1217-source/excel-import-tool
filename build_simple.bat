@echo off
chcp 65001 >nul
echo 开始打包...
pyinstaller --clean build.spec
echo.
echo 打包完成！文件位置: dist\Excel导入工具.exe
pause
