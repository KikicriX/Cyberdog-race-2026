# CyberDog 2026 Windows 工作区

Windows 负责写代码、同步文件和远程启动；依赖 ROS2 / CyberDog 的程序仍在机器狗 NX 端运行。

## 目录约定

- `program/`：活动代码，完整对应机器狗的 `/home/mi/cyberdog_course/program/`。
- `program/core/`：动作、步态和控制台等基础控制模块。
- `program/perception/`：相机、画面预览和视觉识别。
- `program/manual_tests/`：状态检查及需要人工看护的站立、趴下测试。
- `program/stages/`：后续按赛道阶段编写的任务代码。
- `tools/`：Windows PowerShell 连接、同步和启动工具。
- `legacy/`：旧 Ubuntu 主机工具和已停用实验，不会被 `push_to_dog.ps1 -All` 同步。
- `docs/`：赛题、规则和项目笔记。
- `log/`：Windows 侧运行日志。

新组员或新的 AI 对话请先阅读：

- [`docs/AI_CYBERDOG_DEVELOPMENT_GUIDE.md`](docs/AI_CYBERDOG_DEVELOPMENT_GUIDE.md)
- [`docs/RACE_RULES_CORRECTED.md`](docs/RACE_RULES_CORRECTED.md)

## 首次连接

先创建不会提交到 Git 的本地连接配置，并填写机器狗当前地址：

```powershell
Copy-Item .\tools\config.example.ps1 .\tools\config.ps1
```

确认电脑和机器狗处于可通信网络后运行：

```powershell
.\tools\connect_dog.ps1
```

相机启动器需要免密 SSH；只需配置一次：

```powershell
.\tools\setup_ssh_key.ps1
```

连接参数统一放在本地 `tools/config.ps1`；仓库只提供不含真实地址的 `tools/config.example.ps1`。

## 打开相机画面

第一次使用、代码刚更新或不确定狗内文件版本时运行：

```powershell
.\tools\start_camera_view.ps1 -PushFirst
```

确认狗内已经是最新版后可直接运行：

```powershell
.\tools\start_camera_view.ps1
```

左右鱼眼预览会直接读取两颗 OV9782，不调用原厂 `stereo_camera` lifecycle 节点：

```powershell
.\tools\start_camera_view.ps1 -Source fisheye -PushFirst
```

鱼眼模式要求 `/dev/video2` 和 `/dev/video3` 未被 MIVINS 或其他相机进程占用。

脚本会自动执行以下步骤：

1. 建立 Windows `127.0.0.1:18080` 到机器狗 `127.0.0.1:8080` 的 SSH 隧道。
2. 在机器狗上启动 `program/perception/run_camera_view.sh`。
3. 由该 shell 脚本加载 ROS2 环境并运行 `camera_view.py`。
4. 页面就绪后打开浏览器 `http://127.0.0.1:18080/`。

`connect_dog.ps1` 主要用于检查连接或手动进入狗端；`start_camera_view.ps1` 会自行建立所需连接，因此不要求前一个 SSH 会话一直保持打开。按 `Ctrl-C` 停止相机预览和隧道。

## 同步与运行

同步单个文件，并保留其功能子目录：

```powershell
.\tools\push_to_dog.ps1 -Files manual_tests/check_status.py
```

同步全部活动 Python / shell 文件：

```powershell
.\tools\push_to_dog.ps1 -All
```

在机器狗上运行状态检查：

```powershell
.\tools\run_on_dog.ps1 -Script manual_tests/check_status.py -PushFirst
```

不要直接在 Windows 本机运行 `program/` 下依赖 ROS2 的脚本。

## Windows cc 执行区

```powershell
cd G:\Cyberdog_win
.\cc_executor\start_cc.ps1
```

会话日志写入 `G:\Cyberdog_win\log\cc_sessions`。安全模式使用：

```powershell
.\cc_executor\start_cc.ps1 -Safe
```
