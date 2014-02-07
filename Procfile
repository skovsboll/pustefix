# web: bundle exec thin start -p $PORT -e $RACK_ENV
# web: bundle exec puma -p $PORT -e $RACK_ENV
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb -E $RACK_ENV
