$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))

require 'helper'

# CPE examples borrowed from CPE Spec document ver. 2.2:
# http://cpe.mitre.org/specification/
class TestGenerate < Test::Unit::TestCase
  def setup
    @cpe = CPE.parse("cpe:/a:microsoft:internet_explorer:8.0.6001:beta")
  end

  def test_uri
    uri = @cpe.to_uri
    assert_equal("cpe:/a:microsoft:internet_explorer:8.0.6001:beta", uri)
  end

  def test_wfn
    wfn = @cpe.to_wfn
    assert_equal('wfn:[part="a",vendor="microsoft",product="internet_explorer",version="8.0.6001",update="beta"]', wfn)
  end
  
  def test_formatted
    formatted = @cpe.to_formatted
    assert_equal('cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*', formatted)
  end

  def test_xml
    xml = @cpe.to_xml
    xml.write($stdout, 2)
  end
end
