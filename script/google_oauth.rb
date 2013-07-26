class GoogleOAuth
  def initialize(client_id, client_secret)

  end

  def request_token

  end

  def request_code

  end

  def refresh_token (refreshToken)
    # This code will automatically refresh our access token to make sure we can still access the API
    google_oauth = URI.parse('https://accounts.google.com/o/oauth2/token')
    client_id = '524332453800-b31p35fpq4chitlbfp4aol3cfda4bv7e.apps.googleusercontent.com'
    client_secret = '0Os0EqKH36aHQuAdCDxvPmML'
    refresh_token = '1/HMfIVUwemOGr1ktPNCqgAK8LW4WVVoMNixIDUiy55Ow' #Needs to be obtained first.

    # Create the HTTP object
    https = Net::HTTP.new(google_oauth.host, google_oauth.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.set_debug_output(Logger.new("http.log"))

    puts 'Asking Google to refresh our access token...'
    response = https.post(google_oauth.path, 'client_id=' + client_id + '&client_secret=' + client_secret + '&refresh_token=' + refresh_token + '&grant_type=refresh_token')

    puts 'Parsing response from Google for access token...'
    # Get the access token from the response.
    access_token = JSON.parse(response.body)['access_token'];
  end


end
