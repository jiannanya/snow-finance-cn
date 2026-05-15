# 中国股市数据源手册

> 本文档记录所有可用的中国A股/港股数据获取渠道，包含URL模板、数据字段说明和交叉验证规则。
> 来源于德明利（001309）实战分析经验提炼，2026年5月验证有效。

---

## 一、数据源总览

| 平台 | 域名 | 强项 | 可靠性 | 实时性 |
|------|------|------|--------|--------|
| **同花顺** | 10jqka.com.cn | 财务/资金/研报/F10全面 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **东方财富** | eastmoney.com | 研报/公告/行情 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **百度财经** | finance.baidu.com | 快速查询/PE概览 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **新浪财经（P0优先）** | hq.sinajs.cn / finance.sina.com.cn | **实时行情API（轻量/免JS渲染/稳定）** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **富途牛牛** | futu.io | 分析师评级/目标价 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **雪球** | xueqiu.com | 社区舆情/讨论 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **深交所** | szse.cn | 官方公告（最权威） | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **上交所** | sse.com.cn | 官方公告（最权威） | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **巨潮资讯** | cninfo.com.cn | 官方公告集合 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 二、URL 模板详解

### 2.1 同花顺（最核心数据源）

#### 代码格式说明
- A股深市：代码前缀无需添加（如 `001309`）
- A股沪市：代码前缀无需添加（如 `600519`）

```
# F10 总览（行情、基本面快照）
https://stockpage.10jqka.com.cn/{code}/

# 财务分析（历史营收、净利、ROE、毛利率等）
https://stockpage.10jqka.com.cn/{code}/finance/

# 经营分析（主营构成、客户供应商、董事会评述）
https://stockpage.10jqka.com.cn/{code}/operate/

# 公司资料（公司简介、高管、子公司、发行信息）
https://stockpage.10jqka.com.cn/{code}/company/

# 资金流向（大中小单净流入、历史趋势）
https://stockpage.10jqka.com.cn/{code}/funds/

# 股东股本（前十大股东、股本结构变化）
https://stockpage.10jqka.com.cn/{code}/holder/

# 主力持仓（基金/机构持仓变动）
https://stockpage.10jqka.com.cn/{code}/position/

# 分红融资（历史分红、定增、可转债）
https://stockpage.10jqka.com.cn/{code}/bonus/

# 价值分析（估值历史分位）
https://stockpage.10jqka.com.cn/{code}/worth/

# 行业分析（行业对比、行业资讯）
https://stockpage.10jqka.com.cn/{code}/field/

# 大宗交易历史
https://data.10jqka.com.cn/market/dzjy/op/code/code/{code}/

# 龙虎榜历史
https://data.10jqka.com.cn/market/lhbgg/code/{code}/

# 融资融券历史
https://data.10jqka.com.cn/market/rzrqgg/op/code/code/{code}/
```

#### 研报URL格式
```
# 研报列表页（需搜索）
https://search.10jqka.com.cn/search?tid=report&w={code}

# 研报详情（从列表获取具体ID）
https://news.10jqka.com.cn/field/sr/{YYYYMMDD}/{report_id}.shtml
```

### 2.2 东方财富

```
# 个股行情页
https://quote.eastmoney.com/sz{code}.html  # 深市
https://quote.eastmoney.com/sh{code}.html  # 沪市

# 股吧
https://guba.eastmoney.com/list,{code}.html

# 财务报表（利润表）
https://data.eastmoney.com/stock/lrb/{code}.html

# 财务报表（资产负债表）
https://data.eastmoney.com/stock/zcfzb/{code}.html
```

### 2.3 百度财经

```
# A股个股页（快速PE/PB/股价）
https://finance.baidu.com/stock/ab-{code}

# 百度搜索快捷（适合侦察阶段）
https://www.baidu.com/s?wd={公司名}股票代码
```

### 2.4 新浪财经（P0 — 实时行情首选）

> ✅ **2026-05 实测稳定**：纯文本 API 响应，无 JS 渲染，无 WAF 拦截，支持批量查询，是所有数据源中可用性最高的实时行情接口。

