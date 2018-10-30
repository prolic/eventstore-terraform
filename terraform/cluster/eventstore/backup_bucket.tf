resource "template_file" "backup_bucket_policy" {
    filename = "${path.module}/templates/bucket-access-policy.tmpl"

    vars {
        bucket_name = "${var.backup_bucket_name}"
    }
}

resource "aws_s3_bucket" "backup" {
    bucket = "${var.backup_bucket_name}"
    policy = "${template_file.backup_bucket_policy.rendered}"
}

resource "template_file" "backup_bucket_role_policy" {
    filename = "${path.module}/templates/eventstore-backup-role.tmpl"

    vars {
        backup_bucket_name = "${aws_s3_bucket.backup.bucket}"
        region = "${var.region}"
        cluster_name = "${var.cluster_name}"
        node_number = "todo"
    }
}

resource "aws_iam_role" "backup_bucket" {
    name = "EventStore-Backup"
    assume_role_policy = "${file("${path.module}/policies/assume-role-policy.json")}"
}

resource "aws_iam_role_policy" "backup_bucket" {
    name = "EventStore-Backup"
    role = "${aws_iam_role.backup_bucket.id}"
    policy = "${template_file.backup_bucket_role_policy.rendered}"
}

