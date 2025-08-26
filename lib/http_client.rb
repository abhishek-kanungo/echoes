require "net/http"
require "uri"
require "json"

class HttpClient
  def initialize(base_url:, headers: {}, timeout: 15)
    @base = URI(base_url)
    @headers = headers
    @timeout = timeout
  end

  # lib/http_client.rb
  def get(path, params = {})
    base = @base.to_s
    # ensure single slash between base and path, and keep the /3 segment
    url  = File.join(base.end_with?('/') ? base : "#{base}/", path.to_s.sub(%r{^/}, ''))
    uri  = URI(url)

    uri.query = URI.encode_www_form(params) if params.any?
    req = Net::HTTP::Get.new(uri)
    # include Accept; keep your Authorization from the caller
    @headers.merge("Accept" => "application/json").each { |k, v| req[k] = v }

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: @timeout) do |http|
      res = http.request(req)
      raise "HTTP #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end
  end

end
