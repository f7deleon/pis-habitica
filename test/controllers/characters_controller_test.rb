# frozen_string_literal: true

require 'test_helper'

class CharactersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    Character.create([
                       { name: 'Mago', description: I18n.t('mage_description') },
                       { name: 'Elfa', description: I18n.t('elf_description') },
                       { name: 'Fantasma', description: I18n.t('gost_description') },
                       { name: 'No muerto', description: I18n.t('dead_description') },
                       { name: 'Cazador', description: I18n.t('hunter_description') }
                     ])
  end

  test 'get Characters' do
    url = '/characters'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    body = response.body
    expected_response = CharacterSerializer.new(Character.all).serialized_json
    assert result == 200
    assert body == expected_response
  end

  test 'get Character' do
    last_character = Character.last
    url = '/characters/' + last_character.id.to_s
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    body = response.body
    expected_response = CharacterSerializer.new(last_character).serialized_json
    assert result == 200
    assert body == expected_response

    nonexistant_character = last_character.id + 1
    url = '/characters/' + nonexistant_character.to_s
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 404
  end
end
