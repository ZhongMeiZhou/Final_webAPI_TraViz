config_env do
  set 'AWS_ACCESS_KEY_ID', '...'
  set 'AWS_SECRET_ACCESS_KEY', '...'
end

config_env :development, :test do
  set 'AWS_REGION', '...'
end

config_env :production do
  set 'AWS_REGION', '...'
end
