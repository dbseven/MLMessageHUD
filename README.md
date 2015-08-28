# MLMessageHUD
MLMessageHUD 非常简单实用的用户消息提示的指示器, 简单的1行代码即可调用 Loading 视图, 您还可以对 LMessageHUD 的显示位置进行设置等

// 1. 调用 show 方法, 展示 Loading 指示器

[MLMessageHUD show];


// 2. 当 MLMessageHUD 处于 Loading 状态时, 调用 dismissWithMessage:messageType: 方法, 会从 Loading 指示器直接过度到 加载成功 或 加载失败 的指示器样式. (例如: 网络请求的时候, 您可以在开始请求的时候调用 [MLMessageHUD show], 当请求完成 或 请求失败的时候, 调用 dismissWithMessage:messageType: 方法)

[MLMessageHUD dismissWithMessage:@"Your Message" messageType:MLHUDMessageTypeSuccess];


// 3. 单纯的显示 加载成功 或 加载失败 的指示器. showStyle 参数用来设置只是器出现的位置, 暂时只允许3种方式, 分别为: 状态栏模式, 导航栏模式, 普通模式

[MLMessageHUD showSuccessMessage: @"Your Message" showStyle: MLHUDShowStyleNormal];


// 4. 调用 dismiss 方法, 可以隐藏 MLMessageHUD 指示器. (dismiss 方法, 主要应用于 UIViewController 的 viewWillDisappear 方法中, 由于网络请求的时间长短不一, 网速慢的情况下, 用户往往没有耐心去等待加载而直接返回上一级界面, 所以在 viewWillDisappear 方法中 调用 dismiss 方法是一个很好的选择, PS: 我建议您不要在 viewWillDisappear 方法中调用 dismissWithAnimation 方法)

[MLMessageHUD dismiss];


// 5. 调用 dismissWithAnimation 方法, 可以动画效果隐藏 MLMessageHUD 指示器, 您可以将此方法应用于不需要提示用户加载成功 或 加载失败的地方.

[MLMessageHUD dismissWithAnimation];


// 6. MLMessageHUDDemo 中, 已经为您展示了 MLMessageHUD 的用法, 非常简单的 API, 实现非常 NB 的效果.

