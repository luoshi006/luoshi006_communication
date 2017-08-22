> by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

<br><br>

> 参考：https://dev.px4.io/en/log/ekf2_log_replay.html

# sdlog2 日志回放功能

## 参数调整
1.  `SYS_LOGGER`  = 0 （sdlog2）
2.  `EKF2_REC_RPL` = 1 (replay function)
3.  `SDLOG_PRIO_BOOST` = {2 , 3} （提高 log 优先级，减少数据丢包）

## 日志回放

1. 依上述参数修改后，得到日志文件（.px4log）。

2. 使用 Matlab / FlightPlot 等工具查看估计状态。

2. 在 `PX4 Firmware` 根目录下执行：
	```
	make posix_sitl_replay replay logfile=<absolute_path_to_log_file>/my_log_file.px4log
	```
3.  执行结束后得到 `replay log file` ，路径：
	```
	<path to Firmware>/build_posix_sitl_replay/src/firmware/posix/rootfs/replay_replayed.px4log
	```
	在该路径中 `replay_params.txt` 修改 EKF2 参数，如：
	`EKF2_GB_NOISE 0.001`
	
4.  重新执行 【3】中命令，得到修改参数后的状态日志；执行【2--5】步，调整参数。


# ulog 日志回放

##参数
 - `SYS_LOGGER` = 1 (ulog)

## 日志回放

- 整体流程同上；
- 在 `Firmware` 根目录执行：
	`export replay_mode=ekf2
export replay=<abs_path_to_log.ulg>
make posix none`
- 回放日志目录同上（sdlog2）；
- 在 `build_posix_sitl_default_replay/tmp/rootfs/orb_publisher.rules` 中修改 EKF2 所需要的 `topics` ，如：
`restrict_topics: sensor_combined, vehicle_gps_position, vehicle_land_detected
module: replay
ignore_others: true`
- 调整 EKF2 参数方法同上（sdlog2）
- `make posix_sitl_default jmavsim` 生成新日志文件，该命令会打开模拟仿真，可以通过 QGC 查看状态。
- `unset replay
	unset replay_mode` 取消环境变量。

**`ulog` 文件的分析也可以通过官方的脚本**：https://github.com/PX4/pyulog

**PS: ulog 日志也可以通过 QGC 记录，详情参见：**https://dev.px4.io/en/log/logging.html

<hr color=FF0000>

最后，附上福利~
https://github.com/ecmnet/MAVGCL

- 支持 .px4log 日志分析~
- ulog 日志分析，很强大~
- SLAM 大势所趋啊~


> 毕业以后没有设备，所以以上方法均未验证……如有错漏，请海涵，留言或Gitter联系均可。


