//
//  JSPictureBrowserController.m
//  BrowerDemo
//
//  Created by BreazeMago on 2017/4/23.
//  Copyright © 2017年 JoesRain. All rights reserved.
//

#import "JSPictureBrowserController.h"
#define ScWidth [[UIScreen mainScreen] bounds].size.width   //获取屏幕宽度
#define ScHeight [[UIScreen mainScreen] bounds].size.height  //获取屏幕高度


@interface JSPictureBrowserController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    CGFloat lastScale;
    NSMutableArray *imageViews;
    UIScrollView *scrollImageView;
}
@end

@implementation JSPictureBrowserController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.backgroundColor = [UIColor lightGrayColor];
    if (_index > 0 && _index < _images.count) {
        [scrollImageView setContentOffset:CGPointMake(scrollImageView.frame.size.width*_index, 0)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    lastScale = 1.0;
    
    self.view.backgroundColor = [UIColor blackColor];
    imageViews = [NSMutableArray arrayWithCapacity:2];
    scrollImageView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScWidth, ScHeight)];
    scrollImageView.backgroundColor=[UIColor blackColor];
    scrollImageView.showsHorizontalScrollIndicator = NO;
    scrollImageView.pagingEnabled = YES;
    scrollImageView.delegate = self;
    [self.view addSubview:scrollImageView];
    
    if (_images && _images.count > 0) {
        self.title = [NSString stringWithFormat:@"1/%ld",(unsigned long)_images.count];
        scrollImageView.contentSize = CGSizeMake(_images.count * ScWidth, 0);
        for (int i=0; i<_images.count; i++) {
            NSInteger x_offset=ScWidth*i;
            UIView *parentImageView = [[UIView alloc] initWithFrame:CGRectMake(x_offset, 0, ScWidth, scrollImageView.bounds.size.height)];
            [scrollImageView addSubview:parentImageView];
            
            UIImageView *view = [[UIImageView alloc] initWithFrame:parentImageView.bounds];
            view.contentMode = UIViewContentModeScaleAspectFit;
            parentImageView.clipsToBounds = YES;
            
            if ([[_images objectAtIndex:i] isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL URLWithString:[_images objectAtIndex:i]];
                if (![url isKindOfClass:NSURL.class]) {
                    return;
                }
                dispatch_async(dispatch_get_global_queue(0, 0), ^{;
                    NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
                    if (!imageData) {
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{;
                        view.image = [UIImage imageWithData:imageData];
                        [view setNeedsLayout];
                    });
                });
            }else{
                UIImage *bigImage = [_images objectAtIndex:i];
                view.image = bigImage;
            }
            
            [parentImageView addSubview:view];
            [imageViews addObject:view];
            UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
            [pinchRecognizer setDelegate:self];
            [self.view addGestureRecognizer:pinchRecognizer];
            
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
            [panGesture setMinimumNumberOfTouches:1];
            [panGesture setMaximumNumberOfTouches:1];
            [self.view addGestureRecognizer:panGesture];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidNavAction)];
            [self.view addGestureRecognizer:tapGesture];
        }
    }
    // Do any additional setup after loading the view.
}



-(void)hidNavAction
{
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.hidden = !navBar.isHidden;
}

-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    }
    
    NSInteger page = scrollImageView.contentOffset.x / scrollImageView.frame.size.width;
    UIImageView *imageView = imageViews[page];
    
    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [imageView setTransform:newTransform];
    
    CGRect rect = CGRectZero;
    rect.size = imageView.bounds.size;
    if (rect.size.width < 240) {
        rect.size.width = 240;
        rect.size.height = (imageView.frame.size.height/imageView.frame.size.width)*rect.size.width;
    }else if (rect.size.height < 240){
        rect.size.height = 240;
        rect.size.width = (imageView.frame.size.width/imageView.frame.size.height)*rect.size.height;
    }else if (rect.size.width > imageView.image.size.width*1.5){
        rect.size.width = imageView.image.size.width*1.5;
        rect.size.height = (imageView.frame.size.height/imageView.frame.size.width)*rect.size.width;
    }else if (rect.size.height > imageView.image.size.height*1.5){
        rect.size.height = imageView.image.size.height*1.5;
        rect.size.width = (imageView.frame.size.width/imageView.frame.size.height)*rect.size.height;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = rect;
        imageView.center = CGPointMake(0.5*scrollImageView.bounds.size.width, scrollImageView.bounds.size.height*0.5);
    }];
    
    lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(CGSize)getCenterDistance:(UIImageView *)imageView{
    CGFloat w =  fabs(imageView.frame.size.width/2-imageView.superview.frame.size.width/2);
    CGFloat h =  fabs(imageView.frame.size.height/2-imageView.superview.frame.size.height/2);
    CGSize size = CGSizeMake(w, h);
    return size;
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (lastScale == 1) {
        return;
    }
    
    NSInteger page = scrollImageView.contentOffset.x / scrollImageView.frame.size.width;
    UIImageView *imageView = imageViews[page];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:imageView.superview];
        [imageView setCenter:(CGPoint){imageView.center.x + translation.x, imageView.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:imageView.superview];
        
        CGPoint p = imageView.center;
        CGSize size = [self getCenterDistance:imageView];
        if (imageView.center.x < -size.width+imageView.superview.frame.size.width/2) {
            p.x = -size.width+imageView.superview.frame.size.width/2;
        } else if (imageView.center.x > size.width+imageView.superview.frame.size.width/2){
            p.x = size.width+imageView.superview.frame.size.width/2;
        }
        
        if (imageView.center.y < -size.height+imageView.superview.frame.size.height/2){
            p.y = -size.height+imageView.superview.frame.size.height/2;
        }else if (imageView.center.y > size.height+imageView.superview.frame.size.height/2){
            p.y = size.height+imageView.superview.frame.size.height/2;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            imageView.center = p;
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    _index = page;
    self.title = [NSString stringWithFormat:@"%ld/%ld",page+1,_images.count];
    UIImageView *imageView = imageViews[page];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = CGRectZero;
        rect.size = imageView.bounds.size;
        rect.size.width = ScWidth;
        rect.size.height = scrollImageView.bounds.size.height;
        imageView.frame = rect;
        imageView.center = CGPointMake(0.5*scrollImageView.bounds.size.width, scrollImageView.bounds.size.height*0.5);
    }];
}

@end
