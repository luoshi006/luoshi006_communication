> by luoshi006
>欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

#Multicopter Flight Controller Tuning Guide

原文链接：http://px4.io/docs/multicopter-pid-tuning-guide/

本文目录：

[toc]


<hr color="00AA00">

本指南仅适用于高阶用户，如果不了解 PID 参数整定，你可能会炸机~


> <font color="FF0000"><strong>参数整定时，禁止使用碳纤或碳纤增强桨、禁止使用破损桨叶。</strong> </font> 

<br>

> <font color="DDDD00"><strong>出于安全考虑，默认的 P 值较小。如果期望更好的控制响应，需要调大 P 。</strong> </font> 

<br>

本教程适用于所有多旋翼机型（AR.Drone, PWM Quads / Hexa / Octo setups）。PID 控制器是应用最广泛的控制技术。也有一些基于模型预测的控制手段（LQR/LQG），效果更好，但是由于这些控制方法需要比较准确的系统模型，所以应用并不广泛。PX4 底层控制的目标是尽可能跟随多旋翼位置控制（MPC），并非所有支持机型的系统模型都是已知的，（PID 控制能够满足大部分场景），所以 PID 参数整定十分关键。
<hr color="AA0000">
##Introduction
PX4 `multirotor_att_control` 进程中首先运行姿态控制器外环，有由以下参数：

- **Roll control (MC_ROLL_P)**
- **Pitch control (MC_PITCH_P)**
- **Yaw control (MC_YAW_P)**

内环有三个独立的 PID 控制器，控制三个姿态角速度：

- Roll rate control (**MC_ROLLRATE_P, MC_ROLLRATE_I, MC_ROLLRATE_D**)
- Pitch rate control (**MC_PITCHRATE_P, MC_PITCHRATE_I, MC_PITCHRATE_D**)
- Yaw rate control (**MC_YAWRATE_P, MC_YAWRATE_I, MC_YAWRATE_D**)

外环的输出是机身角速度（例如：机身应为水平，当前有30°横滚角，则控制输出可以是 60°/s 的旋转速度）。内环控制改变电机输出，从而使飞机以期望的角速度旋转。

P 参数实际上有一个直观的物理意义。例如：如果 `MC_ROLL_P` 是 6 ，则飞机会以角速度的 6 倍补偿，即 0.5 radian （约30°）的姿态偏差对应 3 radians/s或约170 °/s。 那么，如果内环增益 `MV_ROLLRATE_P` 是 0.1 ，则横滚角推力控制输出为 3 * 0.1 = 0.3 。这意味着它将一侧的转子速度降低 30%，并且增加另一侧的转子速度，使飞机恢复水平。

还有一个 `MC_YAW_FF` 参数，用于航向角速度控制器的前馈控制。0 表示缓慢控制，控制器只有检测到 `yaw` 偏差时才会开始调节；1 表示较灵敏控制，可能有超调，控制器快速调节偏航，使 `yaw` 误差保持在 0 左右。
<hr color="0000AA">
##Motor Band / Limiting
正如前述示例，在某些条件下，可能会出现一个电机的输入大于最大值，而另一个电机的输入小于零。这种情况下，电机产生的力与控制模型相悖，可能会造成飞机翻车。为了防止这种情况发生，在多旋翼混控器（mixer）中有一个限幅。如果某一电机超过安全限，飞机的总推力下降，从而保证控制器输出的百分比。可能会导致飞行器停止爬升或掉高，但能够保证其不侧翻。同理，设定最小值限幅，即使横滚给定值很大，它将缩放值需保证系统大致推力，防止失速侧翻。
<hr color="00AAAA">
##Step 1: Preparation
首先，将所有参数置为初始值：

1. 所有 `MC_XXX_P` 设为 0 （roll/pitch/yaw）
2. 所有 `MC_XXXRATE_P` , `MC_XXXRATE_I` , `MC_XXXRATE_D` 设为 0；（不包括 `MC_ROLLRATE_P`、`MC_PITCHRATE_P`）
3. `MC_ROLLRATE_P` 和 `MC_PITCHRATE_P` 设为 **0.02**
4.  `MC_YAW_FF` 设为 **0.5**

所有增益值 P 都需要慢慢增加，每次增大 20%~30%，甚至在接近最终值时为10%。
<strong>注意：增益 P 太大（即使是最佳值的1.5~2倍）可能引起非常危险的震荡！</strong>
<hr color="0000AA">
##Step 2: Stabilize Roll and Pitch Rates

### P Gain Tuning

- **MC_ROLLRATE_P**
- **MC_PITCHRATE_P**

