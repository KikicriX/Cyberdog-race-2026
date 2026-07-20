# 机器狗 program 目录

此目录完整同步到机器狗：

```text
Windows: G:\Cyberdog_win\program
Robot:   /home/mi/cyberdog_course/program
```

- `core/`：动作、步态和公共控制模块。
- `perception/`：相机预览和视觉识别。
- `manual_tests/`：状态检查、站立和趴下等人工测试。
- `stages/`：按赛道阶段组织的任务代码。

功能目录内互相依赖的脚本放在同一目录。例如 `camera_view.py` 与 `cyberdog_camera.py` 都位于 `perception/`，狗端通过 `perception/run_camera_view.sh` 启动。

鱼眼相机只读探测：

```powershell
.\tools\run_on_dog.ps1 -Script perception/fisheye_probe.py -PushFirst -Args "--duration","12"
```

脚本只有在左右两路都收到至少 3 帧时才输出 `FISHEYE_PAIR_READY=yes`。它不会调用相机服务、lifecycle 或运动接口。
