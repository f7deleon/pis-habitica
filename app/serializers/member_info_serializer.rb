# frozen_string_literal: true

class MemberInfoSerializer < UserInfoSerializer
  set_type :user

  attribute :score do |object, params|
    object.memberships.find_by(group_id: params[:group_id]).score
  end

  attribute :is_admin,
            if: proc { |object, params|
              object.memberships.find_by(group_id: params[:group_id]).admin
            } do |object, params|
    object.memberships.find_by(group_id: params[:group_id]).admin
  end
end
