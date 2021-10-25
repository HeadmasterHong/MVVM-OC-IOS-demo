//
//  LightArtSectionListView.m
//  LightArt
//
//  Created by 彭利章 on 2018/5/18.
//

#import "LightArtSectionListView.h"
#import "LightArtView.h"
#import <MJRefresh/MJRefresh.h>
#import "LightArtRefreshHeader.h"
#import "LightArtLoadMoreFooter.h"
#import "LightArtSectionListLayout.h"
#import "LightArtCustomView.h"
#import "LightArtSegmentView.h"

@implementation LightArtCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(lightArtCollectionView:gestureRecognizerShouldBegin:)]) {
        BOOL b = [self.d lightArtCollectionView:self gestureRecognizerShouldBegin:gestureRecognizer];
        return b;
    } else {
        return YES;
    }
}

@end

@interface LightArtSectionListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, LightArtSegmentViewDelegate, LightArtCollectionViewDelegate>

@property (nonatomic, strong) LightArtSectionListLayout *layout;
@property (nonatomic, strong) LightArtUIView *scrollButton;
@property (nonatomic, assign) BOOL scrollButtonAnimating;
@property (nonatomic, strong) NSMutableSet *componentSet;
@property (nonatomic, strong) NSMutableDictionary *reusableQueueDic;
@property (nonatomic, assign) BOOL loadingMore;

@property (nonatomic, assign) int componentCount;
@property (nonatomic, assign) int preload;

@end

@interface LightArtSectionListCell : UICollectionViewCell

@property (nonatomic, strong) LightArtUIView *lightArtUIView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) LightArtSectionListView *sectionListView;

@end

@implementation LightArtSectionListCell

- (void)dealloc {
//    NSLog(@"%@ dealloc", self.lightArtUIView.model.index);
//    iOS8上会导致很奇怪的Crash，所以先注释掉
//    [self collectModelView];
}

- (void)collectModelView {
    if (nil == self.sectionListView.reusableQueueDic) {
        self.sectionListView.reusableQueueDic = [NSMutableDictionary dictionary];
    }
    
    if (nil != self.lightArtUIView) {
        if (self.lightArtUIView.superview == self.contentView) {
            // 可能已经被用在其他地方了，所以需要判断
            
            NSString *identifier = [self.lightArtUIView identifier];
            NSMutableArray *queue = self.sectionListView.reusableQueueDic[identifier];
            if (nil == queue) {
                queue = [NSMutableArray array];
                self.sectionListView.reusableQueueDic[identifier] = queue;
            }
            [queue addObject:self.lightArtUIView];
            
//            NSLog(@"%@ addQueue", self.lightArtUIView.model.index);
            
            [self.lightArtUIView removeFromSuperview];
        }
        self.lightArtUIView = nil;
    }
}

- (void)setupWithModel:(LightArtUIComponent *)model {
    self.contentView.clipsToBounds = YES;

    [self collectModelView];
    
    if (nil != model.view && model.view.model == model) {
        // model的view尚未被复用到其他model
        self.lightArtUIView = model.view;
        // 从复用队列里移除
        for (NSString *identifier in self.sectionListView.reusableQueueDic) {
            NSMutableArray *queue = self.sectionListView.reusableQueueDic[identifier];
            [queue removeObject:self.lightArtUIView];
        }
//        NSLog(@"%@ same %@", model.index, [model class]);
    } else {
        NSString *identifier = [model identifier];
        NSMutableArray *queue = self.sectionListView.reusableQueueDic[identifier];
        while (queue.count > 0) {
            LightArtUIView *v = queue[0];
            [queue removeObjectAtIndex:0];
            if ([identifier isEqual:[v identifier]]) {
                // 可能已经被update了，需要重新比较一次
                self.lightArtUIView = v;
                break;
            }
        }
        if (nil != self.lightArtUIView) {
            [self.lightArtUIView setupWithModel:model];
//            NSLog(@"%@ setup %@", model.index, [model class]);
        } else {
            self.lightArtUIView = [LightArtUIView viewWithModel:model];
//            NSLog(@"%@ create %@", model.index, [model class]);
        }
    }
    [self.lightArtUIView refreshFrameWithParentSize:self.la_size]; // parentSize为单元格的size
    [self.contentView addSubview:self.lightArtUIView];
    
    if (![model isKindOfClass:[LightArtCountdown class]] && ![model isKindOfClass:[LightArtCustomView class]]) {
        // 渲染优化
        self.lightArtUIView.layer.drawsAsynchronously = YES;
        self.lightArtUIView.layer.shouldRasterize = YES;
        self.lightArtUIView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    } else {
        self.lightArtUIView.layer.drawsAsynchronously = NO;
        self.lightArtUIView.layer.shouldRasterize = NO;
    }
}

