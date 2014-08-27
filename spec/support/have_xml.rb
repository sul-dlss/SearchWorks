require 'nokogiri'

RSpec::Matchers.define :have_xml do |xpath, matcher|
  match do |body|
    doc = Nokogiri::XML::Document.parse(body)
    nodes = Array(doc.xpath(xpath))
    nodes.map! { |node| node.respond_to?(:content) ? node.content : node }

    if nodes.empty?
      false
    elsif matcher
      nodes.all? { |node| matcher === node }
    else
      true
    end
  end

  failure_message_for_should do |body|
    "expected to find xml tag #{xpath} in:\n#{body}"
  end

  failure_message_for_should_not do |body|
    "expected not to find xml tag #{xpath} in:\n#{body}"
  end

  description do
    "have xml tag #{xpath}"
  end
end
