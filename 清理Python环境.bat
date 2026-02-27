@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║              清理 Python 便携版环境                        ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

set PYTHON_DIR=%~dp0python_portable
set PYTHON_LOCAL_DIR=%~dp0python_local
set BUILD_DIR=%~dp0build
set DIST_DIR=%~dp0dist

echo 此脚本将删除以下内容：
echo.
echo [1] Python 便携版环境
if exist "%PYTHON_DIR%" (
    for /f "tokens=3" %%a in ('dir /-c "%PYTHON_DIR%" ^| find "File(s)"') do set SIZE=%%a
    echo     位置：%PYTHON_DIR%
    echo     大小：约 !SIZE! 字节
    echo     状态：✓ 存在
) else (
    echo     位置：%PYTHON_DIR%
    echo     状态：✗ 不存在
)
echo.

echo [2] Python 本地安装
if exist "%PYTHON_LOCAL_DIR%" (
    echo     位置：%PYTHON_LOCAL_DIR%
    echo     状态：✓ 存在
) else (
    echo     位置：%PYTHON_LOCAL_DIR%
    echo     状态：✗ 不存在
)
echo.

echo [3] 打包临时文件
if exist "%BUILD_DIR%" (
    echo     位置：%BUILD_DIR%
    echo     状态：✓ 存在
) else (
    echo     位置：%BUILD_DIR%
    echo     状态：✗ 不存在
)
echo.

echo [3] 打包输出目录（可选）
if exist "%DIST_DIR%" (
    echo     位置：%DIST_DIR%
    echo     状态：✓ 存在
    if exist "%DIST_DIR%\Excel导入工具.exe" (
        echo     包含：Excel导入工具.exe
    )
) else (
    echo     位置：%DIST_DIR%
    echo     状态：✗ 不存在
)
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 注意事项：
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo • Python 便携版：可以安全删除，不影响系统
echo • 打包临时文件：可以安全删除
echo • 打包输出目录：包含生成的 exe，建议先备份
echo.
echo • 如果你已经复制了 Excel导入工具.exe，可以全部删除
echo • 如果以后还要打包，删除后会重新下载 Python
echo.

set /p CONFIRM="确认删除？(Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo 已取消操作
    pause
    exit /b 0
)

echo.
echo 开始清理...
echo.

:: 删除 Python 便携版
if exist "%PYTHON_DIR%" (
    echo [1/4] 删除 Python 便携版...
    rmdir /s /q "%PYTHON_DIR%"
    if !errorlevel! equ 0 (
        echo ✓ 已删除 Python 便携版
    ) else (
        echo ✗ 删除失败，可能有文件正在使用
    )
) else (
    echo [1/4] Python 便携版不存在，跳过
)
echo.

:: 删除 Python 本地安装
if exist "%PYTHON_LOCAL_DIR%" (
    echo [2/4] 删除 Python 本地安装...
    rmdir /s /q "%PYTHON_LOCAL_DIR%"
    if !errorlevel! equ 0 (
        echo ✓ 已删除 Python 本地安装
    ) else (
        echo ✗ 删除失败，可能有文件正在使用
    )
) else (
    echo [2/4] Python 本地安装不存在，跳过
)
echo.

:: 删除 build 目录
if exist "%BUILD_DIR%" (
    echo [3/4] 删除打包临时文件...
    rmdir /s /q "%BUILD_DIR%"
    if !errorlevel! equ 0 (
        echo ✓ 已删除打包临时文件
    ) else (
        echo ✗ 删除失败
    )
) else (
    echo [3/4] 打包临时文件不存在，跳过
)
echo.

:: 询问是否删除 dist 目录
if exist "%DIST_DIR%" (
    echo [4/4] 处理打包输出目录...
    
    if exist "%DIST_DIR%\Excel导入工具.exe" (
        echo.
        echo ⚠️  警告：dist 目录包含生成的 exe 文件
        set /p DEL_DIST="是否也删除 dist 目录？(Y/N): "
        
        if /i "!DEL_DIST!"=="Y" (
            rmdir /s /q "%DIST_DIR%"
            if !errorlevel! equ 0 (
                echo ✓ 已删除 dist 目录
            ) else (
                echo ✗ 删除失败
            )
        ) else (
            echo ✓ 保留 dist 目录
        )
    ) else (
        rmdir /s /q "%DIST_DIR%"
        if !errorlevel! equ 0 (
            echo ✓ 已删除 dist 目录
        ) else (
            echo ✗ 删除失败
        )
    )
) else (
    echo [3/3] dist 目录不存在，跳过
)
echo.

echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║                    清理完成！                              ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 已清理的内容：
if not exist "%PYTHON_DIR%" echo ✓ Python 便携版
if not exist "%PYTHON_LOCAL_DIR%" echo ✓ Python 本地安装
if not exist "%BUILD_DIR%" echo ✓ 打包临时文件
if not exist "%DIST_DIR%" echo ✓ 打包输出目录
echo.
echo 提示：
echo • 源代码文件未被删除
echo • 如需重新打包，再次运行打包脚本即可
echo • Python 会重新下载（约 5-10 分钟）
echo.
pause
