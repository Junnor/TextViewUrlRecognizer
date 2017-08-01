//
//  TextView+hashTags.swift
//  TextViewUrlRecognizer
//
//  Created by nyato on 2017/7/26.
//  Copyright © 2017年 nyato. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    func replaceHttpText(with title: String) -> [(text: String, range: NSRange)] {
        //先将字符串按空格和分隔符拆分
        let sentences:[String] = self.text.components(
            separatedBy: CharacterSet.whitespacesAndNewlines)
        var https: [(String, NSRange)] = []
        
        
        for sentence in sentences {
            let nstext = NSString(string: self.text)

            //如果是url 替换为 "网页链接"
            if sentence.contains("http") {
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: sentence, options: [], range: NSRange(location: 0, length: sentence.utf16.count))
                
                for match in matches {
                    let url = (sentence as NSString).substring(with: match.range)
                    
                    
                    let range = nstext.range(of: url)
                    
                    var tp = NSRange()
                    tp.location = range.location + 1
                    tp.length = 4
                    let item = (url, tp)
                    https.append(item)
                    
                    self.text = self.text.replacingOccurrences(of: url, with: title)
                }
            }
        
        }
        
        return https
    }
    
    func ranges(with title: String) -> [String] {
        //先将字符串按空格和分隔符拆分
        let sentences:[String] = self.text.components(
            separatedBy: CharacterSet.whitespacesAndNewlines)
        
        var https: [String] = []
        
        for sentence in sentences {
            //如果是url 替换为 "网页链接"
            if sentence.hasPrefix("http") {
                self.text = self.text.replacingOccurrences(of: sentence, with: title)
                https.append(sentence)
            } else if sentence.contains("http") {
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: sentence, options: [], range: NSRange(location: 0, length: sentence.utf16.count))
                
                for match in matches {
                    let url = (sentence as NSString).substring(with: match.range)
                    self.text = self.text.replacingOccurrences(of: url, with: title)
                    https.append(url)
                }
            }
        }
        
        return https
    }
    
    /**
     转换特殊符号标签字段
     */
    func resolveHashTags(){
        
        let webTitle = " 网页链接 "
        let https = replaceHttpText(with: webTitle)
        
        let nsText:NSString = self.text! as NSString

        // 使用默认设置的字体样式
        let attrs = [NSFontAttributeName : self.font!]
        let attrString = NSMutableAttributedString(string: nsText as String,
                                                   attributes:attrs)
        
        
        
        //用来记录遍历字符串的索引位置
        var bookmark = 0
        //用于拆分的特殊符号
        let charactersSet = CharacterSet(charactersIn: "@#")
        
        //先将字符串按空格和分隔符拆分
        let sentences:[String] = self.text.components(
            separatedBy: CharacterSet.whitespacesAndNewlines)
        
        let linkText: String = "网页链接"
        
        for sentence in sentences {
            //如果是url链接则跳过
            
            
            if !verifyUrl(sentence as String) {
                //再按特殊符号拆分
                let words:[String] = sentence.components(
                    separatedBy: charactersSet)
                var bookmark2 = bookmark
                for i in 0..<words.count{
                    let word = words[i]

                    let keyword = chopOffNonAlphaNumericCharacters(word as String)
                    
                    if linkText == keyword {
                    }
                    
                    if (keyword != "" && i>0) || keyword == linkText {
                        //使用自定义的scheme来表示各种特殊链接，比如：mention:hangge
                        //使得这些字段会变蓝色且可点击
                        
                        //匹配的范围
                        let remainingRangeLength = min((nsText.length - bookmark2 + 1),
                                                       word.characters.count+2)
                        let remainingRange = NSRange(location: bookmark2-1,
                                                     length: remainingRangeLength)
                        
                        //获取转码后的关键字，用于url里的值
                        //（确保链接的正确性，比如url链接直接用中文就会有问题）
                        let encodeKeyword = keyword
                            .addingPercentEncoding(
                                withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                        
                        //匹配@某人
                        var matchRange = nsText.range(of: "@\(keyword)",
                            options: .literal,
                            range:remainingRange)
                        attrString.addAttribute(NSLinkAttributeName,
                                                value: "mention:\(encodeKeyword)",
                            range: matchRange)
                        
                        // 匹配#话题#   not needed
                        matchRange = nsText.range(of: "#\(keyword)#",
                            options: .literal,
                            range:remainingRange)
                        attrString.addAttribute(NSLinkAttributeName,
                                                value: "hash:\(encodeKeyword)",
                            range: matchRange)
                        
                        
                        //匹配http   not needed
                           matchRange = nsText.range(of: webTitle,
                                                  options: .literal,
                                                  range:remainingRange)
                        attrString.addAttribute(NSLinkAttributeName,
                                                value: "http:\(encodeKeyword)",
                            range: matchRange)
                        
                    }
                    //移动坐标索引记录
                    bookmark2 += word.characters.count + 1
                }
            }
            //移动坐标索引记录
            bookmark += sentence.characters.count + 1
        }
        
        
        for i in 0 ..< https.count {
            let http = https[i]
            attrString.setAsLink(textToFindRange: http.range, linkURL: http.text)
        }

        //最终赋值
        self.attributedText = attrString
    }
    
    /**
     验证URL格式是否正确
     */
    fileprivate func verifyUrl(_ str:String) -> Bool {
        // 创建一个正则表达式对象
        do {
            let dataDetector = try NSDataDetector(types:
                NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
            // 匹配字符串，返回结果集
            let res = dataDetector.matches(in: str,
                                           options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                           range: NSMakeRange(0, str.characters.count))
            // 判断结果(完全匹配)
            if res.count == 1  && res[0].range.location == 0
                && res[0].range.length == str.characters.count {
                return true
            }
        }
        catch {
            print(error)
        }
        return false
    }
    
    
    /**
     过滤部多余的非数字和字符的部分
     比如：@hangge.123 -> @hangge
     */
    func chopOffNonAlphaNumericCharacters(_ text:String) -> String {
        let nonAlphaNumericCharacters = CharacterSet.alphanumerics.inverted
        let characterArray = text.components(separatedBy: nonAlphaNumericCharacters)
        return characterArray[0]
    }
}

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind: String, linkURL: String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
    
    public func setAsLink(textToFindRange: NSRange, linkURL:String) {
        self.addAttribute(NSLinkAttributeName, value: linkURL, range: textToFindRange)
    }
}

