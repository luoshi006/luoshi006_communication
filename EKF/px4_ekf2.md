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


## How do I use the 'ecl' library EKF?

参数 'SYS_MC_EST_GROUP' 置 2，启用 ecl EKF。

## What are the advantages and disadvantages of the ecl EKF over other estimators?

正如其他滤波器一样，其性能需要通过匹配传感器特性的参数来提升。调参是在精度和鲁棒性之间做权衡，尽管我们想要提供满足大部分用户的参数，但仍然有需要调参的地方。
所以，在精度上无法保证由于之前的 `attitude_estimator_q` + `local_position_estimator`，这完全取决于参数的整定。

### Disadvantages

- ecl EKF 是复杂的算法，需要理解 EKF 及其在导航方面的应用，所以较难定位与问题相关的参数；
- ecl EKF 占用更多的 RAM FLASH 空间；
- ecl EKF 占用更多的 logging 空间；
- ecl EKF 航时较少；

### Advantages

- ecl EKF 能够以数学一致的方式融合不同延时和传输速率的传感器数据，当延时参数准确时，能够提供更精确的动态精度。
- ecl EKF 能够融合大量不同类型的传感器；
- ecl EKF 能够检测传感器在统计上的显著不一致问题，用于传感器故障检测；
- 对于固定翼，不论是否使用空速传感器，ecl EKF 都会估计风速。考虑空速与侧滑假设，在GPS丢失时，提供航位更新；
- ecl EKF 估计三轴加计零偏，能够为垂尾或其他变体无人机在不同飞行阶段提供较高精度估计；
- 联合架构（姿态、速度、位置联合估计）意味着姿态估计可以由所有传感器修正。有较大的调参潜在价值；


## How do I check the EKF performance?

在飞行过程中，EKF 会发布大量 uORB topic，并写入 SD 卡。以下步骤假设这些数据已经以 .ulog 格式记录。

EKF 相关的数据记录在  `ekf2_innovations` 和 `estimator_status` 消息中。

官方在 `Tools/ecl_ekf` 提供了分析数据的脚本。

### output Data

- 姿态 [vehicle_attitude]
- Local position [vehicle_local_position]
- 控制反馈回路数据 [control_state]
- Global(WGS-84) [vehicle_global_position]
- 风速 [wind_estimate]

### States

24个估计状态 [estimator_status]

- [0 ... 3] Quaternions
- [4 ... 6] Velocity NED (m/s)
- [7 ... 9] Position NED (m)
- [10 ... 12] IMU delta angle bias XYZ (rad)
- [13 ... 15] IMU delta velocity bias XYZ (m/s)
- [16 ... 18] Earth magnetic field NED (gauss)
- [19 ... 21] Body magnetic field XYZ (gauss)
- [22 ... 23] Wind velocity NE (m/s)
- [24 ... 32] Not Used

### State Variances

24维方差阵 [estimator_status]

- [0 ... 3] Quaternions
- [4 ... 6] Velocity NED (m/s)^2
- [7 ... 9] Position NED (m^2)
- [10 ... 12] IMU delta angle bias XYZ (rad^2)
- [13 ... 15] IMU delta velocity bias XYZ (m/s)^2
- [16 ... 18] Earth magnetic field NED (gauss^2)
- [19 ... 21] Body magnetic field XYZ (gauss^2)
- [22 ... 23] Wind velocity NE (m/s)^2
- [24 ... 28] Not Used

### Observation Innovations

- Magnetometer XYZ (gauss) :            mag_innov[3]      in ekf2_innovations.
- Yaw angle (rad) :                     heading_innov     in ekf2_innovations.
- Velocity and position innovations :   vel_pos_innov[6]  in ekf2_innovations. 
    - [0 ... 2] Velocity NED (m/s)
    - [3 ... 5] Position NED (m)
- True Airspeed (m/s) :                 airspeed_innov    in ekf2_innovations.
- Synthetic sideslip (rad) :            beta_innov        in ekf2_innovations.
- Optical flow XY (rad/sec) :           flow_innov        in ekf2_innovations.
- Height above ground (m) :             hagl_innov        in ekf2_innovations.

### Observation Innovation Variances

变量同上，一一对应，单位平方。

### Output Complementary Filter

用于更新 fusion time horizon 到当前时刻的状态。计算 fusion time horizon 时刻的姿态、速度、位置的误差，output_tracking_error[3] in ekf2_innovations.

- [0] 姿态误差大小(rad)
- [1] 速度误差大小(m/s)
- [2] 位置误差大小(m)

相关参数： EKF2_TAU_VEL / EKF2_TAU_POS；
减小参数会降低稳态误差，同时增加观测噪声。

### EKF Errors

在恶劣条件下的状态和协方差更新中，EKF 包含错误检测，filter_fault_flags  in estimator_status.

### Observation Errors

有两种观测错误：
- 数据丢失。
- 状态预测和传感器量测的新息过大。

这两种错误都会引起拒绝观测数据，在一定时间之后，EKF 将使用传感器观测重置状态量。所有的观测新息都会计算统计置信度。相关参数：`EKF2_*_GATE`。

