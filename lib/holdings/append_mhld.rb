module AppendMHLD
  def append_mhld(group_by, items, klass)
    mhld.group_by(&group_by).map do |code, mhld|
      if (current = items.find{|item| item.code == code})
        current.mhld = mhld
      else
        current = klass.new(code)
        current.mhld = mhld
        items << current
      end
    end if mhld.present?
  end
end
