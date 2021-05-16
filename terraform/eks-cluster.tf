#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "demo-cluster" {
  name = "dubizzle-demo-cluster"
  tags = { 
   sre_candidate = "velmurugan"
  }
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo-cluster.name
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.demo-cluster.name
}

resource "aws_security_group" "demo-cluster" {
  name        = "dubizzle-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 tags = {
    Name = "dubizzle-demo"
    sre_candidate = "velmurugan"
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-cluster.id
  to_port           = 443
  type              = "ingress"
}

data "tls_certificate" "oidc" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc-provider" {
 client_id_list = ["sts.amazonaws.com"]	
 thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
 url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
      #variable = "www.amazon.com:app_id:sub"
      #values   = [data.tls_certificate.oidc.url]
      values =  ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_clusterautoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
  name               = "eks_clusteras"
}

resource "aws_iam_role_policy_attachment" "demo-node-EKSDUBIZZLE" {
  policy_arn = aws_iam_policy.autoscaler-policy.arn
  role       = aws_iam_role.eks_clusterautoscaler.name
}

resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  role_arn = aws_iam_role.demo-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.demo-cluster.id]
    subnet_ids         = aws_subnet.demo[*].id
  }

  tags = {
   sre_candidate = "velmurugan"
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSVPCResourceController,
  ]
}
