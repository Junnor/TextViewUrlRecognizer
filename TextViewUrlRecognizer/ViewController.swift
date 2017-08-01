//
//  ViewController.swift
//  TextViewUrlRecognizer
//
//  Created by nyato on 2017/7/26.
//  Copyright © 2017年 nyato. All rights reserved.
//

import UIKit

var httpsText = ""

class ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
            containerView.addGestureRecognizer(tap)
        }
    }
    
    let text = "@nwulala 就开始发神经咖啡馆开发工具发感慨时光 https://www.bing.com 是否接受罚款是否好看 #willain# 使科技部方式开发包括部分.将房间分隔 #喵特# 使肌肤"
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.text = text
            textView.delegate = self
            textView.resolveHashTags()
        }
    }
    
    @objc private func tapGesture(_ gesture: UITapGestureRecognizer) {
        hashText = "is container view"
        performSegue(withIdentifier: "see hash", sender: nil)
    }
    
    private var hashText = ""
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        print("URL.scheme: \(URL.scheme ?? "nil")")
        
        if !(URL.scheme?.hasPrefix("http"))! {
            hashText = URL.scheme!
            performSegue(withIdentifier: "see hash", sender: nil)
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "see hash" {
             let vc = segue.destination as! DetailViewController
            vc.title = hashText
        }
    }
}


