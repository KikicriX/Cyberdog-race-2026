# CyberDog Race 2026

CyberDog 2026 小米杯实体机赛道开发仓库。

当前仓库保存的是实体机开发初版程序骨架，重点包括：

- ROS2 Galactic 环境下的基础状态检查与动作调用
- CyberDog 相机启动、图像订阅和本地预览
- 蓝色/橙色球的初步视觉检测脚本
- 终端版动作控制台雏形
- Ubuntu VM 与机器人之间的辅助同步脚本

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
  SH/                      # Ubuntu 侧 SSH、同步和运行辅助脚本
```

## 安全原则

实体机调试时默认遵守：

- 人在旁边，手机 APP 急停可用
- 空旷地面先测试，低风险动作优先
- 不直接运行高速、跳跃、撞击、下台动作
- 步态类程序必须有速度上限、持续时间和停止逻辑
- 感知丢失、状态异常、服务调用失败时停止或退出

## 开发约定

- `main` 分支保存稳定版本。
- 新功能从 `dev` 或功能分支开发。
- cc/自动助手提交建议进入 `cc/*` 分支，不直接推送 `main`。
- 赛道功能按模块推进：基础动作、相机感知、第一关石板、第二关球阵、第三关黄线、第四关隧道、第五关独木桥、第六关终点。

## 运行环境

已验证的实体机环境：

```text
Ubuntu 18.04.5 LTS
aarch64 / tegra
ROS2 Galactic
ROS_DOMAIN_ID=42
```

机器人侧运行前通常需要加载 ROS2 环境。具体脚本仍在实体机开发阶段，执行前请先阅读对应文件。
