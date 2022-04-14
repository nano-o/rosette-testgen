CCX=clang++
CPPFLAGS=-g -std=c++11 `pkg-config --cflags xdrpp`
LDLIBS=`pkg-config --libs xdrpp`
LDFLAGS=-L/home/nano/lib -no-pie

SRCS=test.cpp
OBJS=$(subst .cpp,.o,$(SRCS))

all: print

print: $(OBJS)
	$(CXX) $(LDFLAGS) -o print $(OBJS) $(LDLIBS)

test.o: test.cpp Stellar.hh

Stellar.hh: Stellar.x
	xdrc -hh Stellar.x

clean:
	$(RM) $(OBJS)

distclean: clean
	$(RM) tool
