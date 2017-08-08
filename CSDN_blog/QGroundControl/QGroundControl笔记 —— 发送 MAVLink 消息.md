>`by luoshi006`
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

#消息发送函数

QGroundControl 中发送 MAVLink 的命令主要被封装在 `Vehicle` 类中。

```cpp
    /// Sends a message to the specified link
    /// @return true: message sent, false: Link no longer connected
    bool sendMessageOnLink(LinkInterface* link, mavlink_message_t message);

    /// Sends a message to the priority link
    /// @return true: message sent, false: Link no longer connected
    bool sendMessageOnPriorityLink(mavlink_message_t message) { return sendMessageOnLink(priorityLink(), message); }

    /// Sends the specified messages multiple times to the vehicle in order to attempt to
    /// guarantee that it makes it to the vehicle.
    void sendMessageMultiple(mavlink_message_t message);
```

在 MAVLinkProtocol 中封装的发送消息函数：
```cpp
    void _sendMessage(mavlink_message_t message);
    void _sendMessage(LinkInterface* link, mavlink_message_t message);
    void _sendMessage(LinkInterface* link, mavlink_message_t message, quint8 systemid, quint8 componentid);
```

#消息函数使用范围

 `Vehicle` 类中：
 
 `sendMessageOnLink`，主要用于大量数据发送，包括：航点、参数、日志消息。
 
 `sendMessageOnPriorityLink`，主要用于短消息传输，包括：应答、参数设置、飞行控制、飞控设置、校准等。
 
 `sendMessageMultiple`，主要用于请求飞控版本号、发送数据请求等重要信息。

`MAVLinkProtocol` 类中的消息发送函数为私有方法，其调用主要功能是在 `receiveBytes()` 中，对需要反馈的消息进行回应。


# 示例

## sendMessageOnLink

刷新所有参数：
```cpp
void ParameterLoader::refreshAllParameters(uint8_t componentID)
{
....
    mavlink_message_t msg;
    mavlink_msg_param_request_list_pack(mavlink->getSystemId(), mavlink->getComponentId(), &msg, _vehicle->id(), componentID);
    _vehicle->sendMessageOnLink(_vehicle->priorityLink(), msg);
```

读取参数：
```cpp
void ParameterLoader::_readParameterRaw(int componentId, const QString& paramName, int paramIndex)
{
    mavlink_message_t msg;
    char fixedParamName[MAVLINK_MSG_PARAM_REQUEST_READ_FIELD_PARAM_ID_LEN];

    strncpy(fixedParamName, paramName.toStdString().c_str(), sizeof(fixedParamName));
    mavlink_msg_param_request_read_pack(_mavlink->getSystemId(),    // Our system id
                                        _mavlink->getComponentId(), // Our component id
                                        &msg,                       // Pack into this mavlink_message_t
                                        _vehicle->id(),             // Target system id
                                        componentId,                // Target component id
                                        fixedParamName,             // Named parameter being requested
                                        paramIndex);                // Parameter index being requested, -1 for named
    _vehicle->sendMessageOnLink(_vehicle->priorityLink(), msg);
}
```

写入参数：
```cpp
void ParameterLoader::_writeParameterRaw(int componentId, const QString& paramName, const QVariant& value)
{
...
    mavlink_message_t msg;
    mavlink_msg_param_set_encode(_mavlink->getSystemId(), _mavlink->getComponentId(), &msg, &p);
    _vehicle->sendMessageOnLink(_vehicle->priorityLink(), msg);
}
```

保存到静态存储：
```cpp
void ParameterLoader::_saveToEEPROM(void)
{
    if (_saveRequired) {
        _saveRequired = false;
        if (_vehicle->firmwarePlugin()->isCapable(FirmwarePlugin::MavCmdPreflightStorageCapability)) {
            mavlink_message_t msg;
            mavlink_msg_command_long_pack(_mavlink->getSystemId(), _mavlink->getComponentId(), &msg, _vehicle->id(), 0, MAV_CMD_PREFLIGHT_STORAGE, 1, 1, -1, -1, -1, 0, 0, 0);
            _vehicle->sendMessageOnLink(_vehicle->priorityLink(), msg);
            qCDebug(ParameterLoaderLog) << "_saveToEEPROM";
        } else {
            qCDebug(ParameterLoaderLog) << "_saveToEEPROM skipped due to FirmwarePlugin::isCapable";
        }
    }
}
```

