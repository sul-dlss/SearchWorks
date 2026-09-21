# frozen_string_literal: true

# Stands in for the embed.stanford.edu oEmbed provider. The viewer iframe is inserted while
# the document is still loading, so requests to the real provider can hold the page load open
# until Capybara gives up; serving the viewer from the test server keeps :js specs off the network.
class MockPurlEmbedEndpoint
  def call(env)
    request = Rack::Request.new(env)

    case request.path_info
    when '/embed.json'
      json_response(type: 'rich', version: '1.0',
                    html: viewer_iframe(request.script_name, request.params['url']))
    when '/iframe'
      html_response(viewer_page(request.params['url']))
    else
      [404, { 'content-type' => 'text/plain' }, ["No such embed endpoint: #{request.path_info}"]]
    end
  end

  private

  def viewer_iframe(script_name, purl_url)
    src = "#{script_name}/iframe?url=#{purl_url}"

    <<~HTML.strip
      <iframe src="#{ERB::Util.html_escape(src)}" title="Digital content" frameborder="0"
              width="100%" style="height: 520px;"></iframe>
    HTML
  end

  def viewer_page(purl_url)
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
        <head><title>Mock PURL viewer</title></head>
        <body><div data-purl-url="#{ERB::Util.html_escape(purl_url)}">Mock PURL viewer</div></body>
      </html>
    HTML
  end

  def json_response(payload)
    [200, { 'content-type' => 'application/json' }, [payload.to_json]]
  end

  def html_response(body)
    [200, { 'content-type' => 'text/html; charset=utf-8' }, [body]]
  end
end
