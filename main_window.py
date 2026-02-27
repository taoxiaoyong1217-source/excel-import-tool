"""
主窗口模块
"""
import customtkinter as ctk
from tkinter import filedialog
import threading
import os
from config_manager import ConfigManager
from api_client import APIClient
from config_window import ConfigWindow


class MainWindow(ctk.CTk):
    """主窗口"""
    
    def __init__(self):
        super().__init__()
        
        # 窗口设置
        self.title("Excel 导入工具")
        self.geometry("900x700")
        self.resizable(False, False)
        
        # 设置深色模式
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")
        
        # 初始化组件
        self.config_manager = ConfigManager()
        self.api_client = APIClient()
        
        # 状态变量
        self.selected_file = None
        self.is_uploading = False
        
        # 创建界面
        self._create_widgets()
    
    def _create_widgets(self):
        """创建界面组件"""
        # 主容器
        main_frame = ctk.CTkFrame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # 标题
        title_label = ctk.CTkLabel(
            main_frame,
            text="Excel 运势数据导入工具",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title_label.pack(pady=(0, 20))
        
        # 配置区域
        config_frame = ctk.CTkFrame(main_frame)
        config_frame.pack(fill="x", pady=(0, 20))
        
        # 导入类型选择
        type_frame = ctk.CTkFrame(config_frame)
        type_frame.pack(fill="x", padx=20, pady=10)
        
        type_label = ctk.CTkLabel(
            type_frame,
            text="导入类型:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        type_label.pack(side="left", padx=(0, 20))
        
        self.import_type_var = ctk.StringVar(value="daily")
        
        daily_radio = ctk.CTkRadioButton(
            type_frame,
            text="每日运势导入",
            variable=self.import_type_var,
            value="daily"
        )
        daily_radio.pack(side="left", padx=10)
        
        weekly_radio = ctk.CTkRadioButton(
            type_frame,
            text="每周运势导入",
            variable=self.import_type_var,
            value="weekly"
        )
        weekly_radio.pack(side="left", padx=10)
        
        monthly_radio = ctk.CTkRadioButton(
            type_frame,
            text="每月运势导入",
            variable=self.import_type_var,
            value="monthly"
        )
        monthly_radio.pack(side="left", padx=10)
        
        # 环境选择
        env_frame = ctk.CTkFrame(config_frame)
        env_frame.pack(fill="x", padx=20, pady=10)
        
        env_label = ctk.CTkLabel(
            env_frame,
            text="目标环境:",
            font=ctk.CTkFont(size=14, weight="bold"),
            width=100,
            anchor="w"
        )
        env_label.pack(side="left", padx=(0, 20))
        
        self.env_var = ctk.StringVar(value="dev")
        env_dropdown = ctk.CTkComboBox(
            env_frame,
            values=["dev", "test", "pre", "prod"],
            variable=self.env_var,
            width=200,
            state="readonly"
        )
        env_dropdown.pack(side="left")
        
        # 文件选择
        file_frame = ctk.CTkFrame(config_frame)
        file_frame.pack(fill="x", padx=20, pady=10)
        
        file_label = ctk.CTkLabel(
            file_frame,
            text="选择文件:",
            font=ctk.CTkFont(size=14, weight="bold"),
            width=100,
            anchor="w"
        )
        file_label.pack(side="left", padx=(0, 20))
        
        self.file_path_label = ctk.CTkLabel(
            file_frame,
            text="未选择文件",
            anchor="w",
            text_color="gray"
        )
        self.file_path_label.pack(side="left", fill="x", expand=True, padx=(0, 10))
        
        select_file_button = ctk.CTkButton(
            file_frame,
            text="浏览",
            command=self._select_file,
            width=100
        )
        select_file_button.pack(side="left")
        
        # 操作按钮区域
        action_frame = ctk.CTkFrame(main_frame)
        action_frame.pack(fill="x", pady=(0, 20))
        
        self.start_button = ctk.CTkButton(
            action_frame,
            text="开始导入",
            command=self._start_upload,
            width=150,
            height=40,
            font=ctk.CTkFont(size=14, weight="bold")
        )
        self.start_button.pack(side="left", padx=20)
        
        config_button = ctk.CTkButton(
            action_frame,
            text="环境配置",
            command=self._open_config_window,
            width=150,
            height=40,
            font=ctk.CTkFont(size=14, weight="bold"),
            fg_color="gray"
        )
        config_button.pack(side="left", padx=10)
        
        # 日志区域
        log_frame = ctk.CTkFrame(main_frame)
        log_frame.pack(fill="both", expand=True)
        
        log_title = ctk.CTkLabel(
            log_frame,
            text="执行日志",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        log_title.pack(anchor="w", padx=10, pady=(10, 5))
        
        self.log_text = ctk.CTkTextbox(
            log_frame,
            height=200,
            font=ctk.CTkFont(size=12)
        )
        self.log_text.pack(fill="both", expand=True, padx=10, pady=(0, 10))
        
        # API 返回状态区域
        status_frame = ctk.CTkFrame(main_frame)
        status_frame.pack(fill="x", pady=(10, 0))
        
        status_title = ctk.CTkLabel(
            status_frame,
            text="API 返回状态",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        status_title.pack(anchor="w", padx=10, pady=(10, 5))
        
        self.status_label = ctk.CTkLabel(
            status_frame,
            text="等待操作...",
            font=ctk.CTkFont(size=12),
            anchor="w",
            justify="left"
        )
        self.status_label.pack(fill="x", padx=10, pady=(0, 10))
    
    def _select_file(self):
        """选择文件"""
        file_path = filedialog.askopenfilename(
            title="选择 Excel 文件",
            filetypes=[
                ("Excel 文件", "*.xlsx *.xls"),
                ("所有文件", "*.*")
            ]
        )
        
        if file_path:
            self.selected_file = file_path
            self.file_path_label.configure(
                text=os.path.basename(file_path),
                text_color="white"
            )
            self._log(f"已选择文件: {os.path.basename(file_path)}")
    
    def _start_upload(self):
        """开始上传"""
        # 验证
        if not self.selected_file:
            self._log("错误: 请先选择文件", "error")
            self.status_label.configure(text="错误: 未选择文件", text_color="red")
            return
        
        # 检查文件类型
        if not self.selected_file.lower().endswith(('.xlsx', '.xls')):
            self._log("错误: 文件类型必须是 .xlsx 或 .xls", "error")
            self.status_label.configure(text="错误: 文件类型不正确", text_color="red")
            return
        
        # 检查文件是否存在
        if not os.path.exists(self.selected_file):
            self._log("错误: 文件不存在", "error")
            self.status_label.configure(text="错误: 文件不存在", text_color="red")
            return
        
        # 防止重复点击
        if self.is_uploading:
            self._log("提示: 正在上传中，请勿重复点击", "warning")
            return
        
        # 获取配置
        env = self.env_var.get()
        import_type = self.import_type_var.get()
        api_url = self.config_manager.get_api_url(env, import_type)
        
        if not api_url:
            self._log(f"错误: {env} 环境的 {import_type} API 未配置", "error")
            self.status_label.configure(text="错误: API 未配置", text_color="red")
            return
        
        # 开始上传
        self.is_uploading = True
        self.start_button.configure(state="disabled", text="上传中...")
        self.status_label.configure(text="正在上传...", text_color="yellow")
        
        self._log(f"开始上传到 {env} 环境 ({import_type})")
        self._log(f"API URL: {api_url}")
        
        # 在后台线程执行上传
        thread = threading.Thread(
            target=self._upload_thread,
            args=(self.selected_file, api_url),
            daemon=True
        )
        thread.start()
    
    def _upload_thread(self, file_path: str, api_url: str):
        """上传线程"""
        try:
            # 调用 API
            success, message = self.api_client.upload_file(file_path, api_url)
            
            # 更新 UI（线程安全）
            self.after(0, self._upload_complete, success, message)
            
        except Exception as e:
            self.after(0, self._upload_complete, False, f"上传异常: {str(e)}")
    
    def _upload_complete(self, success: bool, message: str):
        """上传完成回调"""
        self.is_uploading = False
        self.start_button.configure(state="normal", text="开始导入")
        
        if success:
            self._log(f"成功: {message}", "success")
            self.status_label.configure(
                text=f"✓ 导入成功: {message}",
                text_color="green"
            )
        else:
            self._log(f"失败: {message}", "error")
            self.status_label.configure(
                text=f"✗ 导入失败: {message}",
                text_color="red"
            )
    
    def _open_config_window(self):
        """打开环境配置窗口"""
        ConfigWindow(self, self.config_manager, self._on_config_saved)
    
    def _on_config_saved(self):
        """配置保存后的回调"""
        self.config_manager.reload_config()
        self._log("配置已更新", "success")
    
    def _log(self, message: str, level: str = "info"):
        """添加日志"""
        # 颜色映射
        colors = {
            "info": "white",
            "success": "green",
            "warning": "yellow",
            "error": "red"
        }
        
        color = colors.get(level, "white")
        
        # 插入日志
        self.log_text.configure(state="normal")
        self.log_text.insert("end", f"{message}\n")
        
        # 设置颜色（customtkinter 的 textbox 不支持 tag，所以颜色统一）
        self.log_text.configure(state="disabled")
        self.log_text.see("end")
