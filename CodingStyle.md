

#Objective-C代码规范


#### 语言

应该使用US英语

应该：

```
UIColor *myColor = [UIColor whiteColor];

UIColor *backgroundColor = [UIColor greenColor];
```


不应该：

```
UIColor *myColour = [UIColor whiteColor]; 

UIColor *beijingColor = [UIColor greenColor];
```
#### 组织

在函数分组和protocol/delegate实现中使用#pragma mark - 来分类方法，要遵循以下一般结构：

```
#pragma mark - Lifecycle  
- (instancetype)init {}
- (void)dealloc {}
- (void)viewDidLoad {}
- (void)viewWillAppear:(BOOL)animated {}
- (void)didReceiveMemoryWarning {}

#pragma mark - Public Method 
- (void)publicMethod {}

#pragma mark - Private Method
- (void)privateMethod {}

#pragma mark - Protocol conformance  
#pragma mark - UITextFieldDelegate
#pragma mark - Other Delegate...
#pragma mark - UITableViewDataSource  
#pragma mark - UITableViewDelegate  

#pragma mark - Getters & Setters  
- (id)customProperty {} 
```

###空格

* 缩进使用4个空格，确保在Xcode偏好设置来设置。
* 方法大括号和其他大括号(if/else/switch/while 等.) 总是在同一行语句打开但在新行中关闭。


命名规则 
类名首字母大写，方法首字母小写，方法中的参数首字母小写，同时尽量让方法的命名读起来像一句话，能够传达出方法的意思，同时取值方法前不要加前缀“get”

变量名小写字母开头

常量以小写字母k开头，后续首字母大写

声明类或方法时，注意空格的使用，参数过多时可换行保持对齐，

调用方法时也是如此，参数都写在一行或换行冒号对齐，

关于注释
注释很重要，但除了开头的版权声明，尽可能把代码写的如同文档一样，让别人直接看代码就知道意思，写代码时别担心名字太长，相信Xcode的提示功能。

代码行最大字符数100

实例变量应该在实现文件.m中声明或以@property形式在.h文件中声明，一定要直接在.h文件声明，加上@priavte，另外，使用@private、@public，前面需要一个缩进空格。

尽可能保证 .h文件的简洁性，可以不公开的API就不要公开了，写在实现文件中即可。

写delegate的时候类型应该为weak弱引用，以避免循环引用，当delegate对象不存在后，我们写的delegate也就没有存在意义了自然是需要销毁的，weak与strong可以参考上一篇文章介绍。

建议使用“#pragma mark”，方便阅读代码



#参考
- [Apple Coding Guideline](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/Articles/NamingBasics.html#//apple_ref/doc/uid/20001281-1002931-BBCFHEAB)
