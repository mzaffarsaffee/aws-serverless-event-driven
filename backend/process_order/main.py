import json
import boto3
import os

def lambda_handler(event, context):
    # Iterate over DynamoDB Stream records
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            order_id = new_image['OrderId']['S']
            
            # Simulate processing (e.g., Charging credit card)
            print(f"Processing Order: {order_id}")
            print(f"Payment Captured for amount: {new_image['Amount']['N']}")
            
            # Here you would integrate with Stripe/SendGrid/etc.
            
    return {'status': 'Processing Complete'}