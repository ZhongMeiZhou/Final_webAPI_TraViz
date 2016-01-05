config_env do
  set 'AWS_ACCESS_KEY_ID', '...'
  set 'AWS_SECRET_ACCESS_KEY', '...'
  set 'SG_UN', '...'
  set 'SG_PW', '...'
end

config_env :development, :test do
  set 'AWS_REGION', '...'

  #memcachier region :europe
  set 'MEMCACHIER_SERVERS', 'mc1.dev.eu.ec2.memcachier.com:11211'
  set 'MEMCACHIER_USERNAME', '434316'
  set 'MEMCACHIER_PASSWORD', '70e6956b0b6c9593ecb2a4f70637accf'
end

config_env :production do
  set 'AWS_REGION', '...'

  #memcachier region :us
  set 'MEMCACHIER_SERVERS', '...'
  set 'MEMCACHIER_USERNAME', '...'
  set 'MEMCACHIER_PASSWORD', '...'
end
