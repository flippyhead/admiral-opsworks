require 'aws-sdk-v1'

module Admiral
  module Util
    module OpsWorks

      def opsworks
        AWS::OpsWorks::Client.new(region: 'us-east-1') # opsworks command-and-control is us-east-1 ONLY ;)
      end

      def instance_online?(instance_id)
        response = opsworks.describe_instances(:instance_ids => [instance_id])
        response[:instances].first[:status] == "online"
      end

      def instance_status(instance_id)
        begin
          response = opsworks.describe_instances(:instance_ids => [instance_id])
        rescue AWS::OpsWorks::Errors::ResourceNotFoundException
          return "nonexistent"
        end
        response[:instances].first[:status].tap do |status|
          raise "Instance #{instance_id} has a failed status #{status}" if status =~ /fail|error/i
        end
      end

      def wait_for_instance(instance_id, status)
        while (ins_status = instance_status(instance_id)) != status
          puts "[Instance #{instance_id}] waiting for instance to become #{status}. Current status: #{ins_status}"
          sleep 10
        end
      end

      def all_availability_zones
        ec2 = AWS::EC2.new
        ec2.availability_zones.map(&:name)
      end

      def get_all_instances(layer_id)
        response = opsworks.describe_instances({:layer_id => layer_id})
        response[:instances]
      end

      def attach_ebs_volumes(instance_id, volume_ids)
        volume_ids.each do |volume_id|
          puts "Attaching EBS volume #{volume_id} to instance #{instance_id}"
          opsworks.assign_volume({:volume_id => volume_id, :instance_id => instance_id})
        end
      end

      def detach_ebs_volumes(instance_id)
        response = opsworks.describe_volumes(:instance_id => instance_id)
        volume_ids = response[:volumes].map { |v| v[:volume_id] }
        volume_ids.each do |volume_id|
          puts "Detaching EBS volume #{volume_id} from instance #{instance_id}"
          opsworks.unassign_volume(:volume_id => volume_id)
        end

        volume_ids
      end

      def create_instance(stack_id, layer_id, az)
        opsworks.create_instance({:stack_id => stack_id,
                                  :layer_ids => [layer_id],
                                  :instance_type => ENV['INSTANCE_TYPE'] || 't2.small',
                                  :install_updates_on_boot => !ENV['SKIP_INSTANCE_PACKAGE_UPDATES'],
                                  :availability_zone => az})
      end

      def update_instances(stack_id, layer_id, count)
        azs = all_availability_zones
        existing_instances = get_all_instances(layer_id)
        count_to_create = count.to_i - existing_instances.size
        new_instances = (1..count_to_create).map do |i|
          instance = create_instance(stack_id, layer_id, azs[(existing_instances.size + i) % azs.size])
          puts "Created instance, id: #{instance[:instance_id]}, starting the instance now."
          opsworks.start_instance(:instance_id => instance[:instance_id])
          instance
        end

        new_instances.each do |instance|
          wait_for_instance(instance[:instance_id], "online")
        end

        puts "Replacing existing instances.." if existing_instances.size > 0

        existing_instances.each do |instance|
          puts "Stopping instance #{instance[:hostname]}, id: #{instance[:instance_id]}"
          opsworks.stop_instance({:instance_id => instance[:instance_id]})
          wait_for_instance(instance[:instance_id], "stopped")
          ebs_volume_ids = detach_ebs_volumes(instance[:instance_id])

          puts "Creating replacement instance"
          replacement = create_instance(stack_id, layer_id, instance[:availability_zone])
          attach_ebs_volumes(replacement[:instance_id], ebs_volume_ids)

          puts "Starting new instance, id: #{replacement[:instance_id]}"
          opsworks.start_instance(:instance_id => replacement[:instance_id])
          wait_for_instance(replacement[:instance_id], "online")

          puts "Deleting old instance #{instance[:hostname]}, #{instance[:instance_id]}"
          opsworks.delete_instance(:instance_id => instance[:instance_id])
        end
      end

    end
  end
end