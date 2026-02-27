@echo off
chcp 65001 >nul
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║          上传项目到 GitHub                                 ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: 检查是否安装了 Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ 未检测到 Git
    echo.
    echo 请先安装 Git：
    echo https://git-scm.com/download/win
    echo.
    echo 或使用 GitHub Desktop：
    echo https://desktop.github.com/
    echo.
    pause
    exit /b 1
)

echo ✓ 检测到 Git
git --version
echo.

:: 检查是否已经初始化
if exist ".git" (
    echo ✓ Git 仓库已初始化
) else (
    echo 初始化 Git 仓库...
    git init
    git branch -M main
    echo ✓ Git 仓库初始化完成
)
echo.

:: 添加所有文件
echo 添加文件到 Git...
git add .
echo ✓ 文件已添加
echo.

:: 提交
echo 提交更改...
set /p COMMIT_MSG="请输入提交信息（直接回车使用默认）: "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=初始提交

git commit -m "%COMMIT_MSG%"
echo ✓ 更改已提交
echo.

:: 询问仓库地址
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 请输入 GitHub 仓库地址
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 格式示例：
echo https://github.com/你的用户名/excel-import-tool.git
echo.

set /p REPO_URL="仓库地址: "

if "%REPO_URL%"=="" (
    echo ✗ 未输入仓库地址
    echo.
    echo 请先在 GitHub 创建仓库，然后重新运行此脚本
    pause
    exit /b 1
)

:: 检查是否已添加 remote
git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo 更新远程仓库地址...
    git remote set-url origin %REPO_URL%
) else (
    echo 添加远程仓库...
    git remote add origin %REPO_URL%
)
echo ✓ 远程仓库已配置
echo.

:: 推送到 GitHub
echo 推送到 GitHub...
echo 这可能需要输入 GitHub 用户名和密码/Token
echo.

git push -u origin main

if %errorlevel% neq 0 (
    echo ✗ 推送失败
    echo.
    echo 可能的原因：
    echo 1. 仓库地址错误
    echo 2. 没有权限
    echo 3. 需要配置 GitHub 认证
    echo.
    echo 请检查后重试
    pause
    exit /b 1
)

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║                    上传成功！                              ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 后续步骤：
echo 1. 访问你的 GitHub 仓库
echo 2. 点击 "Actions" 标签
echo 3. 查看自动打包进度
echo 4. 打包完成后下载 exe
echo.
echo 仓库地址：%REPO_URL%
echo.

set /p OPEN_BROWSER="是否在浏览器中打开仓库？(Y/N): "
if /i "%OPEN_BROWSER%"=="Y" (
    start %REPO_URL:~0,-4%
)

pause
