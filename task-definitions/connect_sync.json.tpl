[
  {
    "name": "op-connect-api",
    "image": "1password/connect-sync:${connect_sync_version}",
    "cpu": ${connect_sync_cpu},
    "memory": ${connect_sync_ram},
    "environment": [
      {"name": "OP_HTTP_PORT", "value": "8081"}
    ],
    "secrets": [{
      "name": "OP_SESSION",
      "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:op-connect-credentials-file"
    }],
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "op-connect-storage",
        "containerPath": "/home/opuser/.op/data"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/op-connect",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "connect-sync"
      }
    }
  }
]
