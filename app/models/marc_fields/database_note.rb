# frozen_string_literal: true

class DatabaseNote < MarcField
  def values
    return [] unless document.is_a_database?

    super
  end

  private

  def tags
    %w(592)
  end
end
