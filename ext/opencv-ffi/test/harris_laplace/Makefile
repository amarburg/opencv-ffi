
CXX = g++
BIN = harris_laplace
OBJS = harris_laplace.o ../../harris_laplace/harris_laplace.o ../../harris_laplace/gaussian_pyramid.o ../../harris_laplace/affine_adaptation.o \
       ../../harris_laplace/elliptic_keypoint.o

CFLAGS = -ggdb -I../.. -I/home/amarburg/usr/include -I/localhome/amm299/usr/include -I../../harris_laplace
LFLAGS = -L$(HOME)/usr/lib 
LIBS = -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_features2d


default: run

run: $(BIN)
	LD_LIBRARY_PATH=~/usr/lib ./harris_laplace


$(BIN): $(OBJS)
	$(CXX) $(CFLAGS) -o $@ $^ $(LFLAGS) $(LIBS)

.cpp.o:
	$(CXX) -c  $(CFLAGS) -o $@ $^

clean:
	rm -f $(BIN) *.o
