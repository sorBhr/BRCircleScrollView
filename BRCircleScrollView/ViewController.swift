//
//  ViewController.swift
//  BRCircleScrollView
//
//  Created by 白海瑞 on 16/7/4.
//  Copyright © 2016年 白海瑞. All rights reserved.
//

import UIKit
public let AppWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
public let AppHeight: CGFloat = UIScreen.mainScreen().bounds.size.height

class ViewController: UIViewController {
    var scroll :BRScrollViewPage!
    override func viewDidLoad() {
        super.viewDidLoad()
        //网络图片
        scroll = BRScrollViewPage(NetWorkImages: ["http://c.hiphotos.baidu.com/image/pic/item/eac4b74543a98226e523cd238882b9014b90ebd0.jpg","http://f.hiphotos.baidu.com/image/pic/item/b151f8198618367ac7d2a1e92b738bd4b31ce5af.jpg","http://c.hiphotos.baidu.com/image/pic/item/eac4b74543a98226e523cd238882b9014b90ebd0.jpg","http://f.hiphotos.baidu.com/image/pic/item/b151f8198618367ac7d2a1e92b738bd4b31ce5af.jpg"], frame: CGRect(x: 30, y: 100, width: AppWidth - 60 , height: (AppWidth - 60) * 467 / 700), placeholderImage: "banner01")
        //本地图片
//        scroll = BRScrollViewPage(NetWorkImages : ["banner01","banner02","banner03","banner04"], frame: CGRect(x: 30, y: 100, width: AppWidth - 60 , height: 200),placeholderImage:nil)
        scroll.delegate = self
        scroll.pageStyle = .right
//        scroll.timeSpace  时间间隔
//        scroll.currentPageIndicatorTintColor
//        scroll.pageIndicatorTintColor
        view.addSubview(scroll)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        //释放定时器
        scroll.timer?.invalidate()
    }


}
// MARK: - 代理方法
extension ViewController:BRScrollViewPageDelegate{
    func didSelectAtIndex(index: NSInteger) {
        print("点击了第\(index)张图片")
    }
}


