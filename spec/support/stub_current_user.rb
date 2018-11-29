##
# Stub the current user context.
# stub_current_user by iteself will stub the application controller context (useful for feature specs)
# You can also pass in a context to stub the user on (either an instance of a class or the class itself)
module StubCurrentUser
  def stub_current_user(
        user: User.new(email: 'example@stanford.edu'),
        context: ApplicationController,
        method_name: :current_user,
        affiliation: nil
  )
    return unless user

    if context.is_a?(Class)
      allow_any_instance_of(context).to receive(method_name).and_return(user)
      allow_any_instance_of(context).to receive(:session).and_return('suAffiliation' => affiliation) if affiliation
    else
      allow(context).to receive(method_name).and_return(user)
      allow(context).to receive(:session).and_return('suAffiliation' => affiliation) if affiliation
    end
  end
end

RSpec.configure do |config|
  config.include StubCurrentUser
end
