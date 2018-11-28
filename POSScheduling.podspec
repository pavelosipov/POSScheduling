Pod::Spec.new do |s|
  s.name         = 'POSScheduling'
  s.version      = '3.1.0'
  s.license      = 'MIT'
  s.summary      = 'Objective-C implementation of SchedulableObject pattern.'
  s.homepage     = 'https://github.com/pavelosipov/POSScheduling'
  s.authors      = { 'Pavel Osipov' => 'posipov84@gmail.com' }
  s.source       = { :git => 'https://github.com/pavelosipov/POSScheduling.git', :tag => s.version }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.source_files = 'Classes/**/*.{h,m}'
  s.dependency 'Aspects'
  s.dependency 'ReactiveObjC'
  s.dependency 'POSErrorHandling'
end
