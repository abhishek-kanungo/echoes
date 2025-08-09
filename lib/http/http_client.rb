require "net/http"
require "json"
require "uri"

class HttpClient
  def initialize(base_url:, headers: {}, timeout: 15)
    @base = URI(base_url)
    @headers = headers
    @timeout = timeout
  end

  def get(path, params = {})
    uri = @base + path
    uri.query = URI.encode_www_form(params) if params.any?
    req = Net::HTTP::Get.new(uri)
    @headers.each { |k,v| req[k] = v }

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: @timeout) do |http|
      res = http.request(req)
      raise "HTTP \#{res.code} \#{res.body}" unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end
  end
end
