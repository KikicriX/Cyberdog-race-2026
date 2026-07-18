# CyberDog 实体机开发与 AI 交接指南

更新日期：2026-07-18

适用范围：CyberDog 2026 小米杯实体机赛道项目。本文既供新组员阅读，也可以直接作为新 AI 对话的首份上下文。

目录约定：公开 GitHub 仓库以 `robot_runtime/` 作为机器狗端脚本目录；当前维护者的 Windows 工作区将它映射为 `G:\Cyberdog_win\program\robot_runtime/`。两者内容对应，但组员和 AI 编写仓库代码时应使用相对路径 `robot_runtime/`，不得依赖个人绝对路径。

## 1. 先说结论

本项目不是在 Windows 上直接控制机器人。正确链路是：

```text
组员自己的电脑编写代码
        ↓
通过 SSH/SCP 或项目脚本把文件传到机器狗
        ↓
在机器狗 NX 的 Ubuntu 环境中加载 ROS 2/CyberDog 环境
        ↓
由机器狗端的 Python 3 + rclpy 程序调用 ROS 2 接口
        ↓
订阅状态/图像，调用动作服务，发布连续步态命令
```

因此，“让 AI 会写这个机器狗的代码”不能只给它一份赛题 PDF。至少要让 AI 同时知道：

1. 实体机实际提供了哪些 ROS 2 话题、服务和消息类型。
2. 官方消息定义和官方示例代码从哪里来。
3. 本项目已经验证过哪些接口和脚本。
4. 本项目的安全规则、赛题校正规则和代码组织方式。

## 2. 资料可信度顺序

遇到资料冲突时，按下面的顺序判断：

| 优先级 | 依据 | 用途 |
| --- | --- | --- |
| 1 | 当前参赛实体机的 `ros2` 探测结果和 `ros2 interface show` | 决定真实接口名、类型、字段和 QoS |
| 2 | 与实体机版本匹配的 Xiaomi/MiRoboticsLab 官方源码 | 理解字段含义、动作 ID 和官方调用方式 |
| 3 | 本仓库已在实体机验证过的脚本 | 作为项目代码基线 |
| 4 | 官方赛题 PDF + 小组确认后的规则校正 | 决定状态机和任务策略 |
| 5 | 博客、论坛、其他机器狗代码和 AI 的记忆 | 只能参考，不能直接用于实体机 |

最重要的原则是：**AI 不得凭印象猜 ROS 2 接口、消息字段、动作 ID、相机命名空间或速度范围。** 缺少证据时，应先请求或执行只读探测。

## 3. 官方开发资料从哪里来

当前项目所用的 `protocol.msg`、`protocol.srv` 和运动示例，主要来自 Xiaomi/MiRoboticsLab 的四足开发者平台源码，而不是普通的 ROS 2 教程。

### 3.1 官方主仓库和文档索引

