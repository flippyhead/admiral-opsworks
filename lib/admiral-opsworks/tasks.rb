require 'thor'
require_relative 'util'

module Admiral
  module Tasks
    class OpsWorks < Thor

      include Util::OpsWorks
      include Util::CloudFormation

      NAME = 'ow'
      USAGE = 'ow <command> <options>'
      DESCRIPTION = 'Commands for wielding AWS OpsWorks stacks.'

      namespace :ow

      default_command :create

      desc "provision ENVIRONMENT", "Replace and update existing instances for ENVIRONMENT"

      option :count,
        desc: 'Number of instances to boot',
        type: :numeric,
        default: 0

      def provision(env)
        stack = client.stacks[stack_name(env)]
        stack_id = cf_query_output(stack, "StackId")
        layer_id = cf_query_output(stack, "LayerId")

        update_instances stack_id, layer_id, options[:count]
      end

      desc 'ssh ENVIRONMENT', 'ssh to ENVIRONMENT using ssh key specified in env settings.'

      def ssh(env)
        stack = client.stacks[stack_name(env)]
        stack_id = cf_query_output(stack, "StackId")
        layer_id = cf_query_output(stack, "LayerId")

        instances = get_all_instances(layer_id)
        ssh_to_instance instances[0], params(env)['SshKeyName']
      end

      desc 'deploy ENVIRONMENT APP_NAME', 'Deploy the APP_NAME application in ENVIRONMENT. APP_NAME need only partially match one existing app.'

      def deploy(env, app_name)
        puts "[admiral] Deploying to opsworks"
        stack = client.stacks[stack_name(env)]
        stack_id = cf_query_output stack, 'StackId'
        app_id = cf_query_output stack, app_name

        puts "[admiral] Deploying app #{app_id}."

        opsworks.create_deployment(
          stack_id: stack_id,
          app_id: app_id,
          command: {
            name: "deploy",
          }
        )
      end
    end
  end
end