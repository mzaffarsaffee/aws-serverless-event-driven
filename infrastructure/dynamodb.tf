resource "aws_dynamodb_table" "orders" {
  name             = "serverless-orders-demo"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "OrderId"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE" # We need the new data to process it

  attribute {
    name = "OrderId"
    type = "S"
  }
}