require 'launchy'
require 'uri'
require 'net/http'
require 'net/https'
require 'logger' # Allows file logging
require 'json'

# A simple module for authenticating an installed application using a Google API. - DW
# OAuth should be performed in the following order:
#   -Request a code (opens a browser window)
#   -Use the code to request an authorization token AND a refresh token
#   -Use the authorization token to use the API or the refresh token to get a new authorization token
module GoogleOAuth

@@client_id = '77847676586.apps.googleusercontent.com'
@@client_secret = 'L3uV5e4IpnGcm4TLMXCphcbE'
@@AUTH_URL = 'https://accounts.google.com/o/oauth2/auth'
@@TOKEN_URL = 'https://accounts.google.com/o/oauth2/token'

  # Defines constant URLs used for specifying some authorization scopes for Google APIs
  module Scopes
    PREDICTION_SCOPE = 'https://www.googleapis.com/auth/prediction';
    FUSION_SCOPE = 'https://www.googleapis.com/auth/fusiontables'
  end

  # Constructs a proper URL and opens a browser window to request API access from a user. Gives an auth code to the user.
  def self.request_code (scope, state = nil, login_hint = nil)
    response_type = 'code'
    redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    url_string = @@AUTH_URL + "?response_type=" + response_type +
                              "&client_id=" + @@client_id +
                              "&redirect_uri=" + redirect_uri +
                              "&scope=" + scope +
                              (state ? ("&state=" + state) : "") +
                              (state ? ("&login_hint=" + login_hint) : "")

    # Open the default browser window for authentication.
    Launchy.open(url_string)
  end

  # Returns an object with token information. Use properties 'access_token' and 'refresh_token'
  def self.request_token (authorization_code)
    redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    grant_type = 'authorization_code'

    # Create the HTTP object
    https = get_https_object(@@TOKEN_URL)

    puts 'Asking Google for an authorization token...'
    response = https.post(URI.parse(@@TOKEN_URL).path, 'code=' + authorization_code +
                                              '&client_id=' + @@client_id +
                                              '&client_secret=' + @@client_secret +
                                              '&redirect_uri=' + redirect_uri +
                                              '&grant_type=' + grant_type)

    if ! response.kind_of? Net::HTTPSuccess
      return nil
    end

    response_data = JSON.parse(response.body)
    if response_data['access_token'] && response_data['refresh_token']
      return response_data
    else
      # Unable to obtain authorization token - auth code is likely invalid.
      return nil;
    end
  end

  # Obtains a new access token using only a refresh token (instead of an auth code)
  # Returns the new access token (string), or nil if one could not be obtained.
  def self.refresh_token (refreshtoken)
    grant_type = 'refresh_token'

    # Create the HTTP object
    https = get_https_object(@@TOKEN_URL)

    puts 'Asking Google to refresh our access token...'
    response = https.post(URI.parse(@@TOKEN_URL).path, 'client_id=' + @@client_id +
                                              '&client_secret=' + @@client_secret +
                                              '&refresh_token=' + refreshtoken +
                                              '&grant_type=' + grant_type)

    if ! response.kind_of? Net::HTTPSuccess
      return nil
    end

    response_data = JSON.parse(response.body)
    if response_data['access_token']
      return response_data['access_token']
    else
      # Unable to obtain authorization token - refresh token is likely invalid.
      return nil;
    end
  end

  private

  # Returns a Net::HTTP object to use for making specifically HTTPS requests.
  # url - The url you will be making the request to, as a string.
  # logfile - The file you wish to send debugging information to, as a string.
  def self.get_https_object(url, logfile = 'http.log')
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.set_debug_output(Logger.new(logfile))
    return https
  end




end
