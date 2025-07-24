class JsonWebToken
    SECRET = Rails.application.secret_key_base
    
    def self.encode(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET, 'HS512' )
    end
    
    def self.decode(token)
        decoded = JWT.decode(token, SECRET, true, {algorithm: "HS512", verify_expiration: true})[0]
        HashWithIndifferentAccess.new(decoded)
    end
end