# heroku-publisher

A CLI tool to publish static websites to Heroku.

## Installation

Just run

```sh
$ npm install heroku-publisher
```

Use `-g` if you want to use this as a CLI tool.

## Usage

### From CLI

Running

```sh
$ heroku-publisher
```

will try to create a Heroku application with the name of
the current directory, or to use the existing one.
You can pass `-n APP_NAME` to change the application name.

By default, this will serve your `./public` directory.

If you need to build your project before publishing,
pass the `-b` option with your compile command:

```sh 
$ heroku-publisher publish -n "grunt compile"
```

### Programatically

```coffee
options = { retry: true, appName: 'myherokuapp', build: 'grunt compile:dev' }
publisher.publish options, (err, app) ->
  console.log "App published to #{app.web_url}"
```
