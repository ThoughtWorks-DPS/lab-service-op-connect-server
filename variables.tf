variable "aws_region" {}
variable "platform_vpc_name" {}

variable "ecs-cluster-name" {}
variable "capacity_providers" {}
variable "target_group_name" {}


variable "connect_api_version" {} # 1password/connect-api:1.5.2
variable "connect_api_cpu" {} # 256
variable "connect_api_ram" {} # 512

variable "connect_sync_version" {} # 1password/connect-sync:1.5.2
variable "connect_sync_cpu" {} # 256
variable "connect_sync_ram" {} # 512

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}



task definitions

ContainerDefinitions:
        - Name: connect-api
          Image: 1password/connect-api:latest
          PortMappings:
            - ContainerPort: 8080
              HostPort: 8080
          MountPoints:
            - ContainerPath: '/home/opuser/.op/data'
              SourceVolume: 'connect-data'
          Environment:
            - Name: 'OP_SESSION'
              Value: !Ref "Base64Credentials"
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref "CloudWatchLogsGroup"
              awslogs-region: !Ref "AWS::Region"
              awslogs-stream-prefix: connect-api

        - Name: connect-sync
          Image: 1password/connect-sync:latest
          MountPoints:
            - ContainerPath: '/home/opuser/.op/data'
              SourceVolume: 'connect-data'
          Environment:
            - Name: 'OP_HTTP_PORT'
              Value: '8081'
            - Name: 'OP_SESSION'
              Value: !Ref "Base64Credentials"
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref "CloudWatchLogsGroup"
              awslogs-region: !Ref "AWS::Region"
              awslogs-stream-prefix: connect-sync