//
//  ViewController.swift
//  FirstApp
//
//  Created by 吴正涛 on 2018/1/3.
//  Copyright © 2018年 吴正涛. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //屏幕常数
    let LEFT_AND_RIGHT_MARGIN : CGFloat = 20.0 //左右边距
    let UP_MARGIN : CGFloat = 59.0 //上边距
    let BOTTOM_MARGIN : CGFloat = 30 //下边距
    let SCREEN_WIDTH = UIScreen.main.bounds.width //屏幕宽度
    let SCREEN_HEIGHT = UIScreen.main.bounds.height //屏幕高度
    //数值常数
    let THRESHOLD : Double = 150 //滑动阈值
    let LOCK_THRESHOLD : Double = 1 //手势锁定阈值
    let DURATION :Double = 0.5 //动画播放速度
    //字符串常数
    let MSG_FRONT = "汤姆米切尔提出的机器学习的定义" //卡片前面文本
    let MSG_BACK = "汤姆米切尔提出的机器学习的定义,balabalabalabala" //卡片后面文本
    let KNOW = "知道" //按钮——知道
    let NOT_SURE = "不确定" //按钮——不确定
    let NOT_KNOW = "不知道" //按钮——不知道
    //颜色常数
    let VIEW_BACKGROUND_COLOR : UIColor = #colorLiteral(red: 0.9725001454, green: 0.9764924645, blue: 0.9841788411, alpha: 1)//页面背景色
    let LEFT_BTN_COLOR : UIColor = #colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1)//左边 知道 按钮
    let MIDDLE_BTN_COLOR : UIColor = #colorLiteral(red: 0.8509803922, green: 0.8745098039, blue: 0.8980392157, alpha: 1)//中间 不确定 按钮
    let RIGHT_BTN_COLOR : UIColor = #colorLiteral(red: 1, green: 0.7333333333, blue: 0.3176470588, alpha: 1)//右边 不知道 按钮
    
    var width : CGFloat!
    var height : CGFloat!
    var btnHeight : CGFloat!
    var subWidth : CGFloat!
    
    var lblFront : UILabel!
    var lblBack : UILabel!
    var btn_know : UIButton! = UIButton()
    var btn_notSure : UIButton! = UIButton()
    var btn_notKnow : UIButton! = UIButton()
    
    var lock : Bool!
    var isUp : Bool!
    var isFront : Bool!
    
    var childView : UIView!
    //动作
    var aniTapGesture, aniNewViewGesture, aniAddNewView, aniShowNewView : UIViewPropertyAnimator!
    var aniLeftGesture, aniRightGesture, aniUpGesture : UIViewPropertyAnimator!
    var aniSlideToLeft, aniSlideToUp, aniSlideToRight : UIViewPropertyAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //初始化宽高、界面
        width = SCREEN_WIDTH - self.LEFT_AND_RIGHT_MARGIN * 2
        height = SCREEN_HEIGHT - UP_MARGIN - BOTTOM_MARGIN
        btnHeight = 72
        subWidth = width / 3
        
        //前面的label
        lblFront = lblMaker(message: MSG_FRONT, width: width, height: height)
        
        //后面的label
        lblBack = lblMaker(message: MSG_BACK, width: width, height: height - btnHeight)
        
        //后面下排的按钮
        btn_know.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aniLeft)))
        btn_notSure.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aniUp)))
        btn_notKnow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aniRight)))
        btnInit()
        
        lockInit()
        
        childView = subViewInit()
        showNewView()
        
        view.backgroundColor = VIEW_BACKGROUND_COLOR
    }
    
    func subViewInit() -> UIView {
        let subView = UIView(frame: CGRect(x: LEFT_AND_RIGHT_MARGIN, y: UP_MARGIN, width: width, height: height))
        subView.isUserInteractionEnabled = true
        subView.backgroundColor = UIColor.white
        subView.addSubview(lblFront)
        subView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapView)))
        subView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(swipe)))
        subView.alpha = 0
        view.addSubview(subView)
        isFront = true
        return subView
    }
    
    //新的动作函数
    @objc func aniLeft(gesture: UITapGestureRecognizer) {
        aniLeftGesture.startAnimation()
        aniSlideToLeft.startAnimation()
    }
    @objc func aniRight(gesture: UITapGestureRecognizer) {
        aniRightGesture.startAnimation()
        aniSlideToRight.startAnimation()
    }
    @objc func aniUp(gesture: UITapGestureRecognizer) {
        aniUpGesture.startAnimation()
        aniSlideToUp.startAnimation()
    }
    @objc func tapView(gesture: UITapGestureRecognizer) {
        aniTapGesture.startAnimation()
    }
    
    //手势控制
    @objc func swipe(sender: UIPanGestureRecognizer) {
        if isFront {return}
        let translation : CGPoint = sender.translation(in: childView)
        let delta_x : Double = Double(translation.x)
        let delta_y : Double = Double(translation.y)
        
        var pre : Double!
        
        if !lock {
            checkLock(delta_x: abs(delta_x), delta_y: abs(delta_y))
        }
        if isUp {
            if delta_y < 0 {
                let temp = abs(delta_y) / Double(self.SCREEN_HEIGHT) * 5
                pre = temp > 1.0 ? 1.0 : temp
                childView.transform = CGAffineTransform(translationX: 0, y: translation.y)
                aniUpGesture.fractionComplete = CGFloat(pre)
            }
        } else {
            childView.transform = CGAffineTransform(translationX: translation.x, y: getY(x: delta_x))
            let temp = abs(delta_x) / Double(self.SCREEN_WIDTH) * 5
            pre = temp > 1.0 ? 1.0 : temp
            if delta_x > 0 {
                aniRightGesture.fractionComplete = CGFloat(pre)
            } else {
                aniLeftGesture.fractionComplete = CGFloat(pre)
            }
        }
        if sender.state == UIGestureRecognizerState.ended {
            if isUp && abs(delta_y) > THRESHOLD {
                aniSlideToUp.startAnimation()
            } else if abs(delta_x) > THRESHOLD {
                if delta_x > 0 {
                    aniSlideToRight.startAnimation()
                } else {
                    aniSlideToLeft.startAnimation()
                }
            } else {
                childView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            aniUpGesture.stopAnimation(true)
            aniLeftGesture.stopAnimation(true)
            aniRightGesture.stopAnimation(true)
            lockInit()
            btnInit()
        }
    }
    
    func btnInit() {
        btnSharp(btn: btn_know, title: KNOW, x: 0)
        btnSharp(btn: btn_notSure, title: NOT_SURE, x: subWidth)
        btnSharp(btn: btn_notKnow, title: NOT_KNOW, x: subWidth * 2)
        aniInit()
    }
    
    func btnSharp(btn: UIButton, title : String, x: CGFloat) {
        btn.frame = CGRect(x: x, y: height - btnHeight, width: subWidth, height: btnHeight)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.alpha = 0.5
        btn.isUserInteractionEnabled = true
        btn.backgroundColor = UIColor.white
    }
    
    func checkLock(delta_x: Double,delta_y: Double){
        if delta_x > LOCK_THRESHOLD || delta_y > LOCK_THRESHOLD {
            lock = true
            if delta_x * 2 < delta_y {
                isUp = true
            }else{
                isUp = false
            }
        }
    }
    
    func lockInit() {
        lock = false
        isUp = false
    }
    
    func aniInit() {
        aniTapGesture = UIViewPropertyAnimator(duration: 1, curve: .easeInOut, animations: {
            //页面翻转
            if !self.isFront {return}
            UIView.setAnimationCurve(UIViewAnimationCurve.easeInOut)
            UIView.setAnimationTransition(UIViewAnimationTransition.flipFromRight, for: self.childView, cache: true)
            self.childView.subviews.map({$0.removeFromSuperview()})
            self.btnInit()
            self.childView.addSubview(self.lblBack)
            self.childView.addSubview(self.btn_know)
            self.childView.addSubview(self.btn_notSure)
            self.childView.addSubview(self.btn_notKnow)
            self.isFront = false
        })
        
        aniLeftGesture = UIViewPropertyAnimator(duration: DURATION, curve: .easeInOut, animations: {
            //左滑
            UIView.animate(withDuration: 2, animations: {
                self.btn_know.frame = CGRect(x: 0, y: self.height - self.btnHeight, width: self.width, height: self.btnHeight)
                self.btn_know.alpha = 1
                self.btn_know.backgroundColor = self.LEFT_BTN_COLOR
                self.btn_notSure.alpha = 0
                self.btn_notKnow.alpha = 0
            })
        })
        aniRightGesture = UIViewPropertyAnimator(duration: DURATION, curve: .easeInOut, animations: {
            //右滑
            self.btn_notKnow.frame = CGRect(x: 0, y: self.height - self.btnHeight, width: self.width, height: self.btnHeight)
            self.btn_notKnow.alpha = 1
            self.btn_notKnow.backgroundColor = self.MIDDLE_BTN_COLOR
            self.btn_know.alpha = 0
            self.btn_notSure.alpha = 0
        })
        
        aniUpGesture = UIViewPropertyAnimator(duration: DURATION, curve: .linear, animations: {
            //上滑
            self.btn_notSure.frame = CGRect(x: 0, y: self.height - self.btnHeight, width: self.width, height: self.btnHeight)
            self.btn_notSure.alpha = 1
            self.btn_notSure.backgroundColor = self.RIGHT_BTN_COLOR
            self.btn_know.alpha = 0
            self.btn_notKnow.alpha = 0
        })
        
        aniSlideToRight = UIViewPropertyAnimator(duration: DURATION, curve: .easeInOut, animations: {
            //滑向右边
            self.childView.transform = CGAffineTransform(translationX: self.SCREEN_WIDTH, y: self.getY(x: Double(self.SCREEN_WIDTH)))
            self.aniAddNewView.startAnimation(afterDelay: self.DURATION)
            self.aniShowNewView.startAnimation(afterDelay: self.DURATION)
        })
        
        aniSlideToUp = UIViewPropertyAnimator(duration: DURATION, curve: .easeInOut, animations: {
            //滑向上
            self.childView.transform = CGAffineTransform(translationX: 0, y: -self.SCREEN_HEIGHT)
            self.aniAddNewView.startAnimation(afterDelay: self.DURATION)
            self.aniShowNewView.startAnimation(afterDelay: self.DURATION)
        })
        
        aniSlideToLeft = UIViewPropertyAnimator(duration: DURATION, curve: .easeInOut, animations: {
            //滑向左边
            self.childView.transform = CGAffineTransform(translationX: -self.SCREEN_WIDTH, y: self.getY(x: Double(self.SCREEN_WIDTH)))
            self.aniAddNewView.startAnimation(afterDelay: self.DURATION)
            self.aniShowNewView.startAnimation(afterDelay: self.DURATION)
        })
        
        aniAddNewView = UIViewPropertyAnimator(duration: DURATION, curve: .linear, animations: {
            self.childView = self.subViewInit()
        })
        
        aniShowNewView = UIViewPropertyAnimator(duration: DURATION, curve: .linear, animations: {
            self.showNewView()
        })
    }
    
    func showNewView() {
        self.childView.alpha = 1
    }
    
    fileprivate func  getY(x: Double) -> CGFloat {
        let temp : Double = Double(width)
        return CGFloat(sqrt(pow(7.21 * temp, 2) - x * x) - 7.12 * temp) - BOTTOM_MARGIN
    }
    
    fileprivate func lblMaker(message: String, width: CGFloat, height: CGFloat) -> UILabel {
        //建立一个label
        let lblTemp = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        lblTemp.text = message
        lblTemp.backgroundColor = UIColor.white
        return lblTemp
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}