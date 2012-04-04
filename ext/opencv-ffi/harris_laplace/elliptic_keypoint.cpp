
#include "harris_laplace.hpp"

namespace cv {

Elliptic_KeyPoint::Elliptic_KeyPoint(Point centre, double _phi, Size axes, float _size, float _si) :
	KeyPoint(centre,_size), phi(_phi), size(_size), si(_si) {
this->centre = centre;
	this->axes = axes;
}

Elliptic_KeyPoint::Elliptic_KeyPoint(){

}

Elliptic_KeyPoint::~Elliptic_KeyPoint() {
}
}
