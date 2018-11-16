# frozen_string_literal: true

class ListGroupsHabitsTest < ActionDispatch::IntegrationTest
  def setup
    # Create users
    @user = User.create(nickname: 'Pai', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @user1 = User.create(nickname: 'German', email: 'example1@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'Feli', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        "password": @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    @user3 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        "password": @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    # Characters
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo', description: 'Descripcion brujo')
    @user_character = UserCharacter.create(user_id: @user.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)
    @user_character1 = UserCharacter.create(user_id: @user1.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)
    @user_character2 = UserCharacter.create(user_id: @user2.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)
    @user_character3 = UserCharacter.create(user_id: @user3.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Create groups:

    # public group
    @group = Group.create(name: 'Grupito prueba', description: 'Grupito prueba desc', privacy: false)
    @group3 = Group.create(name: 'Grupito prueba3', description: 'Grupito prueba desc', privacy: false)

    # private group
    @group1 = Group.create(name: 'Grupito prueba1', description: 'Grupito prueba desc', privacy: true)
    @group2 = Group.create(name: 'Grupito prueba2', description: 'Grupito prueba desc', privacy: true)

    # Add admins
    Membership.create(user_id: @user.id, admin: true, group_id: @group.id)
    Membership.create(user_id: @user.id, admin: true, group_id: @group1.id)
    Membership.create(user_id: @user1.id, admin: true, group_id: @group3.id)

    # Add members (not admins)
    Membership.create(user_id: @user1.id, admin: false, group_id: @group.id)

    # Add group_habits to groups
    @gh = GroupHabit.create(name: 'Correr', description: 'Corer mucho',
                            difficulty: 2, privacy: 1, frequency: 1,
                            active: true, group_id: @group.id, negative: false)
    @gh1 = GroupHabit.create(name: 'Cantar', description: 'Lala',
                             difficulty: 1, privacy: 1, frequency: 2, active: true,
                             group_id: @group.id, negative: false)
    @gh2 = GroupHabit.create(name: 'Comer sano', description: 'Comer',
                             difficulty: 1, privacy: 1, frequency: 2, active: true,
                             group_id: @group.id, negative: false)
  end
  # Endpoint /me/groups/id
  test 'List my group group_habits alphabetically' do
    url = '/groups/' + @group.id.to_s + '/habits'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)

    assert body['data'][0]['type'] == 'group_habit'
    assert body['data'][0]['attributes']['name'] == @gh1.name
    assert body['data'][1]['type'] == 'group_habit'
    assert body['data'][1]['attributes']['name'] == @gh2.name
    assert body['data'][2]['type'] == 'group_habit'
    assert body['data'][2]['attributes']['name'] == @gh.name
  end

  # Endpoint /me/groups/id
  test 'My group without group_habits' do
    url = '/groups/' + @group1.id.to_s + '/habits'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].empty?
  end

  # Endpoint /users/user_id/groups/id
  test 'List other users group group_habits alphabetically' do
    url = '/groups/' + @group.id.to_s + '/habits'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 200
    body = JSON.parse(response.body)

    assert body['data'][0]['type'] == 'group_habit'
    assert body['data'][0]['attributes']['name'] == @gh1.name
    assert body['data'][1]['type'] == 'group_habit'
    assert body['data'][1]['attributes']['name'] == @gh2.name
    assert body['data'][2]['type'] == 'group_habit'
    assert body['data'][2]['attributes']['name'] == @gh.name
  end

  test 'Group without group_habits' do
    url = '/groups/' + @group3.id.to_s + '/habits'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length == @group3.group_habits.length
  end
end
