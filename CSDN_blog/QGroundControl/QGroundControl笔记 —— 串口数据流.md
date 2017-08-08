>`by luoshi006`
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

地面站与飞行器的链接常用的就是：串口（Serial Link）。

本文主要描述数据经由串口读取后的流向。

# 相关文档

涉及到的主要文档包括：
`\src\comm\SerialLink.h`
`\src\comm\LinkInterface.h`
`\src\comm\LinkManager.h`
`\src\comm\MAVLinkProtocol.h`
`\src\ui\MAVLinkDecoder.h`
`\src\uas\UASMessageHandler.h`
`\src\uas\UAS.h`
`\src\Vehicle\Vehicle.h`

#串口数据流

当串口缓冲区有数据时，进行读串口操作，通过与 `readyRead` 信号关联槽函数实现。

```cpp
//    \src\comm\SerialLink.cc
    QObject::connect(_port, &QIODevice::readyRead, this, &SerialLink::_readBytes);

//    \src\comm\SerialLink.cc
void SerialLink::_readBytes(void)
{
    qint64 byteCount = _port->bytesAvailable();
    if (byteCount) {
        QByteArray buffer;
        buffer.resize(byteCount);
        _port->read(buffer.data(), buffer.size());
        emit bytesReceived(this, buffer);//@@@@@@@@@@@@@@
    }
}
```

在槽函数中，再次发送信号 `bytesReceived()` ，该信号定义于 `LinkInterface` 中。


```cpp
    /**        \src\comm\LinkInterface.h
     * @brief New data arrived
     *
     * The new data is contained in the QByteArray data. The data is copied for each
     * receiving protocol. For high-speed links like image transmission this might
     * affect performance, for control links it is however desirable to directly
     * forward the link data.
     *
     * @param data the new bytes
     */
    void bytesReceived(LinkInterface* link, QByteArray data);


	//    \src\comm\LinkManager.cc
    connect(link, &LinkInterface::bytesReceived,        _mavlinkProtocol,   &MAVLinkProtocol::receiveBytes);

```

`bytesReceived` 信号直接关联到  `MAVLinkProtocol`。

```cpp
/**   		\src\comm\MAVLinkProtocol.cc
 * This method parses all incoming bytes and constructs a MAVLink packet.
 * It can handle multiple links in parallel, as each link has it's own buffer/
 * parsing state machine.
 * @param link The interface to read from
 * @see LinkInterface
 **/
void MAVLinkProtocol::receiveBytes(LinkInterface* link, QByteArray b)
{
...
//检测到以下命令，则直接反馈；
	MAVLINK_MSG_ID_PING
	MAVLINK_MSG_ID_RADIO_STATUS
	MAVLINK_MSG_ID_HEARTBEAT


            // The packet is emitted as a whole, as it is only 255 - 261 bytes short
            // kind of inefficient, but no issue for a groundstation pc.
		// 之前的消息都是短消息，这里则是满负荷的消息。
            emit messageReceived(link, message);//@@@@@@@@@@@@@
...

	m_multiplexingEnabled//这个多路传输，看起来好像是消息广播，难道是用于多地面站？？？
}
```

此处将满载的消息发射，用于解码线程。

```cpp

	//    \src\comm\MAVLinkProtocol.h   信号定义
signals:
    /** @brief Message received and directly copied via signal */
    void messageReceived(LinkInterface* link, mavlink_message_t message);

	//      \src\Vehicle\Vehicle.cc    该槽函数 用于解码
    connect(_mavlink, &MAVLinkProtocol::messageReceived,     this, &Vehicle::_mavlinkMessageReceived);

//      \src\ui\MAVLinkDecoder.cc     信号槽  用于显示？？？
MAVLinkDecoder::MAVLinkDecoder(MAVLinkProtocol* protocol, QObject *parent) :
    QThread()
{
...
connect(protocol, &MAVLinkProtocol::messageReceived, this, &MAVLinkDecoder::receiveMessage);
}
```

此处先讲 `MAVLinkDecoder::receiveMessage`，解码作为单章。


```cpp
//      \src\ui\MAVLinkDecoder.cc
void MAVLinkDecoder::receiveMessage(LinkInterface* link,mavlink_message_t message)
{
...
	//调整消息中的时间，与地面站对齐。

    // Send out all field values for this message
    for (unsigned int i = 0; i < messageInfo[msgid].num_fields; ++i)
    {
        emitFieldValue(&message, i, time);//@@@@@@@@@@@@@@
    }
}
```

