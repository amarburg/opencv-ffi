
#include <opencv2/core/core.hpp>
#include <opencv2/core/core_c.h>
#include <eigen3/Eigen/Core>
#include <eigen3/Eigen/SVD>
#include <eigen3/Eigen/Eigenvalues>

using Eigen::MatrixXf;
using namespace Eigen;
using namespace cv;


typedef struct {
  CvMat *D;
  CvMat *U, *V;
} EigenSVDResult_t;

MatrixXf cvMatToEigen( CvMat *A )
{
  MatrixXf a( A->rows, A->cols );
  for( int i = 0; i < A->rows; i++ ) {
    for( int j = 0; j < A->cols; j++ ) {
      a(i,j) = cvGetReal2D( A, i, j );
    }
  }
  return a;
}

CvMat *eigenToCvMat( MatrixXf a )
{
  CvMat *mat = cvCreateMat( a.rows(), a.cols(), CV_32F );
  
  for( int i = 0; i < a.rows(); i++ ) {
    for( int j = 0; j < a.cols(); j++ ) { 
      cvSetReal2D( mat, i, j, a(i,j) );
    }
  }

  return mat;
}

extern "C"
void eigenSvdWithCvMat( CvMat* A, EigenSVDResult_t *result, unsigned char thin )
{
  // Brute force pack/unpack I'm afraid
//  assert( ( A->type == CV_32F ) || (A->type == CV_64F) );

  MatrixXf m = cvMatToEigen( A );
  unsigned int options = (thin == 0) ? (ComputeFullU | ComputeFullV) : (ComputeThinU | ComputeThinV);
  JacobiSVD<MatrixXf> svd( m, options );

  result->D = eigenToCvMat( svd.singularValues() );
  result->U = eigenToCvMat( svd.matrixU() );
  result->V = eigenToCvMat( svd.matrixV() );
}

typedef struct {
  CvMat *D;
  CvMat *V;
} EigenDecompResult_t;

CvMat *eigenvaluesToCvMat( EigenSolver<MatrixXf>::EigenvalueType a )
{
  CvMat *mat = cvCreateMat( a.rows(), a.cols(), CV_32F );
  
  for( int i = 0; i < a.rows(); i++ ) {
    for( int j = 0; j < a.cols(); j++ ) { 
      cvSetReal2D( mat, i, j, a(i,j).real() );
    }
  }

  return mat;
}

CvMat *eigenvectorsToCvMat( EigenSolver<MatrixXf>::EigenvectorsType a )
{
  CvMat *mat = cvCreateMat( a.rows(), a.cols(), CV_32F );
  
  for( int i = 0; i < a.rows(); i++ ) {
    for( int j = 0; j < a.cols(); j++ ) { 
      cvSetReal2D( mat, i, j, a(i,j).real() );
    }
  }

  return mat;
}

extern "C"
void eigenDecompWithCvMat( CvMat *A, EigenDecompResult_t *result )
{
  // Brute force pack/unpack I'm afraid
//  assert( ( A->type == CV_32F ) || (A->type == CV_64F) );

  MatrixXf m = cvMatToEigen( A );
  EigenSolver<MatrixXf> eig( m );

  result->D = eigenvaluesToCvMat( eig.eigenvalues() );
  result->V = eigenvectorsToCvMat( eig.eigenvectors() );
}

