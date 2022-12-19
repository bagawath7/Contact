//
//  ContactModels.swift

import UIKit
import CoreData
enum contact
{
  // MARK: Use cases
  

    struct Request
    {
        let contacts:[NSManagedObject]
        
    }
    struct Response
    {
    }
    struct ViewModel
    {
        var fullname:String?
        var mobileNumber:String?
        

    }
  }

