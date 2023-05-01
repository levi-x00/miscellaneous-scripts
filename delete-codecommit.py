import boto3

codecommit = boto3.client('codecommit')
response = codecommit.list_repositories()

# delete codecommit that contain 'levi-test' on it's name
for repository in response['repositories']:
    if 'levi-test' in repository['repositoryName']:
        repo_name = repository['repositoryName']
        print(repo_name)

        response = codecommit.delete_repository(
            repositoryName=repo_name
        )
        print(response)
