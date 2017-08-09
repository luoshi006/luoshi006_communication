原文：https://dev.px4.io/en/tutorials/tuning_the_ecl_ekf.html

## What is the ecl EKF

EKF 对于各个传感器的延时，采用 `fusion time horizon`处理， 各传感器数据缓存于 FIFO ，在 EKF 需要时取出。传感器的延时补偿有参数 `EKF2_*_DELAY` 控制。

使用互补滤波处理 `fusion time horizon`到当前时刻的 IMU 数据更新状态。滤波器的时间常数：`EKF2_TAU_VEL` `EKF2_TAU_POS`。

IMU的安装位置与 body frame 之间的位置会对位置和速度状态产生影响，需要预先设定：`EKF2_IMU_POS_X,Y,Z`。

EKF 仅使用 IMU 数据进行状态预测，而不是更新时的观测量。协方差预测、状态更新、协方差更新的数学表达式通过 Matlab符号运算工具箱得到。


## What sensor measurements does it use?
