Pod::Spec.new do |s|
  s.name         = 'POSSchedulableObject'
  s.version      = '1.0.0'
  s.license      = 'MIT'
  s.summary      = 'Objective-C implementation of SchedulableObject pattern.'
  s.homepage     = 'https://github.com/pavelosipov/POSRx'
  s.authors      = { 'Pavel Osipov' => 'posipov84@gmail.com' }
  s.source       = { :git => 'https://github.com/pavelosipov/POSSchedulableObject.git', :tag => '1.0.0' }
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'
  s.source_files = 'Classes/**/*.{h,m}'
  s.dependency 'Aspects'
  s.dependency 'ReactiveCocoa', '< 3.0'
end
