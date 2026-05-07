import boto3
import json

def lambda_handler(event, context):
    """
    AWS Lambda function triggered by CloudTrail/EventBridge when a bucket ACL is changed.
    This acts as the auto-remediation function to enforce compliance.
    """
    s3_client = boto3.client('s3')
    
    # Extract the bucket name from the drift event log
    bucket_name = event['detail']['requestParameters']['bucketName']
    
    try:
        # Revert the change to the baseline state (Private ACL)
        print(f"Drift detected on {bucket_name}. Applying remediation policy...")
        s3_client.put_bucket_acl(
            Bucket=bucket_name,
            ACL='private'
        )
        print(f"Successfully remediated {bucket_name}. Restored to private.")
        
        # In a full system, you would also update logs & dashboards here
        return {
            'statusCode': 200,
            'body': json.dumps(f'Remediation applied to {bucket_name}')
        }
        
    except Exception as e:
        print(f"Error remediating {bucket_name}: {str(e)}")
        raise e
