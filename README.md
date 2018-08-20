# Habitica proyecto 

La función de este repositorio es alojar la api del proyecto ***habitica*** una aplicación mobile que permite llevar un seguimiento de los hábitos de salud de una persona.


## Organización

El repositorio estará organizado de forma tal que hay una rama `master` la cual tiene la ultima versión del proyecto al momento. Para agregar features, corregir bugs y  hacer releases se deberá partiendo de `master` crear una rama con el prefijo:

* `feature/nombreDeLaFeature`
* `fix/nombreDelFix`
* `release/nombreDelRelease`

Para hacer tags se utilizara el formato con un prefijo `v` y luego el numero de versión ej `v0.1.5`

La guía de estilo para los pull request se encuentra el la carpeta `.github` en el archivo `PULL_REQUEST_TEMPLATE.md`

Cada pull request debe ser aprobado por al menos 1 integrante del equipo y el servidor de integración continua `CircleCi` antes de ser mergeado a `master`. Para mergear a `master` debe seleccionarse la opción `squash and merge` y borrar la descripción auto generada por github



## Guia de estilo y linter

Para este proyecto se utilizaran las siguientes guiás de etilos y linters 

* [Linter ruby](https://github.com/rubocop-hq/rubocop)

* [Guia ruby](https://github.com/rubocop-hq/rails-style-guide)



## Circle Ci 

Se hará una configuración de el servidor de integración continua ***CircleCi*** los archivos relacionados a esta podrán encontrarse en la carpeta `.cicleci` en el archivo `config.yml`
