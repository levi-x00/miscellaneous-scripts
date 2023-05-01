import boto3

s3client = boto3.client('s3')
s3 = boto3.resource('s3')
response = s3client.list_buckets()

for bucket in response['Buckets']:
    # if you want to delete specific bucket name that contain 'asset-prv'
    if 'asset-prv' in bucket['Name']:

        bucket_name = bucket['Name']
        print(bucket_name)

        s3_bucket = s3.Bucket(bucket_name)
        bucket_versioning = s3.BucketVersioning(bucket_name)
        if bucket_versioning.status == 'Enabled':
            s3_bucket.object_versions.delete()
        else:
            s3_bucket.objects.all().delete()

        response = s3client.delete_bucket(Bucket=bucket_name)
        print(response)
