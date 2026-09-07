obj-m := tas58xx.o

# Keep the debug symbols in both manual and DKMS builds.
CFLAGS_tas58xx.o += -g

KERNELRELEASE ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KERNELRELEASE)/build
PWD := $(CURDIR)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install:
	install -D -m 0644 tas58xx.ko \
		/lib/modules/$(KERNELRELEASE)/updates/dkms/tas58xx.ko
	depmod -a $(KERNELRELEASE)

.PHONY: all clean install
