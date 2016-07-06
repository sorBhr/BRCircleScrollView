//
//  BRScrollViewPage.swift
//  NetWorkFramework
//
//  Created by 白海瑞 on 16/6/21.
//  Copyright © 2016年 白海瑞. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
//常量

let DefineTimeSpace:NSTimeInterval = 5
let pageViewOffSet = 10


/// 协议
@objc public protocol BRScrollViewPageDelegate: class {
    optional func didSelectAtIndex(index:NSInteger)
}

/**
 pageView 位置
 
 - left:   左边
 - center: 中间
 - right:  右边
 */
public enum BRScrollViewPageStyle:Int {
    case left
    case center
    case right
    
}



public class BRScrollViewPage: UIView ,UIScrollViewDelegate {
    /// 懒加载
    private lazy var scrollView:UIScrollView = {
       return UIScrollView()
    }()
    
    private lazy var leftImageView:UIImageView = {
       return UIImageView()
    }()
    
    private lazy var centerImageView:UIImageView = {
       return UIImageView()
    }()
    
    private lazy var rightImageView:UIImageView = {
        return UIImageView()
    }()
    
    private lazy var pageView:UIPageControl = {
       return UIPageControl()
    }()
    typealias block = ()->Void
    
    var BlockWith:block?
    
    
    ///pageView样式
    public var pageStyle:BRScrollViewPageStyle = .center {
        willSet{
            print("newValue = \(newValue)")
        }
        didSet{
            print("oldValue = \(oldValue) newValue = \(pageStyle)")
            switch pageStyle {
            case .left: pageView.snp_remakeConstraints(closure: { [unowned self](make) in
                make.left.equalTo(self.scrollView).offset(pageViewOffSet)
                make.size.equalTo(self.pageSize)
                make.bottom.equalTo(self).offset(-pageViewOffSet)
                });break
            case .right: pageView.snp_remakeConstraints(closure: { [unowned self](make) in
                make.right.equalTo(self.scrollView).offset(-pageViewOffSet)
                make.size.equalTo(self.pageSize)
                make.bottom.equalTo(self).offset(-pageViewOffSet)
            });  break
            default: pageView.snp_makeConstraints {[unowned self] (make) in
                    make.centerX.equalTo(self)
                    make.size.equalTo(self.pageSize)
                    make.bottom.equalTo(self).offset(-pageViewOffSet)
                };break
            }

        }
    }
    //占位图
    private var placeholderImage:String?
    