```
# ★ 核心接口：实时行情 API（推荐，P0优先使用）
https://hq.sinajs.cn/list={市场前缀}{code}

# 请求要求：必须携带 Referer 头，否则返回空值
Headers: Referer: https://sina.com.cn

# 市场前缀规则
沪市（600/601/603/605/688 等）→ sh，例：sh600519
深市（000/001/002/003/300 等）→ sz，例：sz001309

# 批量查询（逗号分隔，一次最多约100只）
https://hq.sinajs.cn/list=sh600519,sz001309,sz000001

# 返回格式（逗号分隔字段）
var hq_str_{市场}{code}="名称,今开,昨收,最新价,最高,最低,竞买价,竞卖价,成交量(股),成交额(元),买一量,买一价,...,日期,时间";

# 字段序号索引（0-based）
[0]名称  [1]今开  [2]昨收  [3]最新价  [4]最高  [5]最低
[6]竞买价  [7]竞卖价  [8]成交量(股)  [9]成交额(元)
[10-19]买一至买五（量/价交替）  [20-29]卖一至卖五（量/价交替）
[30]日期  [31]时间

# Python 调用示例（✅已验证，见 assets/sina-realtime.py）
import requests
headers = {'Referer': 'https://sina.com.cn'}
response = requests.get('https://hq.sinajs.cn/list=sh600519', headers=headers)
# → {'名称': '贵州茅台', '最新价': '1330.410', '成交量(股)': '3020614', ...}
```

```
# 备用：网页行情页（JS渲染，可用性低于API）
https://finance.sina.com.cn/realstock/company/sz{code}/nc.shtml  # 深市
https://finance.sina.com.cn/realstock/company/sh{code}/nc.shtml  # 沪市
```

### 2.5 官方公告源（最权威）

```
# 巨潮资讯（A股公告集合门户）
http://www.cninfo.com.cn/new/commonUrl/pageOfSearch?url=disclosure/list/search#{code}

# 深交所上市公司信披
https://www.szse.cn/disclosure/listed/notice/index.html?1={code}

# 上交所上市公司信披
https://www.sse.com.cn/disclosure/listedinfo/announcement/?productId={code}
```

---

## 三、关键数据字段对照表

### 3.1 股价与估值字段

| 字段名 | 同花顺显示 | 说明 | 注意事项 |
|--------|-----------|------|---------|
| 最新价 | 实时/收盘价 | 元/股 | 盘中与收盘值不同 |
| PE(TTM) | 市盈率TTM | 滚动12个月盈利计算 | 利润大幅变动期失真 |
| PE(动态) | 市盈率(动) | 基于最新年化预测EPS | 反映前瞻预期 |
| PB | 市净率 | 总市值/净资产 | >1说明溢价 |
| PS | 市销率 | 总市值/营收 | 适用亏损企业 |
| 总市值 | 总市值 | 亿元 | = 股价×总股本 |
| 流通市值 | 流通市值 | 亿元 | = 股价×流通股数 |

**重要：PE差异解读**
```
同一股票可能出现两个PE值截然不同的情况：
- 百度财经 PE(TTM) = 39.89（基于2025Q2~2026Q1历史利润）
- 同花顺 动态PE = 12.23（基于2026Q1×4年化EPS的前瞻值）
→ 差异原因：2026Q1利润爆发性增长，TTM基数中含2025前三季度低利润
→ 处理方式：在报告中明确注明两种PE的计算基准，均列出
```

### 3.2 财务报表关键字段

| 字段 | 单位 | 获取来源 | 验证方式 |
|------|------|---------|---------|
| 营业收入 | 亿元 | 同花顺财务 | 与季报/年报原文核对 |
| 归母净利润 | 亿元 | 同花顺财务 | 与机构研报数据比对 |
| 扣非净利润 | 亿元 | 同花顺财务 | 验证非经常损益金额 |
| 毛利率 | % | 同花顺财务 | = (营收-营业成本)/营收 |
| 净利率 | % | 同花顺财务 | = 归母净利/营收 |
| ROE（摊薄） | % | 同花顺财务 | = 归母净利/期末净资产 |
| 资产负债率 | % | 同花顺财务 | = 总负债/总资产 |
| 存货 | 亿元 | 同花顺财务 | 结合主营业务理解合理性 |
| 应收账款 | 亿元 | 同花顺财务 | 结合营收计算账款周转天数 |
| 每股收益(EPS) | 元 | 同花顺财务 | 基本EPS vs 稀释EPS |
| 每股净资产(BVPS) | 元 | 同花顺财务 | = 净资产/总股本 |

### 3.3 资金流向字段

| 字段 | 说明 |
|------|------|
| 大单净流入 | >50万元单笔，代表主力/机构动向 |
| 中单净流入 | 10-50万元单笔 |
| 小单净流入 | <10万元，散户为主 |
| 融资余额 | 融资买入余额，持续增加=做多意愿强 |
| 融券余额 | 融券卖出余额，增加=做空压力 |
| 换手率 | 成交量/流通股，高换手=活跃/放量 |

