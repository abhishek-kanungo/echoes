    module Auth
        class FetchGoogleProfile
                  GOOGLE_USERINFO_ENDPOINT = 'https://www.googleapis.com/oauth2/v3/userinfo'
                  
            def self.fetch(access_token)
                uri = URI(GOOGLE_USERINFO_ENDPOINT)
                req = Net::HTTP::Get.new(uri)
                req['Authorization'] = "Bearer #{access_token}"

                res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
                http.request(req)
                end

                unless res.is_a?(Net::HTTPSuccess)
                raise "Google API request failed: #{res.code} #{res.body}"
                end

                data = JSON.parse(res.body)

                {
                birthday: data["birthdate"],
                gender: data["gender"]
                }.compact # removes nil keys
            end
        end
        
    end
