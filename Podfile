source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
workspace 'POSScheduling'

abstract_target 'All' do
    pod 'Aspects', :inhibit_warnings => true
    pod 'ReactiveObjC', :inhibit_warnings => true
    pod 'POSErrorHandling', :git => 'https://github.com/pavelosipov/POSErrorHandling.git'
    target 'POSScheduling'
    target 'POSSchedulingTests' do
        pod 'POSScheduling', :path => '.'
        pod 'POSAllocationTracker'
    end
end
