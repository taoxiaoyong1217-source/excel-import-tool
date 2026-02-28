"""
配置管理模块
负责读取和保存 config.json
"""
import json
import os
from typing import Dict


class ConfigManager:
    """配置管理器"""
    
    def __init__(self, config_file: str = "config.json"):
        self.config_file = config_file
        self.config_data = {}
        self._load_config()
    
    def _load_config(self):
        """加载配置文件"""
        if not os.path.exists(self.config_file):
            self._create_default_config()
        
        try:
            with open(self.config_file, 'r', encoding='utf-8') as f:
                self.config_data = json.load(f)
        except Exception as e:
            print(f"加载配置文件失败: {e}")
            self._create_default_config()
    
    def _create_default_config(self):
        """创建默认配置文件"""
        default_config = {
            "dev": {
                "daily": "http://gateway-dev.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-daily",
                "weekly": "http://gateway-dev.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-weekly",
                "monthly": "http://gateway-dev.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-monthly",
                "client_id": "0"
            },
            "test": {
                "daily": "http://gateway-test.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-daily",
                "weekly": "http://gateway-test.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-weekly",
                "monthly": "http://gateway-test.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-monthly",
                "client_id": "0"
            },
            "pre": {
                "daily": "http://gateway-pre.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-daily",
                "weekly": "http://gateway-pre.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-weekly",
                "monthly": "http://gateway-pre.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-monthly",
                "client_id": "0"
            },
            "prod": {
                "daily": "https://gateway.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-daily",
                "weekly": "https://gateway.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-weekly",
                "monthly": "https://gateway.baitaoxingqiu.com/api/xingchen/fate-v2/import-fate-monthly",
                "client_id": "0"
            }
        }
        
        self.config_data = default_config
        self.save_config(default_config)
    
    def get_api_url(self, env: str, import_type: str) -> str:
        """获取 API URL"""
        try:
            return self.config_data.get(env, {}).get(import_type, "")
        except Exception:
            return ""
    
    def get_client_id(self, env: str) -> str:
        """获取 CLIENT_ID"""
        try:
            return self.config_data.get(env, {}).get("client_id", "0")
        except Exception:
            return "0"
    
    def get_all_config(self) -> Dict:
        """获取所有配置"""
        return self.config_data
    
    def save_config(self, config: Dict) -> bool:
        """保存配置"""
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
            self.config_data = config
            return True
        except Exception as e:
            print(f"保存配置失败: {e}")
            return False
    
    def reload_config(self):
        """重新加载配置"""
        self._load_config()
