# 系统库或已导入的库
import time
import hmac
import hashlib
import base64
import urllib.parse
# 需要额外安装，可以通过 pip 命令安装 pip install xxx
import requests

def sign(params):
    if "secret" not in params:
        raise Exception(f"缺少机器人签名(secret)")
    secret = params['secret']
    timestamp = str(round(time.time() * 1000))
    secret_enc = secret.encode('utf-8')
    string_to_sign = '{}\n{}'.format(timestamp, secret)
    string_to_sign_enc = string_to_sign.encode('utf-8')
    hmac_code = hmac.new(secret_enc, string_to_sign_enc, digestmod=hashlib.sha256).digest()
    sign = urllib.parse.quote_plus(base64.b64encode(hmac_code))
    if "access_token" not in params:
        raise Exception("机器人缺少 access_token")
    return {
        "access_token" : params["access_token"],
        "sign" : sign,
        "timestamp" : timestamp
    }
def query(params):
    query = []
    for key, value in params.items():
        query.append(f"{key}={value}")
    return "&".join(query)

def request(sign, jsonBody):
    link = f'https://oapi.dingtalk.com/robot/send?{query(sign)}'
    headers = { 'Content-Type' : 'application/json' }
    result = requests.post(link, headers=headers, json=jsonBody)
    # print(jsonBody)
    return result.text
