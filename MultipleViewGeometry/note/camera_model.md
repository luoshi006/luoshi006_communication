> 摘自：http://blog.csdn.net/lsh_2013/article/details/47615309

# 理想透视模型（小孔成像）

![](http://img.blog.csdn.net/20150813170130308)

其中，$u$ - 物距(m)； $f$ - 焦距(m)；$v$ - 像距；
$$ \frac{1}{f} = \frac{1}{u} + \frac{1}{v} $$

---

![](http://img.blog.csdn.net/20150813170427741)

## 坐标系
1. 世界坐标系
2. 相机坐标系（光心）
3. 图像坐标系
	用物理单位（m/mm）表示图像中像素的位置。
4. 像素坐标系

## 坐标系的关系
### 像素坐标系 && 图像坐标系
![](http://img.blog.csdn.net/20150813170616321)
$$\begin{align}
u = \frac{x}{dx} + u_0\\    
v = \frac{y}{dy} + v_0 \\
\end{align}$$
此处，$(u_0, v_0)$ 是* 图像坐标系 *原点在* 像素坐标系 *中的坐标；
$dx, dy $ 分别为每个像素在图像平面$x,y$方向的物理尺寸；
即：
$$
  \begin{pmatrix}
  u \\ v \\ 1
  \end{pmatrix}
  =
  \begin{pmatrix}
  \frac{1}{dx} & 0 & u_0\\ 
  0 & \frac{1}{dy} & v_0 \\
  0&0&1
  \end{pmatrix}
  \begin{pmatrix}
  x \\ y \\ 1
  \end{pmatrix}
$$

### 图像坐标系 && 相机坐标系
> 相似三角形


$$
  \begin{pmatrix}
  x \\ y \\ 1
  \end{pmatrix}
  =
  \begin{pmatrix}
  f&0&0 \\ 0&f&0 \\0&0& 1
  \end{pmatrix}
  \begin{pmatrix}
  X_c/Z_c \\ Y_c/Z_c \\ 1
  \end{pmatrix}
$$

### 像素坐标系 && 相机坐标系

$$
  \begin{pmatrix}
  u \\ v \\ 1
  \end{pmatrix}
  =
  \begin{pmatrix}
  \frac{1}{dx} & 0 & u_0\\ 
  0 & \frac{1}{dy} & v_0 \\
  0&0&1
  \end{pmatrix}
  \begin{pmatrix}
  x \\ y \\ 1
  \end{pmatrix}
    =
     \begin{pmatrix}
  \frac{1}{dx} & 0 & u_0\\ 
  0 & \frac{1}{dy} & v_0 \\
  0&0&1
  \end{pmatrix}
  \begin{pmatrix}
  f&0&0 \\ 0&f&0 \\0&0& 1
  \end{pmatrix}
  \begin{pmatrix}
  X_c/Z_c \\ Y_c/Z_c \\ 1
  \end{pmatrix}
$$

$$
 Z_c\begin{pmatrix}
  u \\ v \\ 1
  \end{pmatrix}
  =
  \begin{pmatrix}
  f_x & 0 & c_x \\
  0 & f_y & c_y \\
  0 & 0 & 1
  \end{pmatrix}
  \begin{pmatrix}
  X_c \\ Y_c \\ Z_c
  \end{pmatrix}
$$