#if 0
- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    CGRect frame = attributes.frame;
    attributes.frame = frame;
    return attributes;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize {
    CGSize size = [super systemLayoutSizeFittingSize:targetSize];
    return size;
}

- (CGSize)sizeThatFits:(CGSize)targetSize {
    CGSize size = [super sizeThatFits:targetSize];
    size.width = self.lightArtUIView.la_width;
    size.height = self.lightArtUIView.la_height;
    return size;
}
#endif

@end

@interface LightArtSectionListHeaderView : UICollectionReusableView

@property (nonatomic, strong) LightArtUIComponent *model;
@property (nonatomic, strong) LightArtUIView *lightArtUIView;

@end

@implementation LightArtSectionListHeaderView

- (void)setupWithModel:(LightArtUIComponent *)model {
    [self.lightArtUIView removeFromSuperview];
    self.model = model;
    LightArtUIView *lightArtUIView = [LightArtUIView viewWithModel:model];
    self.lightArtUIView = lightArtUIView;
    [self.lightArtUIView refreshFrameWithParentSize:self.la_size];
    [self addSubview:lightArtUIView];
}

@end

@implementation LightArtSectionListView

- (BOOL)setupWithModel:(LightArtSectionList *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    [self reloadData];
    self.collectionView.mj_header = nil; // 必须在此置为nil，让conentInset恢复原值
    self.collectionView.mj_footer = nil; // 同上
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (nil != model.safe_areas) {
        inset = [model.safe_areas insetWithScreenWidth:model.screenWidth];
    }
    self.collectionView.contentInset = inset;
    self.collectionView.scrollIndicatorInsets = inset;
    [self refreshHeader]; // 不能放到reloadData里面，否则下拉刷新触发的reloadData会导致UI异常
    [self refreshFooter]; // 同上
    return YES;
}

- (void)reallyReloadData {
    self.componentSet = [NSMutableSet set];
    int index = 1;
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    for (int i = 0; i < model.sections.count + (nil != model.tail_tab ? 1 : 0); i++) {
        LightArtSection *lightArtSection = nil;
        if (i < model.sections.count) {
            lightArtSection = model.sections[i];
        } else {
            LightArtTailTab *tailTab = model.tail_tab;
            lightArtSection = tailTab.sections[tailTab.segment.selected_index];
            model.load_more.url = lightArtSection.load_more_url;
        }
        for (LightArtUIComponent *component in lightArtSection.components) {
            component.index = [NSString stringWithFormat:@"%i", index];
            index++;
            if (nil != component.component_id) {
                [self.componentSet addObject:component.component_id];
            }
        }
    }
    self.componentCount = index - 1;
    if (0 != model.load_more.preload.length) {
        self.preload = [model.load_more.preload intValue];
    } else {
        self.preload = 0;
    }
    if (nil == self.layout) {
        self.layout = [[LightArtSectionListLayout alloc] init];
    }
    self.layout.sectionList = model;
    if (nil != self.layout.collectionView) {
        [self.layout caculateLayout];
    }
    if (nil == self.collectionView) {
        LightArtCollectionView *collectionView = [[LightArtCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.d = self;
        collectionView.showsVerticalScrollIndicator = YES;
        collectionView.showsHorizontalScrollIndicator = YES;
        [collectionView registerClass:[LightArtSectionListCell class] forCellWithReuseIdentifier:NSStringFromClass([LightArtSectionListCell class])];
        [collectionView registerClass:[LightArtSectionListHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([LightArtSectionListHeaderView class])];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
    }
    [self.collectionView reloadData];
    [self.scrollButton removeFromSuperview];
    if (nil != model.scroll_button) {
        self.scrollButton = [LightArtUIView viewWithModel:model.scroll_button];
        [self addSubview:self.scrollButton];
    }
    [self refreshFrame];
}

- (void)reallyRefreshFrame {
    if (!CGSizeEqualToSize(self.la_size, self.collectionView.la_size)) {
        self.collectionView.la_size = self.la_size;
        // 异步调用，因为reloadData->refreshFrame->isRefreshingFrame->return
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupWithModel:self.model]; // reloadData不会刷新refreshHeader和loadMoreFooter
        });
        return;
    }
    
    self.scrollButton.la_right = self.la_width;
    if (self.collectionView.contentOffset.y >= self.la_height) {
        LightArtSectionList *model = (LightArtSectionList *)self.model;
        UIEdgeInsets inset = UIEdgeInsetsZero;
        if (nil != model.safe_areas) {
            inset = [model.safe_areas insetWithScreenWidth:model.screenWidth];
        }
        self.scrollButton.la_bottom = self.la_height - inset.bottom;
    } else {
        self.scrollButton.la_top = self.la_height;
    }
}

