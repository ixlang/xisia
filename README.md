# xisia
 another compiler
 
## 一个编译器, 自一个叫做Visia的VB项目移植到xlang.

### 该项目全部代码均用 xlang 实现, 编译器能够生成 Windows 平台 x86 架构的可执行程序.

### 在原有语法上做了如下改动:
  #### 将 frame 关键字替换为 func
  #### 将 single 替换为 float
  #### 将 local 替换为 var
  
### 玩法: xisia -e main.xia -c modules.xia -o main.exe
     #### -e 入口模块源文件
     #### -c 其他模块源文件
     #### -o 输出目标文件
     
### 随便玩.
