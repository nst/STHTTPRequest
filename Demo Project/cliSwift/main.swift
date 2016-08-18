//
//  main.swift
//  cliSwift
//
//  Created by nst on 18/08/16.
//  Copyright © 2016 Nicolas Seriot. All rights reserved.
//

import Foundation

autoreleasepool {

    let r = STHTTPRequest(URLString:"http://www.perdu.com")
    
    r.completionBlock = { (headers, body) in
        print(headers)
        print(body)
    }
    
    r.errorBlock = { (error) in
        print(error)
    }
    
    r.startAsynchronous()
    
    NSRunLoop.currentRunLoop().run()
}
