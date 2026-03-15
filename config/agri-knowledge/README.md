# 农业知识库目录说明

该目录用于存放 `agri-orchestrator` 使用的本地农业知识库资料。

目录约定：
- `raw/`：存放团队提供的原始资料，例如 PDF、DOCX、Markdown、TXT、截图、导出笔记等。
- `curated/`：存放根据原始资料整理后的结构化知识，例如 JSON、YAML、Markdown 摘要等。
  - `extracted/`：从 PDF 等原始资料中抽取出的中间文本，便于人工校对和二次整理。

向量知识库约定：
- 桥接服务会继续直接读取 `curated/` 下的结构化知识 JSON 作为保底知识。
- 轻量级向量索引的输入来源主要是：
  - `curated/extracted/*.txt`
  - `curated/*.md`
  - `curated/铁皮石斛知识库.json` 中的结构化摘要
- 文献新增或更新后，需要手动执行一次：
  - `python3 scripts/build_agri_vector_index.py --config config/agri-context-bridge.ini`
- 向量索引文件默认写入 `data/agri-vectordb/`，不提交到 Git。

建议优先收集的资料类型：
- 石斛适宜生长环境参数
- 不同生长期管理要求
- 常见病虫害症状
- 常见病虫害处置建议
- 温度、湿度、光照、pH 等阈值说明

建议文件名保持稳定、明确，方便后续做索引、更新和版本追踪。
