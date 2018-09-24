# Habitica proyecto 

La función de este repositorio es alojar la api del proyecto ***habitica*** una aplicación mobile que permite llevar un seguimiento de los hábitos de salud de una persona.


## Organización

El repositorio estará organizado de forma tal que hay una rama `master` la cual tiene la ultima versión del proyecto al momento. Para agregar features, corregir bugs y  hacer releases se deberá partiendo de `master` crear una rama con el prefijo:

* `feature/nombreDeLaFeature`
* `fix/nombreDelFix`
* `release/nombreDelRelease`

Para hacer tags se utilizara el formato con un prefijo `v` y luego el numero de versión ej `v0.1.5`

La guía de estilo para los pull request se encuentra el la carpeta `.github` en el archivo `PULL_REQUEST_TEMPLATE.md`

Cada pull request debe ser aprobado por al menos 1 integrante del equipo y el servidor de integración continua `CircleCi` antes de ser mergeado a `master`. Para mergear a `master` debe seleccionarse la opción `squash and merge` y borrar la descripción auto generada por github. La persona que creea el pull request es la encargada de mergear el mismo.


## Configuración de ambiente

La siguiente guía de configuración es para el sistema operativo `Ubuntu 18.04 LTS`

* Instalar curl y gpg

```
sudo apt-get install -y curl gnupg build-essential
```
* Referenciar repositorios, etc.

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

* Confirmar version de ruby (2.5.1)

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

* Entrar a la carpeta de la aplicacion `cd pis-habitica`

* Instalar las gemas `bundle install`

* Si tenias alguna gema instalada con una version diferente ejecutar `bundle update`

* Crear la base de datos: `rake db:create`


## Guia de estilo y linter

Para este proyecto se utilizaran las siguientes guiás de etilos y linters 

* [Linter ruby](https://github.com/rubocop-hq/rubocop)

* [Guia ruby](https://github.com/rubocop-hq/rails-style-guide)


## Circle Ci 

Se hará una configuración de el servidor de integración continua ***CircleCi*** los archivos relacionados a esta podrán encontrarse en la carpeta `.cicleci` en el archivo `config.yml`
