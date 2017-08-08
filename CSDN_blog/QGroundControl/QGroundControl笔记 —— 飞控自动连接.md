> by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


在 PX4 中可以在软件设置中设置是否启用**自动连接**：

<center>![这里写图片描述](http://img.blog.csdn.net/20161102155502276)</center>

QML 通过 `Q_PROPERTY` 宏，将属性注册到元对象系统中，实现与C++的交互【详见：http://blog.csdn.net/luoshi006/article/details/52353821】

``` 
    Q_PROPERTY(bool     usbDirect       READ usbDirect          WRITE setUsbDirect          NOTIFY usbDirectChanged)        ///< true: direct usb connection to board
```

此处实现复选框与属性 `usbDirect` 的交互。

在系统初始化【QGCToolbox】时，`LinkManager` 设置**定时器**，定时检测自动连接：


```cpp
void LinkManager::setToolbox(QGCToolbox *toolbox)
{
......
     connect(&_portListTimer, &QTimer::timeout, this, &LinkManager::_updateAutoConnectLinks);
    _portListTimer.start(_autoconnectUpdateTimerMSecs); // timeout must be long enough to get past bootloader on second pass
}
```

默认1000毫秒检测执行一次，

```cpp
void LinkManager::_updateAutoConnectLinks(void)
{
.....
                case QGCSerialPortInfo::BoardTypePX4FMUV4:
                    if (_autoconnectPixhawk) {
                        pSerialConfig = new SerialConfiguration(QString("Pixhawk on %1").arg(portInfo.portName().trimmed()));
                        pSerialConfig->setUsbDirect(true);
                    }
                    break;

....
....
                if (pSerialConfig) {
                    pSerialConfig->setBaud(boardType == QGCSerialPortInfo::BoardTypeSikRadio ? 57600 : 115200);
....                    _autoconnectConfigurations.append(pSerialConfig);
                    createConnectedLink(pSerialConfig);
                }
....
}
```

两次跳转，调用 `createConnectedLink()` ：

```cpp
LinkInterface* LinkManager::createConnectedLink(LinkConfiguration* config)
{
....
                if (serialConfig->usbDirect()) {
                    _activeLinkCheckList.append((SerialLink*)pLink);
                    if (!_activeLinkCheckTimer.isActive()) {
                        _activeLinkCheckTimer.start();
                    }
....
}
```

至此，完成启动过程。

