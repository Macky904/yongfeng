# 方式B：用 Cookie 导入（推荐 / 最稳）

把浏览器里已登录 X 的 `auth_token` + `ct0` 两个 cookie 直接导入 twscrape 的账号池，
免去"账密 + 邮箱验证码"的登录流程。这个登录身份**不必是 @kannbwx 本人**，只是抓取用的"门票"。

## ⚠️ 重要前提：HttpOnly cookie，JS 读不到

X（Twitter）的 `auth_token` 和 `ct0` 都是 **HttpOnly** cookie。浏览器禁止页面 JS 读取
`document.cookie`，所以在 Console 里贴 JS 脚本**拿不到这两个值**（还会报语法/读不到错误）。
**正确做法只有一个：从 DevTools 的 Application 面板手动复制。**

## 步骤

1. 电脑浏览器打开 https://x.com，登录一个 X 账号（建议用**备用小号**当抓取身份）。
2. 按 `F12` → 点 **Application（应用程序）** 标签 → 左侧 `Storage → Cookies → https://x.com`。
3. 右侧表格里找到 `auth_token` 和 `ct0` 两行，**分别双击它们的 Value 列**，全选复制
   （ct0 很长，务必完整，别截断）。
4. 把这两个值发给助手，格式：
   ```
   auth_token=一长串; ct0=另一长串
   账号名：scraper1
   ```

助手收到后会：
- 写入 `news_articles/cookies.txt`（格式 `账号名:auth_token=...; ct0=...`），
  该文件已被 `.gitignore` 忽略，不会误提交；
- 用 `twscrape` 的 `add_account_cookies` 导入账号池（**免登录、立即生效**）；
- 直接运行 `01_crawl_twitter.py`，从 `START_DATE=2026-01-01` 起把 `@kannbwx` 的推文
  写入 `public.news_articles`（`platform='twitter'`）。

## 安全提示

- cookie ≈ 账号的"临时钥匙"，建议用备用小号；用完后不想留，在浏览器退出该 X 账号登录，
  cookie 即失效。
- 账号池存在本机 `~/.twscrape.db`，不会进 git 仓库。
- cookie 有时效，X 改密/登出会失效，到时重新取一次即可。

## 命令行（备查）

若想在自己机器上手动导入，可参考：

```powershell
$env:DATABASE_URL="postgresql://..."
python src/01_crawl_twitter.py   # 脚本在 setup_accounts 里会自动优先读 cookies.txt 并导入
```
