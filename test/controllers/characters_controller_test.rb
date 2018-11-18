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

    @char = Character.create(name: 'Mago', description: I18n.t('mage_description'))

    Character.create([
                       { name: 'Elfa', description: I18n.t('elf_description') },
                       { name: 'Fantasma', description: I18n.t('gost_description') },
                       { name: 'No muerto', description: I18n.t('dead_description') },
                       { name: 'Cazador', description: I18n.t('hunter_description') }
                     ])
  end

  def create_character(user_token = @user_token, character = @char, date = Time.zone.now.iso8601)
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + user_token
    }, params: {
      'data': {
        'id': character.id.to_s,
        'type': 'characters',
        'attributes': { 'name': character.name, 'description': character.description }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': date } }]
    }
  end

  test 'should be valid' do
    assert @user.valid?
    assert @char.valid?
  end

  test 'get Characters' do
    get '/characters', headers: { 'Authorization': 'Bearer ' + @user_token }
    body = response.body
    expected_response = CharacterSerializer.new(Character.all).serialized_json
    assert_equal 200, status # Ok
    assert body == expected_response
  end

  test 'get Character' do
    last_character = Character.last
    get '/characters/' + last_character.id.to_s, headers: { 'Authorization': 'Bearer ' + @user_token }
    body = response.body
    expected_response = CharacterSerializer.new(last_character).serialized_json
    assert_equal 200, status # Ok
    assert body == expected_response

    nonexistant_character = last_character.id + 1
    get '/characters/' + nonexistant_character.to_s, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert_equal 404, status # Not Found
  end

  test 'get Characters: user has to be logged in' do
    get '/characters', headers: { 'Authorization': 'Bearer asdasdasd' }
    assert_equal 401, status # Unauthorized
  end

  test 'create Character' do
    create_character
    assert_equal 201, status # Created
    expected = {
      'data': {
        'id': @char.id.to_s,
        'type': 'character',
        'attributes': { 'name': @char.name, 'description': @char.description }
      }
    }
    assert_equal expected.to_json, response.body
    create_character
    assert_equal 409, status # Conflict
    expected = {
      'errors': [{ 'status': '409', 'title': 'Conflict', 'message': 'User already has an alive character' }]
    }
    assert_equal expected.to_json, response.body
  end

  test 'create character, invalid token' do
    create_character('asda')
    assert_equal 401, status # Unauthorized
  end

  test 'create character, format should be valid' do
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'di': @char.id.to_s,
        'type': 'characters',
        'attributes': { 'nave': @char.name, 'description': @char.description }
      },
      'included': [{ 'type': 'date', 'attributes': { 'dam': Time.zone.now.iso8601 } }]
    }
    assert_equal 400, status # Bad Request

    create_character(@user_token, @char, Time.now.rfc2822)
    assert_equal 400, status # Bad Request
  end

  test 'create nonexistant character' do
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'id': 122,
        'type': 'characters',
        'attributes': { 'name': @char.name, 'description': @char.description }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': Time.zone.now.iso8601 } }]
    }
  end
end
