#!/bin/bash

fnames=(kset_init)
fnames+=(kset_register)
fnames+=(kset_unregister)
fnames+=(kset_create_and_add)
fnames+=(to_kset)
fnames+=(kset_get)
fnames+=(kset_put)
fnames+=(kset_find_obj)
fnames+=(kset_release)
fnames+=(kset_get_ownership)
fnames+=(kset_create)
fnames+=(kset_create_and_add)
fnames+=(kobj_kset_join)
fnames+=(kobj_kset_leave)
fnames+=(kobj_kset_join)


for name in ${fnames[@]}; do
  touch "${name}".md
  printf '# Arguments\n\n' >> "${name}".md
  printf '# Description\n\n' >> "${name}".md
  printf '# Actions and Changes\n\n' >> "${name}".md
  printf '## sysfs\n' >> "${name}".md
  printf '## uevent\n' >> "${name}".md
  printf '## kref\n' >> "${name}".md
  printf '## kobject hierarchy\n' >> "${name}".md
done

