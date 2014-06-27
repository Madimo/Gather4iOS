//
//  EmoticonViewController.m
//  Gather
//
//  Created by Madimo on 6/26/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import "EmoticonViewController.h"
#import "EmoticonManager.h"
#import "EmoticonCell.h"
#import "Emoticon.h"

@interface EmoticonViewController ()

@end

@implementation EmoticonViewController

- (void)loadView
{
    //[super loadView];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(90, 90);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                             collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor darkGrayColor];
    [self.collectionView registerClass:[EmoticonCell class] forCellWithReuseIdentifier:@"EmoticonCell"];
    self.view = self.collectionView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView data source & delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [EmoticonManager manager].emoticons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmoticonCell" forIndexPath:indexPath];
    
    Emoticon *emoticon = [EmoticonManager manager].emoticons[indexPath.item];
    cell.emoticon = emoticon;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emoticonViewController:didSelectEmoticon:)]) {
        [self.delegate emoticonViewController:self
                            didSelectEmoticon:[EmoticonManager manager].emoticons[indexPath.item]];
    }
}

@end
