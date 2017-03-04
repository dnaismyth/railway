//
//  TrainCrossingData.swift
//  railway
//
//  Created by Dayna Naismyth on 2017-03-02.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation

class TrainCrossingData : NSObject{
    
    private var trainCrossingId : Int = -1
    private var notificationCount : Int = 0
    private var isActive : Bool = false
    
    public func getNotificationCount() -> Int {
        return notificationCount
    }
    
    public func setNotificationCount(notificationCount : Int){
        self.notificationCount = notificationCount
    }
    
    public func getIsActive() -> Bool {
        return isActive
    }
    
    public func setIsActive(isActive : Bool){
        self.isActive = isActive
    }
    
    public func getTrainCrossingId() -> Int {
        return trainCrossingId
    }
    
    public func setTrainCrossingId(trainCrossingId : Int){
        self.trainCrossingId = trainCrossingId
    }
    
}
