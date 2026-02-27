# Excel 运势数据导入工具

一个基于 Python 和 customtkinter 的 Windows 桌面应用程序，用于将 Excel 文件导入到不同环境的 API。

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/你的用户名/excel-import-tool/build.yml?branch=main)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/你的用户名/excel-import-tool)
![GitHub](https://img.shields.io/github/license/你的用户名/excel-import-tool)

## 功能特性

- ✅ 深色模式现代化界面
- ✅ 支持三种导入类型（每日/每周/每月运势）
- ✅ 支持四种环境（dev/test/pre/prod）
- ✅ 可视化环境配置管理
- ✅ 实时日志显示
- ✅ API 返回状态显示
- ✅ 多线程上传，界面不卡顿
- ✅ 完整的异常处理
- ✅ 打包为独立 EXE，无需 Python 环境

## 快速开始

### 方式 1：下载已打包的 EXE（推荐）

1. 访问 [Releases](https://github.com/你的用户名/excel-import-tool/releases) 页面
2. 下载最新版本的 `Excel导入工具-vX.X.X.exe`
3. 双击运行（无需安装）

### 方式 2：从源码运行

```bash
# 克隆仓库
git clone https://github.com/你的用户名/excel-import-tool.git
cd excel-import-tool

# 安装依赖
pip install -r requirements.txt

# 运行程序
python main.py
```

### 方式 3：本地打包

```bash
# 安装依赖
pip install -r requirements.txt

# 打包
pyinstaller build.spec
```

生成的 exe 文件位于 `dist/Excel导入工具.exe`

## 使用说明

1. 首次运行会自动生成 `config.json` 配置文件
2. 点击"环境配置"按钮配置各环境的 API 地址和 CLIENT_ID
3. 在主界面输入 Authorization Token
4. 选择导入类型（每日/每周/每月）
5. 选择目标环境（dev/test/pre/prod）
6. 点击"浏览"选择 Excel 文件（.xlsx 或 .xls）
7. 点击"开始导入"执行上传
8. 查看日志和 API 返回状态

## 配置文件

`config.json` 文件结构：

```json
{
  "dev": {
    "daily": "http://dev-api.example.com/api/xingchen/fate-v2/import-fate-daily",
    "weekly": "http://dev-api.example.com/api/xingchen/fate-v2/import-fate-weekly",
    "monthly": "http://dev-api.example.com/api/xingchen/fate-v2/import-fate-monthly",
    "client_id": "0"
  },
  "test": { ... },
  "pre": { ... },
  "prod": { ... }
}
```

## API 要求

API 需要满足以下规范：

- 接受 POST 请求
- 使用 multipart/form-data 格式
- 文件字段名为 `file`
- 请求头包含：
  - `Authorization`: 用户认证 Token（界面输入）
  - `CLIENT_ID`: 客户端 ID（配置文件中）
- 返回 JSON 格式：
  ```json
  {
    "code": 0,
    "msg": "成功消息"
  }
  ```
- code=0 表示成功，其他值表示失败

### 请求示例

```bash
curl --location --request POST '/api/xingchen/fate-v2/import-fate-daily' \
--header 'Authorization: 9e5311a6-f792-495a-a7ae-66dfb03d6e4c-1896488519313035264' \
--header 'CLIENT_ID: 0' \
--form 'file=@"your-file.xlsx"'
```

## 开发

### 项目结构

```
.
├── main.py              # 程序入口
├── main_window.py       # 主窗口界面
├── config_window.py     # 环境配置窗口
├── config_manager.py    # 配置管理模块
├── api_client.py        # API 客户端模块
├── config.json          # 配置文件
├── requirements.txt     # 依赖列表
├── build.spec          # PyInstaller 配置
└── .github/
    └── workflows/
        ├── build.yml    # 自动构建
        └── release.yml  # 发布版本
```

### 技术栈

- Python 3.10+
- customtkinter 5.2.1 - 现代化 GUI 框架
- requests 2.31.0 - HTTP 客户端
- openpyxl 3.1.2 - Excel 文件支持
- pyinstaller 6.3.0 - 打包工具

### 本地开发

```bash
# 安装依赖
pip install -r requirements.txt

# 运行程序
python main.py

# 打包
pyinstaller build.spec
```

## GitHub Actions 自动打包

本项目配置了 GitHub Actions，可以自动在云端打包：

1. 推送代码到 GitHub
2. GitHub Actions 自动开始打包
3. 在 Actions 页面下载打包好的 exe

详见 [GitHub Actions 使用指南.txt](GitHub%20Actions%20使用指南.txt)

## 发布新版本

```bash
# 创建并推送 tag
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 会自动创建 Release 并上传 exe 文件。

## 系统要求

- Windows 7 或更高版本
- 64 位系统
- 可能需要 Visual C++ Redistributable（大部分系统已安装）

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### v1.0.0 (2026-02-27)

- 首次发布
- 支持三种导入类型
- 支持四种环境配置
- 深色模式界面
- 实时日志显示

## 联系方式

如有问题，请提交 [Issue](https://github.com/你的用户名/excel-import-tool/issues)
