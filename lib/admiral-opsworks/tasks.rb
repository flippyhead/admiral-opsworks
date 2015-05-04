require 'thor'
require 'admiral/base'
require 'admiral-cloudformation/util'
require_relative 'util'

module Admiral
  module Tasks
    class OpsWorks < Thor
      extend Admiral::Base
      include Util::OpsWorks
      include Util::CloudFormation

      NAME = 'ow'
      USAGE = 'ow <command> <options>'
      DESCRIPTION = 'Commands for wielding AWS OpsWorks stacks.'

      namespace :ow

      desc "provision", "Replace and update existing instances"

      option :count,
        desc: 'Number of instances to create.',
        type: :numeric,
        default: 0

      def provision
        stack = client.stacks[stack_name(options[:environment])]
        stack_id = cf_query_output(stack, "StackId")
        layer_id = cf_query_output(stack, "LayerId")

        update_instances stack_id, layer_id, options[:count]
      end


      desc 'ssh', 'ssh to first instance in environment. Connects to first instance in current environment stack.'

      option :username,
        desc: 'Override the default ssh username.',
        type: :string,
        default: 'ec2-user'

      def ssh
        stack = client.stacks[stack_name(options[:environment])]
        stack_id = cf_query_output(stack, "StackId")
        layer_id = cf_query_output(stack, "LayerId")

        instances = get_all_instances(layer_id)
        ssh_to_instance instances[0], params(options[:environment])['SshKeyName'], options[:username]
      end

      desc 'deploy APP_NAME', 'Deploy the APP_NAME application. APP_NAME need only partially match one existing app.'

      def deploy(app_name)
        puts "[admiral] Deploying to opsworks"
        stack = client.stacks[stack_name(options[:environment])]
        stack_id = cf_query_output stack, 'StackId'
        app_id = cf_query_output stack, app_name

        raise "#{app_name} did not match any existing applications." unless app_id

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