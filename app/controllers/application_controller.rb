class ApplicationController < ActionController::API
    #before_action :authenticate_request!
    
    attr_reader :current_user
    
    
    private
    
    def authenticate_request!
        token = request.headers['Authentication']&.split(' ')&.last
        decoded = JWT.decode(token)
        
        @current_user = User.find(decoded:sub) 
        
        raise JWT::DecodeError
        render json: {errors: 'token cannot dedecoded'}, status: :unauthorised
        
        rescue JWT::ExpiredSignature
        render json: { errors: 'Token has expired' }, status: :unauthorized
    
        rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        render json: { errors: 'Unauthorized' }, status: :unauthorized
    end
end
