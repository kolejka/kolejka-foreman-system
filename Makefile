.PHONY: all
all : clean kolejka-foreman.build kolejka-foreman.squashfs kolejka-foreman.vmlinuz

.PHONY: clean
clean :
	rm -rf kolejka-foreman.squashfs kolejka-foreman.vmlinuz kolejka-foreman.initrd

.PHONY: build
build : clean kolejka-foreman.build

kolejka-foreman.build : Dockerfile kolejka.conf rc.local
	docker build --no-cache --tag kolejka:foreman .
	touch kolejka-foreman.build

kolejka-foreman.squashfs : kolejka-foreman.build
	./docker_squash kolejka:foreman kolejka-foreman.squashfs

kolejka-foreman.vmlinuz : kolejka-foreman.squashfs
	./squash_extract_vmlinuz kolejka-foreman.squashfs kolejka-foreman.vmlinuz kolejka-foreman.initrd

.PHONY: deploy
deploy : kolejka-foreman.squashfs kolejka-foreman.vmlinuz
	cp -a kolejka-foreman.squashfs /srv/nfs/kolejka/foreman/casper/filesystem.squashfs
	cp -a kolejka-foreman.vmlinuz /srv/tftp/configs/kolejka/foreman/vmlinuz
	cp -a kolejka-foreman.initrd /srv/tftp/configs/kolejka/foreman/initrd
