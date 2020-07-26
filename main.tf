
resource "aws_sqs_queue" "queue" {
  name = var.queue

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = var.dlq_max_receive_count
  })
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name = "${var.queue}-dlq"
}

resource "aws_sns_topic_subscription" "event_subscription" {
  topic_arn = var.sns_topic
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue.arn
}

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.queue_policy_document.json
}

data "aws_iam_policy_document" "queue_policy_document" {
  version   = "2012-10-17"
  policy_id = "sqsPolicy"
  statement {
    sid    = "First"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.queue.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_topic]
    }
  }
}