此处将消息送到 `emitFieldValue()` 函数解码。

```cpp
	//        \src\ui\MAVLinkDecoder.cc   源程序约300行，摘取部分注释；
	
void MAVLinkDecoder::emitFieldValue(mavlink_message_t* msg, int fieldid, quint64 time)
{
	...	
        // 支持多组件检测，传感器的冗余检测；
            componentMulti[msg->msgid] = true;
	...
	//此处根据 消息的数据类型 进行处理；
    switch (messageInfo[msgid].fields[fieldid].type)
    {
    case MAVLINK_TYPE_CHAR:
        if (messageInfo[msgid].fields[fieldid].array_length > 0) {
            emit textMessageReceived(msg->sysid, msg->compid, MAV_SEVERITY_INFO, string);
        }  else {
            emit valueChanged(msg->sysid, name, unit, b, time);
        }
        break;
    case MAVLINK_TYPE_UINT8_T:
        if (messageInfo[msgid].fields[fieldid].array_length > 0)
        {
          emit valueChanged(msg->sysid, QString("%1.%2").arg(name).arg(j), fieldType, nums[j], time);
        }
        else
        {
            emit valueChanged(msg->sysid, name, fieldType, u, time);
        }
        break;

	....
	....
	....
    case MAVLINK_TYPE_INT64_T:
        if (messageInfo[msgid].fields[fieldid].array_length > 0)
        {
            emit valueChanged(msg->sysid, QString("%1.%2").arg(name).arg(j), fieldType, (qint64) nums[j], time);
        }
        else
        {
            emit valueChanged(msg->sysid, name, fieldType, (qint64) n, time);
        }
        break;
    default:
        qDebug() << "WARNING: UNKNOWN MAVLINK TYPE";
    }
}
```

其中，主要用到了 两个信号：

```cpp
signals:
    void textMessageReceived(int uasid, int componentid, int severity, const QString& text);
    void valueChanged(const int uasId, const QString& name, const QString& unit, const QVariant& value, const quint64 msec);
```

```cpp
	//   \src\ui\uas\UASMessageView.cc   UASMessageViewWidget 构造函数中；
    connect(_uasMessageHandler, &UASMessageHandler::textMessageReceived, this, &UASMessageViewWidget::handleTextMessage);

	该槽函数用于（ui()->plainTextEdit）消息显示，支持滚动条；
	
####################################################################

	//    \src\ui\MainWindow.cc  _buildCommonWidgets(void) 在构造函数中调用；
    connect(mavlinkDecoder.data(), &MAVLinkDecoder::valueChanged, this, &MainWindow::valueChanged);//信号转发，没有找到相关的槽

	//    \src\ui\linechart\Linecharts.cc
    connect(_mavlinkDecoder, &MAVLinkDecoder::valueChanged, widget, &LinechartWidget::appendData);
    //用于显示，下同。

	//      \src\ui\uas\UASQuickView.cc
	connect(decoder,SIGNAL(valueChanged(int,QString,QString,QVariant,quint64)),this,SLOT(valueChanged(int,QString,QString,QVariant,quint64)));
```

# MAVLink 解码

MAVLink 解码分为两个部分：

1. 一部分在 `Vehicle` 类中，这里解码后，主要对地面站的飞行器状态进行更新；
2. 另一部分在 `UAS` 类中，这里有完整的解码函数，解码得到对应的信息；

```cpp
void Vehicle::_mavlinkMessageReceived(LinkInterface* link, mavlink_message_t message)
{
	...
	//此处通过 switch 函数调取相应的消息处理函数；
	//此处只对几个重要消息进行解码，并更新地面站对应的状态；与后面的解码不冲突；
    switch (message.msgid) {
    case MAVLINK_MSG_ID_HOME_POSITION:
        _handleHomePosition(message);
        break;
    case MAVLINK_MSG_ID_HEARTBEAT:
        _handleHeartbeat(message);
        break;
  ...
  ...
    case MAVLINK_MSG_ID_AUTOPILOT_VERSION:
        _handleAutopilotVersion(message);
        break;
    case MAVLINK_MSG_ID_WIND_COV:
        _handleWindCov(message);
        break;

    // Following are ArduPilot dialect messages

    case MAVLINK_MSG_ID_WIND:
        _handleWind(message);
        break;
    }

    emit mavlinkMessageReceived(message);//发送至文件管理，文件传输？？

    _uas->receiveMessage(message);//这里是解码函数；
}
```

