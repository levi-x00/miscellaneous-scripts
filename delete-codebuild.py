import boto3

# Create a CodeBuild client
client = boto3.client('codebuild')

# List all CodeBuild projects
projects = client.list_projects()['projects']

# Loop through the build projects and delete each one that contain 'asset-provision' name
for project in projects:
    if "asset-provision" in project:
        print(f"deleting project {project}...")
        client.delete_project(name=project)
        print(f"Project {project} deleted.")
