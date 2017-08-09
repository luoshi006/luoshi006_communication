原文：https://dev.px4.io/en/tutorials/tuning_the_ecl_ekf.html

## What is the ecl EKF

EKF 对于各个传感器的延时，采用 `fusion time horizon`处理， 各传感器数据缓存于 FIFO ，在 EKF 需要时取出。传感器的延时补偿有参数 `EKF2_*_DELAY` 控制。

使用互补滤波处理 `fusion time horizon`到当前时刻的 IMU 数据更新状态。滤波器的时间常数：`EKF2_TAU_VEL` `EKF2_TAU_POS`。

IMU的安装位置与 body frame 之间的位置会对位置和速度状态产生影响，需要预先设定：`EKF2_IMU_POS_X,Y,Z`。

EKF 仅使用 IMU 数据进行状态预测，而不是更新时的观测量。协方差预测、状态更新、协方差更新的数学表达式通过 Matlab符号运算工具箱得到。


## What sensor measurements does it use?

EKF 可以有很多种不同的传感器组合方式。在启动时，滤波器检测传感器最小系统，初始化姿态角和高度，在该模式下，会输出旋转，垂直方向位置速度，IMU 角度和速度零偏。
该模式需要 IMU 数据、航向数据源、高度数据源。 这个传感器最小系统在 EKF 的所有模式中，都是必须的。

### IMU

body系输出角速度和加速度，大于 100Hz。**EKF 在使用 IMU 数据之前需要进行圆锥补偿 **

### Magnetometer

body系磁力计输出（或其他），大于 5Hz。磁场数据用法分两种：

- 通过 倾斜（tilt）补偿和磁偏角补偿，得到航向角。作为 EKF 的观测量。该方法精度较低且无法感知机身本身的磁偏，但是，对陀螺零偏和磁异常鲁棒。所以，是启动和地面时的默认方法；
- 磁力计 XYZ 作为独立观测。该方法精度较高，且能够感知机身磁场零偏，但是，该方法假设地磁场仅缓慢变化，在强磁干扰下性能受限。是在空中且爬升超过 1.5m 时的默认模式。

模式选择由 `EKF2_MAG_TYPE` 控制；

### Height

数据源包括：GPS、气压计、红外、外部视觉，大于 5Hz。
主数据源由 `EKF2_HGT_MODE` 确定。

如果高度量测异常，EKF 无法启动。当检测到高度量测时，EKF 会初始化状态，并对准姿态。姿态对准完成后，EKF 会切换到其他模式加载其他传感器数据。

### GPS

满足以下条件，GPS 将用于位置和速度估计：
1. GPS 在 `EKF2_AID_MASK` 中启用；
2. GPS 质量检测通过，相关参数：`EKF2_GPS_CHECK` `EKF2_REQ_*`；
3. GPS 高度可已在 EKF 中直接使用，相关参数：`EKF2_HGT_MODE`；

### Range Finder

Range Finder 测量对地高度，使用单状态滤波器估计地形高度；

在平整表面飞行时，可直接用于 EKF 估计，相关参数：`EKF2_HGT_MODE = 2`；

### Airspeed

`EKF2_ARSP_THR` 为正时，等效空速（EAS）可以用于估计风速，在 GPS 丢失的情况下抑制飘逸。当风速超过阈值 `EKF2_ARSP_THR` 且不是旋翼机，则使用空速数据。

### Synthetic Sideslip

固定翼平台可以通过零侧滑的观测来修正风速估计，在没有空速管的情况下进行风速估计。相关参数：`EKF2_FUSE_BETA = 1`.

### Drag Specific Forces

多旋翼平台能够通过风速和xy轴拉力的关系，估计北/东向的风速。相关参数：`EKF2_AID_MASK`
风速和受力（acc）关系的相关参数：`EKF2_BCOEF_X` and `EKF2_BCOEF_Y` 

### Optical Flow

光流使用条件：
1. 对地距离有效；
2. `EKF2_AID_MASK` 第1bit置true；
3. 光流数据质量高于阈值：`EKF2_OF_QMIN`

### External Vision System

外部视觉系统的位姿测量：

1. `EKF2_AID_MASK` 第3 bit置true，则用于水平位置估计；
2. `EKF2_HGT_MODE` 置 3，则用于垂直位置估计；
3. `EKF2_AID_MASK` 第4 bit置true，则用于偏航角估计；



















