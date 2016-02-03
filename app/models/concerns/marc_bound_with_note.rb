###
#  Simple mdoule to mixin BoundWithNote behavior
###
module MarcBoundWithNote
  def bound_with?
    bound_with_note.present?
  end

  def bound_with_note
    return unless (note_object = BoundWithNote.new(self)).present?
    @bound_with_note ||= note_object
  end
end
