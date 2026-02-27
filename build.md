# Excel 导入工具打包说明

## 环境要求

- Python 3.10 或更高版本
- Windows 操作系统

## 快速打包（推荐）

### 方法一：使用自动打包脚本（最简单）

双击运行 `build.bat` 文件，脚本会自动完成：
1. 检查 Python 环境
2. 安装所有依赖
3. 清理旧文件
4. 执行打包

打包完成后，exe 文件位于 `dist\Excel导入工具.exe`

### 方法二：使用简化脚本（已安装依赖）

如果已经安装过依赖，可以双击运行 `build_simple.bat`，快速打包。

### 方法三：手动命令行打包

在项目根目录执行：

```bash
# 1. 安装依赖
pip install -r requirements.txt

# 2. 使用 spec 文件打包
pyinstaller build.spec
```

## 打包配置说明

项目已包含优化的 `build.spec` 配置文件，特点：

- `--onefile`: 打包成单个 exe 文件
- `--windowed`: 无控制台窗口（纯 GUI）
- `upx=True`: 启用 UPX 压缩（减小文件体积）
- 自动包含 config.json
- 预配置所有必要的隐藏导入

## 打包输出

打包完成后，生成的文件：
- `dist\Excel导入工具.exe` - 独立可执行文件（约 30-50 MB）
- `build\` - 临时构建文件（可删除）

## 分发说明

### 独立分发（推荐）

只需分发 `dist\Excel导入工具.exe` 文件即可！

- ✓ 无需安装 Python
- ✓ 无需安装任何依赖
- ✓ 双击即可运行
- ✓ 首次运行自动生成 config.json

### 预配置分发

如果想预先配置好 API 地址，可以：
1. 分发 `Excel导入工具.exe`
2. 同时分发编辑好的 `config.json`（放在同一目录）

## 在目标机器上运行

1. 将 `Excel导入工具.exe` 复制到任意目录
2. 双击运行（无需安装任何东西）
3. 首次运行会在同目录生成 config.json
4. 点击"环境配置"按钮配置 API 地址
5. 开始使用

## 注意事项

1. 首次运行时，程序会在同目录下自动生成 `config.json` 配置文件
2. 如果打包时遇到 DLL 缺失问题，可以添加 `--hidden-import` 参数
3. 如果需要更小的文件体积，可以使用 UPX 压缩（需要单独安装 UPX）
4. 建议在打包前测试所有功能是否正常

## 常见问题

### 问题 1：打包后运行报错找不到模块
解决方案：build.spec 已经预配置了所有必要的隐藏导入，如果仍有问题，检查是否安装了所有依赖。

### 问题 2：打包后界面显示异常
解决方案：确保使用的是 customtkinter 5.2.1 版本，已在 requirements.txt 中指定。

### 问题 3：文件体积过大
解决方案：
1. build.spec 已启用 UPX 压缩
2. 使用虚拟环境打包可进一步减小体积：
   ```bash
   python -m venv venv
   venv\Scripts\activate
   pip install -r requirements.txt
   pyinstaller build.spec
   ```

### 问题 4：目标机器运行报错缺少 DLL
解决方案：
- 确保目标机器安装了 Visual C++ Redistributable
- 下载地址：https://aka.ms/vs/17/release/vc_redist.x64.exe

### 问题 5：Windows Defender 误报病毒
解决方案：
- 这是 PyInstaller 打包程序的常见问题
- 可以添加到白名单
- 或使用代码签名证书对 exe 进行签名

## 测试建议

打包完成后，建议在干净的 Windows 环境中测试：
1. 在没有 Python 的机器上运行
2. 测试文件选择功能
3. 测试所有导入类型和环境组合
4. 测试环境配置窗口的保存和加载
5. 测试网络异常情况
6. 测试日志显示功能
7. 测试 config.json 自动生成

## 优化建议

### 减小文件体积

使用虚拟环境打包：
```bash
# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt

# 打包
pyinstaller build.spec

# 退出虚拟环境
deactivate
```

### 添加图标

1. 准备一个 icon.ico 文件（256x256 或 128x128）
2. 修改 build.spec 中的 `icon=None` 为 `icon='icon.ico'`
3. 重新打包

### 启用代码签名（可选）

如果有代码签名证书，可以在打包后对 exe 进行签名：
```bash
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com dist\Excel导入工具.exe
```

## 完整打包流程示例

```bash
# 1. 克隆或下载项目
cd excel-import-tool

# 2. 创建虚拟环境（可选，但推荐）
python -m venv venv
venv\Scripts\activate

# 3. 安装依赖
pip install -r requirements.txt

# 4. 打包
pyinstaller build.spec

# 5. 测试
dist\Excel导入工具.exe

# 6. 分发
# 只需要分发 dist\Excel导入工具.exe 文件
```
