> by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

<br><br>

**参考**：https://github.com/PX4/Firmware/blob/master/src/modules/sdlog2/sdlog2_messages.h
<br><br>
PX4 log 文件中变量名称。

下表中变量按字母排序，与原顺序略有不同。


|abs.|全称|结构体变量|
|:---|:---|:---|
|AIR1|AIR SPEED SENSORS - DIFF. PRESSURE|BaroPa,BaroAlt,BaroTmp,DiffPres,DiffPresF|
|AIRS|AIRSPEED|IAS,TAS,TASraw,Temp,Confidence|
|ARSP|ATTITUDE RATE SET POINT|RollRateSP,PitchRateSP,YawRateSP|
|ATC1|ACTUATOR_0 CONTROLS|Roll,Pitch,Yaw,Thrust|
|ATSP|ATTITUDE SET POINT|RollSP,PitchSP,YawSP,ThrustSP,qw,qx,qy,qz|
|ATT|ATTITUDE |qw,qx,qy,qz,Roll,Pitch,Yaw,RollRate,PitchRate,YawRate|
|ATTC|ATTITUDE CONTROLS |Roll,Pitch,Yaw,Thrust|
|BATT|BATTERY |V,VFilt,C,CFilt,Discharged,Remaining,Scale,Warning|
|CAMT|CAMERA TRIGGER|timestamp,seq|
|CTS|CONTROL STATE|Vx_b,Vy_b,Vz_b,Vinf,P,Q,R|
|DGPS|GPS POSITION(差分)|GPSTime,Fix,EPH,EPV,Lat,Lon,Alt,VelN,VelE,VelD,Cog,nSat,SNR,N,J|
|DIST|RANGE SENSOR DISTANCE|Id,Type,Orientation,Distance,Covariance|
|DPRS|DIFFERENTIAL PRESSURE|errors,DPRESraw,DPRES,DPRESmax,Temp|
|ENCD|ENCODER DATA|cnt0,vel0,cnt1,vel1|
|ESC|ESC STATE|count,nESC,Conn,N,Ver,Adr,Volt,Amp,RPM,Temp,SetP,SetPRAW|
|EST0|ESTIMATOR STATUS|s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,nStat,fNaN,fFault,fTOut|
|EST1|ESTIMATOR STATUS|s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27|
|EST2|ESTIMATOR STATUS|P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,GCHK,CTRL,fHealth,IC|
|EST3|ESTIMATOR STATUS|P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27|
|EST4|ESTIMATOR INNOVATIONS|VxI,VyI,VzI,PxI,PyI,PzI,VxIV,VyIV,VzIV,PxIV,PyIV,PzIV,e1,e2,e3|
|EST5|ESTIMATOR INNOVATIONS|MaxI,MayI,MazI,MaxIV,MayIV,MazIV,HeI,HeIV,AiI,AiIV,BeI,BeIV|
|EST6|ESTIMATOR INNOVATIONS|FxI,FyI,FxIV,FyIV,HAGLI,HAGLIV|
|FLOW|OPTICAL FLOW|ID,RawX,RawY,RX,RY,RZ,Dist,TSpan,DtSonar,FrmCnt,GT,Qlty|
|GPOS|GLOBAL POSITION ESTIMATE|Lat,Lon,Alt,VelN,VelE,VelD,EPH,EPV,TALT|
|GPS|GPS POSITION|GPSTime,Fix,EPH,EPV,Lat,Lon,Alt,VelN,VelE,VelD,Cog,nSat,SNR,N,J|
|GPSP|GLOBAL POSITION SETPOINT|NavState,Lat,Lon,Alt,Yaw,Type,LoitR,LoitDir,PitMin|
|GS0A|GPS SNR #0, SAT GROUP A|s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15|
|GS0B|GPS SNR #0, SAT GROUP B|s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15|
|GS1A||s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15|
|GS1B||s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15|
|GVSP|GLOBAL VELOCITY SETPOINT|VX,VY,VZ|
|IMU|IMU SENSORS|AccX,AccY,AccZ,GyroX,GyroY,GyroZ,MagX,MagY,MagZ,tA,tG,tM|
|IMU1| |AccX,AccY,AccZ,GyroX,GyroY,GyroZ,MagX,MagY,MagZ,tA,tG,tM|
|IMU2| |AccX,AccY,AccZ,GyroX,GyroY,GyroZ,MagX,MagY,MagZ,tA,tG,tM|
|LAND|LAND DETECTOR|Landed|
|LOAD|SYSTEM LOAD|CPU|
|LPOS|LOCAL POSITION|X,Y,Z,Dist,DistR,VX,VY,VZ,RLat,RLon,RAlt,PFlg,GFlg,EPH,EPV|
|LPSP|LOCAL POSITION SETPOINT|X,Y,Z,Yaw,VX,VY,VZ,AX,AY,AZ|
|MACS|MULTIROTOR ATTITUDE CONTROLLER STATUS|RRint,PRint,YRint|
|MOCP|MOCAP ATTITUDE AND POSITION|QuatW,QuatX,QuatY,QuatZ,X,Y,Z|
|OUT0|ACTUATOR OUTPUT|Out0,Out1,Out2,Out3,Out4,Out5,Out6,Out7|
|OUT1||Out0,Out1,Out2,Out3,Out4,Out5,Out6,Out7|
|PARM|PARAMETER|Name,Value|
|PWR|ONBOARD POWER SYSTEM|Periph5V,Servo5V,RSSI,UsbOk,BrickOk,ServoOk,PeriphOC,HipwrOC|
|RC|RC INPUT CHANNELS|C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,RSSI,CNT,Lost,Drop|
|RPL1|EKF2 REPLAY Part 1|t,gIdt,aIdt,Tm,Tb,gx,gy,gz,ax,ay,az,magX,magY,magZ,b_alt|
|RPL2|EKF2 REPLAY Part 2|Tpos,Tvel,lat,lon,alt,fix,nsats,eph,epv,sacc,v,vN,vE,vD,v_val|
|RPL3|EKF2 REPLAY Part 3|Tflow,fx,fy,gx,gy,delT,qual|
|RPL4|EKF2 REPLAY Part 4|Trng,rng|
|RPL5|EKF2 REPLAY Part 5|Tev,x,y,z,q0,q1,q2,q3,posErr,angErr|
|RPL6|EKF2 REPLAY Part 6|Tasp,inAsp,trAsp|
|SENS|OTHER SENSORS|BaroPres,BaroAlt,BaroTemp|
|STAT|VEHICLE STATE|MainState,NavState,ArmS,Failsafe,IsRotWing|
|STCK|LOW STACK|Task,Free|
|TECS|TECS STATUS|ASP,AF,FSP,F,AsSP,AsF,AsDSP,AsD,EE,ERE,EDE,EDRE,PtchI,ThrI,M|
|TEL0|TELEMETRY STATUS|RSSI,RemRSSI,Noise,RemNoise,RXErr,Fixed,TXBuf,HbTime|
|TEL1|TELEMETRY STATUS|RSSI,RemRSSI,Noise,RemNoise,RXErr,Fixed,TXBuf,HbTime|
|TEL2|TELEMETRY STATUS|RSSI,RemRSSI,Noise,RemNoise,RXErr,Fixed,TXBuf,HbTime|
|TEL3|TELEMETRY STATUS|RSSI,RemRSSI,Noise,RemNoise,RXErr,Fixed,TXBuf,HbTime|
|TIME|TIME STAMP|StartTime|
|TSYN|TIME SYNCHRONISATION OFFSET|TimeOffset|
|VER|VERSION|Arch,FwGit|
|VISN|VISION POSITION|X,Y,Z,VX,VY,VZ,QuatW,QuatX,QuatY,QuatZ|
|VTOL|VTOL VEHICLE STATUS|Arsp,RwMode,TransMode,Failsafe|
|WIND|WIND ESTIMATE|X,Y,CovX,CovY|

