"""
环境配置窗口模块
"""
import customtkinter as ctk
from typing import Callable
from config_manager import ConfigManager


class ConfigWindow(ctk.CTkToplevel):
    """环境配置窗口"""
    
    def __init__(self, parent, config_manager: ConfigManager, on_save_callback: Callable = None):
        super().__init__(parent)
        
        self.config_manager = config_manager
        self.on_save_callback = on_save_callback
        
        # 窗口设置
        self.title("环境配置")
        self.geometry("700x600")
        self.resizable(False, False)
        
        # 保持窗口在最前
        self.transient(parent)
        self.grab_set()
        
        # 存储输入框
        self.entries = {}
        
        # 创建界面
        self._create_widgets()
        
        # 加载当前配置
        self._load_current_config()
    
    def _create_widgets(self):
        """创建界面组件"""
        # 主容器
        main_frame = ctk.CTkFrame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # 标题
        title_label = ctk.CTkLabel(
            main_frame,
            text="API 环境配置",
            font=ctk.CTkFont(size=20, weight="bold")
        )
        title_label.pack(pady=(0, 20))
        
        # 滚动区域
        scroll_frame = ctk.CTkScrollableFrame(main_frame, height=400)
        scroll_frame.pack(fill="both", expand=True, pady=(0, 20))
        
        # 四个环境
        environments = ["dev", "test", "pre", "prod"]
        import_types = [
            ("daily", "每日运势 API"),
            ("weekly", "每周运势 API"),
            ("monthly", "每月运势 API")
        ]
        
        for env in environments:
            # 环境标题
            env_frame = ctk.CTkFrame(scroll_frame)
            env_frame.pack(fill="x", padx=10, pady=10)
            
            env_label = ctk.CTkLabel(
                env_frame,
                text=f"{env.upper()} 环境",
                font=ctk.CTkFont(size=16, weight="bold")
            )
            env_label.pack(anchor="w", padx=10, pady=(10, 5))
            
            # 三个 API 输入框
            for type_key, type_label in import_types:
                input_frame = ctk.CTkFrame(env_frame)
                input_frame.pack(fill="x", padx=10, pady=5)
                
                label = ctk.CTkLabel(
                    input_frame,
                    text=f"{type_label}:",
                    width=120,
                    anchor="w"
                )
                label.pack(side="left", padx=(5, 10))
                
                entry = ctk.CTkEntry(input_frame, width=450)
                entry.pack(side="left", fill="x", expand=True, padx=(0, 5))
                
                # 保存引用
                self.entries[f"{env}_{type_key}"] = entry
            
            # 底部间距
            ctk.CTkLabel(env_frame, text="").pack(pady=5)
        
        # 按钮区域
        button_frame = ctk.CTkFrame(main_frame)
        button_frame.pack(fill="x")
        
        # 保存按钮
        save_button = ctk.CTkButton(
            button_frame,
            text="保存配置",
            command=self._save_config,
            width=150,
            height=40
        )
        save_button.pack(side="left", padx=(0, 10))
        
        # 取消按钮
        cancel_button = ctk.CTkButton(
            button_frame,
            text="取消",
            command=self.destroy,
            width=150,
            height=40,
            fg_color="gray"
        )
        cancel_button.pack(side="left")
    
    def _load_current_config(self):
        """加载当前配置到输入框"""
        config = self.config_manager.get_all_config()
        
        for env in ["dev", "test", "pre", "prod"]:
            for type_key in ["daily", "weekly", "monthly"]:
                key = f"{env}_{type_key}"
                if key in self.entries:
                    url = config.get(env, {}).get(type_key, "")
                    self.entries[key].insert(0, url)
    
    def _save_config(self):
        """保存配置"""
        # 构建新配置
        new_config = {
            "dev": {},
            "test": {},
            "pre": {},
            "prod": {}
        }
        
        # 验证并收集数据
        for env in ["dev", "test", "pre", "prod"]:
            for type_key in ["daily", "weekly", "monthly"]:
                key = f"{env}_{type_key}"
                if key in self.entries:
                    url = self.entries[key].get().strip()
                    
                    # 验证 URL 不为空
                    if not url:
                        self._show_error(f"{env.upper()} 环境的 {type_key} API URL 不能为空")
                        return
                    
                    new_config[env][type_key] = url
        
        # 保存到文件
        if self.config_manager.save_config(new_config):
            # 调用回调函数
            if self.on_save_callback:
                self.on_save_callback()
            
            # 显示成功消息
            self._show_success("配置保存成功")
            
            # 关闭窗口
            self.after(1000, self.destroy)
        else:
            self._show_error("保存配置失败，请检查文件权限")
    
    def _show_error(self, message: str):
        """显示错误消息"""
        error_window = ctk.CTkToplevel(self)
        error_window.title("错误")
        error_window.geometry("400x150")
        error_window.resizable(False, False)
        error_window.transient(self)
        error_window.grab_set()
        
        label = ctk.CTkLabel(
            error_window,
            text=message,
            font=ctk.CTkFont(size=14),
            wraplength=350
        )
        label.pack(pady=30)
        
        button = ctk.CTkButton(
            error_window,
            text="确定",
            command=error_window.destroy,
            width=100
        )
        button.pack(pady=10)
    
    def _show_success(self, message: str):
        """显示成功消息"""
        success_window = ctk.CTkToplevel(self)
        success_window.title("成功")
        success_window.geometry("400x150")
        success_window.resizable(False, False)
        success_window.transient(self)
        success_window.grab_set()
        
        label = ctk.CTkLabel(
            success_window,
            text=message,
            font=ctk.CTkFont(size=14),
            text_color="green"
        )
        label.pack(pady=30)
        
        button = ctk.CTkButton(
            success_window,
            text="确定",
            command=success_window.destroy,
            width=100
        )
        button.pack(pady=10)
