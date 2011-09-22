
#include <eigen3/Eigen/Core>
#include <eigen3/unsupported/Eigen/Polynomials>
#include <vector>
#include <iostream>

using Eigen::MatrixXf;
using namespace Eigen;
using namespace std;


typedef struct {
  double a[7];
} Eigen7d_t;

typedef struct {
  double a[6];
} Eigen6d_t;

extern "C"
Eigen6d_t eigenPoly6Solver( Eigen7d_t coeff )
{
  Eigen::Matrix<double,7,1> polynomial;
  for( unsigned int i = 0; i < 7; i++ ) polynomial[i] = coeff.a[i]; 

  PolynomialSolver<double,6> psolve( polynomial );

  std::vector<double> realRoots;
  psolve.realRoots( realRoots );

  Eigen6d_t result;
  for( unsigned int i = 0; i < 6; i++ ) {
    if( i < realRoots.size() )
      result.a[i] = realRoots[i];
    else
      result.a[i] = 0.0;
  }

  return result;
}

