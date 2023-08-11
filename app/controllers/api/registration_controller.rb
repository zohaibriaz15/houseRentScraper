class Api::RegistrationController <  Devise::RegistrationsController
    skip_before_action :verify_authenticity_token

    def google_oauth2
      authorization_code = params[:code]
      
      access_token = exchange_code_for_token(authorization_code)
      
      user_profile = fetch_user_profile(access_token)
      user = User.from_google(
        uid: user_profile["sub"],
        email: user_profile["email"],
        full_name: user_profile["name"],
        avatar_url: user_profile["picture"]
      )
      if user.nil?
        render json: { error: 'User not found' }, status: :not_found
      elsif user.persisted?
        render json: { message: 'User registered successfully', user_id: user.id }
      else
        render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
  
    private
  
    def exchange_code_for_token(authorization_code)
      token_url = "https://oauth2.googleapis.com/token"
      response = HTTParty.post(token_url, body: {
        code: authorization_code,
        client_id: '682659550373-fgl0rhqp1c7s85krtnkcfkdipe8s7ibf.apps.googleusercontent.com',
        client_secret: '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',
        redirect_uri: 'http://localhost:3000/users/signin', # Replace with your redirect URI
        grant_type: 'authorization_code'
      })
  
    
      if response.success?
        response.parsed_response['access_token']
      else
        nil
      end
    end
    
  
    def fetch_user_profile(access_token)
      user_profile_url = "https://www.googleapis.com/oauth2/v3/userinfo"
      response = HTTParty.get(user_profile_url, headers: { "Authorization" => "Bearer #{access_token}" })
      JSON.parse(response.body)
    end
  
end
