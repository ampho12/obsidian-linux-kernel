#!/bin/bash

fnames=(name)
fnames+=(entry)
fnames+=(parent)
fnames+=(kset)
fnames+=(ktype)
fnames+=(sd)
fnames+=(kref)
fnames+=(state_initialized)
fnames+=(state_in_sysfs)
fnames+=(state_add_uevent_sent)
fnames+=(state_remove_uevent_sent)
fnames+=(uevent_suppress)


for name in ${fnames[@]}; do
  touch "${name}".md
done

