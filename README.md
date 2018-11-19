<p align="center">
  <img src="images/logo.png">
</p>

[![codecov](https://codecov.io/gh/wyeworks/pis-habitica/branch/master/graph/badge.svg)](https://codecov.io/gh/wyeworks/pis-habitica)

# Habitica proyecto 

La función de este repositorio es alojar la API del proyecto ***Habitica***, una aplicación mobile que permite llevar un seguimiento de los hábitos de salud de una persona.

## Organización

El repositorio estará organizado de forma tal que hay una rama `master` la cual tiene la ultima versión del proyecto en producción hasta el momento. Además, existe otra rama 'development' que contiene la ultima versión en desarrollo.

Para agregar features, corrección de bugs y realizar releases se deberá crear una rama partiendo de `development` con el prefijo:

* `feature/nombreDeLaFeature`
* `fix/nombreDelFix`
* `release/nombreDelRelease`

Para hacer tags se utilizará el formato con un prefijo `v` y luego el número de versión ej `v0.1.5`

La guía de estilo para los Pull Request se encuentra el la carpeta `.github` en el archivo `PULL_REQUEST_TEMPLATE.md`

Cada Pull Request debe ser aprobado por al menos un integrante del equipo y haber aprobado todos los tests que se encuentran en el servidor de integración continua 'CircleCi' antes de ser mergeado a `master` o `development`. Para mergear debe seleccionarse la opción `squash and merge` y borrar la descripción auto generada por github. La persona que crea el Pull Request es la encargada de mergear el mismo.

## Configuración del ambiente

La siguiente guía de configuración es para el sistema operativo `Ubuntu 18.04 LTS`

* Instalar curl y gpg

```
sudo apt-get install -y curl gnupg build-essential
```
* Referencia repositorios, etc.

``` 
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
``` 

* Actualizar gestor de repositorios

``` 
sudo apt-get update
```

* Instalar dependencias

```
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn libpq-dev

```
* Instalar rbenv y referenciar su ruta

```
cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL
```
* Instalar ruby-build y referenciar su ruta

```
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL
```
* Instalar ruby 2.5.1

```
rbenv install 2.5.1
rbenv global 2.5.1
```

* Confirmar versión de ruby (2.5.1)

```
ruby -v
```

* Instalar Bundler 
```
gem install bundler
```

* Instalar Rails
```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
gem install rails -v 5.2.0
rbenv rehash
```

* Instalar Postgressql
```
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
```

* Crear el usuario habitica:
```
sudo su postgres
psql
CREATE USER habitica PASSWORD 'habitica';
ALTER ROLE habitica WITH CREATEDB;
```

## Configuración de proyecto

* Clonar el repositorio de git: `git clone git@github.com:wyeworks/pis-habitica.git`

* Entrar a la carpeta de la aplicación `cd pis-habitica`

* Instalar las gemas `bundle install`

* Si se tiene alguna gema instalada con una versión diferente ejecutar `bundle update`

* Crear la base de datos: `rake db:create`

* Migrar la base de datos: `rake db:migrate`

* Cargar los datos de prueba: `rake db:seed`

## Ejecución de test

* Obtener las variables de entorno de heroku con el comando `heroku config --app pis-habitica-staging | sed 's/:  */=/g; /^=/d' >> .env `

* Eliminar las siguientes variables: `DATABASE_URL, RAILS_SERVE_STATIC_FILES, RAILS_LOG_TO_STDOUT, RAILS_ENV, RACK_ENV, LANG, DATABASE_URL`

* Ejecutar el comando `heroku local:run rails test`

## Ejecución de la API de forma local

* Obtener las variables de entorno de heroku con el comando `heroku config --app pis-habitica-staging | sed 's/:  */=/g; /^=/d' >> .env `

* Eliminar las siguientes variables (en caso de querer ejecutar la API apuntando a la base de datos de `staging` no borrarlos): 	
`DATABASE_URL, RAILS_SERVE_STATIC_FILES, RAILS_LOG_TO_STDOUT, RAILS_ENV, RACK_ENV, LANG, DATABASE_URL`

* Ejecutar el comando `heroku local server`

## Guía de estilo y linter

Para este proyecto se utilizarán las siguientes guías de etilos y linters 

* [Linter rails](https://github.com/rubocop-hq/rubocop)

* [Guia rails](https://github.com/rubocop-hq/rails-style-guide)


## Circle Ci 

Se hará una configuración de el servidor de integración contínua ***CircleCi***. Los archivos relacionados a esta podrán encontrarse en la carpeta `.cicleci` en el archivo `config.yml`

## Deploys automáticos

Cada vez que un pull request es mergeado a development se hace un deploy automático a la aplicación de ***Staging*** y se resetea la base de datos volviendo a cargar los datos de prueba. 

## Apiary

La documentación de la API puede encontrar siguiendo el siguiente link [swagger](https://habitdone.docs.apiary.io)

## About

Made with ❤️ by the ***HabitDone*** team