##sendMessageOnPriorityLink

 `sendMessageOnPriorityLink` 的用例代码较多，以校准传感器消息为例讲解：

```cpp
void UAS::startCalibration(UASInterface::StartCalibrationType calType)
{
    if (!_vehicle) {
        return;
    }

    int gyroCal = 0;
    int magCal = 0;
    int airspeedCal = 0;
    int radioCal = 0;
    int accelCal = 0;
    int escCal = 0;

    switch (calType) {
    case StartCalibrationGyro:
        gyroCal = 1;
        break;
    case StartCalibrationMag:
        magCal = 1;
        break;
    case StartCalibrationAirspeed:
        airspeedCal = 1;
        break;
    case StartCalibrationRadio:
        radioCal = 1;
        break;
    case StartCalibrationCopyTrims:
        radioCal = 2;
        break;
    case StartCalibrationAccel:
        accelCal = 1;
        break;
    case StartCalibrationLevel:
        accelCal = 2;
        break;
    case StartCalibrationEsc:
        escCal = 1;
        break;
    case StartCalibrationUavcanEsc:
        escCal = 2;
        break;
    case StartCalibrationCompassMot:
        airspeedCal = 1; // ArduPilot, bit of a hack
        break;
    }

    mavlink_message_t msg;
    mavlink_msg_command_long_pack(mavlink->getSystemId(),
                                  mavlink->getComponentId(),
                                  &msg,
                                  uasId,
                                  _vehicle->defaultComponentId(),   // target component
                                  MAV_CMD_PREFLIGHT_CALIBRATION,    // command id
                                  0,                                // 0=first transmission of command
                                  gyroCal,                          // gyro cal
                                  magCal,                           // mag cal
                                  0,                                // ground pressure
                                  radioCal,                         // radio cal
                                  accelCal,                         // accel cal
                                  airspeedCal,                      // PX4: airspeed cal, ArduPilot: compass mot
                                  escCal);                          // esc cal
    _vehicle->sendMessageOnPriorityLink(msg);
}
```

以校准水平为例，开始校准以后，通过关联信号槽，截取飞行器发送的状态消息。
```cpp
    connect(_uas, &UASInterface::textMessageReceived, this, &SensorsComponentController::_handleUASTextMessage);
```

