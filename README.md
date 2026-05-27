# Claude Code Approval Notifications

Sends an iCloud Reminder (+ macOS banner) to your iPhone and Apple Watch whenever Claude Code is about to execute a tool that requires your approval — so you don't miss the prompt while away from your Mac.
每当 Claude Code 即将执行需要审批的操作时，自动通过 iCloud 提醒（+ macOS 横幅）推送通知到你的 iPhone 和 Apple Watch，让你离开 Mac 时也不会错过审批提示。

[English](#english) | [中文](#中文)

---

<a name="english"></a>
## English

### How it works

```
Claude wants to run a tool
        ↓
PreToolUse hook fires
        ↓
iCloud Reminder created (alarm = now) + macOS banner shown
        ↓
iPhone / Apple Watch receive the reminder via iCloud sync → notification fires
        ↓
You return to Mac and approve / deny
        ↓
PostToolUse hook fires → reminder deleted after 60 seconds
```

The reminder title shows the tool type and content:
- **Bash** → first 80 chars of the command
- **Write / Edit** → file name

### Requirements

- macOS with iCloud account signed in
- Reminders app enabled in iCloud (System Settings → Apple ID → iCloud → Reminders)
- `jq` installed (`brew install jq`)
- iPhone / Apple Watch on the same iCloud account

### Installation

**Option 1: Git clone**

```bash
git clone https://github.com/Kaliveya/claude-notice.git
cd claude-notice
chmod +x install.sh
./install.sh
```

**Option 2: Install via Claude Code**

Paste the following prompt into Claude Code:

```
Please clone https://github.com/Kaliveya/claude-notice.git into a temporary directory, run install.sh, then delete the cloned folder.
```

The installer:
1. Copies `hooks/notify.sh` and `hooks/cleanup.sh` to `~/.claude/hooks/`
2. Registers `PreToolUse` and `PostToolUse` hooks in `~/.claude/settings.json`

### iPhone Setup

1. **Settings → Notifications → Reminders**
   - Allow Notifications: **ON**
   - Banner style: **Persistent**
   - Sounds: **ON**
2. If you use Focus modes: add **Reminders** to the allowed apps list

### Uninstallation

**Option 1: Manual**

```bash
# Remove hook scripts
rm -f ~/.claude/hooks/notify.sh ~/.claude/hooks/cleanup.sh

# Remove hooks config from settings.json
jq 'del(.hooks.PreToolUse, .hooks.PostToolUse)' ~/.claude/settings.json > /tmp/settings_tmp.json \
  && mv /tmp/settings_tmp.json ~/.claude/settings.json

# Remove hooks directory if empty
rmdir ~/.claude/hooks 2>/dev/null || true
```

**Option 2: Uninstall via Claude Code**

Paste the following prompt into Claude Code:

```
Please uninstall the claude-notice hooks: delete ~/.claude/hooks/notify.sh and ~/.claude/hooks/cleanup.sh, then remove the PreToolUse and PostToolUse entries from ~/.claude/settings.json using jq.
```

### Logs

Hook activity is logged to `/tmp/claude_hook.log` for debugging.

### Manual settings.json Config

If you prefer to configure manually, add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Write|Edit",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|Write|Edit",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/cleanup.sh" }]
      }
    ]
  }
}
```

---

<a name="中文"></a>

## 中文


### 工作原理

```
Claude 即将执行工具
        ↓
PreToolUse 钩子触发
        ↓
iCloud 提醒创建（立即响铃）+ macOS 横幅弹出
        ↓
iPhone / Apple Watch 通过 iCloud 同步收到提醒 → 通知触发
        ↓
回到 Mac 审批或拒绝
        ↓
PostToolUse 钩子触发 → 60 秒后提醒自动删除
```

提醒标题会显示工具类型和内容：
- **Bash** → 命令的前 80 个字符
- **Write / Edit** → 文件名

### 环境要求

- 已登录 iCloud 的 macOS
- iCloud 中已启用提醒事项（系统设置 → Apple ID → iCloud → 提醒事项）
- 已安装 `jq`（`brew install jq`）
- 与 Mac 使用同一 iCloud 账号的 iPhone / Apple Watch

### 安装

**方式一：Git clone**

```bash
git clone https://github.com/Kaliveya/claude-notice.git
cd claude-notice
chmod +x install.sh
./install.sh
```

**方式二：通过 Claude Code 安装**

将以下提示词粘贴到 Claude Code 中：

```
请将 https://github.com/Kaliveya/claude-notice.git 克隆到临时目录，执行 install.sh 完成安装，然后删除克隆的文件夹。
```

安装脚本会执行以下操作：
1. 将 `hooks/notify.sh` 和 `hooks/cleanup.sh` 复制到 `~/.claude/hooks/`
2. 在 `~/.claude/settings.json` 中注册 `PreToolUse` 和 `PostToolUse` 钩子

### iPhone 设置

1. **设置 → 通知 → 提醒事项**
   - 允许通知：**开启**
   - 横幅样式：**持续**
   - 声音：**开启**
2. 如果你使用专注模式：将**提醒事项**加入允许的 App 列表

### 卸载

**方式一：手动卸载**

```bash
# 删除钩子脚本
rm -f ~/.claude/hooks/notify.sh ~/.claude/hooks/cleanup.sh

# 从 settings.json 中删除钩子配置
jq 'del(.hooks.PreToolUse, .hooks.PostToolUse)' ~/.claude/settings.json > /tmp/settings_tmp.json \
  && mv /tmp/settings_tmp.json ~/.claude/settings.json

# 如果目录已空则一并删除
rmdir ~/.claude/hooks 2>/dev/null || true
```

**方式二：通过 Claude Code 卸载**

将以下提示词粘贴到 Claude Code 中：

```
请卸载 claude-notice 钩子：删除 ~/.claude/hooks/notify.sh 和 ~/.claude/hooks/cleanup.sh，然后用 jq 从 ~/.claude/settings.json 中移除 PreToolUse 和 PostToolUse 配置项。
```

### 日志

钩子活动日志记录在 `/tmp/claude_hook.log`，可用于排查问题。

### 手动配置 settings.json

如果你希望手动配置，将以下内容添加到 `~/.claude/settings.json`：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Write|Edit",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|Write|Edit",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/cleanup.sh" }]
      }
    ]
  }
}
```
