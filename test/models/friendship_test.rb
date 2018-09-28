# frozen_string_literal: true

require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase
  def setup
    @amigi1 = User.create(nickname: 'Amigi1', email: 'amigi1@habitica.com', password: '12341234')
    @amigi2 = User.create(nickname: 'Amigi2', email: 'amigi2@habitica.com', password: '12341234')
    @noami = User.create(nickname: 'noami', email: 'noami@habitica.com', password: '12341234')

    @amigi1.friends << @amigi2
    @amigi2.friends << @amigi1

    @r1 = UserUserRequest.create(user_id: @noami.id, receiver_id: @amigi1.id)
    @noami.user_user_requests << @r1
    @amigi1.user_user_requests << @r1

    @r2 = UserUserRequest.create(user_id: @amigi2.id, receiver_id: @noami.id)
    @noami.user_user_requests << @r2
    @amigi2.user_user_requests << @r2
  end
  test 'should be valid' do
    assert @amigi1.valid?
    assert @amigi2.valid?
    assert @noami.valid?
    assert @r1.valid?
    assert @r2.valid?
  end
end
