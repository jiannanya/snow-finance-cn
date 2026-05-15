
#返回数据字段解析接口返回的为 JavaScript 变量赋值语句，以逗号分隔，具体字段顺序如下：
# 股票名称
# 今日开盘价
# 昨日收盘价
# 当前最新价
# 今日最高价
# 今日最低价
# 竞买价（买一报价）
# 竞卖价（卖一报价）
# 成交数量（单位为股，如果是港股/美股可能为手或股）
# 成交金额（单位为元）
# 买一申请股数
# 买一报价
# 买二申请股数
# 买二报价
# 买三申请股数
# 买三报价
# 买四申请股数
# 买四报价
# 买五申请股数
# 买五报价
# 卖一申请股数
# 卖一报价
# 卖二申请股数
# 卖二报价
# 卖三申请股数
# 卖三报价
# 卖四申请股数
# 卖四报价
# 卖五申请股数
# 卖五报价
# 日期时间

import requests

def get_sina_stock_data(symbol):
    url = f"https://hq.sinajs.cn/list={symbol}"
    # 必须添加Referer头部，否则会请求失败
    headers = {
        'Referer': 'https://sina.com.cn'
    }
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.text
        # 返回格式: var hq_str_sh600519="贵州茅台,..."
        if '=' in data:
            content = data.split('"')[1]
            fields = content.split(',')
            return {
                "名称": fields[0],
                "今开": fields[1],
                "昨收": fields[2],
                "最新价": fields[3],
                "最高": fields[4],
                "最低": fields[5],
                "成交量(股)": fields[8],
                "成交额(元)": fields[9]
            }
    return None

# 获取贵州茅台实时行情
print(get_sina_stock_data("sh600519"))