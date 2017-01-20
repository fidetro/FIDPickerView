//
//  FIDPickerField.m
//  FIDPickerView
//
//  Created by Fidetro on 16/9/12.
//  Copyright © 2016年 Fidetro. All rights reserved.
//

#import "FIDPickerField.h"
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define kLabelFontSize (15.f)

@interface FIDPickerField ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
       UIToolbar *_inputAccessoryView;
       UIPickerView *_inputView;
}
@property (nonatomic,strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic,strong) NSArray *detailArray;
/** leftButton **/
@property(nonatomic,strong) UIButton *leftButton;
/** rightButton **/
@property(nonatomic,strong) UIButton *rightButton;

@property(nonatomic,strong,readwrite)NSArray *selectArray;

@end

@implementation FIDPickerField


- (instancetype)initWithDataSource:(NSArray *)dataArray detailSource:(NSArray *)detailArray{
    
    self = [super init];
    if (self) {
        self.dataArray = dataArray;
        self.detailArray = detailArray;
    }
    return self;
    
}

- (void)setDataArray:(NSArray *)dataArray{
    
    _dataArray = dataArray;
    [self.pickerView reloadAllComponents];
    
}
- (void)setDetailArray:(NSArray *)detailArray{
    
    _detailArray = detailArray;
    [self.pickerView reloadAllComponents];
    
}


- (UIButton *)leftButton{
    
    if (!_leftButton) {
        
        _leftButton = [[UIButton alloc]init];
        [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [_leftButton sizeToFit];
        [_leftButton addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _leftButton;
    
}

- (UIButton *)rightButton{
    
    if (!_rightButton) {
        
        _rightButton = [[UIButton alloc]init];
        [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
        [_rightButton sizeToFit];
        [_rightButton addTarget:self action:@selector(selectDataSource:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _rightButton;
    
}



- (UIView *)inputAccessoryView{
    
    if (!_inputAccessoryView) {
        
        UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        
        toolBar.barTintColor = [UIColor whiteColor];//设置toolBar背景颜色
        UIBarButtonItem * DoneItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
        
        UIBarButtonItem * enterItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
        UIBarButtonItem *springItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        toolBar.items = @[DoneItem,springItem,enterItem];
        
        
        return toolBar;
        
    }
    
    return _inputAccessoryView;
    
}

- (UIView *)inputView{
    
    if (!_inputView) {
        
        self.pickerView = [[UIPickerView alloc]init];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        return self.pickerView;
        
    }
    
    return _inputView;
    
}


- (void)selectDataSource:(UIBarButtonItem *)sender{
    
    [self resignFirstResponder];
    NSMutableArray *selectArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        [selectArray addObject:self.dataArray[i][[self.pickerView selectedRowInComponent:i]]];
    }
    NSMutableArray *rowInComponentArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        [rowInComponentArray addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    
    if (self.select_block) {
        self.select_block(selectArray,rowInComponentArray);
    }
    [self.pickerDelegate selectPickerDataSource:selectArray selectedRowInComponent:rowInComponentArray];
    
}

-(BOOL)canBecomeFirstResponder{
    
    return YES;
    
}



#pragma mark - --------------------------UIPickerViewDataSource--------------------------
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return self.dataArray.count;
    
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return ((NSArray *)((self.dataArray[component]))).count;
    
}
#pragma mark - --------------------------UIPickerViewDelegate--------------------
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return self.dataArray[component][row];
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *rowLabel = [[UILabel alloc]init];
    rowLabel.textAlignment = NSTextAlignmentCenter;
    [rowLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    if (self.detailArray.count != self.dataArray.count) {
        
        rowLabel.text = [NSString stringWithFormat:@"%@",self.dataArray[component][row]];
    }else
        
        rowLabel.text = [NSString stringWithFormat:@"%@%@",self.dataArray[component][row],self.detailArray[component]];
    
    return rowLabel;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    
    if (self.detailArray.count != self.dataArray.count) {
        
        return [[NSString stringWithFormat:@"%@",[self.dataArray[component] lastObject]] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kLabelFontSize]}].width+20;//防止选中的时候会偏移
    }else
        
        return [[NSString stringWithFormat:@"%@",[self.dataArray[component] lastObject]] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kLabelFontSize]}].width+[[NSString stringWithFormat:@"%@",self.detailArray[component]] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kLabelFontSize]}].width+20;//防止选中的时候会偏移
    
}

//选择pickerView显示内容的时候，需要重写这个方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"滚动选择的内容 %@",self.dataArray[component][row]);
    
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
}


@end
