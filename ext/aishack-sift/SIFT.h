/****************************************************** 
 *	Code by Utkarsh Sinha
 *	Based on JIFT by Jun Liu
 *	Visit http://aishack.in/ for more indepth articles and tutorials
 *	on artificial intelligence
 * Use, reuse, modify, hack, kick. Do whatever you want with
 * this code :)
 ******************************************************/

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

#include "KeyPoint.h"
#include "Descriptor.h"

#define SIGMA_ANTIALIAS			0.5
#define SIGMA_PREBLUR			1.0
#define CURVATURE_THRESHOLD		5.0
#define CONTRAST_THRESHOLD		0.03		// in terms of 255
#define NUM_BINS				36
#define MAX_KERNEL_SIZE			20
#define FEATURE_WINDOW_SIZE		16
#define DESC_NUM_BINS			8
#define FVSIZE					128
#define	FV_THRESHOLD			0.2


class SIFT
{
  public:
    SIFT(IplImage* img, int octaves, int intervals);
    SIFT(const char* filename, int octaves, int intervals);
    ~SIFT();

    void DoSift();
    void DetectKeypoints();
    void DescribeKeypoints();

    void ShowKeypoints();
    void ShowAbsSigma();

    const vector<Keypoint> keypoints( void ) { return m_keyPoints; }
    const vector<Descriptor> descriptor( void ) { return m_keyDescs; }

  private:
    void GenerateLists();
    void BuildScaleSpace();
    void DetectExtrema();
    void AssignOrientations();
    void ExtractKeypointDescriptors();

    unsigned int GetKernelSize(double sigma, double cut_off=0.001);
    CvMat* BuildInterpolatedGaussianTable(unsigned int size, double sigma);
    double gaussian2D(double x, double y, double sigma);


  private:
    IplImage* m_srcImage;			// The image we're working on
    unsigned int m_numOctaves;		// The desired number of octaves
    unsigned int m_numIntervals;	// The desired number of intervals
    unsigned int m_numKeypoints;	// The number of keypoints detected

    IplImage***	m_gList;		// A 2D array to hold the different gaussian blurred images
    IplImage*** m_dogList;		// A 2D array to hold the different DoG images
    IplImage*** m_extrema;		// A 2D array to hold binary images. In the binary image, 1 = extrema, 0 = not extrema
    double**	m_absSigma;		// A 2D array to hold the sigma used to blur a particular image

    class Extrema {
      public:
      int octave, interval, xi, yi;

      Extrema( int oct, int intv, int x, int y )
        : octave( oct ), interval( intv ), xi( x ), yi( y )
      {}
    };

    vector<Extrema> extrema;

    vector<Keypoint> m_keyPoints;	// Holds each keypoint's basic info
    vector<Descriptor> m_keyDescs;	// Holds each keypoint's descriptor

    IplImage *magnitude_mat( int i, int j );
    double orientation_at( int i, int j, int xi, int yi );
};
