#Cluster Autoscaler IAM policy
#

resource "aws_iam_policy" "autoscaler-policy" {
  name = "dubizzle-autoscaler-policy"
  path = "/"
  description = "Autoscaler EKS Policy"
  tags = {
  sre_candidate = "velmurugan"
  }
  policy  = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Action = [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            Resource = "*",
            Effect = "Allow"
        }
    ]
  })
}

#resource "aws_iam_role_policy_attachment" "demo-node-EKSDUBIZZLE" {
 # eolicy_arn = aws_iam_policy.autoscaler-policy.arn
 # role       = aws_iam_role.EKSDUBIZZLE.name
#}

#resource "aws_iam_role" "EKSDUBIZZLE" {
#  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
#  name               = "EKSDUBIZZLE"
#}

#resource "aws_iam_role_policy_attachment" "demo-node-EKSDUBIZZLE" {
#  policy_arn = "${aws_iam_policy.autoscaler-policy.arn}"
#  role       = aws_iam_role.EKSDUBIZZLE.name
#}
