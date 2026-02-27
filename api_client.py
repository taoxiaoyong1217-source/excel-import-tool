"""
API 客户端模块
负责文件上传和 API 请求
"""
import requests
from typing import Dict, Tuple
import os


class APIClient:
    """API 客户端"""
    
    def __init__(self, timeout: int = 60):
        self.timeout = timeout
    
    def upload_file(self, file_path: str, api_url: str) -> Tuple[bool, str]:
        """
        上传文件到 API
        
        Args:
            file_path: Excel 文件路径
            api_url: API URL
            
        Returns:
            (是否成功, 消息)
        """
        if not os.path.exists(file_path):
            return False, "文件不存在"
        
        if not api_url:
            return False, "API URL 未配置"
        
        try:
            # 打开文件
            with open(file_path, 'rb') as f:
                files = {'file': (os.path.basename(file_path), f, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')}
                
                # 发送 POST 请求
                response = requests.post(
                    api_url,
                    files=files,
                    timeout=self.timeout
                )
                
                # 解析响应
                return self._parse_response(response)
                
        except requests.exceptions.Timeout:
            return False, "请求超时，请检查网络连接"
        except requests.exceptions.ConnectionError:
            return False, "网络连接失败，请检查网络或 API 地址"
        except requests.exceptions.RequestException as e:
            return False, f"请求异常: {str(e)}"
        except Exception as e:
            return False, f"未知错误: {str(e)}"
    
    def _parse_response(self, response: requests.Response) -> Tuple[bool, str]:
        """
        解析 API 响应
        
        Args:
            response: requests 响应对象
            
        Returns:
            (是否成功, 消息)
        """
        try:
            # 尝试解析 JSON
            data = response.json()
            
            # 检查 code 字段
            code = data.get('code', -1)
            msg = data.get('msg', '未知响应')
            
            if code == 0:
                return True, msg
            else:
                return False, f"API 返回错误 (code={code}): {msg}"
                
        except ValueError:
            # JSON 解析失败
            return False, f"API 返回格式错误，HTTP 状态码: {response.status_code}"
        except Exception as e:
            return False, f"解析响应失败: {str(e)}"
