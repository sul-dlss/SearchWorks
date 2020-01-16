# frozen_string_literal: true

class MockExhibitsFinderEndpoint
  cattr_accessor :content, :content_type, :status

  class << self
    def status
      @@status || 200
    end

    def content_type
      @@content_type || 'application/json'
    end

    def content
      @@content || [].to_json
    end

    def configure
      yield(self) if block_given?
      self
    end
  end

  def call(_env)
    [
      self.class.status,
      { 'content_type' => self.class.content_type },
      [self.class.content]
    ]
  end
end