截取状态信息并更新状态显示。
```cpp
void SensorsComponentController::_handleUASTextMessage(int uasId, int compId, int severity, QString text)
{
    Q_UNUSED(compId);
    Q_UNUSED(severity);
    
    UASInterface* uas = _autopilot->vehicle()->uas();
    Q_ASSERT(uas);
    if (uasId != uas->getUASID()) {
        return;
    }
    
    if (text.contains("progress <")) {
        QString percent = text.split("<").last().split(">").first();
        bool ok;
        int p = percent.toInt(&ok);
        if (ok) {
            Q_ASSERT(_progressBar);
            _progressBar->setProperty("value", (float)(p / 100.0));
        }
        return;
    }

    _appendStatusLog(text);
    qCDebug(SensorsComponentControllerLog) << text;
    
    if (_unknownFirmwareVersion) {
        // We don't know how to do visual cal with the version of firwmare
        return;
    }
    
    // All calibration messages start with [cal]
    QString calPrefix("[cal] ");
    if (!text.startsWith(calPrefix)) {
        return;
    }
    text = text.right(text.length() - calPrefix.length());

    QString calStartPrefix("calibration started: ");
    if (text.startsWith(calStartPrefix)) {
        text = text.right(text.length() - calStartPrefix.length());
        
        // Split version number and cal type
        QStringList parts = text.split(" ");
        if (parts.count() != 2 && parts[0].toInt() != _supportedFirmwareCalVersion) {
            _unknownFirmwareVersion = true;
            QString msg = "Unsupported calibration firmware version, using log";
            _appendStatusLog(msg);
            qDebug() << msg;
            return;
        }
        
        //开始校准准备，并将进度条置零；
        _startVisualCalibration();
        
        text = parts[1];
        if (text == "accel" || text == "mag" || text == "gyro") {
            // Reset all progress indication
            _orientationCalDownSideDone = false;
            _orientationCalUpsideDownSideDone = false;
            _orientationCalLeftSideDone = false;
            _orientationCalRightSideDone = false;
            _orientationCalTailDownSideDone = false;
            _orientationCalNoseDownSideDone = false;
            _orientationCalDownSideInProgress = false;
            _orientationCalUpsideDownSideInProgress = false;
            _orientationCalLeftSideInProgress = false;
            _orientationCalRightSideInProgress = false;
            _orientationCalNoseDownSideInProgress = false;
            _orientationCalTailDownSideInProgress = false;
            
            // Reset all visibility
            _orientationCalDownSideVisible = false;
            _orientationCalUpsideDownSideVisible = false;
            _orientationCalLeftSideVisible = false;
            _orientationCalRightSideVisible = false;
            _orientationCalTailDownSideVisible = false;
            _orientationCalNoseDownSideVisible = false;
            
            _orientationCalAreaHelpText->setProperty("text", "Place your vehicle into one of the Incomplete orientations shown below and hold it still");
            
            if (text == "accel") {
                _accelCalInProgress = true;
                _orientationCalDownSideVisible = true;
                _orientationCalUpsideDownSideVisible = true;
                _orientationCalLeftSideVisible = true;
                _orientationCalRightSideVisible = true;
                _orientationCalTailDownSideVisible = true;
                _orientationCalNoseDownSideVisible = true;
            } else if (text == "mag") {

                // Work out what the autopilot is configured to
                int sides = 0;

                if (_autopilot->parameterExists(FactSystem::defaultComponentId, "CAL_MAG_SIDES")) {
                    // Read the requested calibration directions off the system
                    sides = _autopilot->getParameterFact(FactSystem::defaultComponentId, "CAL_MAG_SIDES")->rawValue().toFloat();
                } else {
                    // There is no valid setting, default to all six sides
                    sides = (1 << 5) | (1 << 4) | (1 << 3) | (1 << 2) | (1 << 1) | (1 << 0);
                }

                _magCalInProgress = true;
                _orientationCalTailDownSideVisible =   ((sides & (1 << 0)) > 0);
                _orientationCalNoseDownSideVisible =   ((sides & (1 << 1)) > 0);
                _orientationCalLeftSideVisible =       ((sides & (1 << 2)) > 0);
                _orientationCalRightSideVisible =      ((sides & (1 << 3)) > 0);
                _orientationCalUpsideDownSideVisible = ((sides & (1 << 4)) > 0);
                _orientationCalDownSideVisible =       ((sides & (1 << 5)) > 0);
            } else if (text == "gyro") {
                _gyroCalInProgress = true;
                _orientationCalDownSideVisible = true;
            } else {
                Q_ASSERT(false);
            }
            //在 QML 界面显示单侧完成信息；
            emit orientationCalSidesDoneChanged();
            //在 QML 界面显示状态变换；
            emit orientationCalSidesVisibleChanged();
            //在 QML 界面显示进度信息；
            emit orientationCalSidesInProgressChanged();
            
            _updateAndEmitShowOrientationCalArea(true);
        }
        return;
    }
    
    if (text.endsWith("orientation detected")) {
        QString side = text.section(" ", 0, 0);
        qDebug() << "Side started" << side;
        
        if (side == "down") {
            _orientationCalDownSideInProgress = true;
            if (_magCalInProgress) {
                _orientationCalDownSideRotate = true;
            }
        } else if (side == "up") {
            _orientationCalUpsideDownSideInProgress = true;
            if (_magCalInProgress) {
                _orientationCalUpsideDownSideRotate = true;
            }
        } else if (side == "left") {
            _orientationCalLeftSideInProgress = true;
            if (_magCalInProgress) {
                _orientationCalLeftSideRotate = true;
            }
        } else if (side == "right") {
            _orientationCalRightSideInProgress = true;
            if (_magCalInProgress) {
                _orientationCalRightSideRotate = true;
            }
        } else if (side == "front") {
            _orientationCalNoseDownSideInProgress = true;
            if (_magCalInProgress) {
                _orientationCalNoseDownSideRotate = true;
            }
        } else if (side == "back") {
            _orientationCalTailDownSideInProgress = true;
            if (_magCalInProgress) {
                _orientationCalTailDownSideRotate = true;
            }
        }
        
        if (_magCalInProgress) {
            _orientationCalAreaHelpText->setProperty("text", "Rotate the vehicle continuously as shown in the diagram until marked as Completed");
        } else {
            _orientationCalAreaHelpText->setProperty("text", "Hold still in the current orientation");
        }
        
        emit orientationCalSidesInProgressChanged();
        emit orientationCalSidesRotateChanged();
        return;
    }
    
    if (text.endsWith("side done, rotate to a different side")) {
        QString side = text.section(" ", 0, 0);
        qDebug() << "Side finished" << side;
        
        if (side == "down") {
            _orientationCalDownSideInProgress = false;
            _orientationCalDownSideDone = true;
            _orientationCalDownSideRotate = false;
        } else if (side == "up") {
            _orientationCalUpsideDownSideInProgress = false;
            _orientationCalUpsideDownSideDone = true;
            _orientationCalUpsideDownSideRotate = false;
        } else if (side == "left") {
            _orientationCalLeftSideInProgress = false;
            _orientationCalLeftSideDone = true;
            _orientationCalLeftSideRotate = false;
        } else if (side == "right") {
            _orientationCalRightSideInProgress = false;
            _orientationCalRightSideDone = true;
            _orientationCalRightSideRotate = false;
        } else if (side == "front") {
            _orientationCalNoseDownSideInProgress = false;
            _orientationCalNoseDownSideDone = true;
            _orientationCalNoseDownSideRotate = false;
        } else if (side == "back") {
            _orientationCalTailDownSideInProgress = false;
            _orientationCalTailDownSideDone = true;
            _orientationCalTailDownSideRotate = false;
        }
        
        _orientationCalAreaHelpText->setProperty("text", "Place you vehicle into one of the orientations shown below and hold it still");

        emit orientationCalSidesInProgressChanged();
        emit orientationCalSidesDoneChanged();
        emit orientationCalSidesRotateChanged();
        return;
    }

    if (text.endsWith("side already completed")) {
        _orientationCalAreaHelpText->setProperty("text", "Orientation already completed, place you vehicle into one of the incomplete orientations shown below and hold it still");
        return;
    }
    
    QString calCompletePrefix("calibration done:");
    if (text.startsWith(calCompletePrefix)) {
	    //校准完成，解除飞行器状态消息截取；设置进度条状态，并完成；
        _stopCalibration(StopCalibrationSuccess);
        return;
    }
    
    if (text.startsWith("calibration cancelled")) {
        _stopCalibration(_waitingForCancel ? StopCalibrationCancelled : StopCalibrationFailed);
        return;
    }
    
    if (text.startsWith("calibration failed")) {
        _stopCalibration(StopCalibrationFailed);
        return;
    }
}

```

