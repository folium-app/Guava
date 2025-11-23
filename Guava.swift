//
//  Guava.swift
//  Guava
//
//  Created by Jarrod Norwell on 4/9/2025.
//

import Foundation

public enum NESKey : Int {
    case a = 0,
         b = 1
    
    case start = 3,
         select = 2
    
    case up = 4,
         down = 5,
         left = 6,
         right = 7
}

public class Guava {
    public var emulator: Nes = .init()
    
    public init() {}
    
    public func insert(_ cartridge: URL) throws {
        abuffer.fill(with: 0)
        fbuffer.fill(with: 0)
        guard let data: NSData = .init(contentsOf: cartridge) else {
            return
        }
        
        var bytes: [Byte] = .init(repeating: 0, count: data.length)
        data.getBytes(&bytes, length: data.length)
        
        try emulator.loadRom(rom: bytes)
    }
    
    public func step() {
        emulator.runFrame()
    }
    
    public func stop() {
        emulator.unloadRom()
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
    
    var abuffer: [Float32] = .init(repeating: 0, count: 735)
    public func audiobuffer(_ completion: @escaping (_ buffer: [Float32]) -> Void) {
        emulator.setSamples(inside: &abuffer)
        completion(abuffer)
    }
    
    var fbuffer: [UInt8] = .init(repeating: 0, count: 256 * 240 * 4)
    public func framebuffer(_ completion: @escaping (_ buffer: [UInt8], _ width: Int, _ height: Int) -> Void) {
        emulator.setPixels(inside: &fbuffer)
        completion(fbuffer, 256, 240)
    }
    
    public func button(button: NESKey, player: Int, pressed: Bool) {
        print(player)
        if pressed {
            emulator.setButtonPressed(pad: player, button: button.rawValue)
        } else {
            emulator.setButtonReleased(pad: player, button: button.rawValue)
        }
    }
}
