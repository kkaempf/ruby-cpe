# Public: CPE is a lightweight library built to simplify working with the
# Common Platform Enumeration spec managed by Mitre.  See http://cpe.mitre.org/
# for further details.
#
# Examples
#
#   # Parse a CPE string
#   cpe = Cpe.parse("cpe:/o:microsoft:windows_xp:::pro")
#   cpe.vendor
#   # => "microsoft"
#   cpe.language
#   # => ""
#
#   # Generate a CPE String
#   cpe = Cpe.new(part: Cpe::OS)
#   cpe.vendor = "microsoft"
#   cpe.product = "windows_xp"
#   cpe.language = "en_US"
#   cpe.generate # => "cpe:/o:microsoft:windows_xp::::en_US"
class CPE
  # Public: Gets/sets the part type String.  Can be '/o' (Cpe::OS),
  # '/a' (Cpe::Application), or '/h' (Cpe::Hardware)
  attr_accessor :part
  # Public: Gets/sets the vendor String
  attr_accessor :vendor
  # Public: Gets/sets the product String
  attr_accessor :product
  # Public: Gets/sets the version String
  attr_accessor :version
  # Public: Gets/sets the Update or patch level String
  attr_accessor :update
  # Public: Gets/sets the part edition String
  attr_accessor :edition
  # Public: Gets/sets the language String
  attr_accessor :language
  # Public: Gets/sets the part sw_edition String
  attr_accessor :sw_edition
  # Public: Gets/sets the target_sw String
  attr_accessor :target_sw
  # Public: Gets/sets the target_hw String
  attr_accessor :target_hw
  # Public: Gets/sets the title String (for to_xml)
  attr_accessor :title

  # Public: String to give easier readability for "o"
  OS = "o"
  # Public: String to give easier readability for "a"
  Application = "a"
  # Public: String to give easier readability for "h"
  Hardware = "h"

  private
  def _wfn_attr attr
    val = self.instance_variable_get("@#{attr}".to_sym)
    if val
      ",#{attr}=\"#{val}\""
    else
      ""
    end
  end
  public
  # Public: Initialize a new CPE Object, initializing all relevent variables to
  # passed values, or else an empty string.  Part must be one of CPE::OS,
  # CPE::Application, CPE::Hardware, or else be nil.
  #
  # args - Hash containing values to set the CPE (default: {}):
  #        :part     - String describing the part.  Must be one of CPE::OS,
  #                    CPE::Application or CPE::Hardware, or nil.
  #        :vendor   - String containing the name of the vendor of the part.
  #        :product  - String containing the name of the part described by the
  #                    CPE.
  #        :version  - String containing the version of the part.
  #        :update   - String describing the update/patch level of the part.
  #        :edition  - String containing any relevant edition text for the
  #                    part.
  #        :language - String describing the language the part targets.
  #
  # Raises ArgumentError if anything other than a Hash is passed.
  # Raises ArgumentError if anything but 'o', 'a', or 'h' are set as the
  # part.
  def initialize(args={})
    raise ArgumentError.new("Argument to CPE.new must be Hash") unless args.kind_of?(Hash)
    @part = args[:part].to_s rescue nil
    unless @part.nil? || /[oah]/.match(@part)
      raise ArgumentError.new(":part must be 'a', 'h', or 'o'")
    end

    @vendor = args[:vendor] ? args[:vendor].to_s : raise(KeyError.new ":vendor must be set")
    @product = args[:product] ? args[:product].to_s : raise(KeyError.new ":product must be set")
    @version = args[:version]
    @update = args[:update]
    @edition = args[:edition]
    @language = args[:language]
    @sw_edition = args[:sw_edition]
    @target_sw = args[:target_sw]
    @target_hw = args[:target_hw]
    @other = args[:other]
    @title = args[:title]
  end

  # output MITRE dictionary format
  def to_xml
    require "rexml/document"
    xml = ::REXML::Document.new
    item = xml.add_element "cpe-item"
    item.attributes["name"] = self.to_s
    cpe23 = item.add_element "cpe-23:cpe23-item"
    cpe23.attributes["name"] = self.to_formatted
    if @title
      title = item.add_element "title"
      title.attributes["xml:lang"] = @language.empty? ? "en-US" : @language
      title.text = @title
    end
    xml
  end

  # Public: Check that at least Part and one other piece of information have
  # been set, and return generated CPE string.
  #
  # Returns a valid CPE string.
  # Raises KeyError if the part specified is invalid.
  # Raises KeyError if at least one piece of information is not set aside from
  # the part type.
  def generate format=:uri

    case format
    # cpe:/a:microsoft:internet_explorer:8.0.6001:beta
    when :uri
      uri = ["cpe", "/#{@part}", @vendor, @product, @version]
      uri << @update if @update
      uri << @edition if @edition
      uri << @language if @language
      uri << @sw_edition if @sw_edition
      uri << @target_sw if @target_sw
      uri << @target_hw if @target_hw
      uri << @other if @other
      uri.join(":").downcase
    # wfn:[part="a",vendor="microsoft",product="internet_explorer", version="8\.0\.6001",update="beta"]
    when :wfn
      wfn = "wfn:[" +
        "part=\"#{@part}\"" +
        ",vendor=\"#{@vendor}\"" +
        ",product=\"#{@product}\""
      wfn << _wfn_attr(:version)
      wfn << _wfn_attr(:update)
      wfn << _wfn_attr(:edition)
      wfn << _wfn_attr(:language)
      wfn << _wfn_attr(:sw_edition)
      wfn << _wfn_attr(:target_sw)
      wfn << _wfn_attr(:target_hw)
      wfn << _wfn_attr(:other)
      wfn + "]"
    # cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*
    when :formatted
      [ "cpe", "2.3", @part, @vendor, @product, @version, @update || "*", @edition || "*", @language || "*", @sw_edition || "*", @target_sw || "*", @target_hw || "*", @other || "*" ].join(":").downcase
    end
  end

  # Public: Test for equality of two CPE strings.
  #
  # cpe - CPE object to compare against, or String containing CPE data
  #
  # Returns a boolean value depending on whether the CPEs are equivalent.
  # Raises ArgumentError if data passed isn't either a String or CPE Object.
  def ==(cpe)
    cpe = cpe.generate if cpe.kind_of?(CPE)
    raise ArgumentError unless cpe.kind_of?(String)

    self.generate == cpe
  end

  # Public: Parse a pre-existing CPE from a String or contained in a File.
  # Attempt to be permissive regarding the number of trailing colons and
  # whitespace.
  #
  # cpe - A String or File object containing the CPE string to parse.
  #
  # Returns a new CPE object.
  # Raises ArgumentError if given anything other than a File or String object.
  # Raises ArgumentError if the string doesn't begin with "cpe:" and a valid
  # part type indicator.
  def CPE.parse(cpe)
    raise ArgumentError unless cpe.kind_of? String or cpe.kind_of? File

    cpe = cpe.read if cpe.kind_of? File
    cpe = cpe.to_s.downcase.strip
    raise ArgumentError, "CPE malformed" unless /^cpe:\/[hoa]:/.match cpe and !/[\s\n]/.match cpe

    data = Hash.new
    discard, data[:part], data[:vendor], data[:product], data[:version],
    data[:update], data[:edition], data[:language] = cpe.split(/:/, 8)
    data[:part] = data[:part][1..-1]
    return self.new data
  end

  # this actually returns the 'uri' representation
  def to_s
    to_uri
  end
  # URI binding representation
  # cpe:/a:microsoft:internet_explorer:8.0.6001:beta
  #
  def to_uri
    generate :uri
  end
  # Well formed name
  # wfn:[part="a",vendor="microsoft",product="internet_explorer", version="8\.0\.6001",update="beta"]
  #
  def to_wfn
    generate :wfn
  end
  # Formatted string binding
  # cpe:2.3:a:microsoft:internet_explorer:8.0.6001:beta:*:*:*:*:*:*
  #
  def to_formatted
    generate :formatted
  end
end
