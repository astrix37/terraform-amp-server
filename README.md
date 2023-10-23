# Terraform AMP Server

Create an AMP instance:
* On an AWS EC2 instance
* Pulling in data from an existing snapshot
* With an optional route53 DNS entry

What you need to know
* The UUID of the snapshot you want to mount. You'll need to play around with the snapshot manually prior to running this.
* Once you launch the server you'll need to re-activate game instances by heading to Configuration > New Instance Default > Reactivate Local Instances