- (void)refreshHeader {
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    if (0 == model.refresh.url.length) {
        self.collectionView.mj_header = nil;
    } else {
        LightArtRefreshHeader *header = (LightArtRefreshHeader *)self.collectionView.mj_header;
        if (model.refresh.view != header.contentComponent) {
            LightArtRefreshHeader *refreshHeader = [[LightArtRefreshHeader alloc] initWithLightArtUIView:self];
            __weak typeof(self) weakSelf = self;
            refreshHeader.refreshingBlock = ^{
                [weakSelf refresh];
            };
            refreshHeader.endRefreshingCompletionBlock = ^{
                [weakSelf refreshHeader];
                [weakSelf refreshFooter];
            };
            self.collectionView.mj_header = refreshHeader;
        }
    }
}

- (void)refreshFooter {
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    if (0 == model.load_more.url.length && model.load_more.hide_when_done) {
        self.collectionView.mj_footer = nil;
    } else {
        LightArtLoadMoreFooter *footer = (LightArtLoadMoreFooter *)self.collectionView.mj_footer;
        if (model.load_more.view != footer.contentComponent) {
            LightArtLoadMoreFooter *loadMoreFooter = [[LightArtLoadMoreFooter alloc] initWithLightArtUIView:self];
            __weak typeof(self) weakSelf = self;
            loadMoreFooter.refreshingBlock = ^{
                [weakSelf loadMore];
            };
            loadMoreFooter.endRefreshingCompletionBlock = ^{
                if (0 == model.load_more.url.length && model.load_more.hide_when_done) {
                    weakSelf.collectionView.mj_footer = nil;
                }
            };
            self.collectionView.mj_footer = loadMoreFooter;
            if (0 == model.load_more.url.length) {
                self.collectionView.mj_footer.state = MJRefreshStateNoMoreData;
            }
        }
    }
}

- (void)didFinishReload {
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtViewDelegate> delegate = lightArtView.delegate;
    if ([delegate respondsToSelector:@selector(lightArtViewDidFinishReload:)]) {
        [delegate lightArtViewDidFinishReload:lightArtView];
    }
}

- (void)didFailReloadWithError:(NSError *)error {
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtViewDelegate> delegate = lightArtView.delegate;
    if ([delegate respondsToSelector:@selector(lightArtView:didFailReloadWithError:)]) {
        [delegate lightArtView:lightArtView didFailReloadWithError:error];
    }
}

- (void)componentDidFinishLoad {
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtViewDelegate> delegate = lightArtView.delegate;
    if ([delegate respondsToSelector:@selector(lightArtView:componentDidFinishLoad:)]) {
        NSString *componentId = self.model.component_id;
        [delegate lightArtView:lightArtView componentDidFinishLoad:componentId];
    }
}

- (void)componentDidFailLoadWithError:(NSError *)error {
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtViewDelegate> delegate = lightArtView.delegate;
    if ([delegate respondsToSelector:@selector(lightArtView:component:didFailLoadWithError:)]) {
        NSString *componentId = self.model.component_id;
        [delegate lightArtView:lightArtView component:componentId didFailLoadWithError:error];
    }
}