    private var isLocal:Bool = false
    ///pageView  size
    private var pageSize:CGSize = CGSizeZero
    ///pageView currentPageIndicatorTintColor
    public var currentPageIndicatorTintColor:UIColor = UIColor.greenColor() {
        didSet{
            pageView.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
    ///pageView pageIndicatorTintColor
    public var pageIndicatorTintColor:UIColor = UIColor.grayColor() {
        didSet{
            pageView.pageIndicatorTintColor = pageIndicatorTintColor
        }
    }
    /// 本地图片数组
    @objc private var imageArray:NSArray?
    /// 定时器
    public var timer:NSTimer?
    ///定时器间隔
    public var timeSpace:NSTimeInterval = DefineTimeSpace {
        didSet{
            timer?.invalidate()
            addTimer()
        }
    }
    /// 图片总数
    private var count:NSInteger = 0
    //代理
    public weak var delegate:BRScrollViewPageDelegate?
    //当前页面Index
    private var currentImageIndex:NSInteger = 0
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //init UI
    private func set_up(){
        
        addScrollView()
        addImageView()
        addPageView()
        reloadImage()
        guard count < 2 else{
            addTimer()
            return
        }
        scrollView.scrollEnabled = false

    }
    /**
     本地图片初始化方法
     - parameter images: 本地图片数组
     - parameter frame:  坐标
     */
    public init(localImages images:NSArray ,frame:CGRect ,placeholderImage:String?){
        self.placeholderImage = placeholderImage
        imageArray = images
        isLocal = true
        super.init(frame:frame)
        guard let _ = imageArray else {
            return
        }
        set_up()
    }
    /**
     网络图片构造方法
     - parameter images: 网络图片数组
     - parameter frame:  坐标
     */
    public init(NetWorkImages images:NSArray , frame:CGRect ,placeholderImage:String?){
        self.placeholderImage = placeholderImage
        imageArray = images
        super.init(frame:frame)
        guard let _ = imageArray else {
            return
        }
        set_up()
    }
    /**
     添加scrollView
     */
    private func addScrollView(){
        self.addSubview(self.scrollView)
        scrollView.frame = CGRect(x: 0, y: 0, width:self.frame.width , height: self.frame.height)
        scrollView.contentSize = CGSizeMake(self.frame.width * 3, self.frame.height)
        scrollView.delegate = self
        scrollView.setContentOffset(CGPoint(x: self.frame.width,y: 0), animated: false)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
    }
    /**
     *  添加的三个ImageView
     */
    private func addImageView(){
        scrollView.addSubview(self.leftImageView)
        scrollView.addSubview(self.rightImageView)
        scrollView.addSubview(self.centerImageView)
        self.leftImageView.contentMode = .ScaleToFill
        self.rightImageView.contentMode = .ScaleToFill
        self.centerImageView.contentMode = .ScaleToFill
        
        let tap:UITapGestureRecognizer  =  UITapGestureRecognizer(target: self, action: #selector(clickIndex))
        leftImageView.addGestureRecognizer(tap)
        rightImageView.addGestureRecognizer(tap)
        centerImageView.addGestureRecognizer(tap)
        leftImageView.userInteractionEnabled = true
        centerImageView.userInteractionEnabled = true
        rightImageView.userInteractionEnabled = true
        leftImageView.snp_makeConstraints {[unowned self] (make) in
            make.left.equalTo(self.scrollView)
            make.height.equalTo(self.scrollView)
            make.width.equalTo(self.frame.width)
            make.top.equalTo(self.scrollView)
        }
        leftImageView.contentMode = .ScaleAspectFit
        centerImageView.snp_makeConstraints {[unowned self] (make) in
            make.left.equalTo(self.scrollView).offset(self.frame.width)
            make.height.equalTo(self.scrollView)
            make.width.equalTo(self.frame.width)
            make.top.equalTo(self.scrollView)
        }
        centerImageView.contentMode = .ScaleAspectFit
        rightImageView.snp_makeConstraints {[unowned self] (make) in
            make.left.equalTo(self.scrollView).offset(self.frame.width * 2)
            make.height.equalTo(self.scrollView)
            make.width.equalTo(self.frame.width)
            make.top.equalTo(self.scrollView)
        }
        rightImageView.contentMode = .ScaleAspectFit
    }
    /**
     添加分页控件
     */
    private func addPageView() {
        guard let array = imageArray else{
            return
        }
        count = array.count
        self.addSubview(self.pageView)
        pageView.currentPage = currentImageIndex
        pageView.numberOfPages = array.count
        pageSize = pageView.sizeForNumberOfPages(array.count)
        pageView.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        pageView.pageIndicatorTintColor = pageIndicatorTintColor
        pageView.snp_makeConstraints { [unowned self](make) in
            make.centerX.equalTo(self)
            make.size.equalTo(self.pageSize)
            make.bottom.equalTo(self).offset(-pageViewOffSet)
        }
        //MARK: - 关掉pageView的交互性
        pageView.userInteractionEnabled = false
    }
     /**
     重新刷新图片
     */
    private func reloadImage(){
        var leftImageIndex,rightImageIndex:NSInteger
        
        let offset:CGPoint = scrollView.contentOffset
        
        if offset.x > self.frame.width {//向右滑动
            currentImageIndex = (currentImageIndex + 1)%count
        }else if(offset.x < self.frame.width){//向左滑动
            currentImageIndex = (currentImageIndex - 1 + count)%count
        }
        leftImageIndex = (currentImageIndex - 1 + count)%count
        rightImageIndex = (currentImageIndex + 1)%count
        
            guard isLocal else{
                //加载网络图片
               // print(imageArray?[currentImageIndex]);
                centerImageView.kf_setImageWithURL(NSURL(string: (imageArray?[currentImageIndex] as? String ?? "")!)!,placeholderImage: UIImage(named: placeholderImage ?? ""))
                leftImageView.kf_setImageWithURL(NSURL(string: (imageArray?[leftImageIndex] as? String ?? "")!)!,placeholderImage: UIImage(named: placeholderImage ?? ""))
                rightImageView.kf_setImageWithURL(NSURL(string: (imageArray?[rightImageIndex] as? String ?? "")!)!,placeholderImage: UIImage(named: placeholderImage ?? ""))
                return
            }
            //加载本地图片
            centerImageView.image = UIImage(named: imageArray?[currentImageIndex] as? String ?? "")
            leftImageView.image = UIImage(named: imageArray?[leftImageIndex] as? String ?? "")
            rightImageView.image = UIImage(named: imageArray?[rightImageIndex] as? String ?? "")
        
    }
    /**
     添加定时器
     */
    private func addTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(timeSpace, target: self, selector: #selector(timerClick), userInfo: nil, repeats: true)
    }
    @objc private func timerClick(){
      UIView.animateWithDuration(0.5, animations: {[unowned self] in
        self.scrollView.contentOffset = CGPoint(x: self.frame.width * 2, y: 0)
        }) {[unowned self] (success) in
            guard success else{
                return
            }
            self.reloadImage()
            self.scrollView.setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
            self.pageView.currentPage = self.currentImageIndex
        }
    }
    /**
     代理回调
     */
      @objc private func clickIndex(){
        BlockWith?()
        self.delegate?.didSelectAtIndex?(currentImageIndex)
    }
    /**
     析构函数
     */
    deinit {
        timer?.invalidate()
    }
}
// MARK: - scrollview Delegate
extension BRScrollViewPage{
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        reloadImage()
        scrollView.setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
        pageView.currentPage = currentImageIndex
    }
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        timer?.invalidate()
    }
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
    }
}

