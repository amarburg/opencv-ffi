
CXX = g++
BIN = sift
OBJS = sift.o ../sift.o ../keypoint.o

CFLAGS = -ggdb -I.. -I/localhome/amm299/usr/include
LFLAGS = -L/localhome/amm299/usr/lib 
LIBS = -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_features2d


default: run

run: $(BIN)
	LD_LIBRARY_PATH=~/usr/lib ./sift


$(BIN): $(OBJS)
	$(CXX) $(CFLAGS) -o $@ $^ $(LFLAGS) $(LIBS)

.cpp.o:
	$(CXX) -c  $(CFLAGS) -o $@ $^

clean:
	rm -f $(BIN) *.o
