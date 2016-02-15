# HKSnippet

HKSnippet is a xcode plug-in for create code snippet with triggers strings.

![Demo](https://github.com/hunk3000/HKSnippet/blob/master/Images/demo.gif?raw=true)

![Setting1](https://github.com/hunk3000/HKSnippet/blob/master/Images/setting1.png?raw=true)

![Setting2](https://github.com/hunk3000/HKSnippet/blob/master/Images/setting2.png?raw=true)


* ###Strong

```
@ps 	@property (strong) type *value; 

@prs	@property (strong, readonly) type *value;

@pns	@property (noatomic, strong) type *value;

@prns	@property (nonatomic, strong, readonly) type *value;


```

* ###Weak

```
@pw 	@property (weak) type *value; 

@prw	@property (weak, readonly) type *value;

@pnw	@property (noatomic, weak) type *value;

@prnw	@property (nonatomic, weak, readonly) type *value;

```

* ###Copy

```
@pc 	@property (copy) type *value; 

@prc	@property (copy, readonly) type *value;

@pnc	@property (noatomic, copy) type *value;

@prnc	@property (nonatomic, copy, readonly) type *value;

```

* ###Assign

```
@pa 	@property (assign) type *value; 

@pra	@property (assign, readonly) type *value;

@pna	@property (noatomic, assign) type *value;

@prna	@property (nonatomic, assign, readonly) type *value;

```
* ### @ff - General Getter 

```
@ff 	

- (type *)name {
    if(!_name) {
        //Init Code
    }
    return _name;
}

```



* ### @fv - UIView Getter 

```
 @fv

- (UIView *)name {
    if(!_name) {
        _name = [UIView new];
        _name.backgroundColor = color;
    }
    return _name;
} 

```

* ### @fl - UILabel Getter

```
@fl	

- (UILabel *)name {
    if(!_name) {
        _name = [UILabel new];
        _name.backgroundColor = [UIColor clearColor];
        _name.textAlignment = NSTextAlignmentCenter;
        _name.numberOfLines = 0;
        _name.textColor = color;
        _name.font = font;
        _name.text = text;
    }
    return _name;
}

```

* ### @fi - UIImageView Getter

```
@fi

- (UIImageView *)name {
    if(!_name) {
        _name = [UIImageView new];
        _name.layer.cornerRadius = radius;
        _name.layer.masksToBounds = YES;
        _name.backgroundColor = [UIColor clearColor];
        _name.image = image;
    }
    return _name;
}

```

* ### @fb - UIButton Getter

```
@fb

- (UIButton *)name {
    if(!_name) {
        _name = [UIButton new];
        _name.layer.cornerRadius = radius;
        _name.layer.masksToBounds = YES;
        _name.backgroundColor = [UIColor clearColor];
        [_name setTitleColor:title color forState:UIControlStateNormal];
        [_name setTitle: title  forState:UIControlStateNormal];
        [_name setImage:image forState:UIControlStateNormal];
    }
    return _name;
}

```

* ### @ft - UITableView Getter

```
@ft

- (UITableView *)name {
    if(!_name) {
        _name = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _name.backgroundColor = [UIColor clearColor];
        _name.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _name.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _name.separatorColor = color;
        _name.delegate = table delegate;
        _name.dataSource = table datasource;

        [_name registerClass:[class name class] forCellReuseIdentifier:cellId];
    }
    return _name;
}

```

* ### Declear

```
@cs		static NSString * const name = @\"value\";

@log	NSLog(@\"format\",data);

@ws		__weak typeof(self) weakSelf = self;

@ss		__strong typeof(weakSelf) strongSelf = weakSelf;

@mk		#pragma mark - section title

@pmk	#pragma mark - Private Method

@lmk	#pragma mark - LifeCycle

@gmk	#pragma mark - Getters & Setters

```

* ### @lv - LoadView

```
@lv

- (void)loadView {
    [super loadView];
}

```

* ### @ls - Layout Subviews

```
@ls

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    //set subview frames
}

```

* ### @vl - ViewWillLayoutSubviews

```
@vl

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    //set subview frames 
}

```

* ### @init - Initialization

```
@init

- (instancetype)init {
    self = [super init];
    if (self) {
        //statements
    }
    return self;
}

```

* ### @de - De-Init

```
@de

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

```

* ### @table -  UITableView Delegate & Datasource

```
@table

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellId];

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

```


