NAME    = ytr
PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

all:
	@echo "usage: make install | make uninstall"

install:
	mkdir -p $(DESTDIR)$(BINDIR)
	install -m755 src/$(NAME).sh $(DESTDIR)$(BINDIR)/$(NAME)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(NAME)

.PHONY: all install uninstall
