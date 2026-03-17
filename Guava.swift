//
//  Guava.swift
//  Guava
//
//  Created by Jarrod Norwell on 4/9/2025.
//

import Foundation

struct GuavaCommon {
    static let height: Int = 240
    static let width: Int = 256
}

public actor Guava {
    public let emulator: Nes = Nes()
    
    var audiobuffer: [Float32] = Array(repeating: 0, count: 735)
    var videobuffer: [UInt8] = Array(repeating: 0, count: 256 * 240 * 4)
    
    var _paused: Bool = false,
        _running: Bool = false
        
    
    public init() {}
    
    public func insert(cartridge: URL) throws {
        audiobuffer.fill(with: 0)
        videobuffer.fill(with: 0)
        guard let data: NSData = NSData(contentsOf: cartridge) else {
            return
        }
        
        var bytes: [Byte] = Array(repeating: 0, count: data.length)
        data.getBytes(&bytes, length: data.length)
        
        try emulator.loadRom(rom: bytes)
    }
    
    
    public func pause() {
        paused = true
    }
    
    public func start() {
        running = true
    }
    
    public func step() {
        if paused {
            return
        }
        
        emulator.runFrame()
    }
    
    public func stop() {
        pause()
        emulator.unloadRom()
        unpause()
        
        running = false
    }
    
    public func unpause() {
        paused = false
    }
    
    
    public var paused: Bool {
        get {
            _paused
        }
        set {
            _paused = newValue
        }
    }
    
    public var running: Bool {
        get {
            _running
        }
        set {
            _running = newValue
        }
    }
    
    
    public func press(button: UInt32) {
        emulator.setButtonPressed(pad: 0, button: Int(button))
    }
    
    public func release(button: UInt32) {
        emulator.setButtonReleased(pad: 0, button: Int(button))
    }
    
    
    public func load(state: URL) {
        // emulator.load(state: state)
    }
    
    public func save(state: URL) {
        // emulator.save(state: state)
    }
    
    
    public var state: [UInt8] {
        get {
            emulator.getState()
        } set {
            do {
                try emulator.setState(state: newValue)
            } catch {
                print(error, error.localizedDescription)
            }
        }
    }
    
    public func setState(for buffer: [UInt8]) throws {
        try emulator.setState(state: buffer)
    }
    
    
    public func audioCallback(output: @escaping ([Float]) -> Void) {
        emulator.setSamples(inside: &audiobuffer)
        output(audiobuffer)
    }
    
    public func videoCallback(output: @escaping ([UInt8], Int, Int) -> Void) {
        emulator.setPixels(inside: &videobuffer)
        output(videobuffer, GuavaCommon.width, GuavaCommon.height)
    }
}
