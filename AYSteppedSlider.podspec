Pod::Spec.new do |s|
  s.name             = "AYSteppedSlider"
  s.version          = "1.0.2"
  s.summary          = "Vertical slider with predefined steps."
  s.license          = 'MIT'
  s.homepage         = 'https://github.com/andjash/AYSteppedSlider'
  s.author           = { "Andrey Yashnev" => "andjash@gmail.com" }
  s.source           = { :git => "https://github.com/andjash/AYSteppedSlider.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'

  s.source_files = 'AYSteppedSlider'

end
