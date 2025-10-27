//
//  WatchBluetoothManager.swift
//  BrainBuzz
//
//  Watch Bluetooth Manager implementing XGQ0005B Protocol
//

import Foundation
import CoreBluetooth
import Combine

// MARK: - Protocol Constants
struct WatchProtocol {
    static let headerByte1: UInt8 = 0xD5
    static let headerByte2: UInt8 = 0x11
    
    enum Mode: UInt8 {
        case vibration = 0x00
        case staticShock = 0x01
        case training = 0x02
    }
    
    enum KeyCommand: UInt8 {
        case beep = 0x01
        case motor = 0x02
        case shock = 0x03
        case batteryInfo = 0x04
        case readGeneralSettings = 0x05
        case readStaticSettings = 0x06
        case timeInfo = 0x07
        case barkInfo = 0x08
        case eraseBarkData = 0x09
        case barkFileInfo = 0x0A
    }
    
    enum ResponseStatus: UInt8 {
        case success = 0x01
        case failure = 0x02  // Covers both checksum failure and length exceed (both 0x02)
    }
}

// MARK: - Watch Configuration
struct WatchConfiguration {
    var mode: WatchProtocol.Mode = .vibration
    var beepCount: UInt8 = 0  // 0 = 1 time, 1 = 2 times
    var beepDuration: UInt8 = 0b000  // 000 = 65ms, 001 = 100ms
    var motorIntensity: UInt8 = 0  // 0 = Low (33%), 1 = High (100%)
    var motorDuration: UInt8 = 0b001  // 001 = 1.5 seconds
    var shockLevel: UInt8 = 0b001  // 001 = Level 2
    var shockDuration: UInt8 = 0b00100  // 00100 = 500ms
    var micSensitivity: UInt8 = 0
    
    // Convert to protocol bytes
    func encodeForMode(mode: WatchProtocol.Mode) -> [UInt8] {
        switch mode {
        case .vibration:
            return encodeVibrationMode()
        case .staticShock:
            return encodeStaticMode()
        case .training:
            return encodeTrainingMode()
        }
    }
    
    private func encodeVibrationMode() -> [UInt8] {
        let data4: UInt8 = beepCount << 7 | (beepDuration & 0b111) << 4 | (motorIntensity & 0b1) << 3 | (motorDuration & 0b111)
        let checksum = calculateChecksum(length: 0x06, command: 0x01, keyValue: data4)
        
        return [
            WatchProtocol.headerByte1,
            WatchProtocol.headerByte2,
            0x06, // length
            0x01, // general settings command
            0x00, // VIBRATION mode
            micSensitivity,
            data4, // VIBRATION config
            checksum
        ]
    }
    
    private func encodeStaticMode() -> [UInt8] {
        let data4: UInt8 = beepCount << 7 | (beepDuration & 0b111) << 4
        let data5: UInt8 = motorIntensity << 3 | (motorDuration & 0b111)
        let data6: UInt8 = (shockLevel >> 2) & 0b111 | ((shockLevel & 0b001) << 5)
        let data7: UInt8 = ((shockDuration & 0b11111) << 3)
        
        let checksum = calculateChecksum(length: 0x0D, command: 0x02, keyValue: data4 &+ data5 &+ data6 &+ data7)
        
        return [
            WatchProtocol.headerByte1,
            WatchProtocol.headerByte2,
            0x0D, // length
            0x02, // static mode command
            data4,
            data5,
            data6,
            data7,
            checksum
        ]
    }
    
    private func encodeTrainingMode() -> [UInt8] {
        // Similar structure but for training mode
        let data4: UInt8 = beepCount << 7 | (beepDuration & 0b111) << 4
        let data5: UInt8 = motorIntensity << 3 | (motorDuration & 0b111)
        let data6: UInt8 = (shockLevel >> 2) & 0b111 | ((shockLevel & 0b001) << 5)
        let data7: UInt8 = ((shockDuration & 0b11111) << 3)
        
        let checksum = calculateChecksum(length: 0x0D, command: 0x02, keyValue: data4 &+ data5 &+ data6 &+ data7)
        
        return [
            WatchProtocol.headerByte1,
            WatchProtocol.headerByte2,
            0x0D,
            0x02,
            data4,
            data5,
            data6,
            data7,
            checksum
        ]
    }
}

// MARK: - Checksum Calculation
func calculateChecksum(length: UInt8, command: UInt8, keyValue: UInt8) -> UInt8 {
    let sum = length &+ command &+ keyValue
    return UInt8((0x100 - UInt16(sum)) & 0xFF)
}

// MARK: - Watch Bluetooth Manager
class WatchBluetoothManager: NSObject, ObservableObject {
    static let shared = WatchBluetoothManager()
    
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var connectionStatus: String = "Disconnected"
    @Published var batteryLevel: Int = 0
    @Published var currentMode: WatchProtocol.Mode = .vibration
    
    // MARK: - Private Properties
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var commandCharacteristic: CBCharacteristic?
    
    // Configuration
    private var configuration = WatchConfiguration()
    
    private override init() {
        super.init()
        // Use CBCentralManagerOptionShowPowerAlertKey for better debugging
        let options: [String: Any] = [CBCentralManagerOptionShowPowerAlertKey: true]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        configuration.beepCount = 0  // 1 beep
        configuration.beepDuration = 0b001  // 100ms
        
        #if targetEnvironment(simulator)
        print("⚠️ Running on iOS Simulator - Bluetooth requires a real device!")
        #endif
    }
    
