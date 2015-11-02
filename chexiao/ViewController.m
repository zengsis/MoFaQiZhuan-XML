//
//  ViewController.m
//  chexiao
//
//  Created by apple on 15/8/23.
//  Copyright (c) 2015年 apple. All rights reserved.
//  

#import "ViewController.h"
#import "XMLDictionary.h"
@interface ViewController ()
{
    NSString *_filePath; //保存矩形的文件路径
    NSMutableArray *_viewArray;//运行过程中显示的所有矩形视图
    NSMutableArray *_rectangleArray;//运行中所有的矩形对象
   // NSString *_jsonFilePath;//保存矩形的json文件路径
    NSString *_xmlFilePath;//保存矩形xml的文件路径
}
@end

@interface Rectangle : NSObject
@property(nonatomic,assign) CGPoint point;
@property(nonatomic,assign) CGSize size;
@property(nonatomic,copy) UIColor *backgroundColor;
@end

@implementation Rectangle

@end


@implementation ViewController
- (IBAction)saveClicked:(id)sender
{
     //准备一个数组来转化为XML数据
    //XML时单根节点表示，需要一个字典
        NSMutableDictionary *dicToXML=[NSMutableDictionary dictionary];
    NSMutableArray *arrayForRect=[NSMutableArray array];//所有举行数组，在xml中同名标签标示
        //遍历出矩形数组的元素，转化为字典
        for(Rectangle *rect in _rectangleArray)
        {
            NSMutableDictionary *rectDic=[NSMutableDictionary dictionary];
            rectDic[@"x"]=@(rect.point.x);
            rectDic[@"y"]=@(rect.point.y);
            rectDic[@"width"]=@(rect.size.width);
            rectDic[@"height"]=@(rect.size.height);
            UIColor *color=rect.backgroundColor;
            CGFloat red,green,blue,alpha;

            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            rectDic[@"red"]=@(red);
            rectDic[@"green"]=@(green);
            rectDic[@"blue"]=@(blue);
            rectDic[@"alpha"]=@(alpha);
            //把存有矩形对象信息的字典加入数组
            [arrayForRect addObject:rectDic];
        }
    //把矩形数组加入字典中
    [dicToXML setObject:arrayForRect forKey:@"rect"];
    //设置字典转换为xml后的根节点名为rects
    [dicToXML setObject:@"rects" forKey:XMLDictionaryNodeNameKey];
    NSString *xmlString=[dicToXML XMLString];
    [xmlString writeToFile:_xmlFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}
- (IBAction)delectClicked:(id)sender {
    [_rectangleArray removeAllObjects];
    for(UIView *view in _viewArray)
    {
        [view removeFromSuperview];
    }
    [_viewArray removeAllObjects];
}
- (IBAction)moveClicked:(id)sender {
    [_rectangleArray removeLastObject];
    UIView *view=[_viewArray lastObject];
    [view removeFromSuperview];
    [_viewArray removeLastObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _xmlFilePath=[@"" stringByAppendingString:@"/Users/apple/Desktop/xml1.plist"];
    _filePath=[NSHomeDirectory() stringByAppendingString:@"/Documents/rectangles.plist"];
    _viewArray=[NSMutableArray array];
    _rectangleArray=[NSMutableArray array];
    [self loadRectanglesFromxmlFile];

}

-(void)loadRectanglesFromxmlFile
{
//从之前保存的xml文件中读出数据
    NSDictionary *dicFromXML=[NSDictionary dictionaryWithXMLFile:_xmlFilePath];
    if(dicFromXML==nil){
        return;
    }
    //把xml数据转化为oc的字典对象后，xml中同名的标签由原来的数组转化而来，现在根据同名标签取出数组
    NSArray *rectArrayFromXML=[dicFromXML objectForKey:@"rect"];
        //快速枚举出数组里的每一个字典，然后把字典里的数据挨个挨个转换为一个Rectangle对象

    for(NSMutableDictionary *rectDic in rectArrayFromXML)
    {
        CGFloat x=[rectDic[@"x"] floatValue];
        CGFloat y=[rectDic[@"y"] floatValue];
        CGFloat width=[rectDic[@"width"] floatValue];
        CGFloat height=[rectDic[@"height"] floatValue];

        CGFloat red=[rectDic[@"red"] floatValue];
        CGFloat green=[rectDic[@"green"] floatValue];
        CGFloat blue=[rectDic[@"blue"] floatValue];
        CGFloat alpha=[rectDic[@"alpha"] floatValue];

        UIColor *color=[UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        
        //下面创建矩形对象并赋初值为恢复的数据值
        Rectangle *rect=[Rectangle new];
        rect.point=CGPointMake(x, y);
        rect.size=CGSizeMake(width, height);
        rect.backgroundColor=color;
    //下面根据回复的大小位置数据创建矩形视图对象并恢复显示到界面，颜色和之前的颜色一致
        CGRect frame=CGRectMake(x, y, width, height);
        UIView *view=[[UIView alloc]initWithFrame:frame];
        view.backgroundColor=rect.backgroundColor;
        [self.view addSubview:view];
        [_rectangleArray addObject:rect];
        [_viewArray addObject:view];
    }
}
-(UIColor *)randomColor
{
    CGFloat red=(arc4random()%256)/255.0;
    CGFloat green=(arc4random()%256)/255.0;
    CGFloat blue=(arc4random()%256)/255.0;
    CGFloat alpha=(arc4random()%256)/255.0;
    UIColor *random=[UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return random;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{//我们只取一个触摸点，暂时只管单个触摸
    UITouch *touch=[touches anyObject];
    //获取触摸点在指定试图中的坐标
    CGPoint point=[touch locationInView:self.view];
    CGSize size=CGSizeMake(0,0);
    //构造一个矩形对象
    Rectangle *re=[Rectangle new];
    re.point=point;
    re.size=size;
    [_rectangleArray addObject:re];//加入举行数组
    //构造一个frame来决定矩形视图位置大小
    CGRect frame=CGRectMake(re.point.x, re.point.y, re.size.width, re.size.height);
    UIView *view=[[UIView alloc]initWithFrame:frame];
    view.backgroundColor=[UIColor redColor];//默认背景颜色
    view.backgroundColor=[self randomColor];
    re.backgroundColor=view.backgroundColor;
    [self.view addSubview:view];
    [_viewArray addObject:view];
    
 
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint newPoint=[touch locationInView:self.view];
    Rectangle *re=[_rectangleArray lastObject];
    CGFloat width,height;
    width=newPoint.x-re.point.x;
    height=newPoint.y-re.point.y;
    re.size=CGSizeMake(width, height);
    CGRect newFrame;
    newFrame.origin=re.point;
    newFrame.size=re.size;
    UIView *curView=[_viewArray lastObject];
    curView.frame=newFrame;
    

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint newPoint=[touch locationInView:self.view];
    Rectangle *re=[_rectangleArray lastObject];
    CGFloat width,height;
    width=newPoint.x-re.point.x;
    height=newPoint.y-re.point.y;
    re.size=CGSizeMake(width, height);
    CGRect newFrame;
    newFrame.origin=re.point;
    newFrame.size=re.size;
    UIView *curView=[_viewArray lastObject];
    curView.frame=newFrame;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


