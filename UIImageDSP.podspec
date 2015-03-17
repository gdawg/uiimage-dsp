Pod::Spec.new do |s|
    s.name         = "UIImageDSP"
    s.version      = "0.0.1"
    s.summary      = "iOS UIImage processing functions using the Accelerate framework for speed"
    s.homepage     = "https://github.com/ssoper/uiimage-dsp"

    s.license      = {
      :type => 'Apache',
      :file => 'LICENSE'
    }

    s.authors       = {
      'gdawg'      => 'support@mad-dog-software.com',
      'Sean Soper' => 'sean.soper@gmail.com'
    }

    s.requires_arc = true
    s.platform     = :ios, "7.0"
    s.source       = { :git => "https://github.com/ssoper/uiimage-dsp.git", :tag => s.version.to_s }
    s.frameworks   = 'Accelerate'

    s.source_files = 'UIImageDSP'
end