    // MARK: - Connection Management
    func startScanning() {
        print("📱 startScanning() called")
        print("📱 Bluetooth state: \(centralManager.state)")
        
        // Check if we need to wait
        guard centralManager.state != .unknown && centralManager.state != .resetting else {
            print("⏳ Bluetooth still initializing, waiting...")
            connectionStatus = "Initializing Bluetooth..."
            return
        }
        
        // If not powered on, we can't scan
        guard centralManager.state == .poweredOn else {
            print("❌ Bluetooth not ready (state: \(centralManager.state))")
            
            switch centralManager.state {
            case .poweredOff:
                connectionStatus = "Please turn on Bluetooth in Settings"
            case .unauthorized:
                connectionStatus = "Bluetooth permission required"
            case .unsupported:
                connectionStatus = "Bluetooth not supported"
            default:
                connectionStatus = "Bluetooth not available"
            }
            return
        }
        
        print("✅ Starting Bluetooth scan...")
        connectionStatus = "Scanning for watch..."
        
        // Start scanning - this will discover any BLE devices
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        // Stop scanning after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !self.isConnected {
                print("⏱️ Scanning timeout - stopping scan")
                self.centralManager.stopScan()
                self.connectionStatus = "No watch found. Make sure your watch is powered on and nearby."
            }
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        connectedPeripheral = nil
        commandCharacteristic = nil
        isConnected = false
        connectionStatus = "Disconnected"
    }
    
    // MARK: - Command Sending
    func sendKeyCommand(_ command: WatchProtocol.KeyCommand) {
        guard isConnected, let characteristic = commandCharacteristic, let peripheral = connectedPeripheral else {
            print("Not connected to watch")
            return
        }
        
        let commandBytes = createKeyCommand(command)
        let data = Data(commandBytes)
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    private func createKeyCommand(_ command: WatchProtocol.KeyCommand) -> [UInt8] {
        let checksum = calculateChecksum(length: 0x02, command: 0x05, keyValue: command.rawValue)
        
        return [
            WatchProtocol.headerByte1,
            0x12,
            0x02, // length
            0x05, // key command
            command.rawValue,
            checksum
        ]
    }
    
    // MARK: - Trigger Feedback on Wrong Answer
    func triggerWrongAnswer() {
        sendKeyCommand(.beep)  // Always beep
        sendKeyCommand(.motor)  // Always vibrate
        
        if currentMode == .staticShock || currentMode == .training {
            // Trigger shock if in shock mode
            sendKeyCommand(.shock)
        }
    }
    
    // MARK: - Mode Management
    func setMode(_ mode: WatchProtocol.Mode) {
        currentMode = mode
        configuration.mode = mode
        configuration.beepCount = 0  // 1 beep
        configuration.beepDuration = 0b001  // 100ms
        configuration.motorIntensity = 0  // Low (33%)
        configuration.motorDuration = 0b001  // 1.5 seconds
        configuration.shockLevel = 0b001  // Level 2
        configuration.shockDuration = 0b00010  // 200ms
        
        let commandBytes = configuration.encodeForMode(mode: mode)
        let data = Data(commandBytes)
        
        if let peripheral = connectedPeripheral, let characteristic = commandCharacteristic {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    
    // MARK: - Battery Info
    func queryBatteryInfo() {
        sendKeyCommand(.batteryInfo)
    }
}

// MARK: - CBCentralManagerDelegate
extension WatchBluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("📡 Bluetooth state changed: \(central.state)")
        
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth powered on - ready to scan!")
            connectionStatus = "Ready to Connect"
        case .poweredOff:
            print("❌ Bluetooth powered off")
            connectionStatus = "Please turn on Bluetooth in Settings"
            isConnected = false
        case .unauthorized:
            print("❌ Bluetooth unauthorized - need permission")
            connectionStatus = "Bluetooth permission required"
        case .unsupported:
            print("❌ Bluetooth unsupported on this device")
            connectionStatus = "Bluetooth not available"
        case .unknown:
            print("❓ Bluetooth state unknown")
            connectionStatus = "Initializing Bluetooth..."
        case .resetting:
            print("🔄 Bluetooth resetting")
            connectionStatus = "Resetting Bluetooth..."
        @unknown default:
            print("❓ Unknown Bluetooth state")
            connectionStatus = "Bluetooth unknown state"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
        
        // Connect to first device with a name (or you can filter by specific name)
        if connectedPeripheral == nil {
            print("Connecting to peripheral...")
            connectionStatus = "Connecting to \(peripheral.name ?? "device")..."
            connectedPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)
            centralManager.stopScan()  // Stop scanning once we found a device
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectionStatus = "Connected - Discovering Services..."
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionStatus = "Connection Failed"
        connectedPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        connectionStatus = "Disconnected"
        connectedPeripheral = nil
    }
}

// MARK: - CBPeripheralDelegate
extension WatchBluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) {
                commandCharacteristic = characteristic
            }
            
            if characteristic.properties.contains(.read) || characteristic.properties.contains(.notify) {
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        if commandCharacteristic != nil {
            isConnected = true
            connectionStatus = "Connected"
            
            // Send initial configuration
            setMode(currentMode)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        // Parse response
        let bytes = [UInt8](data)
        
        if bytes.count >= 6 && bytes[0] == WatchProtocol.headerByte1 {
            if bytes[3] == WatchProtocol.KeyCommand.batteryInfo.rawValue {
                // Parse battery info
                if bytes.count >= 7 {
                    batteryLevel = Int(bytes[4])
                }
            }
        }
    }
}