## `Vehicle` 类的解码

```cpp
    void _handleHomePosition(mavlink_message_t& message);
    void _handleHeartbeat(mavlink_message_t& message);
    void _handleRCChannels(mavlink_message_t& message);
    void _handleRCChannelsRaw(mavlink_message_t& message);
    void _handleBatteryStatus(mavlink_message_t& message);
    void _handleSysStatus(mavlink_message_t& message);
    void _handleWindCov(mavlink_message_t& message);
    void _handleWind(mavlink_message_t& message);
    void _handleVibration(mavlink_message_t& message);
    void _handleExtendedSysState(mavlink_message_t& message);
    void _handleCommandAck(mavlink_message_t& message);
    void _handleAutopilotVersion(mavlink_message_t& message);
```

这里只对 心跳包 详细描述：

```cpp
void Vehicle::_handleHeartbeat(mavlink_message_t& message)
{
    _connectionActive();

    mavlink_heartbeat_t heartbeat;

    mavlink_msg_heartbeat_decode(&message, &heartbeat);//Mavlink 解码；

    bool newArmed = heartbeat.base_mode & MAV_MODE_FLAG_DECODE_POSITION_SAFETY;

    if (_armed != newArmed) {
        _armed = newArmed;
        emit armedChanged(_armed);

        // We are transitioning to the armed state, begin tracking trajectory points for the map
        if (_armed) {
            _mapTrajectoryStart();//解锁后，启动轨迹追踪；
        } else {
            _mapTrajectoryStop();
        }
    }

    if (heartbeat.base_mode != _base_mode || heartbeat.custom_mode != _custom_mode) {
        _base_mode = heartbeat.base_mode;
        _custom_mode = heartbeat.custom_mode;
        emit flightModeChanged(flightMode());//间接发送到 QML 用于显示；
    }
}
```


## `UAS` 类的解码

此处是地面站中完整的解码程序；
内容较为简单，不做注释；

```cpp
void UAS::receiveMessage(mavlink_message_t message)
{
	//对于冗余的传感器，
	//Prefer IMU 2 over IMU 1
	
	...
	...

        switch (message.msgid)
        {
        case MAVLINK_MSG_ID_HEARTBEAT:
        {
            if (multiComponentSourceDetected && wrongComponent)
            {
                break;
            }
            mavlink_heartbeat_t state;
            mavlink_msg_heartbeat_decode(&message, &state);

            // Send the base_mode and system_status values to the plotter. This uses the ground time
            // so the Ground Time checkbox must be ticked for these values to display
            quint64 time = getUnixTime();
            QString name = QString("M%1:HEARTBEAT.%2").arg(message.sysid);
            emit valueChanged(uasId, name.arg("base_mode"), "bits", state.base_mode, time);
            emit valueChanged(uasId, name.arg("custom_mode"), "bits", state.custom_mode, time);
            emit valueChanged(uasId, name.arg("system_status"), "-", state.system_status, time);

            if ((state.system_status != this->status) && state.system_status != MAV_STATE_UNINIT)
            {
                this->status = state.system_status;
                getStatusForCode((int)state.system_status, uasState, stateDescription);
                emit statusChanged(this, uasState, stateDescription);
                emit statusChanged(this->status);
            }

            // We got the mode
            receivedMode = true;
        }

            break;

        case MAVLINK_MSG_ID_SYS_STATUS:
        ...
        ...
        ...//此处省略约400行；
        ...
        case MAVLINK_MSG_ID_LOG_ENTRY:
        {
            mavlink_log_entry_t log;
            mavlink_msg_log_entry_decode(&message, &log);
            emit logEntry(this, log.time_utc, log.size, log.id, log.num_logs, log.last_log_num);
        }
            break;

        case MAVLINK_MSG_ID_LOG_DATA:
        {
            mavlink_log_data_t log;
            mavlink_msg_log_data_decode(&message, &log);
            emit logData(this, log.ofs, log.id, log.count, log.data);
        }
            break;

        default:
            break;
        }


}
```





[toc]