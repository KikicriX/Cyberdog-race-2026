# CyberDog Race 2026

CyberDog 2026 小米杯实体机赛道开发仓库。

这个公开仓库保存的是经过整理的实体机运行脚本和开发记录。真实调试时请始终以实体机安全为第一优先级：低速、可停、可恢复、可逐步验证。

## 当前工作流

当前主开发入口已经迁移到 Windows 工作区：

```text
G:\Cyberdog_win
```

推荐流程是：

```text
Windows 写代码
-> PowerShell 工具同步到机器狗
-> SSH 到机器狗
-> 机器狗端加载 ROS2 / CyberDog 环境
-> 机器狗端 python3 运行脚本
```

Windows 本机不直接运行 `robot_runtime/*.py`。这些脚本依赖 CyberDog NX 端的 ROS2 Galactic、`protocol` 消息/服务和机器狗 DDS 环境。

机器狗端运行目录约定为：

```text
/home/mi/cyberdog_course/program
```

Windows 侧推荐使用 SSH 配置别名 `cyberdog-win`，不要把真实机器狗 IP、密码或私有密钥提交到公开仓库。

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
  development_notes.md     # 开发记录和当前优先级
```

`robot_runtime/SH` 和旧的本机辅助 shell 脚本不是当前 Windows 主线入口。后续整理时会逐步把可复用逻辑迁移到 Windows PowerShell 工具或明确的机器狗端 runtime 脚本。

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
- 新功能从 `dev` 或功能分支开发。
- cc/自动助手提交建议进入 `cc/*` 分支，不直接推送 `main`。
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