- (void)refresh {
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    id <LightArtServiceProtocol> lightArtService = [self.model.lightArtDocument.view lightArtService];
    if (lightArtService && [lightArtService respondsToSelector:@selector(loadDataWithUrl:method:params:headers:succuss:failure:)]) {
        [lightArtService loadDataWithUrl:model.refresh.url method:model.refresh.method params:nil headers:nil succuss:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *template = responseObject[@"template"];
            if (nil == template) {
                template = self.model.originalLightArt;
            }
            id data = responseObject[@"data"];
            if (nil == template || nil == data) {
                [self didFailReloadWithError:nil];
                [self componentDidFailLoadWithError:nil];
                [self.collectionView.mj_header endRefreshing];
                return;
            }
            [self didFinishReload];
            [self componentDidFinishLoad];
            [self.model.lightArtDocument asynParseWithTemplate:template data:data block:^(id result) {
                LightArtSectionList *lightArtSectionList = result;
                
                model.refresh = lightArtSectionList.refresh;
                model.load_more = lightArtSectionList.load_more;
                model.sections = lightArtSectionList.sections;
                for (LightArtSection *lightArtSection in lightArtSectionList.sections) {
                    lightArtSection.header.parent = model;
                    for (LightArtUIComponent *component in lightArtSection.components) {
                        component.parent = model;
                    }
                }
                [self reloadData];
                [self.collectionView.mj_header endRefreshing];
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self didFailReloadWithError:error];
            [self componentDidFailLoadWithError:error];
            [self.collectionView.mj_header endRefreshing];
        }];
    }
}

