//
//  MOSysAlertView.swift
//  UM-Boss
//
//  Created by 莫瑞伟 on 16/1/15.
//  Copyright © 2016年 teaxus. All rights reserved.
//

import UIKit

class MOAlertView: UIAlertView,UIAlertViewDelegate{

    typealias MOAlertViewClick = (index:Int) -> Void
    var action:MOAlertViewClick?
   
    
    class func showAlertWithTitle(title:String,
        message:String?,
        buttonArrayAsString:Array<String>,finish:(index:Int) -> Void){
        
        let aleV = MOAlertView().initWithTitle(title, message:message, buttonArrayAsString: buttonArrayAsString,isTextField: false)
            aleV.action = {(index:Int)-> Void in
                finish(index: index)
            }
    }
    //MARK:选他人的订单列表
    class func showAlertTextFiledWithTitle(title:String,
        message:String?,
        buttonArrayAsString:Array<String>,finish:(alertView:UIAlertView,index:Int) -> Void){
            
            let aleV = MOAlertView().initWithTitle(title, message:message, buttonArrayAsString: buttonArrayAsString,isTextField: true)
            
            aleV.action = {(index:Int)-> Void in
                finish(alertView: aleV,index: index)
            }
    }
     func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        action!(index: buttonIndex)
        
    }
     func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        
    }
    func initWithTitle(title:String,message:String?,buttonArrayAsString:Array<String>,isTextField:Bool) -> MOAlertView{
        
        let ale = MOAlertView()
        ale.title = title
        ale.message = message
        ale.delegate = ale
        for ButtonWithTitle in buttonArrayAsString{
            ale.addButtonWithTitle(ButtonWithTitle)
        }
        if(isTextField){
            ale.alertViewStyle = UIAlertViewStyle.PlainTextInput
        }
        
        ale.show()
        return ale
        
        }

}
