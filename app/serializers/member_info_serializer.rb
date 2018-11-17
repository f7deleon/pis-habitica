# frozen_string_literal: true

class MemberInfoSerializer < UserInfoSerializer
  set_type :user

  attribute :rank, if: proc { |object, params| params[:current_user].id.eql? object.id } do |object, params|
    Group.find(params[:group_id]).memberships.ordered_by_score_and_name.index(
      object.memberships.find_by(group_id: params[:group_id])
    ) + 1
  end

  attribute :score do |object, params|
    object.memberships.find_by(group_id: params[:group_id]).score
  end

  attribute :is_admin,
            if: proc { |object, params|
              object.memberships.find_by(group_id: params[:group_id], admin: true)
            } do
    true
  end
end
