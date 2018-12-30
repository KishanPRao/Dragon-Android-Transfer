//
//  SessionDiscovery.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let INIT_TIMEOUT = 10.0
//let TIMER_TIMEOUT = 1.0

class SessionDevice {
    let device: AndroidDeviceMac
    var timeout = INIT_TIMEOUT
    
    init(_ device: AndroidDeviceMac) {
        self.device = device
    }
}

class SessionDiscovery: AbstractThread {
    let session: SessionProtocol
    private let port: Int32
    private let clientPort: Int32
    private let bufSize: Int
    private var continueRunning = true
    
    private var busy = false
    private var udpEndPoint : UDPServer? = nil
    fileprivate var observableDevices: Variable<[AndroidDeviceMac]> = Variable([])
    var sessionDevices = [SessionDevice]()
//    var timer: Timer? = nil
    var timer: DispatchSourceTimer!
    
    var hasStarted = false
    
    init(_ session: SessionProtocol) {
        self.session = session
        port = Constants.BcastPort
        clientPort = Constants.BcastListenPort
        bufSize = Constants.DiscoverBufSize
    }
    
    func observeAndroidDevices() -> Observable<[AndroidDeviceMac]> {
        return observableDevices.asObservable()
    }
    
    private func initConnection(_ ip: String) {
        let respClient = UDPClient(address: ip, port: clientPort)
        let response = busy ? Constants.ConnectionResponseErr : Constants.ConnectionResponseSuccess
        /*while (respClient.send(string: response).isFailure) {
         print("Resending, failure conn")
         }*/
        if (respClient.send(string: response).isSuccess) {
            print("initConnection: Response sent:", response)
            if (response == Constants.ConnectionResponseSuccess) {//TODO: Need ACK response after, not direct!
                busy = true
                self.session.performAction(Action.OnConnect())
            }
        } else {
            print("initConnection: Failed")
        }
        respClient.close()
    }
    
    @objc func timerDeviceTimeout() {
        NSLog("timerDeviceTimeout")
        for (i, sDevice) in sessionDevices.enumerated().reversed() {
            sDevice.timeout -= 1.0
            if (sDevice.timeout == 0.0) {
                sessionDevices.remove(at: i)
                var devices = observableDevices.value
                devices = devices.filter() { $0 !== sDevice.device }
                observableDevices.value = devices
            }
        }
    }
    
    override func begin() {
        hasStarted = true
        self.udpEndPoint = UDPServer(address: "0.0.0.0", port: self.port)
        let queue = DispatchQueue.global(qos: .background)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler { [weak self] in
            self?.timerDeviceTimeout()
        }
        timer.schedule(deadline: .now(), repeating: 1.0)
        timer.resume()
    }
    
    func compareAndAddDevice(_ ip: String, _ id: String, _ name: String) {
        print("compareAndAddDevice: \(ip), \(id)")
        for sDevice in sessionDevices {
            let device = sDevice.device
            if ip == device.ipAddr && id == device.id && name == device.name {
                sDevice.timeout = INIT_TIMEOUT
                return
            }
        }
        var devices = observableDevices.value
        let device = AndroidDeviceMac(id: id, name: name, storages: [], ipAddr: ip)
        devices.append(device)
        sessionDevices.append(SessionDevice(device))
        observableDevices.value = devices
    }
    
    override func loop() {
        if let udpEndPoint = self.udpEndPoint, self.continueRunning {
            LogD("Waiting...")
            let (data, remoteIp, remotePort) = udpEndPoint.recv(self.bufSize)
            LogI("Connected:", remoteIp, remotePort)
            if let d = data, let msg = String(bytes: d, encoding: String.Encoding.utf8) {
                print("Got message:", msg)
                if (msg == Constants.ConnectionRequest) {
//                    self.initConnection(remoteIp)
                    let id = "5555da"
                    let name = "Moto G4"
                    compareAndAddDevice(remoteIp, id, name)
                }
            }
        }
    }
    
    func resetDiscovery() {
        print("resetDiscovery")
        busy = false
    }
    
    override func end() {
        print("Stopping Connection")
        self.continueRunning = false
        self.udpEndPoint?.close()   //TODO: Close outside thread?
        self.udpEndPoint = nil
    }
    
    override func quit() {
//        self.udpEndPoint?.close() //better?
        self.cancel()
    }
    
//    func end() {
//        print("Stopping Connection")
//        queue.async(execute: {
//            self.continueRunning = false
//            self.udpEndPoint?.close()
//            self.udpEndPoint = nil
//        })
//    }
}