- mag_test_ratio :  magnetometer innovation 
- vel_test_ratio :  largest velocity innovation
- pos_test_ratio :  largest horizontal position innovation 
- hgt_test_ratio :  the vertical position
- tas_test_ratio :  true airspeed 
- hagl_test_ratio : height above ground innovation 

msg: estimator_status -> innovation_check_flags。

### GPS Quality Checks

在使用 GPS 之前，EKF 对 GPS 的数据质量做了大量检测。相关参数： `EKF2_GPS_CHECK` `EKF2_REQ_*`。数据有效标志位将记录于 'estimator_status.gps_check_fail_flags'。所有检测通过时，该标志位为 0 。

### EKF Numerical Errors

为了减少计算负荷，EKF中所有计算量都采用 float ，且求导采用一阶近似，所以，在重新整定参数时，协方差矩阵有可能会变差，导致状态估计值奇异或发散。

为防止这种情况，每一步协方差矩阵和状体更新都包含误差检测校正：
- 如果新息方差小于观测方差（方差负定），或协方差矩阵更新时出现负值：
  - 跳过状态与协方差矩阵更新；
  - 协方差矩阵中对应值重置；
  - 错误信息记录在 estimator_status -->> filter_fault_flags；
- 状态方差（主对角线元素）强制非负；
- 状态方差设置上限；
- 强制协方差矩阵对称性；

重新整定滤波器参数，尤其是降低噪声时，需要检查 estimator_status -->> filter_fault_flags ，确保其一直为零。


## What should I do if the height estimate is diverging?

通常，引起 EKF 高度偏差的原因是 IMU 量测受震动影响后的滤波和混叠。以下变量对偏差体现较为明显：

- `ekf2_innovations.vel_pos_innov[3]` 和 `ekf2_innovations.vel_pos_innov[5]` 都有相同的符号；
- `estimator_status.hgt_test_ratio` 大于 1.0；

首先，推荐为自驾仪设计减振系统，减振系统通常有6个自由度，对应6个谐振频率。通常要求这6个减振频率高于 25 Hz，小于电机转动频率。

然后，通过以下参数，可以有效的抵消振动引起的偏差：
- 对主高度传感器的新息阈值翻倍。气压计：EK2_EKF2_BARO_GATE；
- 初始化 EKF2_ACC_NOISE 为 0.5。如果仍然有偏差，以0.1为步长继续增加，不要超过 1.0；

这些调整会使 EKF 对 GPS 垂直速度和气压高度的噪声更敏感；


## What should I do if the position estimate is diverging?

位置估计的偏差通常有以下原因：

- 大振动
  - 减振系统；
  - 适当增加 EKF2_ACC_NOISE  EKF2_GYR_NOISE 
- 陀螺仪零偏
  - 重新校准陀螺。检查陀螺温漂；
- 航向对齐误差
  - 磁力计校准；
  - 在 QGC 中查看，航向真实偏差在 15 deg 以内；
- GPS 精度较低
  - 检查接口；
  - 改善遮挡和屏蔽；
  - 查看飞行位置的遮挡和反射（高楼）；
- GPS 丢失

定位故障原因就需要分析 EKF log 数据：

- plot( estimator_status.vel_test_ratio ) 速度新息；
- plot( estimator_status.pos_test_ratio ) 水平位置新息；
- plot( estimator_status.hgt_test_ratio ) 高度新息；
- plot( estimator_status.mag_test_ratio ) 磁新息；
- plot( vehicle_gps_position.s_variance_m_s ) GPS 速度精度；
- plot( estimator_status.states[10],[11],[12] )  IMU 姿态估计；
- EKF 计算的高频振动：
  - plot( estimator_status.vibe[0] ) 圆锥振动；
  - plot( estimator_status.vibe[1] ) 高频角度振动；
  - plot( estimator_status.vibe[2] ) 高频速度振动；
  
  以上 ratio 参数都应该在 0.5 以下，偶尔超出。

  振动测量因与 IMU 采样频率接近，所以能反映的信息有限。只能通过惯导精度和新息来反映振动。

### Determination of Excessive Vibration

强振动通常会影响水平竖直方向的高度和速度新息。对磁力计影响不大。

### Determination of Excessive Gyro Bias

大陀螺零偏通常会超过 5E-4 (~3 deg/s) 。如果是yaw轴，还会导致 mag 检测值偏大。高度方向通常不会受影响。如果飞行器在起飞之前有时间收敛，则可以放宽到 5 deg/s.  commander -> pre-flight 防止在位置有偏差时解锁。

### Determination of Poor Yaw Accuracy

yaw 轴对齐误差会在开始移动时，因 GPS 和 INAV 计算的速度方向不一致，导致 速度检测值异常增大。磁力计新息影响不大，高度方向不受影响。

### Determination of Poor GPS Accuracy

GPS 精度差通常伴随着接收机的速度报错，新息增加。由多路径、遮挡、干扰等引起的短时错误。

### Determination of GPS Data Loss

GPS 信号丢失，速度和位置新息测试值将会变平 “flat-lining”，可以检测 GPS 的其他状态数据确定。









