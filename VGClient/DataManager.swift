//
//  DataManager.swift
//  VGClient
//
//  Created by jie on 2017/3/11.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

func randomNumber(from: Int, to: Int) -> Int {
    guard from < to else {
        return 0
    }
    var a: UInt32 = 0
    arc4random_buf(&a, MemoryLayout<UInt32>.size)

    let index = (a % UInt32(to - from)) + UInt32(from)
    return Int(index)
}

class DataManager: NSObject {

    static let `default` = DataManager()

    private override init() {
        super.init()

        fake_data = [fake_measurementData(), fake_charData(), fake_accessoryData()]
    }

    ///

    func fake_accessoryData() -> [AccessorySection] {

        return [
            [
                AccessoryData(type: .rollingMachine, state: .opened),
                AccessoryData(type: .wateringPump, state: .opened)
            ],
            [
                AccessoryData(type: .fillLight, state: .opened),
                AccessoryData(type: .warmingLamp, state: .opened),
                AccessoryData(type: .ventilator, state: .opened)
            ]
        ]
    }

    func fake_measurementData() -> [MeasurementData] {

        return [
            MeasurementData(itemType: .airTemperature, value: 25, updateDate: "02/10 10:23"),
            MeasurementData(itemType: .airHumidity, value: 75.5, updateDate: "02/10 11:34"),
            MeasurementData(itemType: .soilTemperature, value: 22, updateDate: "02/10 08:23"),
            MeasurementData(itemType: .soilHumidity, value: 84.3, updateDate: "02/10 09:41"),
            MeasurementData(itemType: .lightIntensity, value: 16.0, updateDate: "02/10 12:35"),
            MeasurementData(itemType: .co2Concentration, value: 668.3, updateDate: "02/10 13:52")
        ]
    }

    func fake_charData() -> [MeasurementCurveData] {

        return [
            MeasurementCurveData(type: .airTemperature,
                                 fromDate: "02/03 08:00",
                                 toDate: "02/10 08:00",
                                 columns: [
                                    LineColumn(value: 20, prompt: "02/03"),
                                    LineColumn(value: 22, prompt: "02/04"),
                                    LineColumn(value: 22, prompt: "02/05"),
                                    LineColumn(value: 24, prompt: "02/06"),
                                    LineColumn(value: 25, prompt: "02/07"),
                                    LineColumn(value: 24, prompt: "02/08"),
                                    LineColumn(value: 25, prompt: "02/09"),
                                    LineColumn(value: 19, prompt: "02/10")]),
            MeasurementCurveData(type: .airHumidity,
                                 fromDate: "02/03 08:00",
                                 toDate: "02/10 08:00",
                                 columns: [
                                    LineColumn(value: 50, prompt: "02/03"),
                                    LineColumn(value: 35, prompt: "02/04"),
                                    LineColumn(value: 31, prompt: "02/05"),
                                    LineColumn(value: 93, prompt: "02/06"),
                                    LineColumn(value: 86, prompt: "02/07"),
                                    LineColumn(value: 74, prompt: "02/08"),
                                    LineColumn(value: 86, prompt: "02/09"),
                                    LineColumn(value: 69, prompt: "02/10")]),
            MeasurementCurveData(type: .soilTemperature,
                                 fromDate: "02/03 08:00",
                                 toDate: "02/10 08:00",
                                 columns: [
                                    LineColumn(value: 18, prompt: "02/03"),
                                    LineColumn(value: 19, prompt: "02/04"),
                                    LineColumn(value: 22, prompt: "02/05"),
                                    LineColumn(value: 15, prompt: "02/06"),
                                    LineColumn(value: 18.6, prompt: "02/07"),
                                    LineColumn(value: 20, prompt: "02/08"),
                                    LineColumn(value: 16.5, prompt: "02/09"),
                                    LineColumn(value: 21.5, prompt: "02/10")]),
            MeasurementCurveData(type: .soilHumidity,
                                 fromDate: "02/03 08:00",
                                 toDate: "02/10 08:00",
                                 columns: [
                                    LineColumn(value: 65, prompt: "02/03"),
                                    LineColumn(value: 54, prompt: "02/04"),
                                    LineColumn(value: 47, prompt: "02/05"),
                                    LineColumn(value: 98, prompt: "02/06"),
                                    LineColumn(value: 89, prompt: "02/07"),
                                    LineColumn(value: 79, prompt: "02/08"),
                                    LineColumn(value: 92, prompt: "02/09"),
                                    LineColumn(value: 76, prompt: "02/10")]),
            MeasurementCurveData(type: .lightIntensity,
                                 fromDate: "02/03 08:00",
                                 toDate: "02/10 08:00",
                                 columns: [
                                    LineColumn(value: 14.6, prompt: "02/03"),
                                    LineColumn(value: 15.8, prompt: "02/04"),
                                    LineColumn(value: 18.3, prompt: "02/05"),
                                    LineColumn(value: 22.4, prompt: "02/06"),
                                    LineColumn(value: 25.6, prompt: "02/07"),
                                    LineColumn(value: 19.8, prompt: "02/08"),
                                    LineColumn(value: 24.9, prompt: "02/09"),
                                    LineColumn(value: 19.4, prompt: "02/10")]),
            MeasurementCurveData(type: .co2Concentration,
                                 fromDate: "02/03 08:00",
                                 toDate: "02/10 08:00",
                                 columns: [
                                    LineColumn(value: 668.3, prompt: "02/03"),
                                    LineColumn(value: 658.3, prompt: "02/04"),
                                    LineColumn(value: 598.6, prompt: "02/05"),
                                    LineColumn(value: 630.3, prompt: "02/06"),
                                    LineColumn(value: 589, prompt: "02/07"),
                                    LineColumn(value: 630, prompt: "02/08"),
                                    LineColumn(value: 593, prompt: "02/09"),
                                    LineColumn(value: 624, prompt: "02/10")])
        ]
    }

    var fake_data: [Any] = []
}
