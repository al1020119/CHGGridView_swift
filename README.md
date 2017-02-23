#CHGGridView
完成1.0版
功能包括 应用启动导航、广告模式、菜单模式（类似大众点评）、tab模式
![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015444_dd33c2ee_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015502_27ecd593_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015511_15a49e1b_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015529_de244cc5_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015539_5a2b3da8_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015548_e0384aa4_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015556_29f53d39_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015605_9340dc9b_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015613_c72868fd_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015623_c0ddf248_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015632_d0974ddd_3935.jpeg "在这里输入图片标题")![输入图片说明](http://git.oschina.net/uploads/images/2016/0822/015640_63dfe02c_3935.jpeg "在这里输入图片标题")


    使用说明 

    广告模式 
    self.adView = [[CHGAdView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200)];
    _adView.data = @[@"http://ww1.sinaimg.cn/large/7efb7362jw1e3rgypjtzvj.jpg",
    @"http://img.3366.com/fileupload/img/commmanage/151/6780_1.jpg",
    @"http://pic1.nipic.com/2008-11-05/2008115214135913_2.jpg"];//[self simulationData];
    _adView.isCycleShow = YES;//是否循环显示
    _adView.isTimerShow = YES;//是否启用定时切换
    _adView.isShowPageControll = YES;//是否显示pageControll
    _adView.dataSource = self;
    [_adView.chgMenu.gridView registerNibName:@"AdCell" forCellReuseIdentifier:@"AdCell"];
    [_adView reloadData];
    [self.view addSubview:_adView];


    页面启动导航模式 （CHGAdView 导航模式，此模式只需要将isCycleShow、isTimerShow的属性设置为“NO”即可）
    self.adView = [[CHGAdView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _adView.data = @[@"http://ww1.sinaimg.cn/large/7efb7362jw1e3rgypjtzvj.jpg",
    @"http://img.3366.com/fileupload/img/commmanage/151/6780_1.jpg",
    @"http://pic1.nipic.com/2008-11-05/2008115214135913_2.jpg"];
    _adView.isCycleShow = NO;//是否循环显示
    _adView.isTimerShow = NO;//是否启用定时切换
    _adView.isShowPageControll = YES;//是否显示pageControll
    _adView.dataSource = self;
    [_adView.chgMenu.gridView registerNibName:@"NavCell" forCellReuseIdentifier:@"NavCell"];
    [self.view addSubview:_adView];


    菜单模式（类似大众点评） 
    self.menu = [[CHGMenu alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 660)];
    _menu.items = [self simulationData];
    _menu.showPageControl = YES;//是否显示pageControll
    _menu.gridViewDatasource = self;
    _menu.gridViewDelegate = self;
    [_menu.gridView registerNibName:@"MenuItemCell" forCellReuseIdentifier:@"MenuItemCell"];
    [_menu.gridView registerNibName:@"AdCell" forCellReuseIdentifier:@"AdCell"];


    tab切换 
    self.tabPage = [[CHGTabPage alloc] initWithFrame:CGRectMake(0, _userVCMode ? 20 : 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (_userVCMode ? 20 : 64))];
    _tabPage.tabPageDataSource = self;
    _tabPage.gridViewDelegate = self;
    _tabPage.items = [self simulationData];
    _tabPage.selectedColor = [UIColor greenColor];
    _tabPage.normalColor = [UIColor grayColor];
    _tabPage.tabViewLoca = locationTop;//在顶部显示按钮区域
    _tabPage.itemBtnCellLocation = CHGTabViewItemBtnCellLocationBottom;
    _tabPage.slideIndicatorColor = [UIColor redColor];
    _tabPage.useVCMode = _userVCMode;//是否定义左侧和右侧的view
    [_tabPage.gridView registerNibName:@"TableViewCell" forCellReuseIdentifier:@"TableViewCell"];
    [self.view addSubview:_tabPage];
