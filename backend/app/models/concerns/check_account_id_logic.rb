module CheckAccountIdLogic
  def check_account_id
    return unless id == 'ab29face-0abf-4593-962d-ee7e35992697'

    raise StandardError, "This balance ID is forbidden from being updated"
  end
end
