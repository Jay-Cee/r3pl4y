# set credentials
AWS.config({
  :access_key_id     => ENV['s3_access_key_id'],
  :secret_access_key => ENV['s3_secret_access_key'],
  :s3_endpoint => 's3-eu-west-1.amazonaws.com'
})