如果飞机是对称的，`ROLL` 和 `PITCH` 对应的值相等；如果不对称，就需要分别整定。

将多旋翼用手拿稳，将油门推至 50%，此时推力约等于重力，手上几乎不受力。在 `ROLL` 或 `PITCH` 方向倾斜，观察响应。飞行器应该轻微的抵抗运动，但并不会回到水平。如果有振荡，将 `RATE_P` 调小。若控制响应缓慢但正确，小幅增大 `RATE_P` 直到开始振荡。稍稍减小 `RATE_P` 直到仅有轻微振荡或不振荡（约减小10%），一般会有一定超调量。通常 `RATE_P` 约为**0.1**。

###D Gain Tuning

- **MC_ROLLRATE_D**
- **MC_PITCHRATE_D**

假设已经完成 `RATE_P` 参数整定。

从 **0.01** 开始缓慢增加 `RATE_D` ，消除上一环节中的小幅振荡。如果振荡加剧，则 `RATE_D` 太大。通过整定 `RATE_P` 和 `RATE_D` 参数，能够得到较好效果，通常`RATE_D` 值在 0.01~0.02。

在 QGroundControl 中，可以绘制 `ROLLRATE` 和 `PITCHRATE` 的曲线（`ATTITUDE.rollspeed/pitchspeed`）。该响应**必须没有振荡**，但可以有 10~20% 的超调。

###I Gain Tuning

如果 `ROLLRATE` 和 `PITCHRATE` 无法达到设定值，存在静差。以 `MC_ROLLRATE_P` 的 5~10% 为初值，增加 `MC_ROLLRATE_I` and `MC_PITCHRATE_I`。
<hr color="00AAAA">
##Step 3: Stabilize Roll and Pitch Angles

###P Gain Tuning

- **MC_ROLL_P**
- **MC_PITCH_P**

**将 `MC_ROLL_P` 和 `MC_PITCH_P` 设为3。**

将多旋翼用手拿稳，将油门推至 50%，此时推力约等于重力，手上几乎不受力。在 `ROLL` 或 `PITCH` 方向倾斜，观察响应。飞行器应该缓慢回到水平。如果振荡，则减小 P。如果响应正确但较慢，则增加 P 直到开始振荡。最佳情况为超调量约 10~20%。得到稳定响应后，再次微调 `RATE_P`, `RATE_D` 。

在 QGroundControl 中查看 `ATTITUDE.roll/pitch` 和 `ctrl0, ctrl1` 曲线。姿态角度超调应不超过 10~20%。
<hr color="AA00AA">
##Step 4: Stabilize Yaw Rate

###P Gain Tuning

- **MC_YAWRATE_P**

**将 `MC_YAWRATE_P` 设为 0.1**

将多旋翼用手拿稳，将油门推至 50%，此时推力约等于重力，手上几乎不受力。旋转偏航角，观察响应。电机声音会有变化，飞机会抵抗偏航方向的旋转。`yaw` 方向的响应远小于 `roll` 和 `pitch` 方向，是正常现象。如果开始振荡，减小 `RATE_P`。如果响应过大，甚至出现小幅移动（部分电机全速旋转/ 部分电机停转），此时应减小 `RATE_P`。通常设为 0.2~0.3。

`YAWRATE` 控制中，如果响应过大或振荡，可能会降低 `ROLL` 与 `PITCH` 端响应。绕 `yaw`  `roll` 和 `pitch` 轴转动，观察是否正常。

<hr color="0000AA">
##Step 5: Stabilize Yaw Angle

###P Gain Tuning

- **MC_YAW_P**

**将 `MC_YAW_P` 设为 1。**

将多旋翼用手拿稳，将油门推至 50%，此时推力约等于重力，手上几乎不受力。旋转偏航角，观察响应。飞机应该会缓慢回到初始航向。如果发生振荡，减小 P 。如果控制响应较慢，缓慢增大，不要出现振荡。通常设为 2~3。

在 QGroundControl 中查看 `ATTITUDE.yaw`，应控制超调在 2~5% 以内。（小于 pitch/roll）
<hr color="00AAAA">
##Feed Forward Tuning

- **MC_YAW_FF**

该参数并不十分重要，可以在飞行中整定。最坏的情况就是 `yaw` 响应太慢或太快。可以根据个人的感觉调节 `FF` 参数。有效范围：0~1。通常设为 0.8~0.9。（对于空中拍摄的飞行器，该值要小很多以得到较平稳的响应）

在 QGroundControl 中查看 `ATTITUDE.yaw`，应控制超调在 2~5% 以内。（小于 pitch/roll）