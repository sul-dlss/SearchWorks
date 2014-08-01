Squash::Ruby.configure :api_host => Settings.SQUASH_API_HOST,
                       :api_key => Settings.SQUSH_API_KEY,
                       :environment => Settings.SQUASH_ENVIRONMENT || Rails.env,
                       :disabled => (Rails.env.development? || Rails.env.test?),
                       :revision_file => File.join(Rails.root, 'REVISION')
