#!/bin/bash

fnames=(list)
fnames+=(list_lock)
fnames+=(kobj)
fnames+=(uevent_ops)


for name in ${fnames[@]}; do
  touch "${name}".md
done

