require_relative 'google_oauth'

puts "Requesting code from Google..."

GoogleOAuth::request_code(GoogleOAuth::Scopes::FUSION_SCOPE)

puts "Please view the authentication dialog in your browser to authenticate the application."

puts "Paste the code provided here: "

code = gets.chomp

response_data = GoogleOAuth::request_token(code)

if response_data
  puts "Your access token is: " + response_data['access_token']
  puts "Your refresh token is: " + response_data['refresh_token']
else
  puts "We could not obtain an access token with the authorization code provided."
end