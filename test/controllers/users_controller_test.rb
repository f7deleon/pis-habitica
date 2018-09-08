# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', mail: 'example@example.com',
                        password: 'Example123')
    @user2 = User.create(nickname: 'Example12', mail: 'example12@example.com',
                         password: 'Example123')
    ### Characters creation
    @character = Character.create(name: 'Humano',
                                  description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo',
                                   description: 'Descripcion brujo')

    ### Parameters for requests
    @parameters = { "data": { "id": @character.id.to_s,
                              "type": 'characters',
                              "attributes": { "name": 'Mago',
                                              "description": 'Una descripcion de mago' } },
                    "included": [{ "type": 'date',
                                   "attributes": { "date": '2018-09-07T12:00:00Z' } }] }
    @parameters2 = { "data": { "id": @character1.id.to_s,
                               "type": 'characters',
                               "attributes": { "name": 'Mago',
                                               "description": 'Una descripcion de mago' } },
                     "included": [{ "type": 'date',
                                    "attributes": { "date": '2018-09-07T12:00:00Z' } }] }
  end

  # Alta Personaje
  test 'AltaPersonaje: add character id 4 to user
                        id 1 user already have an is_alive character' do
    url = '/me/characters?token=' + @user.id.to_s

    result0 = post url, params: @parameters
    assert result0 == 200 # :created
    result = post url, params: @parameters2
    assert result == 400 # :bad_request
  end

  test 'AltaPersonaje:  user id do not exists' do
    result = post '/me/characters?token=9999', params: @parameters
    assert result == 403 # :forbidden
  end

  test 'AltaPersonaje: char_id do not exists' do
    parameters = { "data": { "id": '300',
                             "type": 'characters',
                             "attributes": { "name": 'Mago',
                                             "description": 'Una descripcion de mago' } },
                   "included": [{ "type": 'date',
                                  "attributes": { "date": '2018-09-07T12:00:00Z' } }] }
    result = post '/me/characters?token=' + @user.id.to_s, params: parameters
    assert result == 400 # :bad_request
  end

  test 'AltaPersonaje: wrong date format' do
    parameters = { "data": { "id": '3',
                             "type": 'characters',
                             "attributes": { "name": 'Mago',
                                             "description": 'Una descripcion de mago' } },
                   "included": [{ "type": 'date',
                                  "attributes": { "date": '2018-2:00:00Z' } }] }
    result = post '/me/characters?token=' + @user.id.to_s, params: parameters
    assert result == 400 # :bad_request
  end
end
