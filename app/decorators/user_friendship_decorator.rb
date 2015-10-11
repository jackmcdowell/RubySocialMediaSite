# class UserFriendshipDecorator < Draper::Base
# decorates :user_friendship

class UserFriendshipDecorator < Draper::Decorator
  delegate_all

def friendship_state
	model.state.titleize

end

def sub_message
  case model.state
    when 'pending'
    "<h3>Do you really want to be friends with John?</h3>"
    when 'accepted'
    "<h3>You are friends with #{model.friend.first_name}</h3>"  
  end
end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
