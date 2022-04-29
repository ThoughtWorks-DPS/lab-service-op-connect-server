[
  {
    "name": "op-connect-api",
    "image": "1password/connect-api:${connect_api_version}",
    "cpu": ${connect_api_cpu},
    "memory": ${connect_api_ram},
    "environment": [
      {"name": "OP_SESSION", "value": ""}
    ],
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "op-connect-api-storage",
        "containerPath": "/home/opuser/.op/data"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/op-connect-api",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
