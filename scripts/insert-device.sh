#!/bin/bash
# Insert DoorNet2 device definition before 'include $(SUBTARGET).mk' in Makefile
MAKEFILE="$1"
INSERT="$2"
sed -i "/^include \$(SUBTARGET).mk$/{
r $INSERT
}" "$MAKEFILE"
echo "Inserted device definition into $MAKEFILE"