- [MiRoboticsLab/cyberdog_ws](https://github.com/MiRoboticsLab/cyberdog_ws)：四足开发者平台主仓库，列出了 `bridges`、`motion`、`sensors`、`devices`、`interaction` 等子仓库和设计文档入口。
- [MiRoboticsLab 开发文档站](https://miroboticslab.github.io/blogs/)：官方模块设计文档入口。
- [MiRoboticsLab/cyberdog_ros2](https://github.com/MiRoboticsLab/cyberdog_ros2)：较早一套 CyberDog ROS 2 总体架构资料，可用于理解 Galactic、Cyclone DDS 和模块划分，但不能自动替代实体机的 `protocol` 接口。

### 3.2 本项目最相关的接口定义

- [MiRoboticsLab/bridges](https://github.com/MiRoboticsLab/bridges)：ROS 消息和服务定义所在仓库。
- [`protocol/ros/msg`](https://github.com/MiRoboticsLab/bridges/tree/rolling/protocol/ros/msg)：消息定义目录。
- [`protocol/ros/srv`](https://github.com/MiRoboticsLab/bridges/tree/rolling/protocol/ros/srv)：服务定义目录。
- [`MotionStatus.msg`](https://github.com/MiRoboticsLab/bridges/blob/rolling/protocol/ros/msg/MotionStatus.msg)：机器人运动状态和 `switch_status` 枚举。
- [`MotionServoCmd.msg`](https://github.com/MiRoboticsLab/bridges/blob/rolling/protocol/ros/msg/MotionServoCmd.msg)：连续运动命令字段以及 `SERVO_START/DATA/END`。
- [`MotionID.msg`](https://github.com/MiRoboticsLab/bridges/blob/rolling/protocol/ros/msg/MotionID.msg)：官方动作和步态 ID。
- [`MotionResultCmd.srv`](https://github.com/MiRoboticsLab/bridges/blob/rolling/protocol/ros/srv/MotionResultCmd.srv)：一次性动作服务的请求和响应字段。
- [`CameraService.srv`](https://github.com/MiRoboticsLab/bridges/blob/rolling/protocol/ros/srv/CameraService.srv)：相机启动、停止和返回状态定义。

### 3.3 官方 Python 运动示例

- [MiRoboticsLab/motion](https://github.com/MiRoboticsLab/motion)：运动管理源码。
- [`motion_action/scripts`](https://github.com/MiRoboticsLab/motion/tree/rolling/motion_action/scripts)：官方 Python 示例目录。
- [`motion_units.py`](https://github.com/MiRoboticsLab/motion/blob/rolling/motion_action/scripts/motion_units.py)：站立、趴下、行走和姿态控制的基础调用示例。
- [`motion_teleop.py`](https://github.com/MiRoboticsLab/motion/blob/rolling/motion_action/scripts/motion_teleop.py)：连续运动发布方式。
- [`pose_teleop.py`](https://github.com/MiRoboticsLab/motion/blob/rolling/motion_action/scripts/pose_teleop.py)：姿态控制示例。

官方示例用于确认接口和基本调用流程，不代表可以原样用于比赛。示例通常缺少本项目要求的运行中安全检查、速度限制、超时、感知丢失处理和状态机恢复。

项目在 2026-07-01 做过一次官方源码探测，参考版本包括：

```text
cyberdog_ws rolling: b101edda49facffb55be0b931ab235e720359a54
bridges rolling:      047a0a48b9f2411ed535555eaa6c2276699378ac
motion rolling:       4d241d1cfca1610f3658bac31acea01277b7a47c
```

这些提交用于解释当前代码来源。若实体机固件升级，应重新探测，不能假定最新版源码与机器人完全一致。

## 4. 当前实体机和项目已确认的事实

机器狗端当前使用：

```text
Ubuntu 18.04.5 LTS
aarch64 / NVIDIA Jetson
ROS 2 Galactic
Cyclone DDS
ROS_DOMAIN_ID=42
/opt/ros2/galactic/setup.bash
/opt/ros2/cyberdog/setup.bash
```

当前项目已确认的运动接口：

```text
/custom_namespace/motion_status       protocol/msg/MotionStatus
/custom_namespace/motion_result_cmd   protocol/srv/MotionResultCmd
/custom_namespace/motion_servo_cmd    protocol/msg/MotionServoCmd
```

当前项目已确认的 RGB 图像链路：

```text
相机服务：<robot-namespace>/camera_service
图像话题：<robot-namespace>/image
当前实测图像：640 x 480, bgr8
```

`<robot-namespace>` 可能和机器人名称或网卡状态有关。其他组员的机器人或固件环境不能直接照抄本机命名空间，必须先探测。

已经完成过实体机验证的最小能力：

- SSH 登录和远程运行 Python 脚本。
- `check_status.py` 能收到 `MotionStatus`。
- `stand1.py` 能通过 `MotionResultCmd` 执行恢复站立。
- 相机服务、图像话题、网页预览和基础颜色检测链路已跑通。

“已验证”只代表上述具体路径曾成功，不代表所有动作表、速度、跳跃和完整赛道状态机都已验证。

## 5. AI 应该怎样理解项目代码

### 5.1 先区分四种东西

| 名称 | 来源 | 例子 |
| --- | --- | --- |
| ROS 2/机器人原生定义 | 官方 `.msg`、`.srv` 或实体机安装包 | `MotionStatus.switch_status`、`MotionResultCmd.Request.motion_id` |
| 实体机接口名称 | 当前机器人运行图中探测得到 | `/custom_namespace/motion_status` |
| 项目保存的运行状态 | 我们自己定义 | `self.latest_status`、`self.latest_frame` |
| 项目辅助逻辑 | 我们自己定义 | `switch_status_name()`、`is_status_safe()`、速度限幅 |

例如安全状态的完整数据链应解释为：

```text
机器人原生字段 MotionStatus.switch_status
        ↓
回调保存到 self.latest_status
        ↓
项目函数 switch_status_name() 翻译数字
        ↓
日志显示 NORMAL / ESTOP / LOW_BAT 等文字
        ↓
项目函数 is_status_safe() 做最终安全判断
```

`status_name` 不是机器人发来的字段，不能和 `switch_status` 混为一谈。

### 5.2 三条主要代码路径

读取状态：

```text
create_subscription(MotionStatus, ...)
-> 回调保存最新消息
-> 等待首条消息并设置超时
-> 读取 switch_status
-> 决定允许、恢复或停止
```

执行一次性动作：

```text
create_client(MotionResultCmd, ...)
-> 等待服务
-> 构造 Request
-> 使用 MotionID 中的官方常量
-> call_async
-> 等待 response 或超时
-> 检查 result 和 code
```

执行连续步态：

```text
create_publisher(MotionServoCmd, ...)
-> 构造运动命令
-> 对速度、角速度和时长限幅
-> 约 20 Hz 周期发布
-> 每个周期继续处理状态消息并重新检查安全状态
-> 任意退出路径都发布 SERVO_END
```

连续步态的 `SERVO_END` 必须放在 `finally` 或等价的必达清理路径中。只在运动开始前检查一次状态是不够的。

### 5.3 相机代码路径

```text
CameraService 启动图像发布
-> 订阅 sensor_msgs/msg/Image
-> 根据 encoding/height/width/step 解码
-> 转成 OpenCV BGR 图像
-> 感知算法输出目标类别、置信度和图像位置
-> 决策层选择低速动作
-> 感知超时或目标丢失时停止
-> finally 停止相机或运动输出
```

相机基础通信放在 `cyberdog_camera.py`；球、黄线、石板、目标物等识别算法不应继续复制一套相机启动逻辑。

## 6. 新代码的标准写法

新 Python/ROS 2 脚本按小模块组织：

1. imports。
2. ROS 2/DDS 环境和常量。
3. 话题、服务、QoS 和安全限值。
4. `Node` 类骨架。
5. 原生消息回调。
6. 状态等待与安全判断。
7. 感知或动作辅助函数。
8. 单次任务流程。
9. `main()` 中的初始化和 `try/finally` 清理。

代码要求：

- CyberDog 项目代码使用中文注释，尤其是机器人原生字段、自定义变量、安全检查和感知流程。
- 优先复用 `cyberdog_base.py`、`cyberdog_camera.py`，不要复制粘贴出多个不一致版本。
- 使用 `MotionID.<NAME>`，只有在兼容旧固件时才允许带说明的数值回退。
- 所有等待都要有超时；所有循环都要能退出；所有连续运动都要能停止。
- 参数默认低速、短时长，并在函数入口再次限幅。
- 高风险动作默认不可见或锁定，不能只靠一条确认提示保护。
- 规则扣分和机器人安全异常是两类状态。触线、普通碰撞等通常记录后继续；急停、摔倒、姿态异常、低电量或感知完全丢失才进入停止/恢复。

## 7. 不知道接口时，先这样探测

下面命令只读，不会主动让机器狗运动。先加载机器人环境：

```bash
set +u
source /opt/ros2/galactic/setup.bash
source /opt/ros2/cyberdog/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=file:///etc/mi/cyclonedds.xml
export ROS_DOMAIN_ID=42
export ROS_LOCALHOST_ONLY=0
```

再检查运行图：

```bash
ros2 node list
ros2 topic list -t
ros2 service list -t
ros2 topic info -v /custom_namespace/motion_status
ros2 service type /custom_namespace/motion_result_cmd
```

检查消息和服务的真实字段：

```bash
ros2 interface show protocol/msg/MotionStatus
ros2 interface show protocol/msg/MotionServoCmd
ros2 interface show protocol/msg/MotionID
ros2 interface show protocol/srv/MotionResultCmd
ros2 interface show protocol/srv/CameraService
```

把这些输出交给 AI，比只告诉它“这是 CyberDog”可靠得多。探测结果应去掉序列号、IP、Wi-Fi、账号等敏感信息后再共享。

## 8. 怎样把代码写进机器狗并运行

### 8.1 任意电脑的通用方式

电脑只需要能使用 SSH/SCP；ROS 2 Python 程序仍在机器狗端运行。

```bash
scp your_script.py <robot-user>@<robot-host>:<remote-program-dir>/
ssh <robot-user>@<robot-host>
```

进入机器狗后：

```bash
set +u
source /opt/ros2/galactic/setup.bash
source /opt/ros2/cyberdog/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=file:///etc/mi/cyclonedds.xml
export ROS_DOMAIN_ID=42
export ROS_LOCALHOST_ONLY=0
cd <remote-program-dir>
python3 your_script.py
```

首次测试先运行只读脚本，再运行低风险动作。不要从 AI 生成代码直接跳到跳跃、翻转、快速行走或撞击测试。

### 8.2 当前维护者 Windows 工作区的辅助方式

在 `G:\Cyberdog_win` 中：

```powershell
# 连接机器人
.\tools\windows\connect_dog.ps1

# 推送一个脚本
.\tools\windows\push_to_dog.ps1 -Files check_status.py

# 在机器人端运行
.\tools\windows\run_on_dog.ps1 -Script check_status.py

# 先推送再运行
.\tools\windows\run_on_dog.ps1 -Script check_status.py -PushFirst
```

这些 PowerShell 封装属于当前维护者的本地工作区工具，不是所有组员环境中的必选入口。缺少这些工具时，使用 8.1 节的 SSH/SCP 通用流程即可。

Windows 本机不需要安装项目中的 `rclpy` 和 `protocol`，也不要直接执行仓库里的 `robot_runtime/*.py`。在当前维护者工作区中，对应路径是 `program/robot_runtime/*.py`。

不同组员可以使用自己的 SSH 配置、Linux shell、IDE 或同步脚本，但仓库内的 Python 代码和远端运行目录约定应保持一致。机器人地址、账号和密钥放在各自本地配置中，不提交到 Git。

## 9. 从不会写到可以验证的开发顺序

每个新功能按以下顺序推进：

1. 静态阅读官方消息定义和本项目封装。
2. 在个人电脑做语法检查、数据处理单元测试和录制图像测试。
3. SSH 到机器人做 `import` 检查和 ROS 2 接口只读探测。
4. 运行 `check_status.py`，确认状态链路。
5. 在空旷平地、有人看护且 APP 急停可用时测试一个低风险短动作。
6. 验证超时、状态异常、感知丢失和 `Ctrl-C` 都会停止输出。
7. 保存日志、参数和测试结论，再扩大速度、时长或任务范围。

单个功能的完成标准至少包括：正常路径、超时路径、异常状态路径和清理路径。

## 10. 赛题对架构的直接要求

比赛共六个赛段，程序启动后必须全程自主。目标物和障碍物会调整，不能依赖固定坐标或固定顺序。

建议分层：

```text
perception/       图像、目标、边线和障碍物识别
motion/           低速移动、转向、低姿通过、绕行和已验证跳跃
safety/           状态、姿态、低电量、看门狗和停止
stages/           六个赛段的局部状态机
race_state_machine.py
```

第四赛段尤其不能写死“左通道可乐、中通道橙球、右通道足球”。每条通道都应从未知状态开始：

```python
lane_1 = {"target": None, "obstacle": None, "completed": False}
lane_2 = {"target": None, "obstacle": None, "completed": False}
lane_3 = {"target": None, "obstacle": None, "completed": False}
```

进入通道后识别目标和障碍类型、判断前后关系、规划处理顺序，再更新通道记录。第五赛段末端必须调用经过实体机验证的跳跃动作；普通走下不算正确完成。

完整赛道规则应同时提供给 AI：

- 组内保存的官方赛题 PDF；公开仓库可能不收录该文件，应由组员从可靠来源单独提供并核对版本。
- [`docs/RACE_RULES_CORRECTED.md`](RACE_RULES_CORRECTED.md)：小组确认后的赛道理解校正版，尤其是第四赛段随机分配说明。

注意：当前维护者工作区里的 `docs/race_problem.pdf` 实际是 HTML 错误页面伪装成 PDF，不能作为赛题资料提供给 AI。

## 11. 当前仓库中应该先给 AI 看的文件

最小上下文包：

```text
docs/AI_CYBERDOG_DEVELOPMENT_GUIDE.md
docs/RACE_RULES_CORRECTED.md
README.md
robot_runtime/check_status.py
robot_runtime/cyberdog_base.py
robot_runtime/cyberdog_camera.py
robot_runtime/cyberdog_actions.py
robot_runtime/cyberdog_gaits.py
```

当前维护者在 `G:\Cyberdog_win` 中工作时，上述 `robot_runtime/` 文件对应 `program/robot_runtime/`。若需要复用本地推送封装，可额外提供 `tools/windows/README.md`；该文件不是理解机器人 ROS 2 代码的必要前提。

按任务追加：

- 动作任务：追加 `stand1.py`、`down1.py`、官方 `MotionID.msg` 和 `MotionResultCmd.srv`。
- 连续移动：追加 `cyberdog_base.py`、官方 `MotionServoCmd.msg` 和当前机器人接口探测输出。
- 视觉任务：追加 `camera_view.py`、`ball_detect2.py`、录制图片或视频，不要只给口头颜色描述。
- 赛道状态机：追加官方赛题 PDF、规则校正版、各单项能力的已验证记录。

不要把密码、私钥、真实机器人 IP、Wi-Fi 信息、完整无关日志和 `captures/` 全目录直接喂给外部 AI。

## 12. 可以直接发给新 AI 的开场提示

```text
你正在协助 CyberDog 2026 小米杯实体机赛道项目。

请先阅读：
1. docs/AI_CYBERDOG_DEVELOPMENT_GUIDE.md
2. README.md
3. 与本次任务相关的 robot_runtime 文件
4. 本次提供的实体机 ros2 接口探测结果

开发约束：
- 代码在电脑上编写，但依赖 rclpy/protocol 的程序在机器狗 NX 端运行。
- 不得猜测话题、服务、消息字段、动作 ID、QoS 或相机命名空间；证据不足时先提出只读探测命令。
- 明确区分机器人/ROS 2 原生字段与项目自定义变量、翻译表和安全判断。
- 优先复用现有基础模块，使用中文注释，按 imports、常量、类、辅助函数、main 的小模块组织。
- 所有动作先检查状态；连续运动期间持续检查状态；所有循环有超时；所有退出路径发送停止命令。
- 默认低速、短时长；高风险动作锁定；未经明确授权不得在实体机运行运动脚本。
- 感知丢失、急停、低电量或姿态异常进入停止/恢复；普通赛道扣分事件记录后尽量继续。
- 不写死赛道目标坐标和顺序，第四赛段三条通道内容随机。
- 不输出或提交机器人地址、密码、SSH 密钥等敏感信息。

本次任务：<在这里写清具体目标、允许修改的文件和验证范围>。

请先说明你依据了哪些原生接口和哪些项目封装，再进行修改。完成后给出变更摘要、静态验证结果、尚未进行的实体机验证和风险点。
```

## 13. 当前代码的已知风险

新 AI 在继续开发前必须知道这些问题：

- `cyberdog_base.py` 的连续步态循环目前只在开始前检查安全状态，循环中虽处理了消息，但还没有在每轮重新判断 `switch_status`。修复前不能把它当作完整看门狗。
- `cyberdog_actions.py` 默认列表包含跳台、空翻等高风险动作；早期开发应隐藏或显式解锁，不应默认展示。
- `run_on_dog.ps1` 当前根据脚本文件名猜测是否有运动风险；带有 `detect`、`camera` 等词的“感知 + 运动”脚本可能被误判为只读。后续应改成明确允许列表或脚本元数据。
- `ball_detect1.py` 和 `ball_detect2.py` 含有旧版相机启动逻辑，应逐步改为复用 `cyberdog_camera.py` 的启动、重试和停止流程。
- 现有动作 ID 表和速度值并非全部经过实体机验证。未经验证的值只能标记为候选，不能写成“已确认”。

## 14. 团队协作约定

- 仓库只保存可共享代码、文档、脱敏配置模板和小型测试样本。
- 每项机器人实测记录日期、机器人/固件环境、脚本版本、参数、结果和停止方式。
- 组员开发环境可以不同，但提交的代码不能依赖个人绝对路径。
- 功能分支分别承载视觉、运动、安全和赛段任务；未经审查不直接覆盖稳定分支。
- AI 可以生成代码、测试和文档，但实体机运动执行必须由在场人员确认环境安全后进行。

这份文档是开发入口，不替代实体机探测结果、官方消息定义和赛题原文。三者应与项目代码一起交给新的组员或 AI。

