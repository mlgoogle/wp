//
//  APISocketHelper.swift
//  viossvc
//
//  Created by yaowang on 2016/11/21.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
//import XCGLogger
import SVProgressHUD
class APISocketHelper:NSObject, GCDAsyncSocketDelegate {
    var socket: GCDAsyncSocket?;
    var dispatch_queue: DispatchQueue!;
    var mutableData: NSMutableData = NSMutableData();

    var isConnected : Bool {
        return socket!.isConnected
    }
    override init() {
        super.init()
        dispatch_queue = DispatchQueue(label: "APISocket_Queue", attributes: DispatchQueue.Attributes.concurrent)
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: dispatch_queue);
//        connect()
    }

    func connect() {
        mutableData = NSMutableData()
        do {
            if !socket!.isConnected {
                try socket?.connect(toHost: AppConst.Network.TcpServerIP, onPort: AppConst.Network.TcpServerPort, withTimeout: 5)
            }
        } catch GCDAsyncSocketError.closedError {

        } catch GCDAsyncSocketError.connectTimeoutError {

        } catch {

        }
    }
    
    func disconnect() {
        socket?.delegate = nil;
        socket?.disconnect()
    }
    
    func sendData(_ data: Data) {
        objc_sync_enter(self)
        socket?.write(data, withTimeout: -1, tag: 0)
        objc_sync_exit(self)
    }


    func onPacketData(_ data: Data) {
   
        let packet: SocketDataPacket = SocketDataPacket(socketData: data as NSData)
        SocketRequestManage.shared.notifyResponsePacket(packet)
//        XCGLogger.debug("onPacketData:\(packet.packetHead.type) \(packet.packetHead.packet_length) \(packet.packetHead.operate_code)")
    }

    //MARK: GCDAsyncSocketDelegate
    @objc func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
//        XCGLogger.debug("didConnectToHost:\(host)  \(port)")
        sock.perform({
            () -> Void in
            sock.enableBackgroundingOnSocket()
        });
        socket?.readData(withTimeout: -1, tag: 0)
    }

    @objc func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: CLong) {
//        XCGLogger.debug("socket:\(data)")
        mutableData.append(data)
        while mutableData.length > 2 {
            var packetLen: Int16 = 0;
            mutableData.getBytes(&packetLen, length: MemoryLayout<Int16>.size)
            if mutableData.length >= Int(packetLen) {
                var range: NSRange = NSMakeRange(0, Int(packetLen))
                onPacketData(mutableData.subdata(with: range))
                range.location = range.length;
                range.length = mutableData.length - range.location;
                mutableData = (mutableData.subdata(with: range) as NSData).mutableCopy() as! NSMutableData;
            } else {
                break
            }
        }
        socket?.readData(withTimeout: -1, tag: 0)
        
    }

    @objc func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: CLong, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return 0
    }

    @objc func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: CLong, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return 0
    }

    @objc func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
//        XCGLogger.error("socketDidDisconnect:\(err)")
//        self.performSelector(#selector(APISocketHelper.connect), withObject: nil, afterDelay: 5)
//        SVProgressHUD.showErrorMessage(ErrorMessage: "连接失败，5秒后重连", ForDuration: 5) {[weak self] in
//            self?.connect()
//        }
    }

    deinit {
        socket?.disconnect()
    }
}
