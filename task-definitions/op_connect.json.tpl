[
  {
    "name": "connect-api",
    "image": "1password/connect-api:${connect_api_version}",
    "secrets": [{
      "name": "OP_SESSION",
      "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:${connect_credential_secret_name}"
    }],
    "portMappings": [
      {
        "containerPort": ${connect_api_port},
        "hostPort": ${connect_api_port}
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "connect-data",
        "containerPath": "/home/opuser/.op/data"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${cloud_watch_log_group_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "connect-api"
      }
    }
  },
  {
    "name": "connect-sync",
    "image": "1password/connect-sync:${connect_sync_version}",
    "environment": [
      {"name": "OP_HTTP_PORT", "value": "8081"}
    ],
    "secrets": [{
      "name": "OP_SESSION",
      "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:${connect_credential_secret_name}"
    }],
    "mountPoints": [
      {
        "sourceVolume": "connect-data",
        "containerPath": "/home/opuser/.op/data"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${cloud_watch_log_group_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "connect-sync"
      }
    }
  }
]
