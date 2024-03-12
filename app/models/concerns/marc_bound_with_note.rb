# frozen_string_literal: true

###
#  Simple module to mixin BoundWithNote behavior
###
module MarcBoundWithNote
  def bound_with_note?
    bound_with_note_for_access_panel.present?
  end

  def bound_with_note
    return unless (note_object = BoundWithNote.new(self)).present?

    @bound_with_note ||= note_object
  end

  def bound_with_note_for_access_panel
    return unless (note_object = BoundWithNoteForAccessPanel.new(self)).present?

    @bound_with_note_for_access_panel ||= note_object
  end
end