```cpp
void SensorsComponentController::_stopCalibration(SensorsComponentController::StopCalibrationCode code)
{
    //解除消息截取；
    disconnect(_uas, &UASInterface::textMessageReceived, this, &SensorsComponentController::_handleUASTextMessage);
    
    //恢复按钮状态；
    _compassButton->setEnabled(true);
    _gyroButton->setEnabled(true);
    _accelButton->setEnabled(true);
    _airspeedButton->setEnabled(true);
    _levelButton->setEnabled(true);
    _setOrientationsButton->setEnabled(true);
    _cancelButton->setEnabled(false);
    
    if (code == StopCalibrationSuccess) {
        _resetInternalState();
        
        _progressBar->setProperty("value", 1);
    } else {
        _progressBar->setProperty("value", 0);
    }
    
    _waitingForCancel = false;
    emit waitingForCancelChanged();

    _refreshParams();
    
    //根据返回的信息状态，更新屏幕显示；
    switch (code) {
        case StopCalibrationSuccess:
            _orientationCalAreaHelpText->setProperty("text", "Calibration complete");
            emit resetStatusTextArea();
            if (_magCalInProgress) {
                emit setCompassRotations();
            }
            break;
            
        case StopCalibrationCancelled:
            emit resetStatusTextArea();
            _hideAllCalAreas();
            break;
            
        default:
            // Assume failed
            _hideAllCalAreas();
            qgcApp()->showMessage("Calibration failed. Calibration log will be displayed.");
            break;
    }
    
    _magCalInProgress = false;
    _accelCalInProgress = false;
    _gyroCalInProgress = false;
}
```






