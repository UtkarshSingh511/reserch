data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../remediation/lambda_remediate.py"
  output_path = "${path.module}/../remediation/lambda_remediate.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "auto_remediation_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_remediation_policy"
  description = "Allows Lambda to modify S3 bucket ACLs and log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutBucketAcl",
          "s3:GetBucketAcl"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_lambda_function" "remediation_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "s3_auto_remediation"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_remediate.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_cloudwatch_event_rule" "s3_acl_change" {
  name        = "capture-s3-acl-change"
  description = "Capture S3 PutBucketAcl events to trigger auto-remediation"

  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["PutBucketAcl"]
    }
  })
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.s3_acl_change.name
  target_id = "TriggerRemediationLambda"
  arn       = aws_lambda_function.remediation_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remediation_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_acl_change.arn
}