---

## 四、交叉验证规则

### 4.1 核心验证矩阵

```
数据优先级（由高到低）：
1. 交易所官方公告（cninfo/szse/sse）
2. 公司季报/年报原文PDF
3. 同花顺F10财务数据
4. 机构研报（财信/国信/中信等）
5. 百度财经/东方财富行情页
6. 雪球/股吧社区信息（仅作参考，不可单独引用）
```

### 4.2 验证通过标准

| 数据类型 | 通过标准 | 失败处理 |
|---------|---------|---------|
| 股价数据 | 两源差异 < 0.5% | 取最新时间戳来源 |
| 季度营收/净利 | 两源完全一致 | 查找原始公告PDF核实 |
| PE估值 | 明确基准，差异有合理解释 | 报告中同时列出并注明差异原因 |
| 机构评级 | 方向一致（≥2家机构） | 注明分歧，不单独使用单一评级 |
| 存货/资产负债 | 同花顺 vs 季报原文 | 以季报原文为准 |

### 4.3 常见数据陷阱

```
⚠️ 陷阱1：前复权 vs 不复权股价
   - 历史分析必须使用后复权价格
   - 同花顺默认不复权，查历史涨幅需切换"后复权"

⚠️ 陷阱2：合并报表 vs 母公司报表
   - 应使用"归母净利润"而非"净利润"
   - 两者差值 = 少数股东损益（控股子公司中少数股东利润）

⚠️ 陷阱3：季报业绩预告 vs 正式季报
   - 业绩预告为预计区间（如"31.5-36.5亿"），正式季报为精确值
   - 区分预测数据和已披露数据

⚠️ 陷阱4：TTM vs 年度 vs 单季度
   - TTM = 过去12个月滚动数据
   - 年度 = 全年累计数据  
   - 单季度 = 当季数据（需从累计数中差分计算）

⚠️ 陷阱5：同名不同股
   - 如"德明利"001309（存储）≠ 锡装股份001332
   - 务必通过股票代码+公司官方全称双重确认
```

---

## 五、行业分类索引

### 申万行业一级分类（常用）

| 代码 | 行业 | 代表公司 |
|------|------|---------|
| 电子 | 半导体、消费电子、PCB | 德明利、江波龙、寒武纪 |
| 计算机 | 软件、IT服务 | 中科曙光、浪潮信息 |
| 通信 | 5G、光模块 | 中际旭创、华为（非上市） |
| 医药生物 | 创新药、CXO、医疗器械 | 恒瑞医药、药明康德 |
| 新能源 | 光伏、储能、电池 | 宁德时代、隆基绿能 |
| 汽车 | 整车、零部件、智能驾驶 | 比亚迪、华域汽车 |
| 银行 | 国有行、股份行 | 工商银行、招商银行 |
| 非银金融 | 券商、保险、信托 | 中信证券、中国平安 |

---

## 六、数据抓取注意事项

### fetch_webpage 最佳实践

```
# ★ P0优先：新浪财经实时行情 API（最稳定，优先使用）
GET https://hq.sinajs.cn/list={市场}{code}
Headers: Referer: https://sina.com.cn
→ 直接返回文本，无需浏览器渲染，Python requests 可直接解析
→ 完整示例见 assets/sina-realtime.py（2026-05 验证可用）

# P1 并行：同花顺主要页面（JS渲染，有时可用）
- stockpage.10jqka.com.cn/{code}/          # 行情+基本面
- stockpage.10jqka.com.cn/{code}/finance/  # 财务详情
- stockpage.10jqka.com.cn/{code}/operate/  # 经营分析

# P1 备用：东方财富行情页（JS渲染，有时可用）
- quote.eastmoney.com/sz{code}.html
- quote.eastmoney.com/sh{code}.html

# 部分URL失败情况说明
- 同花顺/东方财富/百度财经：JS动态渲染，fetch_webpage成功率不稳定
- 新浪财经realstock网页：偶发连接关闭（但 hq.sinajs.cn API 稳定）
- 雪球：有WAF防爬，内容通常无法提取
→ 处理：P1失败时切换备用来源，不重试同一失败URL；P0新浪API始终可尝试
```

### 判断数据时效性

```
优先获取最新季报数据（距今≤3个月）：
- 2026Q1报告：2026年4月末披露
- 2025年报：2026年3月-4月披露
- 业绩预告：季末后10-15天内

数据超过6个月需在报告中注明"历史数据，可能与最新情况有偏差"
```
