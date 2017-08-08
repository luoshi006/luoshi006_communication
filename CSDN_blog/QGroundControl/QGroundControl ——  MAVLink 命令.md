>by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

QGC 中发送 MAVLink 控制命令的函数在：
`\src\FirmwarePlugin\PX4\PX4FirmwarePlugin.cc`

MAVLink 数据结构及编码函数位置：
`  \libs\mavlink\include\mavlink\v1.0\common\mavlink_msg_command_long.h`

<hr color=00FFFF>

`mavlink_command_long_t` 数据结构：
```cpp
  typedef struct __mavlink_command_long_t {
 float param1; /*< Parameter 1, as defined by MAV_CMD enum.*/
 float param2; /*< Parameter 2, as defined by MAV_CMD enum.*/
 float param3; /*< Parameter 3, as defined by MAV_CMD enum.*/
 float param4; /*< Parameter 4, as defined by MAV_CMD enum.*/
 float param5; /*< Parameter 5, as defined by MAV_CMD enum.*/
 float param6; /*< Parameter 6, as defined by MAV_CMD enum.*/
 float param7; /*< Parameter 7, as defined by MAV_CMD enum.*/
 uint16_t command; /*< Command ID, as defined by MAV_CMD enum.*/
 uint8_t target_system; /*< System which should execute the command*/
 uint8_t target_component; /*< Component which should execute the command, 0 for all components*/
 uint8_t confirmation; /*< 0: First transmission of this command. 1-255: Confirmation transmissions (e.g. for kill command)*/
}) mavlink_command_long_t;
```

`mavlink_msg_command_long_encode()` 编码函数：
```cpp
/**
 * @brief Encode a command_long struct
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 * @param command_long C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_command_long_encode(
						uint8_t system_id, 
						uint8_t component_id, 
						mavlink_message_t* msg, 
						const mavlink_command_long_t* command_long)
{
	return mavlink_msg_command_long_pack(
							system_id, 
							component_id, 
							msg, 
							command_long->target_system, 
							command_long->target_component, 
							command_long->command, 
							command_long->confirmation, 
							command_long->param1, 
							command_long->param2, 
							command_long->param3, 
							command_long->param4, 
							command_long->param5, 
							command_long->param6, 
							command_long->param7);
}
```
<hr color=FFFF00>

`\src\MissionManager\MavCmdInfoCommon.json` mavlink命令信息：
```json
    "mavCmdInfo": [
        {
            "id":                   22,
            "rawName":              "MAV_CMD_NAV_TAKEOFF",
            "friendlyName":         "Takeoff",
            "description":          "Take off from the ground.",
            "specifiesCoordinate":  false,
            "friendlyEdit":         true,
            "category":             "Basic",
            "param1": {
                "label":            "Pitch:",
                "units":            "degrees",
                "default":          15,
                "decimalPlaces":    2
            },
            "param7": {
                "label":            "Altitude:",
                "units":            "m",
                "default":          25.0,
                "decimalPlaces":    2
            }
        },
        ....//省略代码;
        ]
```
<hr color=FF00FF>

地面站中发送 `takeoff` 命令：

```cpp
	#include "QGCApplication.h" 
	//该文件包含大量头文件;
	
    MAVLinkProtocol* mavlink = qgcApp()->toolbox()->mavlinkProtocol();
	//获取当前 mavlink 指针；
	
    // Set destination altitude
    mavlink_message_t msg;
    mavlink_command_long_t cmd;

    cmd.command = (uint16_t)MAV_CMD_NAV_TAKEOFF;//起飞命令;
    cmd.confirmation = 0;
    cmd.param1 = -1.0f;//俯仰;
    cmd.param2 = 0.0f;
    cmd.param3 = 0.0f;
    cmd.param4 = NAN;
    cmd.param5 = NAN;
    cmd.param6 = NAN;
    cmd.param7 = vehicle->altitudeAMSL()->rawValue().toDouble() + altitudeRel;//高度;
    cmd.target_system = vehicle->id();
    cmd.target_component = vehicle->defaultComponentId();

    mavlink_msg_command_long_encode(mavlink->getSystemId(), mavlink->getComponentId(), &msg, &cmd);//mavlink命令编码：
    vehicle->sendMessageOnPriorityLink(msg);//将发送信息任务加入主进程;
 

```

