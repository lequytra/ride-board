Dotenv.require_keys('SEND_REAL_MESSAGES')
ENV['SEND_REAL_MESSAGES'] = ENV['SEND_REAL_MESSAGES'].downcase

if ENV['SEND_REAL_MESSAGES'] == "true"
  Dotenv.require_keys('AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY')
end