- (void)loadMore {
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    NSString *url = model.load_more.url;
    if (0 == url.length) return;
    if (self.loadingMore) return;
    self.loadingMore = YES;
    
    NSRange range = [url rangeOfString:@"{{$page_index}}"];
    if (NSNotFound != range.location) {
        url = [url stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%lu", model.currentPageIndex + 1]];
    }
    id <LightArtServiceProtocol> lightArtService = [self.model.lightArtDocument.view lightArtService];
    if (lightArtService && [lightArtService respondsToSelector:@selector(loadDataWithUrl:method:params:headers:succuss:failure:)]) {
        [lightArtService loadDataWithUrl:url method:model.load_more.method params:nil headers:nil succuss:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *template = self.model.originalLightArt;
            id data = responseObject[@"data"];
            if (nil == template || nil == data) {
                [self componentDidFailLoadWithError:nil];
                [self.collectionView.mj_footer endRefreshing];
                self.loadingMore = NO;
                return;
            }
            [self componentDidFinishLoad];
            [self.model.lightArtDocument asynParseWithTemplate:template data:data block:^(id result) {
                LightArtSectionList *lightArtSectionList = result;
                model.load_more = lightArtSectionList.load_more;
                if (nil == model.tail_tab) {
                    NSMutableArray *sections = lightArtSectionList.sections;
                    for (int i = 0; i < sections.count; i++) {
                        LightArtSection *section = sections[i];
                        section.header.parent = model;
                        for (int j = 0; j < section.components.count; j++) {
                            LightArtUIComponent *component = section.components[j];
                            if (nil != component.component_id && [self.componentSet containsObject:component.component_id]) {
                                [section.components removeObjectAtIndex:j];
                                j--;
                                continue;
                            }
                            component.parent = model;
                        }
                        if (0 == section.components.count) {
                            [sections removeObjectAtIndex:i];
                            i--;
                        }
                    }
                    if (0 != model.sections.count && 0 != sections.count) {
                        LightArtSection *lastSection = model.sections.lastObject;
                        LightArtSection *firstSection = sections.firstObject;
                        if ((nil == lastSection.section_id && nil == firstSection.section_id) || [lastSection isEqual:firstSection]) {
                            [lastSection.components addObjectsFromArray:firstSection.components];
                            [sections removeObjectAtIndex:0];
                        }
                    }
                    [model.sections addObjectsFromArray:sections];
                } else {
                    NSUInteger index = model.tail_tab.segment.selected_index;
                    if (index < lightArtSectionList.tail_tab.sections.count) {
                        LightArtSection *section = lightArtSectionList.tail_tab.sections[index];
                        for (int j = 0; j < section.components.count; j++) {
                            LightArtUIComponent *component = section.components[j];
                            if (nil != component.component_id && [self.componentSet containsObject:component.component_id]) {
                                [section.components removeObjectAtIndex:j];
                                j--;
                                continue;
                            }
                            component.parent = model;
                        }
                        LightArtSection *s = model.tail_tab.sections[index];
                        [s.components addObject:section.components];
                    }
                }
                [self reloadData];
                if (0 == model.load_more.url.length) {
                    [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [self.collectionView.mj_footer endRefreshing];
                }
                self.loadingMore = NO;
                model.currentPageIndex++;
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self componentDidFailLoadWithError:error];
            [self.collectionView.mj_footer endRefreshing];
            self.loadingMore = NO;
        }];
    }
}

- (void)scrollTo:(NSDictionary *)params {
    NSString *pos = params[@"pos"];
    NSString *sectionString = params[@"section"];
    NSString *indexString = params[@"index"];
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    if ([@"top" isEqual:pos]) {
        UIEdgeInsets inset = self.collectionView.contentInset;
        [self.collectionView setContentOffset:CGPointMake(0, 0 - inset.top) animated:YES];
    } else if ([@"bottom" isEqual:pos]) {
        LightArtSection *lightArtSection = model.sections.lastObject;
        if (nil != lightArtSection && lightArtSection.components.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(lightArtSection.components.count - 1) inSection:(model.sections.count - 1)];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
    } else if (0 != sectionString.length && 0 != indexString.length) {
        NSInteger row = [indexString integerValue];
        NSInteger section = [sectionString integerValue];
        if (section >= 0 && section < model.sections.count) {
            LightArtSection *lightArtSection = model.sections[section];
            if (row >= 0 && row < lightArtSection.components.count) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    return model.sections.count + (nil != model.tail_tab ? 1 : 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    LightArtSection *lightArtSection = nil;
    if (section < model.sections.count) {
        lightArtSection = model.sections[section];
    } else {
        LightArtTailTab *tailTab = model.tail_tab;
        lightArtSection = tailTab.sections[tailTab.segment.selected_index];
    }
    return lightArtSection.components.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LightArtSectionListCell *cell = (LightArtSectionListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LightArtSectionListCell class]) forIndexPath:indexPath];
    cell.sectionListView = self;
    cell.indexPath = indexPath;
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    LightArtSection *lightArtSection = nil;
    if (indexPath.section < model.sections.count) {
        lightArtSection = model.sections[indexPath.section];
    } else {
        LightArtTailTab *tailTab = model.tail_tab;
        lightArtSection = tailTab.sections[tailTab.segment.selected_index];
    }
    LightArtUIComponent *component = lightArtSection.components[indexPath.row];
    [cell setupWithModel:component];
    if ((self.componentCount - component.index.intValue) < self.preload && 0 != model.load_more.url.length && !self.loadingMore) {
        [self.collectionView.mj_footer beginRefreshing];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqual:UICollectionElementKindSectionHeader]){
        NSString *identifier = NSStringFromClass([LightArtSectionListHeaderView class]);
        LightArtSectionListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier forIndexPath:indexPath];
        LightArtSectionList *model = (LightArtSectionList *)self.model;
        if (indexPath.section < model.sections.count) {
            LightArtSection *lightArtSection = model.sections[indexPath.section];
            [headerView setupWithModel:lightArtSection.header];
        } else {
            LightArtTailTab *tailTab = model.tail_tab;
            [headerView setupWithModel:tailTab.segment];
            if ([headerView.lightArtUIView isKindOfClass:[LightArtSegmentView class]]) {
                [(LightArtSegmentView *)headerView.lightArtUIView setDelegate:self];
            }
        }
        
        reusableView = headerView;
    }
    return reusableView;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    LightArtSection *lightArtSection = nil;
    if (section < model.sections.count) {
        lightArtSection = model.sections[section];
    } else {
        LightArtTailTab *tailTab = model.tail_tab;
        lightArtSection = tailTab.sections[tailTab.segment.selected_index];
    }
    if (nil != lightArtSection.content_insets) {
        return [lightArtSection.content_insets insetWithScreenWidth:model.screenWidth];
    } else {
        return [model.content_insets insetWithScreenWidth:model.screenWidth];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtViewDelegate> delegate = lightArtView.delegate;
    if ([delegate respondsToSelector:@selector(lightArtView:component:scrollViewDidScroll:)]) {
        NSString *componentId = self.model.component_id;
        [delegate lightArtView:lightArtView component:componentId scrollViewDidScroll:scrollView];
    }
    
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    
    if (nil != self.scrollButton && !self.scrollButtonAnimating) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY >= self.la_height && self.scrollButton.la_top >= self.la_height) {
            self.scrollButtonAnimating = YES;
            UIEdgeInsets inset = UIEdgeInsetsZero;
            if (nil != model.safe_areas) {
                inset = [model.safe_areas insetWithScreenWidth:model.screenWidth];
            }
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollButton.la_bottom = self.la_height - inset.bottom;
            } completion:^(BOOL finished) {
                self.scrollButtonAnimating = NO;
            }];
        } else if (offsetY < self.la_height && self.scrollButton.la_top < self.la_height) {
            self.scrollButtonAnimating = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollButton.la_top = self.la_height;
            } completion:^(BOOL finished) {
                self.scrollButtonAnimating = NO;
            }];
        }
    }
    
    if (0 == self.model.component_id.length) {
        return;
    }
    
    // 用于下拉刷新
    Action *action = [[Action alloc] init];
    action.name = @"!emit";
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[@"offset"] = @(scrollView.contentOffset.y);
    options[@"contentInsetTop"] = @(scrollView.contentInset.top);
    action.params = @{@"event": @"did_scroll", @"params": options};
    [self.model.lightArtDocument handleAction:action model:self.model];
    
    action = self.model.actions[@"!scroll"];
    if (nil == action) {
        action = self.model.actions[@"scroll"];
    }
    if (nil != self.collectionView && nil != action) {
        NSArray *visibleCells = [self.collectionView visibleCells];
        LightArtSectionListCell *topCell = nil;
        LightArtSectionListCell *bottomCell = nil;
        for (LightArtSectionListCell *cell in visibleCells) {
            if (nil == topCell || cell.indexPath.section < topCell.indexPath.section || (cell.indexPath.section == topCell.indexPath.section && cell.indexPath.row < topCell.indexPath.row)) {
                topCell = cell;
            }
            if (nil == bottomCell || cell.indexPath.section > bottomCell.indexPath.section || (cell.indexPath.section == bottomCell.indexPath.section && cell.indexPath.row > bottomCell.indexPath.row)) {
                bottomCell = cell;
            }
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if (nil != topCell) {
            params[@"top_index"] = @(topCell.indexPath.row);
            params[@"top_section"] = @(topCell.indexPath.section);
            NSInteger index = topCell.indexPath.section;
            LightArtSection *section = nil;
            if (index < model.sections.count) {
                section = model.sections[index];
            } else {
                LightArtTailTab *tailTab = model.tail_tab;
                section = tailTab.sections[tailTab.segment.selected_index];
            }
            params[@"top_total"] = @(section.components.count);
        }
        if (nil != bottomCell) {
            params[@"bottom_index"] = @(bottomCell.indexPath.row);
            params[@"bottom_section"] = @(bottomCell.indexPath.section);
            NSInteger index = bottomCell.indexPath.section;
            LightArtSection *section = nil;
            if (index < model.sections.count) {
                section = model.sections[index];
            } else {
                LightArtTailTab *tailTab = model.tail_tab;
                section = tailTab.sections[tailTab.segment.selected_index];
            }
            params[@"bottom_total"] = @(section.components.count);
        }
        params[@"offset"] = @(scrollView.contentOffset.y);
        params[@"contentInsetTop"] = @(scrollView.contentInset.top);
        params[@"height"] = @(scrollView.contentSize.height);
        action = [action translateWithArgs:params];
        [self.model.lightArtDocument handleAction:action model:self.model];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    Action *action = [[Action alloc] init];
    action.name = @"!emit";
    action.params = @{@"event": @"begin_drag"};
    [self.model.lightArtDocument handleAction:action model:self.model];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    Action *action = [[Action alloc] init];
    action.name = @"!emit";
    action.params = @{@"event": @"will_end_drag"};
    [self.model.lightArtDocument handleAction:action model:self.model];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    Action *action = [[Action alloc] init];
    action.name = @"!emit";
    action.params = @{@"event": @"end_drag"};
    [self.model.lightArtDocument handleAction:action model:self.model];
}

#pragma mark - LightArtSegmentViewDelegate

- (BOOL)lightArtSegmentView:(LightArtSegmentView *)segmentView shouldSelectIndex:(NSUInteger)index {
    LightArtSectionList *model = (LightArtSectionList *)self.model;
    LightArtTailTab *tailTab = model.tail_tab;
    return index < tailTab.sections.count;
}

- (void)lightArtSegmentView:(LightArtSegmentView *)segmentView didSelectIndex:(NSUInteger)index {
    [self reloadData];
}

#pragma mark - LightArtCollectionViewDelegate

- (BOOL)lightArtCollectionView:(LightArtCollectionView *)collectionView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtViewDelegate> delegate = lightArtView.delegate;
    if ([delegate respondsToSelector:@selector(lightArtView:component:gestureRecognizerShouldBegin:)]) {
        NSString *componentId = self.model.component_id;
        return [delegate lightArtView:lightArtView component:componentId gestureRecognizerShouldBegin:gestureRecognizer];
    } else {
        return YES;
    }
}

@end
