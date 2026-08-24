"""news_articles 每日自动采集总调度。

依次运行三个爬虫（twitter 主源 + akshare + rss），各自经 common.upsert_news 写入
public.news_articles。连接串取自环境变量 DATABASE_URL；twitter 逆向走 TWS_PROXY/HTTPS_PROXY。
本脚本自身只做编排与日志，不直连数据库。

日志写入 <项目根>/logs/news_daily_YYYY-MM-DD.log，便于计划任务排错（任务以 pythonw 无窗口运行）。
"""
import logging
import os
import subprocess
import sys
from datetime import datetime, timezone, timedelta
from pathlib import Path

SRC = Path(__file__).resolve().parent
ROOT = SRC.parent
LOGS = ROOT / "logs"
LOGS.mkdir(exist_ok=True)
BEIJING_TZ = timezone(timedelta(hours=8))

SCRIPTS = [
    "01_crawl_twitter.py",       # 主源：@kannbwx（需 cookies.txt + 代理）
    "03_crawl_news_akshare.py",  # 上海金属网/财新/央视等（免登录）
    "03_crawl_news_rss.py",      # Investing/MarketWatch RSS（免登录）
]


def setup_logging():
    fmt = "%(asctime)s %(levelname)s %(message)s"
    handlers = [
        logging.FileHandler(
            LOGS / f"news_daily_{datetime.now(BEIJING_TZ):%Y-%m-%d}.log",
            encoding="utf-8",
        ),
        logging.StreamHandler(),
    ]
    logging.basicConfig(level=logging.INFO, format=fmt, handlers=handlers)


def main():
    setup_logging()
    log = logging.getLogger("news_daily")
    log.info("=== news daily orchestration START ===")
    failed = []
    for name in SCRIPTS:
        path = SRC / name
        if not path.exists():
            log.warning("SKIP %s (not found)", name)
            continue
        log.info("=== RUN %s ===", name)
        try:
            # 继承当前环境变量（DATABASE_URL / TWS_PROXY 由计划任务注入）
            r = subprocess.run(
                [sys.executable, str(path)],
                env=os.environ.copy(),
                timeout=600,
                cwd=str(SRC),
            )
            log.info("=== %s rc=%s ===", name, r.returncode)
            if r.returncode != 0:
                failed.append(f"{name}:rc={r.returncode}")
        except subprocess.TimeoutExpired:
            log.error("=== %s TIMEOUT(>600s) ===", name)
            failed.append(f"{name}:timeout")
        except Exception as exc:  # noqa: BLE001
            log.exception("=== %s ERROR %s: %s ===", name, type(exc).__name__, exc)
            failed.append(f"{name}:{type(exc).__name__}")
    if failed:
        log.error("=== news daily orchestration FAILED: %s ===", failed)
        return 1
    log.info("=== news daily orchestration DONE ===")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
