JULIAHOME = $(abspath ../..)
include $(JULIAHOME)/Make.inc

override CFLAGS += $(JCFLAGS)
override CXXFLAGS += $(JCXXFLAGS)

SRCS = hashing.c timefuncs.c dblprint.c ptrhash.c operators.c socket.c \
	utf8.c ios.c dirpath.c htable.c bitvector.c \
	int2str.c dump.c libsupportinit.c arraylist.c

OBJS = $(SRCS:%.c=%.o)
DOBJS = $(SRCS:%.c=%.do)

ifneq ($(MAKECMDGOALS),debug)
XOBJS = $(OBJS)
else
XOBJS = $(DOBJS)
endif

FLAGS = -Wall -Wno-strict-aliasing $(CFLAGS) $(HFILEDIRS:%=-I%) -fvisibility=hidden

DEBUGFLAGS += $(FLAGS)
SHIPFLAGS += $(FLAGS)

default: release

%.o: %.c
	$(QUIET_CC) $(CC) $(SHIPFLAGS) -c $< -o $@
%.do: %.c
	$(QUIET_CC) $(CC) $(DEBUGFLAGS) -c $< -o $@

release debug: libsupport.a

libsupport.a: $(XOBJS)
	rm -rf $@
	$(QUIET_LINK) ar -rcs $@ $^

clean:
	rm -f *.o
	rm -f *.do
	rm -f *.a
	rm -f *~ *#
	rm -f core*
	rm -f libsupport.a
