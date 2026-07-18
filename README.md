# CyberDog Race 2026

CyberDog 2026 小米杯实体机赛道开发仓库。

这个公开仓库保存的是经过整理的实体机运行脚本和开发记录。真实调试时请始终以实体机安全为第一优先级：低速、可停、可恢复、可逐步验证。

## 新成员与 AI 开发入口

- [`docs/AI_CYBERDOG_DEVELOPMENT_GUIDE.md`](docs/AI_CYBERDOG_DEVELOPMENT_GUIDE.md)：说明代码依据、ROS 2 接口来源、推荐写法、SSH/SCP 部署、实体机验证顺序，以及应该交给 AI 的最小上下文。
- [`docs/RACE_RULES_CORRECTED.md`](docs/RACE_RULES_CORRECTED.md)：记录小组确认后的六赛段规则理解，特别说明第四赛段目标和障碍需要现场识别，不能写死通道映射。

新组员或新的 AI 对话应先阅读以上两份文档，再结合 `README.md`、相关 `robot_runtime/` 文件、官方赛题 PDF 和当前实体机的只读接口探测结果开展工作。

## 本地目录与运行链路

本仓库不绑定操作系统、盘符或本地文件夹名。组员可以把仓库克隆到任意有读写权限的位置，例如：

```text
Windows:  D:\Projects\Cyberdog-race-2026
Ubuntu:   /home/<your-name>/projects/cyberdog-race-2026
macOS:    /Users/<your-name>/Projects/cyberdog-race-2026
```

本地文件夹可以自主命名。编辑代码或让 AI 协助时，应打开包含 `README.md`、`docs/` 和 `robot_runtime/` 的仓库根目录，并使用仓库相对路径交流。

通用运行链路是：

```text
任意个人电脑编写和检查代码
-> 使用 SSH/SCP 或个人同步工具传到机器狗
-> 机器狗端加载 ROS2 / CyberDog 环境
-> 机器狗端使用 python3 运行脚本
```

个人电脑不直接运行 `robot_runtime/*.py`。这些脚本依赖 CyberDog NX 端的 ROS2 Galactic、`protocol` 消息/服务和机器狗 DDS 环境。机器狗端默认运行目录为：

```text
/home/mi/cyberdog_course/program
```

当前维护者使用 `G:\Cyberdog_win` 作为 Windows 实体机操作工作区，并将仓库的 `robot_runtime/` 对应到本地 `program/robot_runtime/`；PowerShell 推送脚本和 SSH 别名 `cyberdog-win` 也只是该工作区的辅助方式。其他组员无需复刻这些路径、名称或工具，但不要把真实机器狗 IP、密码或私有密钥提交到公开仓库。

## AI 协作方式

项目不要求所有组员使用同一个 AI 或相同的分工。可以让一个 AI 直接实现，也可以由人决定方案、AI 写代码，或者让 AI 只做计划、教学和审查。

当前维护者经常采用“主 AI 做决策和审查，`cc` 执行部分任务”的方式；`cc` 是个人电脑上的本地执行入口，不是仓库或机器狗运行依赖。其他组员可以完全不使用它。

开始任务时，建议告诉 AI 自己的操作系统、仓库根目录、连接方式、希望 AI 承担的角色、允许执行的操作和本次任务范围。详细示例见 [实体机开发与 AI 交接指南](docs/AI_CYBERDOG_DEVELOPMENT_GUIDE.md)。

## 当前目录

```text
robot_runtime/
  check_status.py          # 读取 motion_status，确认机器狗运动状态
  stand1.py                # 低风险站立动作测试
  down1.py                 # 低风险趴下动作测试
  cyberdog_base.py         # 通用 ROS2 节点、安全检查和动作调用封装
  cyberdog_actions.py      # 一次性动作表
  cyberdog_gaits.py        # 步态动作表
  cyberdog_console.py      # 终端控制台入口
  cyberdog_camera.py       # 相机服务和图像订阅基础模块
  camera_view.py           # 相机预览入口
  ball_detect1.py          # 单色球检测探索脚本
  ball_detect2.py          # 蓝球/橙球检测探索脚本
  run_camera_view.sh       # 机器狗端相机预览启动包装
  SH/                      # 早期 Ubuntu 侧辅助脚本，保留作历史参考

docs/
  AI_CYBERDOG_DEVELOPMENT_GUIDE.md  # 实体机开发与 AI 交接入口
  RACE_RULES_CORRECTED.md            # 六赛段规则理解校正版
  development_notes.md               # 开发记录和当前优先级
```

`robot_runtime/SH` 和旧的本机辅助 shell 脚本保留作历史参考，不是所有组员都要使用的开发入口。可复用逻辑应逐步迁移到明确的机器狗端 runtime 脚本或有文档说明的平台辅助工具。

## 安全原则

实体机调试时默认遵守：

- 人在旁边，手机 APP 急停可用。
- 空旷地面先测试，低风险动作优先。
- 不直接运行高速、跳跃、快速撞击、下台动作。
- 每个动作前检查 `motion_status`。
- 步态类程序必须有速度上限、角速度上限、持续时间和停止逻辑。
- 感知丢失、状态异常、服务调用失败时停止或退出。
- 高风险动作默认锁定或需要明确二次确认。

## 开发约定

- `main` 分支保存稳定版本和已审查文档。
- 新功能从 `dev` 或功能分支开发；分支可以使用 `feature/...`、`fix/...`、`docs/...` 或团队约定的其他清晰名称。
- AI 或自动化工具产生的修改同样先进入功能分支并接受审查，不要求使用 `cc/*` 命名，也不直接推送 `main`。
- 赛道功能按模块推进：基础动作、相机感知、第一关石板、第二关球阵、第三关黄线、第四关隧道、第五关独木桥、第六关终点。
- 本地审查、日志、截图、真实机器狗连接信息不进入公开仓库。

## 已验证环境

实体机环境：

```text
Ubuntu 18.04.5 LTS
aarch64 / tegra
ROS2 Galactic
ROS_DOMAIN_ID=42
```

已验证链路包括：

- SSH 连接机器狗。
- `motion_status` 状态读取。
- 低风险站立动作。
- 相机服务、图像话题和网页预览。
- 蓝色/橙色球的初步 HSV 视觉检测。

## 当前优先级

当前最合理的下一步不是直接写六关总状态机，而是先打牢基础安全层：

1. 强化 `cyberdog_base.py`：步态运行中持续检查状态，异常立即停止。
2. 整理 `cyberdog_console.py`：默认隐藏高风险和极高风险动作。
3. 整理远程运行入口：用明确白名单区分纯检查/感知脚本和可能运动的脚本。
4. 统一相机启动逻辑，复用带 STOP/重试保护的相机基础模块。
5. 再开始第一关“石径探路”的低速半自动原型。
