require_relative 'util'

module Admiral
  module Tasks
    module OpsWorks

      include Util::OpsWorks
      include Util::CloudFormation

      def self.included(thor_cli)
        thor_cli.class_eval do

          desc "provision ENVIRONMENT", "Replace and update existing instances for ENVIRONMENT"
          option :count, desc: 'Number of instances to boot', type: :numeric, default: 0
          def provision(env)
            stack = client.stacks[stack_name(env)]
            stack_id = cf_query_output(stack, "StackId")
            layer_id = cf_query_output(stack, "LayerId")

            update_instances stack_id, layer_id, options[:count]
          end

        end
      end

    end
  end
end