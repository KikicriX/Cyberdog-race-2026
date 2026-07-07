# Development Notes

## 初始状态

本仓库初版来自 Ubuntu VM 中的：

```text
/home/kiki/cyberdog_develop/program
```

通过 VMware 共享目录同步到 Windows 后整理入仓库。

同步时排除了：

- Python 缓存
- 日志文件
- 图像截图
- 临时文件
- 压缩归档
- 密钥类文件

## 已确认链路

- 可以通过无线 SSH 连接 CyberDog。
- ROS2 Galactic 可用。
- 已验证 `motion_status` 状态读取。
- 已验证低风险站立动作。
- 已验证相机服务、图像话题和本地预览链路。

## 后续优先级

1. 固化基础控制台和安全检查。
2. 只测试站立、趴下、状态读取等低风险动作。
3. 整理相机感知模块，保留可复用接口。
4. 第一赛段从石板低速通过策略开始。
5. 再进入球阵、黄线、隧道、独木桥等高复杂度赛段。
