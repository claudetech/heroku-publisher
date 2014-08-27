# heroku-publisher

A CLI tool to publish static websites to Heroku.

## Installation

Just run

```
npm install heroku-publisher
```

Use `-g` if you want to use this as a CLI tool.

## Usage

### From CLI

Running

```
heroku-publisher
```

will try to create a Heroku application with the name of
the current directory, or to use the existing one.
You can pass `-n APP_NAME` to change the application name.

By default, this will serve your `./public` directory.

### Programatically

```coffee
options = { retry: true, appName: 'myherokuapp' }
publisher.publish options, (err, app) ->
  console.log "App published to #{app.web_url}"
```
