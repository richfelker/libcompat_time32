
srcdir = ./musl

SRCS = $(wildcard $(srcdir)/compat/time32/*.c)
OBJS = $(SRCS:$(srcdir)/%.c=obj/%.o)
OBJ_DIRS = $(sort $(patsubst %/,%,$(dir $(OBJS))))

CFLAGS = -Os

CC = $(CROSS_COMPILE)gcc
AR = $(CROSS_COMPILE)ar
RANLIB = $(CROSS_COMPILE)ranlib

all: libcompat_time32.a

clean:
	rm -rf obj libcompat_time32.a

libcompat_time32.a: $(OBJS)
	rm -f $@
	$(AR) rc $@ $(OBJS)
	$(RANLIB) $@

obj/%.o: $(srcdir)/%.c
	$(CC) $(CFLAGS) -fPIC -D'weak_alias(a,b)=' -c -o $@ $<

$(OBJS): | $(OBJ_DIRS) $(srcdir)/.

$(OBJ_DIRS):
	mkdir -p $@

.PHONY: all clean
