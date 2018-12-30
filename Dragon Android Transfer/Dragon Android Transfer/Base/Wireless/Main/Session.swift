//
//  Session.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class Session: SessionProtocol {
    static let shared = Session()
    func connectionEstablishing() {
        DispatchQueue.main.async {
            self.callback?.onConnecting()
        }
    }
    
    func connectionEstablished() {
//        DispatchQueue.main.async {
//            self.callback?.onConnected()
//        }
    }
    
    let stateRef = AtomicReference<ConnectionState>(initialValue: Disconnected())
    var state: ConnectionState {
        get {
            return stateRef.value
        }
    }
    var discovery: SessionDiscovery! = nil  //wtf?
    var handler: SessionHandler? = nil
    var callback: UiCallback? = nil
    
    required init() {
        discovery = SessionDiscovery(self)
    }
    
    func onNewConnection(_ data: ConnectionData) {
        handler = SessionHandler(self)
        handler?.start()
    }
    
    func onDisconnection() {
    }
    
    func connectionTerminated(_ code: Int) {
        print("connectionTerminated: \(code)")
        if (code != Constants.ConnectionTermOk) {
            performAction(Action.OnFailure(code))
        } else {
            performAction(Action.OnDisconnect())
        }
    }
    
    func transferTotalSize(_ size: UInt64) {
        DispatchQueue.main.async {
            self.callback?.onTransferSize(size)
        }
    }
    
    func transferProgress(_ file: String, _ size: UInt64) {
        DispatchQueue.main.async {
            self.callback?.onTransferProgress(file, size)
        }
    }
    
    func onChangeState(_ oldState: ConnectionState, _ newState: ConnectionState) {
        print("onChangeState, \(oldState) => \(newState)")
        if oldState is Disconnected && newState is Connected {
            onNewConnection((newState as! Connected).data)
        } else if oldState is Operation && newState is Connected {
//            proper completion
            onOperationCompleted()
        } else if oldState === newState {
            print("WARN: Same state")
            return
        }
        
        /* else if oldState is Connected && newState is Disconnected {
            onDisconnection()
        }*/
//            else {
            switch newState {
            case is Connected:
                onConnected()
                break
            case is Disconnected:
                onDisconnected()
                break
            case is Failed:
                if let failed = newState as? Failed {
                    onFailed(failed.data)
                }
                break
            case is Operation:
                if let op = newState as? Operation {
                    onOperation(op.data.operation)
                }
                break
            default: break
            }
//        }
    }
    
    func onConnected() {
        DispatchQueue.main.async {
            self.callback?.onConnected()
        }
    }
    
    func onDisconnected() {
        handler?.stop()
        discovery.resetDiscovery()
        DispatchQueue.main.async {
            self.callback?.onDisconnected()
        }
    }
    
    func onFailed(_ data: ConnectionData) {
        //TODO handle failure.
        DispatchQueue.main.async {
            self.callback?.onFailure(data.connectionStatus)
        }
        performAction(Action.OnFailureHandled())
    }
    
    func onOperation(_ op: OperationData) {
        switch op.name {
        case CommCommand.List:
            handler?.sendListRequest(op.src)
            break
        case CommCommand.Pull:
            handler?.pull(op.src, op.dest)
            break
        case CommCommand.Push:
            handler?.push(op.src, op.dest)
            break
        default:
            break
        }
        DispatchQueue.main.async {
            self.callback?.onTransferBegin()
        }
    }
    
    func onOperationCompleted() {
        DispatchQueue.main.async {
            self.callback?.onTransferEnd()
        }
    }
    
    func listDirectory(_ path: String) {
        //        TODO: Check state.
        let opData = OperationData()
        opData.name = CommCommand.List
        opData.src = path
        performAction(Action.OnOperation(opData))
    }
    
    func download(_ src: String, _ dest: String) {
        //        TODO: Check state.
        let opData = OperationData()
        opData.name = CommCommand.Pull
        opData.src = src
        opData.dest = dest
        performAction(Action.OnOperation(opData))
    }
    
    func upload(_ src: String, _ dest: String) {
        //        TODO: Check state.
        let opData = OperationData()
        opData.name = CommCommand.Push
        opData.src = src
        opData.dest = dest
        performAction(Action.OnOperation(opData))
    }
    
    func cancel() {
        handler?.cancelOperation()
    }
    
    func begin() {
        if !discovery.hasStarted {
            discovery.start()
        }
    }
    
    func performAction(_ action: Action) {
        let oldState = state
        var newState = oldState
        synchronized(self) {
            newState = oldState.performAction(action)
            _ = stateRef.getAndSet(newValue: newState)
        }
        if (oldState === oldState) {
            onChangeState(oldState, newState)
        }
    }
    
    func getCurrentState() -> ConnectionState {
        return state
    }
}
