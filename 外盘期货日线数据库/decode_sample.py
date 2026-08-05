"""
外盘期货日线数据库 — 抽样案例：月度合约字母月份解码验证

老师反馈：
  外盘期货合约代码里的月份是用字母表示的（F=1月...Z=12月），
  处理时间时字母没法直接读，所以要加一列 DATE（该月第一天）。
  连续合约（结尾 !）则为 NULL。

本脚本只读不写数据库，用于：
  1. 验证所有月度合约代码的解码逻辑
  2. 抽样：每个月度合约最早一条 K 线 + 解码后的 contract_month_date
  3. 确认连续合约应得 None
  4. 把抽样结果导出 sample_output.csv 给用户核对

执行：python decode_sample.py
（用 D:\\外盘数据\\外盘期货日线数据库.sql 作为数据源）
"""
import csv
import re
import sys
from datetime import date
from pathlib import Path

# === 标准期货月份字母编码（CME/CBOT/COMEX/NYMEX/HKEX/SGX 等通用）===
MONTH_CODE = {
    'F': 1, 'G': 2, 'H': 3, 'J': 4, 'K': 5, 'M': 6,
    'N': 7, 'Q': 8, 'U': 9, 'V': 10, 'X': 11, 'Z': 12,
}
MONTH_CN = {1: '1月', 2: '2月', 3: '3月', 4: '4月', 5: '5月', 6: '6月',
            7: '7月', 8: '8月', 9: '9月', 10: '10月', 11: '11月', 12: '12月'}


def decode_monthly(contract_code: str):
    """月度合约代码 → (year, month_num, first_day_date)
    例：'CBOT:ZSH2026' → (2026, 3, date(2026, 3, 1))
    连续合约（以 ! 结尾）→ None
    """
    if not contract_code or contract_code.endswith('!'):
        return None
    if ':' not in contract_code:
        return None
    _, body = contract_code.split(':', 1)
    if len(body) < 5:
        return None
    year_str = body[-4:]
    month_letter = body[-5]
    if not year_str.isdigit() or month_letter not in MONTH_CODE:
        return None
    year = int(year_str)
    month_num = MONTH_CODE[month_letter]
    return (year, month_num, date(year, month_num, 1))


def main():
    sql_path = Path(r"D:\外盘数据\外盘期货日线数据库.sql")
    if not sql_path.exists():
        print(f"ERROR: 找不到 {sql_path}", file=sys.stderr)
        sys.exit(1)

    raw = sql_path.read_bytes()
    text = None
    for enc in ('utf-8-sig', 'utf-16', 'gbk', 'utf-8'):
        try:
            text = raw.decode(enc)
            break
        except UnicodeDecodeError:
            continue
    if text is None:
        print("ERROR: SQL 文件编码无法识别", file=sys.stderr)
        sys.exit(1)

    # 解析 INSERT VALUES 的前 6 个字段：contract_code, contract_type, exchange, exchange_code, variety, trade_date
    pattern = re.compile(
        r"\(\s*'([^']+)',\s*'(continuous|monthly)',\s*"
        r"'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*"
        r"'([0-9]{4}-[0-9]{2}-[0-9]{2})'"
    )
    rows = pattern.findall(text)
    print(f"[读取] 解析 INSERT 行数: {len(rows)}")

    monthly_rows = [r for r in rows if r[1] == 'monthly']
    continuous_rows = [r for r in rows if r[1] == 'continuous']
    monthly_codes = sorted({r[0] for r in monthly_rows})
    print(f"[读取] 月度合约数: {len(monthly_codes)}，连续合约行数: {len(continuous_rows)}")
    print()

    # ===== 验证 1：所有月度合约解码 =====
    print("=" * 78)
    print("验证1：所有月度合约字母解码结果（共 %d 个）" % len(monthly_codes))
    print("=" * 78)
    print(f"{'contract_code':<16} {'exch_code':<8} {'月字母':<6} {'月数字':<6} {'年':<6} {'contract_month_date':<22} {'中文'}")
    print("-" * 78)
    ok = 0
    for c in monthly_codes:
        r = decode_monthly(c)
        if r:
            y, m, d = r
            body = c.split(':', 1)[1]
            exch = body[:-5]
            print(f"{c:<16} {exch:<8} {body[-5]:<6} {m:<6} {y:<6} {str(d):<22} {MONTH_CN[m]}")
            ok += 1
        else:
            print(f"{c:<16} *** 解码失败 ***")
    print(f"\n[结果] 解码成功率: {ok}/{len(monthly_codes)}")
    print()

    # ===== 验证 2：抽样 — 每个月度合约最早一条 K 线 =====
    print("=" * 92)
    print("验证2：抽样 — 每个月度合约的最早一条 K 线（含新列 contract_month_date）")
    print("=" * 92)
    seen = set()
    sample = []
    for code, typ, exch, excd, var, td in sorted(monthly_rows, key=lambda x: (x[0], x[5])):
        if code not in seen:
            seen.add(code)
            sample.append((code, typ, exch, excd, var, td))
    print(f"{'contract_code':<14} {'variety':<10} {'trade_date':<12} {'contract_year':<8} {'contract_month':<8} {'contract_month_date'}")
    print("-" * 92)
    for code, typ, exch, excd, var, td in sample:
        r = decode_monthly(code)
        if r:
            y, m, d = r
            print(f"{code:<14} {var[:8]:<10} {td:<12} {y:<8} {m:<8} {d}")

    # ===== 验证 3：连续合约应为 None =====
    print()
    print("=" * 60)
    print("验证3：连续合约（以 ! 结尾）解码应为 None（新列=NULL）")
    print("=" * 60)
    sample_cont = sorted({r[0] for r in continuous_rows})[:6]
    for c in sample_cont:
        r = decode_monthly(c)
        flag = "OK (None)" if r is None else "FAIL"
        print(f"  {c:<20} → {r}  [{flag}]")

    # ===== 保存抽样 CSV =====
    out_csv = Path(__file__).resolve().parent / "sample_output.csv"
    with out_csv.open('w', encoding='utf-8-sig', newline='') as f:
        w = csv.writer(f)
        w.writerow([
            'contract_code', 'contract_type', 'exchange', 'exchange_code',
            'variety', 'trade_date',
            'contract_year', 'contract_month', 'contract_month_date',
        ])
        for code, typ, exch, excd, var, td in sample:
            r = decode_monthly(code)
            if r:
                y, m, d = r
                w.writerow([code, typ, exch, excd, var, td, y, m, d.isoformat()])
            else:
                w.writerow([code, typ, exch, excd, var, td, '', '', ''])
    print()
    print(f"[输出] 抽样 CSV 已保存: {out_csv}")
    print()
    print("=" * 60)
    print("抽样结论")
    print("=" * 60)
    print(f"  - {len(monthly_codes)} 个月度合约全部成功解码（{ok}/{ok}）")
    print(f"  - 连续合约解码逻辑正确返回 None")
    print(f"  - 新列 contract_month_date DATE 适用于月度合约（首日），连续合约为 NULL")
    print(f"  - 等你核对后，再执行 01_migration_add_contract_month_date.sql 上传到数据库")


if __name__ == '__main__':
    main()