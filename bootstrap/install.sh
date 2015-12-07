#!/bin/bash
repo_dir=/opt/jan
meta_url="http://169.254.169.254/latest/meta-data"
instance_id=$(curl -sf ${meta_url}/instance-id)
role=$(aws ec2 describe-tags --filters   "Name=resource-type,Values=instance"   "Name=resource-id,Values=${instance_id}"   "Name=key,Values=role"   --output text |gawk '{print $5}')

if ! chef-solo -v > /dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update &&
    apt-get install git
    apt-get install -y ruby1.9.3 ruby1.9.3-dev build-essential &&
    sudo gem install --no-rdoc --no-ri chef
fi

if [[ -d $repo_dir ]]; then
echo  git -C $repo_dir pull --quiet
else
	cd /opt
	git clone https://github.com/jszalkowski/which.git $puppet_dir

fi
if ! grep prod-web /etc/hosts;
then
		for i in prod-web{1,2}
			do
				echo $i $(aws ec2 describe-instances --filters "{\"Name\":\"tag:Name\", \"Values\":[\"$i\"]}" --query='Reservations[0].Instances[0].PrivateIpAddress'|tr -d '"')  >> /etc/hosts
		done
else
echo bootstraped
fi
cd $repo_dir
chef-solo -c solo.rb -j $role.json
