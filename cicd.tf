resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "pipeline-artifacts-terraform-464dfg"
  acl    = "private"
}

resource "aws_codebuild_project" "tf-plan" {
  name         = "tf-cicd-plan2"
  description  = "Plan stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn
  artifacts { type = "CODEPIPELINE" }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    privileged_mode             = "true"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-apply" {
  name         = "tf-cicd-apply"
  description  = "Apply stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn
  artifacts { type = "CODEPIPELINE" }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    privileged_mode             = "true"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-docker" {
  name         = "tf-cicd-docker"
  service_role = aws_iam_role.tf-codebuild-role.arn
  artifacts { type = "CODEPIPELINE" }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    privileged_mode             = "true"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/docker-buildspec.yml")
  }
}

resource "aws_codepipeline" "cicd_pipeline" {
  name     = "tf-cicd"
  role_arn = aws_iam_role.tf-codepipeline-role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tfcode"]
      configuration = {
        FullRepositoryId     = "OleksiyMaksymenko/terraform_task"
        Branch               = "main"
        ConnectionArn        = "arn:aws:codestar-connections:eu-west-3:921302943194:connection/cfae7954-0bcd-4bc6-a38c-0410b2a1625c"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      stage
    ]
  }

  stage {
    name = "Plan"
    action {
      name             = "Build"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["tfcode"]
      output_artifacts = ["tfplan"]
      configuration = {
        ProjectName = "tf-cicd-plan2"
      }
    }
  }

  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "DeployDocker"
    action {
      name            = "DeployDocker"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tfcode"]
      configuration = {
        ProjectName = "tf-cicd-docker"
      }
    }
  }

  stage {
    name = "DeployTerraform"
    action {
      name            = "DeployTerraform"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tfplan"]
      configuration = {
        ProjectName = "tf-cicd-apply"
      }
    }
  }
}
