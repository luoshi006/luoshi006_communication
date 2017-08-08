>`by luoshi006`
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


> 参考：http://www.mavlink.org/dev/mavlink_groundcontrol_integration_tutorial


# 自定义 MAVLink 消息

MAVLink 官方提供消息生成工具（***MAVLink Generator*** (C/C++, Python)），用于自定义Mavlink扩展。MAVLink官方库地址：url = https://github.com/mavlink/mavlink.git

其中，`mavgenerate.py` 就是 Python GUI 的MAVLink消息生成工具。【需安装 **Python 2.7**】
<center>![这里写图片描述](http://img.blog.csdn.net/20160911215329056)</center>
MAVLink 消息定义由 .xml 文件完成，可根据库文件中提供的示例完成，路径：`mavlink\message_definitions\v1.0 `

此处自定义消息时，需在官网处文档，查询已占用的Message_ID，避免出现冲突。完成自定义消息后，需通过官方工具将XML 文档编译为 c 代码。

**其中，输出路径最好是一个独立的文件夹**，因为输出的文件很多。。。

对自定义消息不熟练的同学，建议直接对完整的 `XML` 文档进行修改。
MAVLink 1.0 的 `XML` 文档： [传送门](https://raw.githubusercontent.com/mavlink/mavlink/master/message_definitions/v1.0/common.xml)

将生成的 MAVLink 库，放入 `libs/mavlink` 目录中。


# 地面站解析

官方的文档中描述了 `v2.9.6` 及以前版本的修改方法，从 `UAS` 和 `UASInterface` 继承一个新类，并重写其 `receiveMessage()` 函数，用于处理 MAVLink 消息。

此处，由于 在 `v3.0` 版中，对代码重构，代码结构改变较大。所以，**在此建议，直接在 `UAS` 类 的 `receiveMessage()` 函数中进行修改。**
