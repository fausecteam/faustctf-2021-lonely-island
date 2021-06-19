SERVICE := lonely-island
DESTDIR ?= dist_root
SERVICEDIR ?= /srv/$(SERVICE)

.PHONY: build install

build:
	$(MAKE) -C src

install: build
	mkdir -p $(DESTDIR)$(SERVICEDIR)
	cp src/build/server $(DESTDIR)$(SERVICEDIR)/
	cp src/build/server.pck $(DESTDIR)$(SERVICEDIR)/
	cp src/build/client $(DESTDIR)$(SERVICEDIR)/
	cp src/build/client.pck $(DESTDIR)$(SERVICEDIR)/
	mkdir -p $(DESTDIR)$(SERVICEDIR)/data/
	touch $(DESTDIR)$(SERVICEDIR)/data/players $(DESTDIR)$(SERVICEDIR)/data/friendlist
	mkdir -p $(DESTDIR)/etc/systemd/system
	cp src/lonely-island.service $(DESTDIR)/etc/systemd/system/
	cp src/system-lonely\\x2disland.slice $(DESTDIR)/etc/systemd/system/
