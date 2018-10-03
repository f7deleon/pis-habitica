# frozen_string_literal: true

require 'test_helper'

class TypesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    DefaultType.create([
                         { name: 'Ejercicio', description: 'Hacer ejercicio' },
                         { name: 'Nutricion', description: 'Seguir determinada dieta' },
                         { name: 'Estudio', description: 'Estudiar por mas de 1 hora' },
                         { name: 'Social', description: 'Ir al bar' },
                         { name: 'Ocio', description: 'Jugar a la switch' }
                       ])
  end

  test 'get Types' do
    url = '/types'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    body = response.body
    expected_response = TypeSerializer.new(DefaultType.all).serialized_json
    assert result == 200
    assert body == expected_response
  end
end
