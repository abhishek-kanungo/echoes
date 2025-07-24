module Api 
  module V1
    class SessionsController < ApplicationController
      def google_auth
        auth = request.env['omniauth.auth'] 
        access_token = auth.credentials.token

        profile = ::Auth::FetchGoogleProfile.fetch(access_token)

        user = User.find_or_create_by!(google_uid: auth.uid) do |user|
          user.email = auth.info.email
          user.name = auth.info.name
          user.avatar_url = auth.info.image
          user.birthday = profile[:birthday]
          user.gender = profile[:gender]
        end

        user.update(
          name: auth.info.name,
          avatar_url: auth.info.image
        )

        jwt_token = ::JsonWebToken.encode({ user_id: user.id })

        # ✅ Redirect back to React with the JWT
        redirect_to "http://localhost:3000/auth/google_oauth2/callback?jwt=#{jwt_token}"
      end
    end
  end
end
