Pod::Spec.new do |spec|
  spec.name = 'DelegateProxy'
  spec.version  = '0.1.0'
  spec.author = { 'ra1028' => 'r.fe51028.r@gmail.com' }
  spec.homepage = 'https://github.com/ra1028'
  spec.summary = 'Proxy for receive delegate events more practically'
  spec.source = { :git => 'https://github.com/ra1028/DelegateProxy.git', :tag => spec.version.to_s }
  spec.license = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.platform = :ios, '8.0'
  spec.source_files = 'Sources/**/*.{h,m,swift}'
  spec.requires_arc = true
  spec.osx.deployment_target = '10.9'
  spec.ios.deployment_target = '8.0'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target = "9.0"
end
