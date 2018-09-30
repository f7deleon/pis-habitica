# frozen_string_literal: true

require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase
  def setup
    @amigi1 = User.create(nickname: 'Amigi1', email: 'amigi1@habitica.com', password: '12341234')
    @amigi2 = User.create(nickname: 'Amigi2', email: 'amigi2@habitica.com', password: '12341234')
    @noami = User.create(nickname: 'noami', email: 'noami@habitica.com', password: '12341234')

    @amigi1.friends << @amigi2
    @amigi2.friends << @amigi1

    @r1 = Request.create(user_id: @noami.id, receiver_id: @amigi1.id)
    @noami.requests_sent << @r1
    @amigi1.requests_received << @r1

    @r2 = Request.create(user_id: @amigi2.id, receiver_id: @noami.id)
    @noami.requests_received << @r2
    @amigi2.requests_sent << @r2
  end
  test 'should be valid' do
    assert @amigi1.valid?
    assert @amigi2.valid?
    assert @noami.valid?
    assert @r1.valid?
    assert @r2.valid?
  end
end
