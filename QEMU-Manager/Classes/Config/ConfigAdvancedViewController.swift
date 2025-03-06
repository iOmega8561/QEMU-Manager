/*******************************************************************************
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 * Copyright (c) 2025 Giuseppe Rocco
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 ******************************************************************************/

import Cocoa

final class ConfigAdvancedViewController: ConfigViewController {
    
    static let pasteboardType: NSPasteboard.PasteboardType = .init(rawValue: "qemu.argument")
    
    @IBOutlet         var arguments:    NSArrayController!
    @IBOutlet private var accelerators: NSArrayController!
    @IBOutlet private var tableView:    NSTableView!
    
    @objc         dynamic var vm:           VirtualMachine
    @objc private dynamic var supportsUEFI: Bool
    @objc private dynamic var enableUEFI:   Bool   { didSet { vm.config.enableUEFI = enableUEFI } }
    @objc private dynamic var accel:        Accel? { didSet { accel.set(to: &vm.config.accel) } }
    
    private var newDeviceArgWindowController: NewDeviceArgWindowController?
    
    override var nibName: NSNib.Name? { "ConfigAdvancedViewController" }
    
    override func viewDidAppear() {
        
        (accelerators.content, accel) = Accel.fetchValues(
            for: vm.config.architecture.rawValue,
            vm.config.accel
        )
        
        enableUEFI   = vm.config.enableUEFI
        supportsUEFI = vm.config.architecture.supportsUEFI
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let arguments: [Argument] = vm.config.arguments.map {
            .init(value: $0)
        }
        
        registerObservers(for: arguments)
        
        tableView.registerForDraggedTypes([Self.pasteboardType])
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let _ = object as? Argument, keyPath == "value" {
            
            return vm.config.setArguments(arguments.content as? [Argument])
        }

        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    @IBAction private func addRemoveArgument(_ sender: Any?) {
        
        guard let button = sender as? NSSegmentedControl else {
            return NSSound.beep()
        }
        
        switch button.selectedSegment {
        case 0: registerObservers(for: [Argument()])
        case 1: unregisterObservers(for: arguments.selectedObjects as? [Argument])
        default: NSSound.beep()
        }
        
        vm.config.setArguments(arguments.content as? [Argument])
    }
    
    @IBAction private func addDeviceArgument(_ sender: Any?) {
        
        guard self.newDeviceArgWindowController == nil else {
            return NSSound.beep()
        }
        
        let controller = NewDeviceArgWindowController(
            vm: self.vm,
            completionHandler: { [weak self] arguments in
                self?.registerObservers(for: arguments)
                self?.vm.config.setArguments(self?.arguments.content as? [Argument])
            }
        )
        
        guard let window = self.view.window,
              let sheet  = controller.window else { return NSSound.beep() }
        
        self.newDeviceArgWindowController = controller
        
        window.beginSheet(sheet) { _ in self.newDeviceArgWindowController = nil }
    }
    
    private func registerObservers(for arguments: [Argument]?) {
        
        self.arguments.add(contentsOf: arguments ?? [])
       
        arguments?.forEach { argument in
            argument.addObserver(self, forKeyPath: "value", options: .new, context: nil)
        }
    }
        
    private func unregisterObservers(for arguments: [Argument]?) {
        
        self.arguments.remove(contentsOf: arguments ?? [])
       
        arguments?.forEach { argument in
            argument.removeObserver(self, forKeyPath: "value")
        }
    }
        
    init(vm: VirtualMachine, sorting: Int) {
        
        self.vm           = vm
        self.enableUEFI   = vm.config.enableUEFI
        self.supportsUEFI = vm.config.architecture.supportsUEFI
        
        super.init(title: "Advanced", icon: NSImage(named: "TerminalTemplate"), sorting: sorting)
    }
    
    required init?(coder: NSCoder) { nil }
    
    deinit { unregisterObservers(for: arguments.content as? [Argument]) }
}
