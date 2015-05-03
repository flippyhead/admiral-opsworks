# Admiral for AWS OpsWorks

Admiral tasks for wielding AWS OpsWorks resources.

## Installation

Add this line to your application's Gemfile (recommended):

    gem 'admiral-opsworks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install admiral-opsworks

## Usage

On your command line type:

    $ admiral ow help

To see a list of available commands. Make sure your bundle bin is in your PATH.

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

# Setup and Configuration

Admiral for OpsWorks requires and builds on the setup implemented by Admiral for CloudFormation. Commands will look for parameters in the specific environment and query the CloudFormation stack created for the current environment.

For example, to SSH to an instance on your production database server:

    $ admiral ow ssh --environment production --template MongoDB.template