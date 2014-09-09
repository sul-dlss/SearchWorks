Squash::Ruby.configure :api_host => Settings.SQUASH_API_HOST,
                       :api_key => Settings.SQUASH_API_KEY,
                       :environment => Settings.SQUASH_ENVIRONMENT || Rails.env,
                       :disabled => Settings.SQUASH_DISABLE,
                       :revision_file => File.join(Rails.root, 'REVISION')
