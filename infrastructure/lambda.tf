# 1. Zip the Code
data "archive_file" "create_order_zip" {
  type        = "zip"
  source_dir  = "../backend/create_order"
  output_path = "create_order.zip"
}

data "archive_file" "process_order_zip" {
  type        = "zip"
  source_dir  = "../backend/process_order"
  output_path = "process_order.zip"
}

# 2. IAM Role (Shared for simplicity)
resource "aws_iam_role" "lambda_role" {
  name = "serverless_demo_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Policy: Allow Logs and DynamoDB Access
resource "aws_iam_role_policy" "lambda_policy" {
  name = "serverless_demo_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DescribeStream", "dynamodb:GetRecords", "dynamodb:GetShardIterator", "dynamodb:ListStreams"]
        Effect   = "Allow"
        Resource = "*" # Scope this down in production!
      }
    ]
  })
}

# 3. Create Order Function (API Triggered)
resource "aws_lambda_function" "create_order" {
  filename         = "create_order.zip"
  function_name    = "demo_create_order"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.create_order_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.orders.name
    }
  }
}

# 4. Process Order Function (Stream Triggered)
resource "aws_lambda_function" "process_order" {
  filename         = "process_order.zip"
  function_name    = "demo_process_order"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.process_order_zip.output_base64sha256
}

# 5. Connect DynamoDB Stream to Processor Lambda
resource "aws_lambda_event_source_mapping" "stream_trigger" {
  event_source_arn  = aws_dynamodb_table.orders.stream_arn
  function_name     = aws_lambda_function.process_order.arn
  starting_position = "LATEST"
}