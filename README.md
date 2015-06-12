# Admiral for AWS OpsWorks

Admiral tasks for wielding AWS OpsWorks resources.

For additional modules, see the [Admiral base prjoect](https://github.com/flippyhead/admiral).

Developed in Seattle at [Fetching](http://fetching.io).

## Installation

Add this line to your application's Gemfile (recommended):

    gem 'admiral-opsworks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install admiral-opsworks

## Usage

To see a list of available commands, on the command line enter:

    $ admiral ow help

Make sure your bundle bin is in your PATH.

The following commands are available:

```
Commands:
  admiral ow deploy APP_NAME  # Deploy the APP_NAME application. APP_NAME need only partially match one existing app.
  admiral ow help [COMMAND]   # Describe subcommands or one specific subcommand
  admiral ow provision        # Replace and update existing instances
  admiral ow ssh              # ssh to first instance in environment.

Options:
  --env, [--environment=ENVIRONMENT]  # The environment (e.g. staging or production). Can also be specified with ADMIRAL_ENV.
                                      # Default: production
```

Some commands have additional options you can discover with:

    # admiral ow help [COMMAND]

## Setup

Admiral for OpsWorks requires and builds on the setup implemented by [Admiral for CloudFormation](https://github.com/flippyhead/admiral-cloudformation). Commands will look for parameters in the specific environment and query the CloudFormation stack created for the current environment.

It is recommended that you create a distinct repository for each cluster type. For example you might have: `server-elasticsearch`, `server-mongodb`, and `server-meteor` repositories each which specific cluster configurations.

## Examples

To deploy an application already pushed to production:

    $ admiral ow deploy appname

To SSH to an instance on your staging database server:

    $ admiral ow ssh --environment staging

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request