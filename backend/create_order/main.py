import json
import boto3
import uuid
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['TABLE_NAME']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Parse body (handle direct invocation or API Gateway)
        body = json.loads(event.get('body', '{}'))
        
        order_id = str(uuid.uuid4())
        item = {
            'OrderId': order_id,
            'Status': 'PENDING',
            'Amount': body.get('amount', 0),
            'CreatedAt': datetime.now().isoformat()
        }
        
        # Save to DynamoDB
        table.put_item(Item=item)
        
        return {
            'statusCode': 201,
            'body': json.dumps({'message': 'Order Received', 'orderId': order_id})
        }
    except Exception as e:
        print(e)
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}