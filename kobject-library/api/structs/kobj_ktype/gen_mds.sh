#!/bin/bash

fnames=(release)
fnames+=(sysfs_ops)
fnames+=(default_groups)
fnames+=(child_ns_type)
fnames+=(namespace)
fnames+=(get_ownership)


for name in ${fnames[@]}; do
  touch "${name}".md
done

