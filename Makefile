CXX = /usr/bin/gcc
CXXFLAGS = -fPIC -Wall -Wno-unknown-pragmas -Iinc -O6
DBG = -g
DEFINES ?=
LDFLAGS = -shared -lpthread -lrt -lm

BINDIR = ./bin
LIBDIR = ./lib
INCDIR = ./inc
SRCDIR = ./src
ROOTS = pipeline
BINS = $(ROOTS:%=$(BINDIR)/%)
OBJS = $(ROOTS:%=$(BINDIR)/%.o)

all: $(BINDIR) $(LIBDIR) $(LIBDIR)/libhbt-acc-pow.so $(BINS)

$(BINDIR):
	-mkdir -p $(BINDIR)

$(LIBDIR):
	-mkdir -p $(LIBDIR)

$(BINDIR)/%.o : $(SRCDIR)/%.c
	$(CXX) -c $(CXXFLAGS) $(DEFINES) $(DBG) -o $@ $<

$(BINS) : $(OBJS)

$(BINS) : % : %.o
	$(CXX) $(CXXFLAGS) -o $@ $< -Llib -lhbt-acc-pow -lpthread -lrt -lm

$(LIBDIR)/libhbt-acc-pow.so: $(SRCDIR)/heartbeat-tree-accuracy-power.c $(SRCDIR)/heartbeat-tree-util.c
	$(CXX) $(CXXFLAGS) -DHEARTBEAT_MODE_ACC_POW $(LDFLAGS) -Wl,-soname,$(@F) -o $@ $^

# Installation
install: all
	install -m 0644 $(LIBDIR)/*.so /usr/local/lib/
	mkdir -p /usr/local/include/heartbeats-tree
	install -m 0644 $(INCDIR)/* /usr/local/include/heartbeats-tree/

uninstall:
	rm -f /usr/local/lib/libhbt-*.so
	rm -rf /usr/local/include/heartbeats-tree/

## cleaning
clean:
	-rm -rf $(LIBDIR) $(BINDIR) *.log *~ $(SRCDIR)/*~
